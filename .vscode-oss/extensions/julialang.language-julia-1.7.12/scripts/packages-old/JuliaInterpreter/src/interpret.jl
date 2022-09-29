isassign(frame) = isassign(frame, frame.pc)
isassign(frame, pc) = (pc in frame.framecode.used)

lookup_var(frame, val::SSAValue) = frame.framedata.ssavalues[val.id]
lookup_var(frame, ref::GlobalRef) = getfield(ref.mod, ref.name)
function lookup_var(frame, slot::SlotNumber)
    val = frame.framedata.locals[slot.id]
    val !== nothing && return val.value
    throw(UndefVarError(frame.framecode.src.slotnames[slot.id]))
end

function lookup_expr(frame, e::Expr)
    head = e.head
    head === :the_exception && return frame.framedata.last_exception[]
    if head === :static_parameter
        arg = e.args[1]::Int
        if isassigned(frame.framedata.sparams, arg)
            return frame.framedata.sparams[arg]
        else
            syms = sparam_syms(frame.framecode.scope::Method)
            throw(UndefVarError(syms[arg]))
        end
    end
    head === :boundscheck && length(e.args) == 0 && return true
    error("invalid lookup expr ", e)
end

"""
    rhs = @lookup(frame, node)
    rhs = @lookup(mod, frame, node)

This macro looks up previously-computed values referenced as SSAValues, SlotNumbers,
GlobalRefs, QuoteNode, sparam or exception reference expression.
It will also lookup symbols in `moduleof(frame)`; this can be supplied ahead-of-time via
the 3-argument version.
If none of the above apply, the value of `node` will be returned.
"""
macro lookup(args...)
    length(args) == 2 || length(args) == 3 || error("invalid number of arguments ", length(args))
    havemod = length(args) == 3
    local mod
    if havemod
        mod, frame, node = args
    else
        frame, node = args
    end
    nodetmp = gensym(:node)  # used to hoist, e.g., args[4]
    if havemod
        fallback = quote
            isa($nodetmp, Symbol) ? getfield($(esc(mod)), $nodetmp) :
            $nodetmp
        end
    else
        fallback = quote
            $nodetmp
        end
    end
    quote
        $nodetmp = $(esc(node))
        isa($nodetmp, SSAValue) ? lookup_var($(esc(frame)), $nodetmp) :
        isa($nodetmp, GlobalRef) ? lookup_var($(esc(frame)), $nodetmp) :
        isa($nodetmp, SlotNumber) ? lookup_var($(esc(frame)), $nodetmp) :
        isa($nodetmp, QuoteNode) ? $nodetmp.value :
        isa($nodetmp, Symbol) ? getfield(moduleof($(esc(frame))), $nodetmp) :
        isa($nodetmp, Expr) ? lookup_expr($(esc(frame)), $nodetmp) :
        $fallback
    end
end

# This is used only for new struct/abstract/primitive nodes.
# The most important issue is that in these expressions, :call Exprs can be nested,
# and hence our re-use of the `callargs` field of Frame would introduce
# bugs. Since these nodes use a very limited repertoire of calls, we can special-case
# this quite easily.
function lookup_or_eval(@nospecialize(recurse), frame, @nospecialize(node))
    if isa(node, SSAValue)
        return lookup_var(frame, node)
    elseif isa(node, SlotNumber)
        return lookup_var(frame, node)
    elseif isa(node, Symbol)
        return getfield(moduleof(frame), node)
    elseif isa(node, QuoteNode)
        return node.value
    elseif isa(node, Expr)
        ex = Expr(node.head)
        for arg in node.args
            push!(ex.args, lookup_or_eval(recurse, frame, arg))
        end
        if ex.head === :call
            f = ex.args[1]
            if f === Core.svec
                return Core.svec(ex.args[2:end]...)
            elseif f === Core.apply_type
                return Core.apply_type(ex.args[2:end]...)
            elseif f === Core.typeof
                return Core.typeof(ex.args[2])
            elseif f === Base.getproperty
                return Base.getproperty(ex.args[2], ex.args[3])
            else
                error("unknown call f ", f)
            end
        else
            error("unknown expr ", ex)
        end
    elseif isa(node, Int) || isa(node, Number)   # Number is slow, requires subtyping
        return node
    elseif isa(node, Type)
        return node
    end
    return eval_rhs(recurse, frame, node)
