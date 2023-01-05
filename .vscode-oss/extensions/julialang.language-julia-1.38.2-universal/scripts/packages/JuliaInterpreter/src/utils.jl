## Simple utils

# Note: to avoid dynamic dispatch, many of these are coded as a single method using isa statements

function scopeof(@nospecialize(x))::Union{Method,Module}
    (isa(x, Method) || isa(x, Module)) && return x
    isa(x, FrameCode) && return x.scope
    isa(x, Frame) && return x.framecode.scope
    error("unknown scope for ", x)
end

function moduleof(@nospecialize(x))
    s = scopeof(x)
    return isa(s, Module) ? s : s.module
end

function Base.nameof(frame::Frame)
    s = frame.framecode.scope
    isa(s, Method) ? s.name : nameof(s)
end

_Typeof(x) = isa(x, Type) ? Type{x} : typeof(x)

function to_function(@nospecialize(x))
    isa(x, GlobalRef) ? getfield(x.mod, x.name) : x
end

"""
    method = whichtt(tt)

Like `which` except it operates on the complete tuple-type `tt`,
and doesn't throw when there is no matching method.
"""
function whichtt(@nospecialize(tt))
    # TODO: provide explicit control over world age? In case we ever need to call "old" methods.
    @static if VERSION ≥ v"1.8-beta2"
        # branch on https://github.com/JuliaLang/julia/pull/44515
        # for now, actual code execution doesn't ever need to consider overlayed method table
        match, _ = Core.Compiler._findsup(tt, nothing, get_world_counter())
        match === nothing && return nothing
        return match.method
    else
        m = ccall(:jl_gf_invoke_lookup, Any, (Any, UInt), tt, get_world_counter())
        m === nothing && return nothing
        isa(m, Method) && return m
        return m.func::Method
    end
end

instantiate_type_in_env(arg, spsig, spvals) =
    ccall(:jl_instantiate_type_in_env, Any, (Any, Any, Ptr{Any}), arg, spsig, spvals)

function sparam_syms(meth::Method)
    s = Symbol[]
    sig = meth.sig
    while sig isa UnionAll
        push!(s, Symbol(sig.var.name))
        sig = sig.body
    end
    return s
end

separate_kwargs(args...; kwargs...) = (args, values(kwargs))

pc_expr(src::CodeInfo, pc) = src.code[pc]
pc_expr(framecode::FrameCode, pc) = pc_expr(framecode.src, pc)
pc_expr(frame::Frame, pc) = pc_expr(frame.framecode, pc)
pc_expr(frame::Frame) = pc_expr(frame, frame.pc)

function find_used(code::CodeInfo)
    used = BitSet()
    stmts = code.code
    for stmt in stmts
        scan_ssa_use!(used, stmt)
    end
    return used
end

function scan_ssa_use!(used::BitSet, @nospecialize(stmt))
    if isa(stmt, SSAValue)
        push!(used, stmt.id)
    end
    iter = Core.Compiler.userefs(stmt)
    iterval = Core.Compiler.iterate(iter)
    while iterval !== nothing
        useref, state = iterval
        val = Core.Compiler.getindex(useref)
        if isa(val, SSAValue)
            push!(used, val.id)
        end
        iterval = Core.Compiler.iterate(iter, state)
    end
end

function hasarg(predicate, args)
    predicate(args) && return true
    for a in args
        predicate(a) && return true
        if isa(a, Expr)
            hasarg(predicate, a.args) && return true
        elseif isa(a, QuoteNode)
            predicate(a.value) && return true
        elseif isa(a, GlobalRef)
            predicate(a.name) && return true
        end
    end
    return false
end

function wrap_params(expr, sparams::Vector{Symbol})
    isempty(sparams) && return expr
    params = []
    for p in sparams
        hasarg(isidentical(p), expr.args) && push!(params, p)
    end
    return isempty(params) ? expr : Expr(:where, expr, params...)
end

