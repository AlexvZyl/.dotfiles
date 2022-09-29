const calllike = (:call, :foreigncall)

const compiled_calls = Dict{Any,Any}()

function extract_inner_call!(stmt::Expr, idx, once::Bool=false)
    (stmt.head === :toplevel || stmt.head === :thunk) && return nothing
    once |= stmt.head ∈ calllike
    for (i, a) in enumerate(stmt.args)
        isa(a, Expr) || continue
        # Make sure we don't "damage" special syntax that requires literals
        if i == 1 && stmt.head === :foreigncall
            continue
        end
        if i == 2 && stmt.head === :call && stmt.args[1] === :cglobal
            continue
        end
        ret = extract_inner_call!(a, idx, once) # doing this first extracts innermost calls
        ret !== nothing && return ret
        iscalllike = a.head ∈ calllike
        if once && iscalllike
            stmt.args[i] = NewSSAValue(idx)
            return a
        end
    end
    return nothing
end

function replace_ssa(@nospecialize(stmt), ssalookup)
    isa(stmt, Expr) || return stmt
    return Expr(stmt.head, Any[
        if isa(a, SSAValue)
            SSAValue(ssalookup[a.id])
        elseif isa(a, NewSSAValue)
            SSAValue(a.id)
        else
            replace_ssa(a, ssalookup)
        end
        for a in stmt.args
    ]...)
end

function renumber_ssa!(stmts::Vector{Any}, ssalookup)
    # When updating jumps, when lines get split into multiple lines
    # (see "Un-nest :call expressions" below), we need to jump to the first of them.
    # Consequently we use the previous "old-code" offset and add one.
    # Fixes #455.
    jumplookup(l, idx) = idx > 1 ? l[idx-1] + 1 : idx

    for (i, stmt) in enumerate(stmts)
        if isa(stmt, GotoNode)
            stmts[i] = GotoNode(jumplookup(ssalookup, stmt.label))
        elseif isa(stmt, SSAValue)
            stmts[i] = SSAValue(ssalookup[stmt.id])
        elseif isa(stmt, NewSSAValue)
            stmts[i] = SSAValue(stmt.id)
        elseif isa(stmt, Expr)
            stmt = replace_ssa(stmt, ssalookup)
            if (stmt.head === :gotoifnot || stmt.head === :enter) && isa(stmt.args[end], Int)
                stmt.args[end] = jumplookup(ssalookup, stmt.args[end])
            end
            stmts[i] = stmt
        elseif is_GotoIfNot(stmt)
            cond = (stmt::Core.GotoIfNot).cond
            if isa(cond, SSAValue)
                cond = SSAValue(ssalookup[cond.id])
            end
            stmts[i] = Core.GotoIfNot(cond, jumplookup(ssalookup, stmt.dest))
        elseif is_ReturnNode(stmt)
            val = (stmt::Core.ReturnNode).val
            if isa(val, SSAValue)
                stmts[i] = Core.ReturnNode(SSAValue(ssalookup[val.id]))
            end
        end
    end
    return stmts
end

function compute_ssa_mapping_delete_statements!(code::CodeInfo, stmts::Vector{Int})
    stmts = unique!(sort!(stmts))
    ssalookup = collect(1:length(codelocs(code)))
    cnt = 1
    for i in 1:length(stmts)
        start = stmts[i] + 1
        stop = i == length(stmts) ? length(codelocs(code)) : stmts[i+1]
        ssalookup[start:stop] .-= cnt
        cnt += 1
    end
    return ssalookup
end

# Pre-frame-construction lookup
function lookup_stmt(stmts, arg)
    if isa(arg, SSAValue)
        arg = stmts[arg.id]
    end
    if isa(arg, QuoteNode)
        arg = arg.value
    end
    return arg
end

function smallest_ref(stmts, arg, idmin)
    if isa(arg, SSAValue)
        idmin = min(idmin, arg.id)
        return smallest_ref(stmts, stmts[arg.id], idmin)
    elseif isa(arg, Expr)
        for a in arg.args
            idmin = smallest_ref(stmts, a, idmin)
        end
    end
    return idmin
end

function lookup_global_ref(a::GlobalRef)
    if isdefined(a.mod, a.name) && isconst(a.mod, a.name)
        r = getfield(a.mod, a.name)
        return QuoteNode(r)
    else
        return a
    end
end

