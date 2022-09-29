const disconnect_request_type = JSONRPC.RequestType("disconnect", DisconnectArguments, DisconnectResponseArguments)
const set_break_points_request_type = JSONRPC.RequestType("setBreakpoints", SetBreakpointsArguments, SetBreakpointsResponseArguments)
const set_exception_break_points_request_type = JSONRPC.RequestType("setExceptionBreakpoints", SetExceptionBreakpointsArguments, SetExceptionBreakpointsResponseArguments)
const set_function_exception_break_points_request_type = JSONRPC.RequestType("setFunctionBreakpoints", SetFunctionBreakpointsArguments, SetFunctionBreakpointsResponseArguments)
const stack_trace_request_type = JSONRPC.RequestType("stackTrace", StackTraceArguments, StackTraceResponseArguments)
const scopes_request_type = JSONRPC.RequestType("scopes", ScopesArguments, ScopesResponseArguments)
const source_request_type = JSONRPC.RequestType("source", SourceArguments, SourceResponseArguments)
const variables_request_type = JSONRPC.RequestType("variables", VariablesArguments, VariablesResponseArguments)
const continue_request_type = JSONRPC.RequestType("continue", ContinueArguments, ContinueResponseArguments)
const next_request_type = JSONRPC.RequestType("next", NextArguments, NextResponseArguments)
const step_in_request_type = JSONRPC.RequestType("stepIn", StepInArguments, StepInResponseArguments)
const step_in_targets_request_type = JSONRPC.RequestType("stepInTargets", StepInTargetsArguments, StepInTargetsResponseArguments)
const step_out_request_type = JSONRPC.RequestType("stepOut", StepOutArguments, StepOutResponseArguments)
const evaluate_request_type = JSONRPC.RequestType("evaluate", EvaluateArguments, EvaluateResponseArguments)
const terminate_request_type = JSONRPC.RequestType("terminate", TerminateArguments, TerminateResponseArguments)
const exception_info_request_type = JSONRPC.RequestType("exceptionInfo", ExceptionInfoArguments, ExceptionInfoResponseArguments)
const restart_frame_request_type = JSONRPC.RequestType("restartFrame", RestartFrameArguments, RestartFrameResponseResponseArguments)
const set_variable_request_type = JSONRPC.RequestType("setVariable", SetVariableArguments, SetVariableResponseArguments)
const stopped_notification_type = JSONRPC.NotificationType("stopped", StoppedEventArguments)
const threads_request_type = JSONRPC.RequestType("threads", Nothing, ThreadsResponseArguments)
const breakpointslocation_request_type = JSONRPC.RequestType("breakpointLocations", BreakpointLocationsArguments, BreakpointLocationsResponseArguments)

@dict_readable struct DebugArguments <: Outbound
    stopOnEntry::Bool
    program::String
    compiledModulesOrFunctions::Union{Missing,Vector{String}}
    compiledMode::Union{Missing,Bool}
end

@dict_readable struct ExecArguments <: Outbound
    stopOnEntry::Bool
    code::String
    file::String
    compiledModulesOrFunctions::Union{Missing,Vector{String}}
    compiledMode::Union{Missing,Bool}
end

# Our own requests
const run_notification_type = JSONRPC.NotificationType("run", NamedTuple{(:program,),Tuple{String}})
const debug_notification_type = JSONRPC.NotificationType("debug", DebugArguments)
const exec_notification_type = JSONRPC.NotificationType("exec", ExecArguments)
const finished_notification_type = JSONRPC.NotificationType("finished", Nothing)
const set_compiled_items_notification_type = JSONRPC.NotificationType("setCompiledItems", NamedTuple{(:compiledModulesOrFunctions,),Tuple{Vector{String}}})
const set_compiled_mode_notification_type = JSONRPC.NotificationType("setCompiledMode", NamedTuple{(:compiledMode,),Tuple{Bool}})