function scopename(tn::TypeName)
    modpath = Base.fullname(tn.module)
    if isa(modpath, Tuple{Symbol})
        return Expr(:., modpath[1], QuoteNode(tn.name))
    end
    ex = Expr(:., modpath[end-1], QuoteNode(modpath[end]))
    for i = length(modpath)-2:-1:1
        ex = Expr(:., modpath[i], ex)
    end
    return Expr(:., ex, QuoteNode(tn.name))
end

## Predicates

isidentical(x) = Base.Fix2(===, x)   # recommended over isequal(::Symbol) since it cannot be invalidated

# is_goto_node(@nospecialize(node)) = isa(node, GotoNode) || isexpr(node, :gotoifnot)

if isdefined(Core, :GotoIfNot)
    is_GotoIfNot(@nospecialize(node)) = isa(node, Core.GotoIfNot)
    is_gotoifnot(@nospecialize(node)) = is_GotoIfNot(node)
else
    is_GotoIfNot(@nospecialize(node)) = false
    is_gotoifnot(@nospecialize(node)) = isexpr(node, :gotoifnot)
end

if isdefined(Core, :ReturnNode)
    is_ReturnNode(@nospecialize(node)) = isa(node, Core.ReturnNode)
    is_return(@nospecialize(node)) = is_ReturnNode(node)
    get_return_node(@nospecialize(node)) = (node::Core.ReturnNode).val
else
    is_ReturnNode(@nospecialize(node)) = false
    is_return(@nospecialize(node)) = isexpr(node, :return)
    get_return_node(@nospecialize(node)) = node.args[1]
end

is_loc_meta(@nospecialize(expr), @nospecialize(kind)) = isexpr(expr, :meta) && length(expr.args) >= 1 && expr.args[1] === kind

"""
    is_global_ref(g, mod, name)

Tests whether `g` is equal to `GlobalRef(mod, name)`.
"""
is_global_ref(@nospecialize(g), mod::Module, name::Symbol) = isa(g, GlobalRef) && g.mod === mod && g.name == name

is_quotenode(@nospecialize(q), @nospecialize(val)) = isa(q, QuoteNode) && q.value == val
is_quotenode_egal(@nospecialize(q), @nospecialize(val)) = isa(q, QuoteNode) && q.value === val

function is_quoted_type(@nospecialize(a), name::Symbol)
    if isa(a, QuoteNode)
        T = a.value
        if isa(T, UnionAll)
            T = Base.unwrap_unionall(T)
        end
        isa(T, DataType) && return T.name.name === name
    end
    return false
end

function is_function_def(@nospecialize(ex))
    (isexpr(ex, :(=)) && isexpr(ex.args[1], :call)) || isexpr(ex, :function)
end

function is_call(@nospecialize(node))
    isexpr(node, :call) ||
        (isexpr(node, :(=)) && (isexpr(node.args[2], :call)))
end

is_call_or_return(@nospecialize(node)) = is_call(node) || is_return(node)

is_dummy(bpref::BreakpointRef) = bpref.stmtidx == 0 && bpref.err === nothing

function unpack_splatcall(stmt)
    if isexpr(stmt, :call) && length(stmt.args) >= 3 && is_quotenode_egal(stmt.args[1], Core._apply_iterate)
        return true, stmt.args[3]
    end
    return false, nothing
end

function is_bodyfunc(@nospecialize(arg))
    if isa(arg, QuoteNode)
        arg = arg.value
    end
    if isa(arg, Function)
        fname = String((typeof(arg).name::Core.TypeName).name)
        return startswith(fname, "##") && match(r"#\d+$", fname) !== nothing
    end
    return false
end

"""
Determine whether we are calling a function for which the current function
is a wrapper (either because of optional arguments or because of keyword arguments).
"""
function is_wrapper_call(@nospecialize(expr))
    isexpr(expr, :(=)) && (expr = expr.args[2])
    isexpr(expr, :call) && any(x->x==SlotNumber(1), expr.args)