function lookup_global_refs!(ex::Expr)
    (ex.head === :isdefined || ex.head === :thunk || ex.head === :toplevel) && return nothing
    for (i, a) in enumerate(ex.args)
        ex.head === :(=) && i == 1 && continue # Don't look up globalrefs on the LHS of an assignment (issue #98)
        if isa(a, GlobalRef)
            ex.args[i] = lookup_global_ref(a)
        elseif isa(a, Expr)
            lookup_global_refs!(a)
        end
    end
    return nothing
end

"""
    optimize!(code::CodeInfo, mod::Module)

Perform minor optimizations on the lowered AST in `code` to reduce execution time
of the interpreter.
Currently it looks up `GlobalRef`s (for which it needs `mod` to know the scope in
which this will run) and ensures that no statement includes nested `:call` expressions
(splitting them out into multiple SSA-form statements if needed).
"""
function optimize!(code::CodeInfo, scope)
    mod = moduleof(scope)
    evalmod = mod == Core.Compiler ? Core.Compiler : CompiledCalls
    sparams = scope isa Method ? sparam_syms(scope) : Symbol[]
    code.inferred && error("optimization of inferred code not implemented")
    replace_coretypes!(code)
    # TODO: because of builtins.jl, for CodeInfos like
    #   %1 = Core.apply_type
    #   %2 = (%1)(args...)
    # it would be best to *not* resolve the GlobalRef at %1
    ## Replace GlobalRefs with QuoteNodes
    for (i, stmt) in enumerate(code.code)
        if isa(stmt, GlobalRef)
            code.code[i] = lookup_global_ref(stmt)
        elseif isa(stmt, Expr)
            if stmt.head === :call && stmt.args[1] === :cglobal  # cglobal requires literals
                continue
            else
                lookup_global_refs!(stmt)
            end
        end
    end

    # Replace :llvmcall and :foreigncall with compiled variants. See
    # https://github.com/JuliaDebug/JuliaInterpreter.jl/issues/13#issuecomment-464880123
    foreigncalls_idx = Int[]
    delete_idxs = Int[]
    for (idx, stmt) in enumerate(code.code)
        # Foregincalls can be rhs of assignments
        if isexpr(stmt, :(=))
            stmt = (stmt::Expr).args[2]
        end
        if isa(stmt, Expr)
            if stmt.head === :call
                # Check for :llvmcall
                arg1 = stmt.args[1]
                if (arg1 === :llvmcall || lookup_stmt(code.code, arg1) === Base.llvmcall) && isempty(sparams) && scope isa Method
                    nargs = length(stmt.args)-4
                    # Call via `invokelatest` to avoid compiling it until we need it
                    delete_idx = Base.invokelatest(build_compiled_call!, stmt, Base.llvmcall, code, idx, nargs, sparams, evalmod)
                    delete_idx === nothing && error("llvmcall must be compiled, but exited early from build_compiled_call!")
                    push!(foreigncalls_idx, idx)
                    append!(delete_idxs, delete_idx)
                end
            elseif stmt.head === :foreigncall && scope isa Method
                nargs = length(stmt.args[3]::SimpleVector)
                # Call via `invokelatest` to avoid compiling it until we need it
                delete_idx = Base.invokelatest(build_compiled_call!, stmt, :ccall, code, idx, nargs, sparams, evalmod)
                if delete_idx !== nothing
                    push!(foreigncalls_idx, idx)
                    append!(delete_idxs, delete_idx)
                end
            end
        end
    end

    if !isempty(delete_idxs)
        ssalookup = compute_ssa_mapping_delete_statements!(code, delete_idxs)
        let lkup = ssalookup
            foreigncalls_idx = map(x -> lkup[x], foreigncalls_idx)
        end
        deleteat!(codelocs(code), delete_idxs)
        deleteat!(code.code, delete_idxs)
        code.ssavaluetypes = length(code.code)
        renumber_ssa!(code.code, ssalookup)
    end

    ## Un-nest :call expressions (so that there will be only one :call per line)
    # This will allow us to re-use args-buffers rather than having to allocate new ones each time.
    old_code, old_codelocs = code.code, codelocs(code)
    code.code = new_code = eltype(old_code)[]
    code.codelocs = new_codelocs = Int32[]
    ssainc = fill(1, length(old_code))
    for (i, stmt) in enumerate(old_code)
        loc = old_codelocs[i]
        if isa(stmt, Expr)
            inner = extract_inner_call!(stmt, length(new_code)+1)
            while inner !== nothing
                push!(new_code, inner)
                push!(new_codelocs, loc)
                ssainc[i] += 1
                inner = extract_inner_call!(stmt, length(new_code)+1)
            end
        end
        push!(new_code, stmt)
        push!(new_codelocs, loc)
    end
    # Fix all the SSAValues and GotoNodes
    ssalookup = cumsum(ssainc)
    renumber_ssa!(new_code, ssalookup)
    code.ssavaluetypes = length(new_code)

    # Insert the foreigncall wrappers at the updated idxs
    methodtables = Vector{Union{Compiled,DispatchableMethod}}(undef, length(code.code))
    for idx in foreigncalls_idx
        methodtables[ssalookup[idx]] = Compiled()
    end

    return code, methodtables
