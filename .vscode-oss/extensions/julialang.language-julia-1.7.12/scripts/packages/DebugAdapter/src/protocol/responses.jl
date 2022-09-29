@dict_readable struct ErrorResponseArguments <: Outbound
    error::Union{Missing,Message}
end

@dict_readable struct RunInTerminalResponseArguments <: Outbound
    processId::Union{Missing,Int}
    shellProcessId::Union{Missing,Int}
end

@dict_readable struct InitializeResponseArguments <: Outbound
end

@dict_readable struct ConfigurationDoneResponseArguments <: Outbound
end

@dict_readable struct LaunchResponseArguments <: Outbound
end

@dict_readable struct AttachResponseArguments <: Outbound
end

@dict_readable struct RestartResponseArguments <: Outbound
end

@dict_readable struct DisconnectResponseArguments <: Outbound
end

@dict_readable struct TerminateResponseArguments <: Outbound
end

@dict_readable struct SetBreakpointsResponseArguments <: Outbound
    breakpoints::Vector{Breakpoint}
end

@dict_readable struct SetFunctionBreakpointsResponseArguments <: Outbound
    breakpoints::Vector{Breakpoint}
end

@dict_readable struct SetExceptionBreakpointsResponseArguments <: Outbound
    filters::Vector{String}
    exceptionOptions::Union{Missing,Vector{ExceptionOptions}}
end

@dict_readable struct DataBreakpointInfoResponseArguments <: Outbound
    data::Union{Missing,String}
    description::String
    accessTypes::Union{Missing,Vector{DataBreakpointAccessType}}
    canPersist::Union{Missing,Bool}
end

@dict_readable struct SetDataBreakpointsResponseArguments <: Outbound
    breakpoints::Vector{Breakpoint}
end

@dict_readable struct ContinueResponseArguments <: Outbound
    allThreadsContinued::Union{Missing,Bool}
end

@dict_readable struct NextResponseArguments <: Outbound
end

@dict_readable struct StepInResponseArguments <: Outbound
end

@dict_readable struct StepOutResponseArguments <: Outbound
end

@dict_readable struct StepBackResponseArguments <: Outbound
end

@dict_readable struct ReverseContinueResponseArguments <: Outbound
end

@dict_readable struct RestartFrameResponseResponseArguments <: Outbound
end

@dict_readable struct GotoResponseArguments <: Outbound
end

@dict_readable struct PauseResponseArguments <: Outbound
end

@dict_readable struct StackTraceResponseArguments <: Outbound
    stackFrames::Vector{StackFrame}
    totalFrames::Union{Missing,Int}
end

@dict_readable struct ScopesResponseArguments <: Outbound
    scopes::Vector{Scope}
end

@dict_readable struct VariablesResponseArguments <: Outbound
    variables::Vector{Variable}
end

@dict_readable struct SetVariableResponseArguments <: Outbound
    value::String
    type::Union{Missing,String}
    variablesReference::Union{Missing,Int}
    namedVariables::Union{Missing,Int}
    indexedVariables::Union{Missing,Int64}
end

@dict_readable struct SourceResponseArguments <: Outbound
    content::String
    mimeType::Union{Missing,String}
end

@dict_readable struct ThreadsResponseArguments <: Outbound
    threads::Vector{Thread}
end

@dict_readable struct TerminateThreadsResponseArguments <: Outbound
end

@dict_readable struct ModulesResponseArguments <: Outbound
    startModule::Union{Missing,Int}
    moduleCount::Union{Missing,Int}
end

@dict_readable struct LoadedSourcesResponseArguments <: Outbound
    sources::Vector{Source}
end

@dict_readable struct EvaluateResponseArguments <: Outbound
    result::String
    type::Union{Missing,String}
    presentationHint::Union{Missing,VariablePresentationHint}
    variablesReference::Int
    namedVariables::Union{Missing,Int}
    indexedVariables::Union{Missing,Int64}
    memoryReference::Union{Missing,String}
end

@dict_readable struct SetExpressionResponseArguments <: Outbound
    value::String
    type::Union{Missing,String}
    presentationHint::Union{Missing,VariablePresentationHint}
    variablesReference::Int
    namedVariables::Union{Missing,Int}
    indexedVariables::Union{Missing,Int64}
end

@dict_readable struct StepInTargetsResponseArguments <: Outbound
    targets::Vector{StepInTarget}
end

@dict_readable struct GotoTargetsResponseArguments <: Outbound
    targets::Vector{GotoTarget}
end

@dict_readable struct CompletionsResponseArguments <: Outbound
    targets::Vector{CompletionItem}
end

@dict_readable struct ExceptionInfoResponseArguments <: Outbound
    exceptionId::String
    description::Union{Missing,String}
    breakMode::ExceptionBreakMode
    details::Union{Missing,ExceptionDetails}
end

@dict_readable struct ReadMemoryResponseArguments <: Outbound
    address::String
    unreadableBytes::Union{Missing,Int}
    data::Union{Missing,String}
end

@dict_readable struct DisassembleResponseArguments <: Outbound
    instructions::Union{Missing,DisassembledInstruction}
end