end

function resolvefc(frame, @nospecialize(expr))
    if isa(expr, SlotNumber)
        expr = lookup_var(frame, expr)
    elseif isa(expr, SSAValue)
        expr = lookup_var(frame, expr)
        isa(expr, Symbol) && return QuoteNode(expr)
    end
    (isa(expr, Symbol) || isa(expr, String) || isa(expr, Ptr) || isa(expr, QuoteNode)) && return expr
    isa(expr, Tuple{Symbol,Symbol}) && return expr
    isa(expr, Tuple{String,String}) && return expr
    isa(expr, Tuple{Symbol,String}) && return expr
    isa(expr, Tuple{String,Symbol}) && return expr
    if isexpr(expr, :call)
        a = (expr::Expr).args[1]
        (isa(a, QuoteNode) && a.value === Core.tuple) || error("unexpected ccall to ", expr)
        return Expr(:call, GlobalRef(Core, :tuple), (expr::Expr).args[2:end]...)
    end
    error("unexpected ccall to ", expr)
end

function collect_args(frame::Frame, call_expr::Expr; isfc::Bool=false)
    args = frame.framedata.callargs
    resize!(args, length(call_expr.args))
    mod = moduleof(frame)
    args[1] = isfc ? resolvefc(frame, call_expr.args[1]) : @lookup(mod, frame, call_expr.args[1])
    for i = 2:length(args)
        args[i] = @lookup(mod, frame, call_expr.args[i])
    end
    return args
end

"""
    ret = evaluate_foreigncall(frame::Frame, call_expr)

Evaluate a `:foreigncall` (from a `ccall`) statement `callexpr` in the context of `frame`.
"""
function evaluate_foreigncall(frame::Frame, call_expr::Expr)
    head = call_expr.head
    args = collect_args(frame, call_expr; isfc = head==:foreigncall)
    for i = 2:length(args)
        arg = args[i]
        args[i] = isa(arg, Symbol) ? QuoteNode(arg) : arg
    end
    head === :cfunction && (args[2] = QuoteNode(args[2]))
    scope = frame.framecode.scope
    data = frame.framedata
    if !isempty(data.sparams) && scope isa Method
        sig = scope.sig
        args[2] = instantiate_type_in_env(args[2], sig, data.sparams)
        args[3] = Core.svec(map(args[3]) do arg
            instantiate_type_in_env(arg, sig, data.sparams)
        end...)
    end
    return Core.eval(moduleof(frame), Expr(head, args...))
end

# We have to intercept ccalls / llvmcalls before we try it as a builtin
function bypass_builtins(frame, call_expr, pc)
    if isassigned(frame.framecode.methodtables, pc)
        tme = frame.framecode.methodtables[pc]
        if isa(tme, Compiled)
            fargs = collect_args(frame, call_expr)
            f = to_function(fargs[1])
            fmod = parentmodule(f)::Module
            if fmod === JuliaInterpreter.CompiledCalls || fmod === Core.Compiler
                return Some{Any}(Base.invokelatest(f, fargs[2:end]...))
            else
                return Some{Any}(f(fargs[2:end]...))
            end
        end
    end
    return nothing
end

function evaluate_call_compiled!(::Compiled, frame::Frame, call_expr::Expr; enter_generated::Bool=false)
    # @assert !enter_generated
    pc = frame.pc
    ret = bypass_builtins(frame, call_expr, pc)
    isa(ret, Some{Any}) && return ret.value
    ret = maybe_evaluate_builtin(frame, call_expr, false)
    isa(ret, Some{Any}) && return ret.value
    fargs = collect_args(frame, call_expr)
    f = fargs[1]
    popfirst!(fargs)  # now it's really just `args`
    return f(fargs...)