end

function parametric_type_to_expr(@nospecialize(t::Type))
    t isa Core.TypeofBottom && return t
    while t isa UnionAll
        t = t.body
    end
    t = t::DataType
    if Base.isvarargtype(t)
        return Expr(:(...), t.parameters[1])
    end
    if Base.has_free_typevars(t)
        params = map(t.parameters) do @nospecialize(p)
            isa(p, TypeVar) ? p.name :
            isa(p, DataType) && Base.has_free_typevars(p) ? parametric_type_to_expr(p) : p
        end
        return Expr(:curly, scopename(t.name), params...)::Expr
    end
    return t
end

# Handle :llvmcall & :foreigncall (issue #28)
function build_compiled_call!(stmt::Expr, fcall, code, idx, nargs::Int, sparams::Vector{Symbol}, evalmod)
    TVal = evalmod == Core.Compiler ? Core.Compiler.Val : Val
    delete_idx = Int[]
    if fcall === :ccall
        cfunc, RetType, ArgType = lookup_stmt(code.code, stmt.args[1]), stmt.args[2], stmt.args[3]::SimpleVector
        # delete cconvert and unsafe_convert calls and forward the original values, since
        # the same conversions will be applied within the generated compiled variant of this :foreigncall anyway
        args = []
        for (atype, arg) in zip(ArgType, stmt.args[6:6+nargs-1])
            if atype === Any
                push!(args, arg)
            else
                if arg isa SSAValue
                    unsafe_convert_expr = code.code[arg.id]::Expr
                    push!(delete_idx, arg.id) # delete the unsafe_convert
                    cconvert_val = unsafe_convert_expr.args[3]
                    if isa(cconvert_val, SSAValue)
                        push!(delete_idx, cconvert_val.id) # delete the cconvert
                        newarg = (code.code[cconvert_val.id]::Expr).args[3]
                        push!(args, newarg)
                    else
                        @assert isa(cconvert_val, SlotNumber)
                        push!(args, cconvert_val)
                    end
                elseif arg isa SlotNumber
                    idx = findfirst(code.code) do expr
                        Meta.isexpr(expr, :(=)) || return false
                        lhs = expr.args[1]
                        return lhs isa SlotNumber && lhs.id === arg.id
                    end::Int
                    unsafe_convert_expr = code.code[idx]::Expr
                    push!(delete_idx, idx) # delete the unsafe_convert
                    push!(args, unsafe_convert_expr.args[2])
                else
                    error("unexpected foreigncall argument type encountered: $(typeof(arg))")
                end
            end
        end
    else
        # Run a mini-interpreter to extract the types
        framecode = FrameCode(CompiledCalls, code; optimize=false)
        frame = Frame(framecode, prepare_framedata(framecode, []))
        idxstart = idx
        for i = 2:4
            idxstart = smallest_ref(code.code, stmt.args[i], idxstart)
        end
        frame.pc = idxstart
        if idxstart < idx
            while true
                pc = step_expr!(Compiled(), frame)
                pc === idx && break
                pc === nothing && error("this should never happen")
            end
        end
        cfunc, RetType, ArgType = @lookup(frame, stmt.args[2]), @lookup(frame, stmt.args[3]), @lookup(frame, stmt.args[4])::DataType
        args = stmt.args[5:end]
    end
    dynamic_ccall = false
    if isa(cfunc, Expr)   # specification by tuple, e.g., (:clock, "libc")
        cfunc = something(static_eval(cfunc), cfunc)
    end
    if isa(cfunc, Symbol)
        cfunc = QuoteNode(cfunc)
    elseif isa(cfunc, String) || isa(cfunc, Ptr) || isa(cfunc, Tuple)
        # do nothing
    else
        dynamic_ccall = true
        oldcfunc = cfunc
        cfunc = gensym("ptr")
    end
    if isa(RetType, SimpleVector)
        @assert length(RetType) == 1
        RetType = RetType[1]
    end
    # When the ccall is dynamic we pass the pointer as an argument so can reuse the function
    cc_key = (dynamic_ccall ? :ptr : cfunc, RetType, ArgType, evalmod, length(sparams))  # compiled call key
    f = get(compiled_calls, cc_key, nothing)
    argnames = Any[Symbol(:arg, i) for i = 1:nargs]
    if f === nothing
        if fcall == :ccall
            ArgType = Expr(:tuple, Any[parametric_type_to_expr(t) for t in ArgType::SimpleVector]...)
        end
        RetType = parametric_type_to_expr(RetType)
        # #285: test whether we can evaluate an type constraints on parametric expressions
        # this essentially comes down to having the names be available in CompiledCalls,
        # if they are not then executing the method will fail
        try
            isa(RetType, Expr) && Core.eval(CompiledCalls, wrap_params(RetType, sparams))
            isa(ArgType, Expr) && Core.eval(CompiledCalls, wrap_params(ArgType, sparams))
        catch
            return nothing
        end
        wrapargs = copy(argnames)
        if dynamic_ccall
            pushfirst!(wrapargs, cfunc)
        end
        for sparam in sparams
            push!(wrapargs, :(::$TVal{$sparam}))
        end
        methname = gensym("compiledcall")
        calling_convention = stmt.args[5]
        if calling_convention === :(:llvmcall)
            def = :(
                function $methname($(wrapargs...)) where {$(sparams...)}
                    return $fcall($cfunc, llvmcall, $RetType, $ArgType, $(argnames...))
                end)
        elseif calling_convention === :(:stdcall)
            def = :(
                function $methname($(wrapargs...)) where {$(sparams...)}
                    return $fcall($cfunc, stdcall, $RetType, $ArgType, $(argnames...))
                end)
        else
            def = :(
                function $methname($(wrapargs...)) where {$(sparams...)}
                    return $fcall($cfunc, $RetType, $ArgType, $(argnames...))
                end)
        end
        f = Core.eval(evalmod, def)
        compiled_calls[cc_key] = f
    end
    stmt.args[1] = QuoteNode(f)
    stmt.head = :call
    deleteat!(stmt.args, 2:length(stmt.args))
    if dynamic_ccall
        push!(stmt.args, oldcfunc)
    end
    append!(stmt.args, args)
    for i in 1:length(sparams)
        push!(stmt.args, :($TVal($(Expr(:static_parameter, i)))))
    end
    return delete_idx
