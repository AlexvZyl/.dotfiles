using JuliaInterpreter
using JuliaInterpreter: Frame, @lookup
using JuliaInterpreter: finish_and_return!, evaluate_call!, step_expr!, shouldbreak,
                        do_assignment!, SSAValue, isassign, pc_expr, handle_err, get_return,
                        moduleof
using Base.Meta: isexpr
using Test, Random, SHA

function stacklength(frame)
    n = 1
    frame = frame.callee
    while frame !== nothing
        n += 1
        frame = frame.callee
    end
    return n
end

# Execute a frame using Julia's regular compiled-code dispatch for any :call expressions
runframe(frame) = Some{Any}(finish_and_return!(Compiled(), frame))

# Execute a frame using the interpreter for all :call expressions (except builtins & intrinsics)
runstack(frame) = Some{Any}(finish_and_return!(frame))

## For juliatests.jl

function read_and_parse(filename)
    src = read(filename, String)
    ex = Base.parse_input_line(src; filename=filename)
end

## For running interpreter frames under resource limitations

struct Aborted    # for signaling that some statement or test blocks were interrupted
    at::Core.LineInfoNode
end

function Aborted(frame::Frame, pc)
    src = frame.framecode.src
    lineidx = src.codelocs[pc]
    return Aborted(src.linetable[lineidx])
end

"""
    ret, nstmtsleft = evaluate_limited!(recurse, frame, nstmts, istoplevel::Bool=true)

Run `frame` until one of:
- execution terminates normally (`ret = Some{Any}(val)`, where `val` is the returned value of `frame`)
- if `istoplevel` and a `thunk` or `method` expression is encountered (`ret = nothing`)
- more than `nstmts` have been executed (`ret = Aborted(lin)`, where `lnn` is the `LineInfoNode` of termination).
"""
function evaluate_limited!(@nospecialize(recurse), frame::Frame, nstmts::Int, istoplevel::Bool=false)
    refnstmts = Ref(nstmts)
    limexec!(s, f, istl) = limited_exec!(s, f, refnstmts, istl)
    # The following is like finish!, except we intercept :call expressions so that we can run them
    # with limexec! rather than the default finish_and_return!
    pc = frame.pc
    while nstmts > 0
        shouldbreak(frame, pc) && return BreakpointRef(frame.framecode, pc), refnstmts[]
        stmt = pc_expr(frame, pc)
        if isa(stmt, Expr)
            if stmt.head == :call && !isa(recurse, Compiled)
                refnstmts[] = nstmts
                try
                    rhs = evaluate_call!(limexec!, frame, stmt)
                    isa(rhs, Aborted) && return rhs, refnstmts[]
                    lhs = SSAValue(pc)
                    do_assignment!(frame, lhs, rhs)
                    new_pc = pc + 1
                catch err
                    new_pc = handle_err(recurse, frame, err)
                end
                nstmts = refnstmts[]
            elseif stmt.head == :(=) && isexpr(stmt.args[2], :call) && !isa(recurse, Compiled)
                refnstmts[] = nstmts
                try
                    rhs = evaluate_call!(limexec!, frame, stmt.args[2])
                    isa(rhs, Aborted) && return rhs, refnstmts[]
                    do_assignment!(frame, stmt.args[1], rhs)
                    new_pc = pc + 1
                catch err
                    new_pc = handle_err(recurse, frame, err)
                end
                nstmts = refnstmts[]
            elseif istoplevel && stmt.head == :thunk
                code = stmt.args[1]
                if length(code.code) == 1 && JuliaInterpreter.is_return(code.code[end]) && isexpr(code.code[end].args[1], :method)
                    # Julia 1.2+ puts a :thunk before the start of each method
                    new_pc = pc + 1
                else
                    refnstmts[] = nstmts
                    newframe = Frame(moduleof(frame), stmt)
                    if isa(recurse, Compiled)
                        finish!(recurse, newframe, true)
                    else
                        newframe.caller = frame
                        frame.callee = newframe
                        ret = limited_exec!(recurse, newframe, refnstmts, istoplevel)
                        isa(ret, Aborted) && return ret, refnstmts[]
                        frame.callee = nothing
                    end
                    JuliaInterpreter.recycle(newframe)
                    # Because thunks may define new methods, return to toplevel
                    frame.pc = pc + 1
                    return nothing, refnstmts[]
                end
            elseif istoplevel && stmt.head == :method && length(stmt.args) == 3
                step_expr!(recurse, frame, stmt, istoplevel)
                frame.pc = pc + 1
                return nothing, nstmts - 1
            else
                new_pc = step_expr!(recurse, frame, stmt, istoplevel)
                nstmts -= 1
            end
        else
            new_pc = step_expr!(recurse, frame, stmt, istoplevel)
            nstmts -= 1
        end
        (new_pc === nothing || isa(new_pc, BreakpointRef)) && break
        pc = frame.pc = new_pc
    end
    # Handle the return
    stmt = pc_expr(frame, pc)
    if nstmts == 0 && !JuliaInterpreter.is_return(stmt)
        ret = Aborted(frame, pc)
        return ret, nstmts
    end
    ret = get_return(frame)
    return Some{Any}(ret), nstmts