end

function evaluate_call_recurse!(@nospecialize(recurse), frame::Frame, call_expr::Expr; enter_generated::Bool=false)
    pc = frame.pc
    ret = bypass_builtins(frame, call_expr, pc)
    isa(ret, Some{Any}) && return ret.value
    ret = maybe_evaluate_builtin(frame, call_expr, true)
    isa(ret, Some{Any}) && return ret.value
    call_expr = ret
    fargs = collect_args(frame, call_expr)
    if fargs[1] === Core.eval
        return Core.eval(fargs[2], fargs[3])  # not a builtin, but worth treating specially
    elseif fargs[1] === Base.rethrow
        err = length(fargs) > 1 ? fargs[2] : frame.framedata.last_exception[]
        throw(err)
    end
    if fargs[1] === Core.invoke # invoke needs special handling
        f_invoked = which(fargs[2], fargs[3])::Method
        fargs_pruned = [fargs[2]; fargs[4:end]]
        sig = Tuple{mapany(_Typeof, fargs_pruned)...}
        ret = prepare_framecode(f_invoked, sig; enter_generated=enter_generated)
        isa(ret, Compiled) && return invoke(fargs[2:end]...)
        @assert ret !== nothing
        framecode, lenv = ret
        lenv === nothing && return framecode  # this was a Builtin
        fargs = fargs_pruned
    else
        framecode, lenv = get_call_framecode(fargs, frame.framecode, frame.pc; enter_generated=enter_generated)
        if lenv === nothing
            if isa(framecode, Compiled)
                f = popfirst!(fargs)  # now it's really just `args`
                return Base.invokelatest(f, fargs...)
            end
            return framecode  # this was a Builtin
        end
    end
    newframe = prepare_frame_caller(frame, framecode, fargs, lenv)
    npc = newframe.pc
    shouldbreak(newframe, npc) && return BreakpointRef(newframe.framecode, npc)
    # if the following errors, handle_err will pop the stack and recycle newframe
    if recurse === finish_and_return!
        # Optimize this case to avoid dynamic dispatch
        ret = finish_and_return!(finish_and_return!, newframe, false)
    else
        ret = recurse(recurse, newframe, false)
    end
    isa(ret, BreakpointRef) && return ret
    frame.callee = nothing
    return_from(newframe)
    return ret
end

"""
    ret = evaluate_call!(Compiled(), frame::Frame, call_expr)
    ret = evaluate_call!(recurse,    frame::Frame, call_expr)

Evaluate a `:call` expression `call_expr` in the context of `frame`.
The first causes it to be executed using Julia's normal dispatch (compiled code),
whereas the second recurses in via the interpreter.
`recurse` has a default value of [`JuliaInterpreter.finish_and_return!`](@ref).
"""
evaluate_call!(::Compiled, frame::Frame, call_expr::Expr; kwargs...) = evaluate_call_compiled!(Compiled(), frame, call_expr; kwargs...)
evaluate_call!(@nospecialize(recurse), frame::Frame, call_expr::Expr; kwargs...) = evaluate_call_recurse!(recurse, frame, call_expr; kwargs...)
evaluate_call!(frame::Frame, call_expr::Expr; kwargs...) = evaluate_call!(finish_and_return!, frame, call_expr; kwargs...)