end

function replace_coretypes!(src; rev::Bool=false)
    if isa(src, CodeInfo)
        replace_coretypes_list!(src.code; rev=rev)
    elseif isa(src, Expr)
        replace_coretypes_list!(src.args; rev=rev)
    end
    return src
end

function replace_coretypes_list!(list::AbstractVector; rev::Bool)
    function rep(@nospecialize(x), rev::Bool)
        if rev
            if isa(x, SSAValue)
                return Core.SSAValue(x.id)
            elseif isa(x, SlotNumber)
                return Core.SlotNumber(x.id)
            end
            return x
        end
        if isa(x, Core.SSAValue)
            return SSAValue(x.id)
        elseif isa(x, Core.SlotNumber) || isa(x, Core.TypedSlot)
            return SlotNumber(x.id)
        end
        return x
    end

    for (i, stmt) in enumerate(list)
        rstmt = rep(stmt, rev)
        if rstmt !== stmt
            list[i] = rstmt
        elseif is_GotoIfNot(stmt)
            stmt = stmt::Core.GotoIfNot
            cond = stmt.cond
            rcond = rep(cond, rev)
            if rcond !== cond
                list[i] = Core.GotoIfNot(rcond, stmt.dest)
            end
        elseif is_ReturnNode(stmt)
            stmt = stmt::Core.ReturnNode
            val = stmt.val
            rval = rep(val, rev)
            if rval !== val
                list[i] = Core.ReturnNode(rval)
            end
        elseif isa(stmt, Expr)
            replace_coretypes!(stmt; rev=rev)
        end
    end
    return nothing
end

function reverse_lookup_globalref!(list)
    # This only handles the function in calls
    for (i, stmt) in enumerate(list)
        if isexpr(stmt, :(=))
            stmt = (stmt::Expr).args[2]
        end
        if isexpr(stmt, :call)
            stmt = stmt::Expr
            f = stmt.args[1]
            if isa(f, QuoteNode)
                f = f.value
                if isa(f, Function) && !isa(f, Core.IntrinsicFunction)
                    ft = typeof(f)
                    tn = ft.name::Core.TypeName
                    name = String(tn.name)
                    if startswith(name, '#')
                        name = name[2:end]
                    end
                    stmt.args[1] = GlobalRef(tn.module, Symbol(name))
                end
            end
        end
    end
    return list
end
