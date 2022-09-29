
# include("../../VSCodeServer/src/repl.jl")

import Sockets, Base64

include("protocol/debug_adapter_protocol.jl")
include("debugger_utils.jl")
include("debugger_core.jl")
include("debugger_requests.jl")


function clean_up_ARGS_in_launch_mode()
    pipename = ARGS[1]
    crashreporting_pipename = ARGS[2]
    deleteat!(ARGS, 1)
    deleteat!(ARGS, 1)

    if ENV["JL_ARGS"] != ""
        cmd_ln_args_encoded = split(ENV["JL_ARGS"], ';')

        delete!(ENV, "JL_ARGS")

        cmd_ln_args_decoded = map(i -> String(Base64.base64decode(i)), cmd_ln_args_encoded)

        for arg in cmd_ln_args_decoded
            push!(ARGS, arg)
        end
    end

    return pipename, crashreporting_pipename
end

function startdebug(socket, error_handler=nothing)
    @debug "Connected to debug adapter."

    try

        endpoint = JSONRPC.JSONRPCEndpoint(socket, socket, error_handler)

        try

            run(endpoint)

            state = DebuggerState()

            msg_dispatcher = JSONRPC.MsgDispatcher()
            msg_dispatcher[disconnect_request_type] = (conn, params) -> disconnect_request(conn, state, params)
            msg_dispatcher[run_notification_type] = (conn, params) -> run_notification(conn, state, params)
            msg_dispatcher[debug_notification_type] = (conn, params) -> debug_notification(conn, state, params)

            msg_dispatcher[exec_notification_type] = (conn, params) -> exec_notification(conn, state, params)
            msg_dispatcher[set_break_points_request_type] = (conn, params) -> set_break_points_request(conn, state, params)
            msg_dispatcher[set_exception_break_points_request_type] = (conn, params) -> set_exception_break_points_request(conn, state, params)
            msg_dispatcher[set_function_exception_break_points_request_type] = (conn, params) -> set_function_break_points_request(conn, state, params)
            msg_dispatcher[stack_trace_request_type] = (conn, params) -> stack_trace_request(conn, state, params)
            msg_dispatcher[scopes_request_type] = (conn, params) -> scopes_request(conn, state, params)
            msg_dispatcher[source_request_type] = (conn, params) -> source_request(conn, state, params)
            msg_dispatcher[variables_request_type] = (conn, params) -> variables_request(conn, state, params)
            msg_dispatcher[continue_request_type] = (conn, params) -> continue_request(conn, state, params)
            msg_dispatcher[next_request_type] = (conn, params) -> next_request(conn, state, params)
            msg_dispatcher[step_in_request_type] = (conn, params) -> setp_in_request(conn, state, params)
            msg_dispatcher[step_in_targets_request_type] = (conn, params) -> step_in_targets_request(conn, state, params)
            msg_dispatcher[step_out_request_type] = (conn, params) -> setp_out_request(conn, state, params)
            msg_dispatcher[evaluate_request_type] = (conn, params) -> evaluate_request(conn, state, params)
            msg_dispatcher[terminate_request_type] = (conn, params) -> terminate_request(conn, state, params)
            msg_dispatcher[exception_info_request_type] = (conn, params) -> exception_info_request(conn, state, params)
            msg_dispatcher[restart_frame_request_type] = (conn, params) -> restart_frame_request(conn, state, params)
            msg_dispatcher[set_variable_request_type] = (conn, params) -> set_variable_request(conn, state, params)
            msg_dispatcher[threads_request_type] = (conn, params) -> threads_request(conn, state, params)
            msg_dispatcher[breakpointslocation_request_type] = (conn, params) -> breakpointlocations_request(conn, state, params)
            msg_dispatcher[set_compiled_items_notification_type] = (conn, params) -> set_compiled_items_request(conn, state, params)
            msg_dispatcher[set_compiled_mode_notification_type] = (conn, params) -> set_compiled_mode_request(conn, state, params)

            @async try
                for msg in endpoint
                    JSONRPC.dispatch_msg(endpoint, msg_dispatcher, msg)
                end
            catch err
                if error_handler === nothing
                    Base.display_error(err, catch_backtrace())
                else
                    error_handler(err, Base.catch_backtrace())
                end
            end

            while true
                msg = take!(state.next_cmd)

                ret = nothing

                if msg.cmd == :run
                    try
                        Main.include(msg.program)
                    catch err
                        Base.display_error(stderr, err, catch_backtrace())
                    end

                    JSONRPC.send(endpoint, finished_notification_type, nothing)
                    break
                elseif msg.cmd == :stop
                    break
                elseif msg.cmd == :set_source_path
                    task_local_storage()[:SOURCE_PATH] = msg.source_path
                else
                    if msg.cmd == :continue
                        ret = our_debug_command(:c, state)
                    elseif msg.cmd == :next
                        ret = our_debug_command(:n, state)
                    elseif msg.cmd == :stepIn
                        if msg.targetId === missing
                            ret = our_debug_command(:s, state)
                        else
                            itr = 0
                            success = true
                            while state.frame.pc < msg.targetId
                                ret = our_debug_command(:nc, state)
                                if ret isa JuliaInterpreter.BreakpointRef
                                    success = false
                                    break
                                end
                                itr += 1
                                if itr > 100
                                    success = false
                                    @warn "Could not step into sepcified target."
                                    break
                                end
                            end

                            if success
                                ret = our_debug_command(:s, state)
                            end
                        end
                    elseif msg.cmd == :stepOut
                        ret = our_debug_command(:finish, state)
                    end

                    if ret === nothing
                        JSONRPC.send(endpoint, finished_notification_type, nothing)
                        state.debug_mode == :launch && break
                    else
                        send_stopped_msg(endpoint, ret, state)
                    end
                end
            end

            @debug "Finished debugging"
        finally
            close(socket)
        end
    catch err
        if error_handler === nothing
            rethrow(err)
        else
            error_handler(err, Base.catch_backtrace())
        end
    end
end