end

is_generated(meth::Method) = isdefined(meth, :generator)

"""
    is_doc_expr(ex)

Test whether expression `ex` is a `@doc` expression.
"""
function is_doc_expr(@nospecialize(ex))
    docsym = Symbol("@doc")
    if isexpr(ex, :macrocall)
        ex::Expr
        length(ex.args) == 4 || return false
        a = ex.args[1]
        is_global_ref(a, Core, docsym) && return true
        isa(a, Symbol) && a == docsym && return true
        if isexpr(a, :.)
            mod, name = (a::Expr).args[1], (a::Expr).args[2]
            return mod === :Core && isa(name, QuoteNode) && name.value === docsym
        end
    end
    return false
end

is_leaf(frame::Frame) = frame.callee === nothing

function is_vararg_type(x)
    @static if isa(Vararg, Type)
        if isa(x, Type)
            (x <: Vararg && !(x <: Union{})) && return true
            if isa(x, UnionAll)
                x = Base.unwrap_unionall(x)
            end
            return isa(x, DataType) && nameof(x) == :Vararg
        end
    else
        return isa(x, typeof(Vararg))
    end
    return false
end

## Location info

# These getters improve inference since fieldtype(CodeInfo, :linetable)
# and fieldtype(CodeInfo, :codelocs) are both Any
const LineTypes = Union{LineNumberNode,Core.LineInfoNode}
function linetable(arg)
    if isa(arg, Frame)
        arg = arg.framecode
    end
    if isa(arg, FrameCode)
        arg = arg.src
    end
    return (arg::CodeInfo).linetable::Union{Vector{Core.LineInfoNode},Vector{Any}}  # issue #264
end
_linetable(list::Vector, i::Integer) = list[i]::Union{Expr,LineTypes}
function linetable(arg, i::Integer; macro_caller::Bool=false)::Union{Expr,LineTypes}
    lt = linetable(arg)
    lineinfo = _linetable(lt, i)
    macro_caller && while lineinfo.method === Symbol("macro expansion") && lineinfo.inlined_at != 0
        lineinfo = _linetable(lt, lineinfo.inlined_at)
    end
    return lineinfo
end

function codelocs(arg)
    if isa(arg, Frame)
        arg = arg.framecode
    end
    if isa(arg, FrameCode)
        arg = arg.src
    end
    return (arg::CodeInfo).codelocs::Vector{Int32}
end
codelocs(arg, i::Integer) = codelocs(arg)[i]  # for consistency with linetable (but no extra benefit here)

function lineoffset(framecode::FrameCode)
    offset = 0
    scope = framecode.scope
    if isa(scope, Method)
        _, line1 = whereis(scope)
        offset = line1 - scope.line
    end
    return offset
end

function getline(ln::Union{LineTypes,Expr})
    _getline(ln::LineTypes) = ln.line
    _getline(ln::Expr)      = ln.args[1] # assuming ln.head === :line
    return Int(_getline(ln))::Int
end
function getfile(ln::Union{LineTypes,Expr})
    _getfile(ln::LineTypes) = ln.file::Symbol
    _getfile(ln::Expr)      = ln.args[2]::Symbol # assuming ln.head === :line
    return CodeTracking.maybe_fixup_stdlib_path(String(_getfile(ln)))
end

function firstline(ex::Expr)
    for a in ex.args
        isa(a, LineNumberNode) && return a
        if isa(a, Expr)
            line = firstline(a)
            isa(line, LineNumberNode) && return line
        end
    end
    return nothing
end

"""
    loc = whereis(frame, pc::Int=frame.pc; macro_caller=false)

Return the file and line number for `frame` at `pc`.  If this cannot be
determined, `loc == nothing`. Otherwise `loc == (filepath, line)`.

By default, any statements expanded from a macro are attributed to the macro
definition, but with`macro_caller=true` you can obtain the location within the
method that issued the macro.
"""
function CodeTracking.whereis(framecode::FrameCode, pc::Int; kwargs...)
    codeloc = codelocation(framecode.src, pc)
    codeloc == 0 && return nothing
    lineinfo = linetable(framecode, codeloc; kwargs...)
    m = framecode.scope
    return isa(m, Method) ? whereis(lineinfo, m) : (getfile(lineinfo), getline(lineinfo))
