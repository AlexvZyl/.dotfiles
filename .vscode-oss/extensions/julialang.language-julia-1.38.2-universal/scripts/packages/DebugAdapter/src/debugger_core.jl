struct VariableReference
    kind::Symbol
    value
end

mutable struct DebuggerState
    last_exception
    expr_splitter::Union{JuliaInterpreter.ExprSplitter,Nothing}
    frame
    not_yet_set_function_breakpoints::Set{Any}
    debug_mode::Symbol
    compile_mode
    sources::Dict{Int,String}
    next_source_id::Int
    varrefs::Vector{VariableReference}
    next_cmd::Channel{Any}
    not_yet_set_compiled_items::Vector{String}

    function DebuggerState()
        return new(nothing, nothing, nothing, Set{String}(), :unknown, JuliaInterpreter.finish_and_return!, Dict{Int,String}(), 1, VariableReference[], Channel{Any}(Inf), String[])
    end
end

is_toplevel_return(frame) = frame.framecode.scope isa Module && JuliaInterpreter.isexpr(JuliaInterpreter.pc_expr(frame), :return)

function attempt_to_set_f_breakpoints!(bps)
    for bp in bps
        @debug "Trying to set function breakpoint for '$(bp.name)'."
        try
            f = Core.eval(bp.mod, bp.name)

            signat = if bp.signature !== nothing
                Tuple{(Core.eval(Main, i) for i in bp.signature)...}
            else
                nothing
            end

            JuliaInterpreter.breakpoint(f, signat, bp.condition)
            delete!(bps, bp)

            @debug "Setting function breakpoint for '$(bp.name)' succeeded."
        catch err
            @debug "Setting function breakpoint for '$(bp.name)' failed."
        end
    end
end

function get_next_top_level_frame(state)
    state.expr_splitter === nothing && return nothing
    x = iterate(state.expr_splitter)
    x === nothing && return nothing

    (mod, ex), _ = x
    if Meta.isexpr(ex, :global, 1)
        # global assignment can be lowered, but global declaration can't,
        # let's just evaluate and iterate to next
        Core.eval(mod, ex)
        return get_next_top_level_frame(state)
    end
    return JuliaInterpreter.Frame(mod, ex)
end

function our_debug_command(cmd, state)
    while true
        @debug "Running a new frame." state.frame state.compile_mode

        ret = Base.invokelatest(JuliaInterpreter.debug_command, state.compile_mode, state.frame, cmd, true)

        state.not_yet_set_compiled_items = set_compiled_functions_modules!(state.not_yet_set_compiled_items)
        attempt_to_set_f_breakpoints!(state.not_yet_set_function_breakpoints)

        @debug "Finished running frame."

        if ret !== nothing && is_toplevel_return(ret[1])
            ret = nothing
        end

        if ret !== nothing
            state.frame = ret[1]
            return ret[2]
        end

        state.frame = get_next_top_level_frame(state)

        if state.frame === nothing
            return nothing
        end

        ret !== nothing && error("Invalid state.")

        if ret === nothing && (cmd == :n || cmd == :s || cmd == :finish || JuliaInterpreter.shouldbreak(state.frame, state.frame.pc))
            return state.frame.pc
        end
    end
end

function send_stopped_msg(conn, ret_val, state)
    if ret_val isa JuliaInterpreter.BreakpointRef
        if ret_val.err === nothing
            JSONRPC.send(conn, stopped_notification_type, StoppedEventArguments("breakpoint", missing, 1, missing, missing, missing))
        else
            state.last_exception = ret_val.err
            error_msg = try
                Base.invokelatest(sprint, Base.showerror, ret_val.err)
            catch err
                "Error while displaying the original error."
            end
            JSONRPC.send(conn, stopped_notification_type, StoppedEventArguments("exception", missing, 1, missing, error_msg, missing))
        end
    elseif ret_val isa Number
        JSONRPC.send(conn, stopped_notification_type, StoppedEventArguments("step", missing, 1, missing, missing, missing))
    elseif ret_val === nothing
        JSONRPC.send(conn, stopped_notification_type, StoppedEventArguments("step", missing, 1, missing, missing, missing))
    end
end