end

evaluate_limited!(@nospecialize(recurse), modex::Tuple{Module,Expr,Frame}, nstmts::Int, istoplevel::Bool=true) =
    evaluate_limited!(recurse, modex[end], nstmts, istoplevel)
evaluate_limited!(@nospecialize(recurse), modex::Tuple{Module,Expr,Expr}, nstmts::Int, istoplevel::Bool=true) =
    Some{Any}(Core.eval(modex[1], modex[3])), nstmts

evaluate_limited!(frame::Union{Frame, Tuple}, nstmts::Int, istoplevel::Bool=false) =
    evaluate_limited!(finish_and_return!, frame, nstmts, istoplevel)

function limited_exec!(@nospecialize(recurse), newframe, refnstmts, istoplevel)
    ret, nleft = evaluate_limited!(recurse, newframe, refnstmts[], istoplevel)
    refnstmts[] = nleft
    return isa(ret, Aborted) ? ret : something(ret)
end

### Functions needed on workers for running tests

function configure_test()
    # To run tests efficiently, certain methods must be run in Compiled mode,
    # in particular those that are used by the Test infrastructure
    cm = JuliaInterpreter.compiled_methods
    empty!(cm)
    JuliaInterpreter.set_compiled_methods()
    push!(cm, which(Test.eval_test, Tuple{Expr, Expr, LineNumberNode}))
    push!(cm, which(Test.get_testset, Tuple{}))
    push!(cm, which(Test.push_testset, Tuple{Test.AbstractTestSet}))
    push!(cm, which(Test.pop_testset, Tuple{}))
    for f in (Test.record, Test.finish)
        for m in methods(f)
            push!(cm, m)
        end
    end
    push!(cm, which(Random.seed!, Tuple{Union{Integer,Vector{UInt32}}}))
    push!(cm, which(copy!, Tuple{Random.MersenneTwister, Random.MersenneTwister}))
    push!(cm, which(copy, Tuple{Random.MersenneTwister}))
    push!(cm, which(Base.include, Tuple{Module, String}))
    push!(cm, which(Base.show_backtrace, Tuple{IO, Vector}))
    push!(cm, which(Base.show_backtrace, Tuple{IO, Vector{Any}}))
    # issue #101
    push!(cm, which(SHA.update!, Tuple{SHA.SHA1_CTX,Vector{UInt8}}))
end

function run_test_by_eval(test, fullpath, nstmts)
    Core.eval(Main, Expr(:toplevel, :(module JuliaTests using Test, Random end), quote
        # These must be run at top level, so we can't put this in a function
        println("Working on ", $test, "...")
        ex = read_and_parse($fullpath)
        isexpr(ex, :error) && @error "error parsing $($test): $ex"
        aborts = Aborted[]
        ts = Test.DefaultTestSet($test)
        Test.push_testset(ts)
        current_task().storage[:SOURCE_PATH] = $fullpath
        modexs = collect(ExprSplitter(JuliaTests, ex))
        for (i, modex) in enumerate(modexs)  # having the index can be useful for debugging
            nstmtsleft = $nstmts
            # mod, ex = modex
            # @show mod ex
            frame = Frame(modex)
            yield()  # allow communication between processes
            ret, nstmtsleft = evaluate_limited!(frame, nstmtsleft, true)
            if isa(ret, Aborted)
                push!(aborts, ret)
                JuliaInterpreter.finish_stack!(Compiled(), frame, true)
            end
        end
        println("Finished ", $test)
        return ts, aborts
    end))
end