# The following come up only when evaluating toplevel code
function evaluate_methoddef(frame, node)
    f = node.args[1]
    if isa(f, Symbol)
        mod = moduleof(frame)
        if Base.isbindingresolved(mod, f) && isdefined(mod, f)  # `isdefined` accesses the binding, making it impossible to create a new one
            f = getfield(mod, f)
        else
            f = Core.eval(moduleof(frame), Expr(:function, f))  # create a new function
        end
    elseif isa(f, GlobalRef)
        f = getfield(f.mod, f.name)
    end
    length(node.args) == 1 && return f
    sig = @lookup(frame, node.args[2])::SimpleVector
    body = @lookup(frame, node.args[3])
    # branching on https://github.com/JuliaLang/julia/pull/41137
    @static if isdefined(Core.Compiler, :OverlayMethodTable)
        ccall(:jl_method_def, Cvoid, (Any, Ptr{Cvoid}, Any, Any), sig, C_NULL, body, moduleof(frame))
    else
        ccall(:jl_method_def, Cvoid, (Any, Any, Any), sig, body, moduleof(frame))
    end
    return f
end

function structname(frame, node)
    name = node.args[1]
    if isa(name, GlobalRef)
        mod = name.mod
        name = name.name
    else
        mod = moduleof(frame)
        name = name::Symbol
    end
    return name, mod
end

function set_structtype_const(mod::Module, name::Symbol)
    dt = Base.unwrap_unionall(getfield(mod, name))
    ccall(:jl_set_const, Cvoid, (Any, Any, Any), mod, dt.name.name, dt.name.wrapper)
end

function inplace_lookup!(ex, i, frame)
    a = ex.args[i]
    if isa(a, SSAValue) || isa(a, SlotNumber)
        ex.args[i] = lookup_var(frame, a)
    elseif isexpr(a, :call)
        for j = 1:length((a::Expr).args)
            inplace_lookup!(a, j, frame)
        end
    end
    return ex
end

function evaluate_structtype(@nospecialize(recurse), frame, node)
    grsvec!(ex::Expr) = (ex.args[1] = GlobalRef(Core, :svec); return ex)

    name, mod = structname(frame, node)
    supertype = lookup_or_eval(recurse, frame, node.args[4])::Type
    ismutable = node.args[6]::Bool
    ninit = node.args[7]::Int
    newstructexpr = Expr(:struct_type, name, nothing, nothing, supertype, nothing, ismutable, ninit)
    for idx in (2, 3, 5)
        ex = newstructexpr.args[idx] = grsvec!(copy(node.args[idx]::Expr))
        for i = 2:length(ex.args)
            inplace_lookup!(ex, i, frame)
        end
    end
    Core.eval(mod, newstructexpr)
    VERSION < v"1.2.0-DEV.239" && set_structtype_const(mod, name)
end

function evaluate_abstracttype(@nospecialize(recurse), frame, node)
    name, mod = structname(frame, node)
    params = lookup_or_eval(recurse, frame, node.args[2])::SimpleVector
    supertype = lookup_or_eval(recurse, frame, node.args[3])::Type
    Core.eval(mod, Expr(:abstract_type, name, params, supertype))
    VERSION < v"1.2.0-DEV.239" && set_structtype_const(mod, name)
end

function evaluate_primitivetype(@nospecialize(recurse), frame, node)
    name, mod = structname(frame, node)
    params = lookup_or_eval(recurse, frame, node.args[2])::SimpleVector
    nbits = node.args[3]::Int
    supertype = lookup_or_eval(recurse, frame, node.args[4])::Type
    Core.eval(mod, Expr(:primitive_type, name, params, nbits, supertype))
    VERSION < v"1.2.0-DEV.239" && set_structtype_const(mod, name)
end

function do_assignment!(frame, @nospecialize(lhs), @nospecialize(rhs))
    code, data = frame.framecode, frame.framedata
    if isa(lhs, SSAValue)
        data.ssavalues[lhs.id] = rhs
    elseif isa(lhs, SlotNumber)
        counter = (frame.assignment_counter += 1)
        data.locals[lhs.id] = Some{Any}(rhs)
        data.last_reference[lhs.id] = counter
    elseif isa(lhs, GlobalRef)
        Core.eval(lhs.mod, :($(lhs.name) = $(QuoteNode(rhs))))
    elseif isa(lhs, Symbol)
        Core.eval(moduleof(code), :($lhs = $(QuoteNode(rhs))))
    end
end