end
CodeTracking.whereis(frame::Frame, pc::Int=frame.pc; kwargs...) = whereis(frame.framecode, pc; kwargs...)

"""
    line = linenumber(framecode, pc)

Return the "static" line number at statement index `pc`. The static line number
is the location at the time the method was most recently defined.
See [`CodeTracking.whereis`](@ref) for dynamic line information.
"""
function linenumber(framecode::FrameCode, pc)
    codeloc = codelocation(framecode.src, pc)
    codeloc == 0 && return nothing
    return getline(linetable(framecode, codeloc))
end
linenumber(frame::Frame, pc=frame.pc) = linenumber(frame.framecode, pc)

function getfile(framecode::FrameCode, pc)
    codeloc = codelocation(framecode.src, pc)
    codeloc == 0 && return nothing
    return getfile(linetable(framecode, codeloc))
end
getfile(frame::Frame, pc=frame.pc) = getfile(frame.framecode, pc)

function codelocation(code::CodeInfo, idx::Int)
    codeloc = codelocs(code)[idx]
    while codeloc == 0 && (code.code[idx] === nothing || isexpr(code.code[idx], :meta)) && idx < length(code.code)
        idx += 1
        codeloc = codelocs(code)[idx]
    end
    return codeloc
end

function compute_corrected_linerange(method::Method)
    _, line1 = whereis(method)
    offset = line1 - method.line
    src = JuliaInterpreter.get_source(method)
    lastline = linetable(src)[end]::LineTypes
    return line1:getline(lastline) + offset
end

function compute_linerange(framecode)
    getline(linetable(framecode, 1)):getline(last(linetable(framecode)))
end

function statementnumbers(framecode::FrameCode, line::Integer, file::Symbol)
    # Check to see if this framecode really contains that line. Methods that fill in a default positional argument,
    # keyword arguments, and @generated sections may not contain the line.
    scope = framecode.scope
    offset = if scope isa Method
        method = scope
        _, line1 = whereis(method)
        Int(line1 - method.line)
    else
        0
    end

    lt = linetable(framecode)

    # Check if the exact line number exist
    idxs = findall(entry::Union{LineInfoNode,LineNumberNode} -> entry.line + offset == line && entry.file == file, lt)
    locs = codelocs(framecode)
    if !isempty(idxs)
        stmtidxs = Int[]
        stmtidx = 1
        while stmtidx <= length(locs)
            loc = locs[stmtidx]
            if loc in idxs
                push!(stmtidxs, stmtidx)
                stmtidx += 1
                # Skip continous statements that are on the same line
                while stmtidx <= length(locs) && loc == locs[stmtidx]
                    stmtidx += 1
                end
            else
                stmtidx += 1
            end
        end
        return stmtidxs
    end


    # If the exact line number does not exist in the line table, take the one that is closest after that line
    # restricted to the line range of the current scope.
    scope = framecode.scope
    range = scope isa Method ? compute_corrected_linerange(scope) : compute_linerange(framecode)
    if line in range
        closest = nothing
        closest_idx = nothing
        for (i, entry) in enumerate(lt)
            entry = entry::Union{LineInfoNode,LineNumberNode}
            if entry.file == file && entry.line in range && entry.line >= line
                if closest === nothing
                    closest = entry
                    closest_idx = i
                else
                    if entry.line < closest.line
                        closest = entry
                        closest_idx = i
                    end
                end
            end
        end
        if closest_idx !== nothing
            idx = let closest_idx=closest_idx    # julia #15276
                findfirst(i-> i==closest_idx, locs)
            end
            return idx === nothing ? nothing : Int[idx]
        end
    end

    return nothing
end

## Printing

function framecode_lines(src::CodeInfo)
    buf = IOBuffer()
    if isdefined(Base.IRShow, :show_ir_stmt)
        lines = String[]
        src = replace_coretypes!(copy(src); rev=true)
        reverse_lookup_globalref!(src.code)
        io = IOContext(buf, :displaysize => displaysize(stdout),
                       :SOURCE_SLOTNAMES => Base.sourceinfo_slotnames(src))
        used = BitSet()
        cfg = Core.Compiler.compute_basic_blocks(src.code)
        for stmt in src.code
            Core.Compiler.scan_ssa_use!(push!, used, stmt)
        end
        line_info_preprinter = Base.IRShow.lineinfo_disabled
        line_info_postprinter = Base.IRShow.default_expr_type_printer
        bb_idx = 1
        for idx = 1:length(src.code)
            bb_idx = Base.IRShow.show_ir_stmt(io, src, idx, line_info_preprinter, line_info_postprinter, used, cfg, bb_idx)
            push!(lines, chomp(String(take!(buf))))
        end
        return lines
    end
    show(buf, src)
    code = filter!(split(String(take!(buf)), '\n')) do line
        !(line == "CodeInfo(" || line == ")" || isempty(line) || occursin("within `", line))
    end
    code .= replace.(code, Ref(r"\$\(QuoteNode\((.+?)\)\)" => s"\1"))
    return code
end
framecode_lines(framecode::FrameCode) = framecode_lines(framecode.src)

breakpointchar(framecode, stmtidx) =
    isassigned(framecode.breakpoints, stmtidx) ? breakpointchar(framecode.breakpoints[stmtidx]) : ' '

function print_framecode(io::IO, framecode::FrameCode; pc=0, range=1:nstatements(framecode), kwargs...)
    iscolor = get(io, :color, false)
    ndstmt = ndigits(nstatements(framecode))
    lt = linetable(framecode)
    offset = lineoffset(framecode)
    ndline = isempty(lt) ? 0 : ndigits(getline(lt[end]) + offset)
    nullline = " "^ndline
    src = copy(framecode.src)
    replace_coretypes!(src; rev=true)
    code = framecode_lines(src)
    isfirst = true
    for (stmtidx, stmtline) in enumerate(code)
        stmtidx ∈ range || continue
        bpc = breakpointchar(framecode, stmtidx)
        isfirst || print(io, '\n')
        isfirst = false
        print(io, bpc, ' ')
        if iscolor
            color = stmtidx == pc ? Base.warn_color() : :normal
            printstyled(io, lpad(stmtidx, ndstmt); color=color, kwargs...)
        else
            print(io, lpad(stmtidx, ndstmt), stmtidx == pc ? '*' : ' ')
        end
        line = linenumber(framecode, stmtidx)
        print(io, ' ', line === nothing ? nullline : lpad(line, ndline), "  ", stmtline)
    end
end

"""
    local_variables = locals(frame::Frame)::Vector{Variable}

Return the local variables as a vector of [`Variable`](@ref).
"""
function locals(frame::Frame)
    vars, var_counter = Variable[], Int[]
    varlookup = Dict{Symbol,Int}()
    data, code = frame.framedata, frame.framecode
    slotnames = code.src.slotnames
    for (sym, counter, val) in zip(slotnames, data.last_reference, data.locals)
        counter == 0 && continue
        val = something(val)
        if val isa Core.Box && !isdefined(val, :contents)
            continue
        end
        var = Variable(val, sym)
        idx = get(varlookup, sym, 0)
        if idx > 0
            if counter > var_counter[idx]
                vars[idx] = var
                var_counter[idx] = counter
            end
        else
            varlookup[sym] = length(vars)+1
            push!(vars, var)
            push!(var_counter, counter)
        end
    end
    scope = code.scope
    if scope isa Method
        syms = sparam_syms(scope)
        for i in 1:length(syms)
            if isassigned(data.sparams, i)
                push!(vars, Variable(data.sparams[i], syms[i], true))
            end
        end
    end
    for var in vars
        if var.name === Symbol("#self#")
            for field in fieldnames(typeof(var.value))
                field = field::Symbol
                if isdefined(var.value, field)
                    push!(vars, Variable(getfield(var.value, field), field, false, true))
                end
            end
        end
    end
    return vars