function maybe_assign!(frame, @nospecialize(stmt), @nospecialize(val))
    pc = frame.pc
    if isexpr(stmt, :(=))
        lhs = stmt.args[1]
        do_assignment!(frame, lhs, val)
    elseif isassign(frame, pc)
        lhs = SSAValue(pc)
        do_assignment!(frame, lhs, val)
    end
    return nothing
end
maybe_assign!(frame, @nospecialize(val)) = maybe_assign!(frame, pc_expr(frame), val)


function eval_rhs(@nospecialize(recurse), frame, node::Expr)
    head = node.head
    if head === :new
        mod = moduleof(frame)
        args = let mod=mod
            Any[@lookup(mod, frame, arg) for arg in node.args]
        end
        T = popfirst!(args)
        rhs = ccall(:jl_new_structv, Any, (Any, Ptr{Any}, UInt32), T, args, length(args))
        return rhs
    elseif head === :splatnew  # Julia 1.2+
        mod = moduleof(frame)
        rhs = ccall(:jl_new_structt, Any, (Any, Any), @lookup(mod, frame, node.args[1]), @lookup(mod, frame, node.args[2]))
        return rhs
    elseif head === :isdefined
        return check_isdefined(frame, node.args[1])
    elseif head === :call
        # here it's crucial to avoid dynamic dispatch
        isa(recurse, Compiled) && return evaluate_call_compiled!(recurse, frame, node)
        return evaluate_call_recurse!(recurse, frame, node)
    elseif head === :foreigncall || head === :cfunction
        return evaluate_foreigncall(frame, node)
    elseif head === :copyast
        val = (node.args[1]::QuoteNode).value
        return isa(val, Expr) ? copy(val) : val
    elseif head === :enter
        return length(frame.framedata.exception_frames)
    elseif head === :boundscheck
        return true
    elseif head === :meta || head === :inbounds || head == (@static VERSION >= v"1.2.0-DEV.462" ? :loopinfo : :simdloop) ||
           head === :gc_preserve_begin || head === :gc_preserve_end
        return nothing
    elseif head === :method && length(node.args) == 1
        return evaluate_methoddef(frame, node)
    end
    return lookup_expr(frame, node)
end

function check_isdefined(frame, @nospecialize(node))
    data = frame.framedata
    if isa(node, SlotNumber)
        return data.locals[node.id] !== nothing
    elseif isa(node, Core.Compiler.Argument) # just to be safe, since base handles this
        return data.locals[node.n] !== nothing
    elseif isexpr(node, :static_parameter)
        return isassigned(data.sparams, node.args[1]::Int)
    elseif isa(node, GlobalRef)
        return isdefined(node.mod, node.name)
    elseif isa(node, Symbol)
        return isdefined(moduleof(frame), node)
    else # QuoteNode or other implicitly quoted object
        return true
    end
end

function coverage_visit_line!(frame::Frame)
    pc, code = frame.pc, frame.framecode
    code.report_coverage || return
    src = code.src
    codeloc = src.codelocs[pc]
    if codeloc != frame.last_codeloc
        linetable = src.linetable::Vector{Any}
        lineinfo = linetable[codeloc]::Core.LineInfoNode
        file, line = String(lineinfo.file), lineinfo.line
        ccall(:jl_coverage_visit_line, Cvoid, (Cstring, Csize_t, Cint), file, sizeof(file), line)
        frame.last_codeloc = codeloc
    end
end

# For "profiling" where JuliaInterpreter spends its time. See the commented-out block
# in `step_expr!`
const _location = Dict{Tuple{Method,Int},Int}()