end

function print_vars(io::IO, vars::Vector{Variable})
    for v in vars
        v.name == Symbol("#self#") && (isa(v.value, Type) || sizeof(v.value) == 0) && continue
        print(io, '\n', v)
    end
end

"""
    eval_code(frame::Frame, code::Union{String, Expr})

Evaluate `code` in the context of `frame`, updating any local variables
(including type parameters) that are reassigned in `code`, however, new local variables
cannot be introduced.

```jldoctest
julia> foo(x, y) = x + y;

julia> frame = JuliaInterpreter.enter_call(foo, 1, 3);

julia> JuliaInterpreter.eval_code(frame, "x + y")
4

julia> JuliaInterpreter.eval_code(frame, "x = 5");

julia> JuliaInterpreter.finish_and_return!(frame)
8
```

When variables are captured in closures (and thus gets wrapped in a `Core.Box`)
they will be automatically unwrapped and rewrapped upon evaluating them:

```jldoctest
julia> function capture()
           x = 1
           f = ()->(x = 2) # x captured in closure and is thus a Core.Box
           f()
           x
       end;

julia> frame = JuliaInterpreter.enter_call(capture);

julia> JuliaInterpreter.step_expr!(frame);

julia> JuliaInterpreter.step_expr!(frame);

julia> JuliaInterpreter.locals(frame)
2-element Vector{JuliaInterpreter.Variable}:
 #self# = capture
 x = Core.Box(1)

julia> JuliaInterpreter.eval_code(frame, "x")
1

julia> JuliaInterpreter.eval_code(frame, "x = 2")
2

julia> JuliaInterpreter.locals(frame)
2-element Vector{JuliaInterpreter.Variable}:
 #self# = capture
 x = Core.Box(2)
```

"Special" values like SSA values and slots (shown in lowered code as e.g. `%3` and `@_4`
respectively) can be evaluated using the syntax `var"%3"` and `var"@_4"` respectively.
"""
function eval_code end

function extract_usage!(s::Set{Symbol}, expr)
    if expr isa Expr
        for arg in expr.args
            if arg isa Symbol
                push!(s, arg)
            elseif arg isa Expr
                extract_usage!(s, arg)
            end
        end
    elseif expr isa Symbol
        push!(s, expr)
    end
    return s
end

eval_code(frame::Frame, command::AbstractString) = eval_code(frame, Base.parse_input_line(command))
function eval_code(frame::Frame, expr::Expr)
    code = frame.framecode
    data = frame.framedata
    isexpr(expr, :toplevel) && (expr = expr.args[end])

    if isexpr(expr, :toplevel)
        expr = Expr(:block, expr.args...)
    end

    used_symbols = Set{Symbol}((Symbol("#self#"),))
    extract_usage!(used_symbols, expr)
    # see https://github.com/JuliaLang/julia/issues/31255 for the Symbol("") check
    vars = filter(v -> v.name != Symbol("") && v.name in used_symbols, locals(frame))
    defined_ssa    = findall(i -> isassigned(data.ssavalues, i) && Symbol("%$i")  in used_symbols, 1:length(data.ssavalues))
    defined_locals = findall(i-> data.locals[i] isa Some        && Symbol("@_$i") in used_symbols, 1:length(data.locals))
    res = gensym()
    eval_expr = Expr(:let,
                     Expr(:block, map(x->Expr(:(=), x...), [(v.name, QuoteNode(v.value isa Core.Box ? v.value.contents : v.value)) for v in vars])...,
                                  map(x->Expr(:(=), x...), [(Symbol("%$i"), QuoteNode(data.ssavalues[i]))                          for i in defined_ssa])...,
                                  map(x->Expr(:(=), x...), [(Symbol("@_$i"), QuoteNode(data.locals[i].value))                      for i in defined_locals])...,
                     ),
        Expr(:block,
            Expr(:(=), res, expr),
            Expr(:tuple, res, Expr(:tuple, [v.name for v in vars]...))
        ))
    eval_res, res = Core.eval(moduleof(frame), eval_expr)
    j = 1
    for (i, v) in enumerate(vars)
        if v.isparam
            data.sparams[j] = res[i]
            j += 1
        elseif v.is_captured_closure
            selfidx = findfirst(v -> v.name === Symbol("#self#"), vars)
            @assert selfidx !== nothing
            self = vars[selfidx].value
            closed_over_var = getfield(self, v.name)
            if closed_over_var isa Core.Box
                setfield!(closed_over_var, :contents, res[i])
            end
            # We cannot rebind closed over variables that the frontend identified as constant
        else
            slot_indices = code.slotnamelists[v.name]
            idx = argmax(data.last_reference[slot_indices])
            slot_idx = slot_indices[idx]
            data.last_reference[slot_idx] = (frame.assignment_counter += 1)
            data.locals[slot_idx] = Some{Any}(v.value isa Core.Box ? Core.Box(res[i]) : res[i])
        end
    end
    eval_res
end

function show_stackloc(io::IO, frame)
    indent = ""
    fr = root(frame)
    shown = false
    while fr !== nothing
        print(io, indent, scopeof(fr))
        if fr === frame
            println(io, ", pc = ", frame.pc)
            shown = true
        else
            print(io, '\n')
        end
        indent *= "  "
        fr = fr.callee
    end
    if !shown
        println(io, indent, scopeof(frame), ", pc = ", frame.pc)
    end
end
show_stackloc(frame) = show_stackloc(stdout, frame)

# Printing of stacktraces and errors with Frame
function Base.StackTraces.StackFrame(frame::Frame)
    scope = scopeof(frame)
    if scope isa Method
        method = scope
        method_args = something.(frame.framedata.locals[1:method.nargs])
        atypes = Tuple{mapany(_Typeof, method_args)...}
        sig = method.sig
        sparams = Core.svec(frame.framedata.sparams...)
        mi = Core.Compiler.specialize_method(method, atypes, sparams)
        fname = frame.framecode.scope.name
    else
        mi = frame.framecode.src
        fname = gensym()
    end
    Base.StackFrame(
        fname,
        Symbol(getfile(frame)),
        @something(linenumber(frame), getline(linetable(frame, 1))),
        mi,
        false,
        false,
        C_NULL
    )
end

function Base.show_backtrace(io::IO, frame::Frame)
    stackframes = Tuple{Base.StackTraces.StackFrame, Int}[]
    while frame !== nothing
        push!(stackframes, (Base.StackTraces.StackFrame(frame), 1))
        frame = JuliaInterpreter.caller(frame)
    end
    print(io, "\nStacktrace:")
    try invokelatest(Base.update_stackframes_callback[], stackframes) catch end
    frame_counter = 0
    nd = ndigits(length(stackframes))
    for (i, (last_frame, n)) in enumerate(stackframes)
        frame_counter += 1
        if isdefined(Base, :print_stackframe)
            println(io)
            Base.print_stackframe(io, i, last_frame, n, nd, Base.info_color())
        else
            Base.show_trace_entry(IOContext(io, :backtrace => true), last_frame, n, prefix = string(" [", frame_counter, "] "))
        end
    end
end

function Base.display_error(io::IO, er, frame::Frame)
    printstyled(io, "ERROR: "; bold=true, color=Base.error_color())
    showerror(IOContext(io, :limit => true), er, frame)
    println(io)
end

function static_eval(ex)
    try
        eval(ex)
    catch
        nothing
    end
end