function step_expr!(@nospecialize(recurse), frame, @nospecialize(node), istoplevel::Bool)
    pc, code, data = frame.pc, frame.framecode, frame.framedata
    # if !is_leaf(frame)
    #     show_stackloc(frame)
    #     @show node
    # end
    @assert is_leaf(frame)
    @static VERSION >= v"1.8.0-DEV.370" && coverage_visit_line!(frame)
    local rhs
    # For debugging:
    # show_stackloc(frame)
    # @show node
    # For profiling:
    # location_key = (scopeof(frame), pc)
    # _location[location_key] = get(_location, location_key, 0) + 1
    try
        if isa(node, Expr)
            if node.head === :(=)
                lhs, rhs = node.args
                if isa(rhs, Expr)
                    rhs = eval_rhs(recurse, frame, rhs)
                else
                    rhs = istoplevel ? @lookup(moduleof(frame), frame, rhs) : @lookup(frame, rhs)
                end
                isa(rhs, BreakpointRef) && return rhs
                do_assignment!(frame, lhs, rhs)
            elseif node.head === :gotoifnot
                arg = @lookup(frame, node.args[1])
                if !isa(arg, Bool)
                    throw(TypeError(nameof(frame), "if", Bool, arg))
                end
                if !arg
                    return (frame.pc = node.args[2]::Int)
                end
            elseif node.head === :enter
                rhs = node.args[1]
                push!(data.exception_frames, rhs)
            elseif node.head === :leave
                for _ = 1:node.args[1]::Int
                    pop!(data.exception_frames)
                end
            elseif node.head === :pop_exception
                n = lookup_var(frame, node.args[1])
                deleteat!(data.exception_frames, n+1:length(data.exception_frames))
            elseif node.head === :return
                return nothing
            elseif istoplevel
                if node.head === :method && length(node.args) > 1
                    evaluate_methoddef(frame, node)
                elseif node.head === :struct_type
                    evaluate_structtype(recurse, frame, node)
                elseif node.head === :abstract_type
                    evaluate_abstracttype(recurse, frame, node)
                elseif node.head === :primitive_type
                    evaluate_primitivetype(recurse, frame, node)
                elseif node.head === :module
                    error("this should have been handled by split_expressions")
                elseif node.head === :using || node.head === :import || node.head === :export
                    Core.eval(moduleof(frame), node)
                elseif node.head === :const
                    g = node.args[1]
                    if isa(g, GlobalRef)
                        mod, name = g.mod, g.name
                    else
                        mod, name = moduleof(frame), g::Symbol
                    end
                    if VERSION >= v"1.2.0-DEV.239"  # depends on https://github.com/JuliaLang/julia/pull/30893
                        Core.eval(mod, Expr(:const, name))
                    end
                elseif node.head === :thunk
                    newframe = Frame(moduleof(frame), node.args[1])
                    if isa(recurse, Compiled)
                        finish!(recurse, newframe, true)
                    else
                        newframe.caller = frame
                        frame.callee = newframe
                        finish!(recurse, newframe, true)
                        frame.callee = nothing
                    end
                    return_from(newframe)
                elseif node.head === :global
                    Core.eval(moduleof(frame), node)
                elseif node.head === :toplevel
                    mod = moduleof(frame)
                    iter = ExprSplitter(mod, node)
                    rhs = Core.eval(mod, Expr(:toplevel,
                        :(for (mod, ex) in $iter
                              if ex.head === :toplevel
                                  Core.eval(mod, ex)
                                  continue
                              end
                              newframe = ($Frame)(mod, ex)
                              while true
                                  ($through_methoddef_or_done!)($recurse, newframe) === nothing && break
                              end
                              $return_from(newframe)
                          end)))
                elseif node.head === :error
                    error("unexpected error statement ", node)
                elseif node.head === :incomplete
                    error("incomplete statement ", node)
                else
                    rhs = eval_rhs(recurse, frame, node)
                end
            elseif node.head === :thunk || node.head === :toplevel
                error("this frame needs to be run at top level")
            else
                rhs = eval_rhs(recurse, frame, node)
            end
        elseif isa(node, GotoNode)
            return (frame.pc = node.label)
        elseif is_GotoIfNot(node)
            node = node::Core.GotoIfNot
            arg = @lookup(frame, node.cond)
            if !isa(arg, Bool)
                throw(TypeError(nameof(frame), "if", Bool, arg))
            end
            if !arg
                return (frame.pc = node.dest)
            end
        elseif is_ReturnNode(node)
            return nothing
        elseif isa(node, NewvarNode)
            # FIXME: undefine the slot?
        elseif istoplevel && isa(node, LineNumberNode)
        elseif istoplevel && isa(node, Symbol)
            rhs = getfield(moduleof(frame), node)
        else
            rhs = @lookup(frame, node)
        end
    catch err
        return handle_err(recurse, frame, err)
    end
    @isdefined(rhs) && isa(rhs, BreakpointRef) && return rhs
    if isassign(frame, pc)
        # if !@isdefined(rhs)
        #     @show frame node
        # end
        lhs = SSAValue(pc)
        do_assignment!(frame, lhs, rhs)
    end
    return (frame.pc = pc + 1)
end

"""
    pc = step_expr!(recurse, frame, istoplevel=false)
    pc = step_expr!(frame, istoplevel=false)

Execute the next statement in `frame`. `pc` is the new program counter, or `nothing`
if execution terminates, or a [`BreakpointRef`](@ref) if execution hits a breakpoint.

`recurse` controls call evaluation; `recurse = Compiled()` evaluates :call expressions
by normal dispatch. The default value `recurse = finish_and_return!` will use recursive
interpretation.

If you are evaluating `frame` at module scope you should pass `istoplevel=true`.
"""
step_expr!(@nospecialize(recurse), frame::Frame, istoplevel::Bool=false) =
    step_expr!(recurse, frame, pc_expr(frame), istoplevel)
step_expr!(frame::Frame, istoplevel::Bool=false) =
    step_expr!(finish_and_return!, frame, istoplevel)

"""
    loc = handle_err(recurse, frame, err)

Deal with an error `err` that arose while evaluating `frame`. There are one of three
behaviors:

- if `frame` catches the error, `loc` is the program counter at which to resume
  evaluation of `frame`;
- if `frame` doesn't catch the error, but `break_on_error[]` is `true`,
  `loc` is a `BreakpointRef`;
- otherwise, `err` gets rethrown.
"""
function handle_err(@nospecialize(recurse), frame, err)
    data = frame.framedata
    err_will_be_thrown_to_top_level = isempty(data.exception_frames) && !data.caller_will_catch_err
    if break_on_throw[] || (break_on_error[] && err_will_be_thrown_to_top_level)
        return BreakpointRef(frame.framecode, frame.pc, err)
    end
    if isempty(data.exception_frames)
        if !err_will_be_thrown_to_top_level
            return_from(frame)
        end
        # Check for world age errors, which generally indicate a failure to go back to toplevel
        if isa(err, MethodError)
            is_arg_types = isa(err.args, DataType)
            arg_types = is_arg_types ? err.args : Base.typesof(err.args...)
            if (err.world != typemax(UInt) &&
                hasmethod(err.f, arg_types) &&
                !hasmethod(err.f, arg_types, world = err.world))
                @warn "likely failure to return to toplevel, try `ExprSplitter`"
            end
        end
        rethrow(err)
    end
    data.last_exception[] = err
    return (frame.pc = data.exception_frames[end])
end

if isdefined(Core, :ReturnNode)
    lookup_return(frame, node::Core.ReturnNode) = @lookup(frame, node.val)
else
    lookup_return(frame, node::Expr) = @lookup(frame, node.args[1])
end

"""
    ret = get_return(frame)

Get the return value of `frame`. Throws an error if `frame.pc` does not point to a `return` expression.
`frame` must have already been executed so that the return value has been computed (see,
e.g., [`JuliaInterpreter.finish!`](@ref)).
"""
function get_return(frame)
    node = pc_expr(frame)
    is_return(node) || error("expected return statement, got ", node)
    return lookup_return(frame, node)
end
get_return(t::Tuple{Module,Expr,Frame}) = get_return(t[end])
