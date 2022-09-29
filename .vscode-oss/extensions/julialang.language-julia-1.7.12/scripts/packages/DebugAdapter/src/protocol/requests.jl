@dict_readable struct RunInTerminalRequestArguments <: Outbound
    kind::Union{Missing,String}
    title::Union{Missing,String}
    cwd::String
    args::Vector{String}
    env::Union{Missing,Dict{String,Union{Missing,String}}}
end

@dict_readable struct InitializeRequestArguments <: Outbound
    clientID::Union{Missing,String}
    clientName::Union{Missing,String}
    adapterID::String
    locale::Union{Missing,String}
    linesStartAt1::Union{Missing,Bool}
    columnsStartAt1::Union{Missing,Bool}
    pathFormat::Union{Missing,String}
    supportsVariableType::Union{Missing,Bool}
    supportsVariablePaging::Union{Missing,Bool}
    supportsRunInTerminalRequest::Union{Missing,Bool}
    supportsMemoryReferences::Union{Missing,Bool}
end

@dict_readable struct ConfigurationDoneArguments <: Outbound
end

@dict_readable struct LaunchArguments <: Outbound
    noDebug::Union{Missing,Bool}
    __restart::Any
end

@dict_readable struct AttachArguments <: Outbound
    __restart::Any
end

@dict_readable struct RestartArguments <: Outbound
end

@dict_readable struct DisconnectArguments <: Outbound
    restart::Union{Missing,Bool}
    terminateDebuggee::Union{Missing,Bool}
end

@dict_readable struct TerminateArguments <: Outbound
    restart::Union{Missing,Bool}
end

@dict_readable struct SetBreakpointsArguments <: Outbound
    source::Source
    breakpoints::Union{Missing,Vector{SourceBreakpoint}}
    lines::Union{Missing,Vector{Int}}
    sourceModified::Union{Missing,Bool}
end

@dict_readable struct SetFunctionBreakpointsArguments <: Outbound
    breakpoints::Vector{FunctionBreakpoint}
end

@dict_readable struct SetExceptionBreakpointsArguments <: Outbound
    filters::Vector{String}
    exceptionOptions::Union{Missing,Vector{ExceptionOptions}}
end

@dict_readable struct DataBreakpointInfoArguments <: Outbound
    variableReference::Union{Missing,Int}
    name::String
end

@dict_readable struct SetDataBreakpointsArguments <: Outbound
    breakpoints::Vector{DataBreakpoint}
end

@dict_readable struct ContinueArguments <: Outbound
    threadId::Int
end

@dict_readable struct NextArguments <: Outbound
    threadId::Int
end

@dict_readable struct StepInArguments <: Outbound
    threadId::Int
    targetId::Union{Missing,Int}
end

@dict_readable struct StepOutArguments <: Outbound
    threadId::Int
end

@dict_readable struct StepBackArguments <: Outbound
    threadId::Int
end

@dict_readable struct ReverseContinueArguments <: Outbound
    threadId::Int
end

@dict_readable struct RestartFrameArguments <: Outbound
    frameId::Int
end

@dict_readable struct GotoArguments <: Outbound
    threadId::Int
    targetId::Int
end

@dict_readable struct PauseArguments <: Outbound
    threadId::Int
end

@dict_readable struct StackTraceArguments <: Outbound
    threadId::Int
    startFrame::Union{Missing,Int}
    levels::Union{Missing,Int}
    format::Union{Missing,StackFrameFormat}
end

@dict_readable struct ScopesArguments <: Outbound
    frameId::Int
end

@dict_readable struct VariablesArguments <: Outbound
    variablesReference::Int
    filter::Union{Missing,String}
    start::Union{Missing,Int}
    count::Union{Missing,Int}
    format::Union{Missing,ValueFormat}
end

@dict_readable struct SetVariableArguments <: Outbound
    variablesReference::Int
    name::String
    value::String
    format::Union{Missing,ValueFormat}
end

@dict_readable struct SourceArguments <: Outbound
    source::Union{Missing,Source}
    sourceReference::Int
end

@dict_readable struct TerminateThreadsArguments <: Outbound
    threadIds::Union{Missing,Vector{Int}}
end

@dict_readable struct ModulesArguments <: Outbound
    startModule::Union{Missing,Int}
    moduleCount::Union{Missing,Int}
end

@dict_readable struct LoadedSourcesArguments <: Outbound
end

@dict_readable struct EvaluateArguments <: Outbound
    expression::String
    frameId::Union{Missing,Int}
    context::Union{Missing,String}
    format::Union{Missing,ValueFormat}
end

@dict_readable struct SetExpressionArguments <: Outbound
    expression::String
    value::String
    frameId::Union{Missing,Int}
    format::Union{Missing,ValueFormat}
end

@dict_readable struct StepInTargetsArguments <: Outbound
    frameId::Int
end

@dict_readable struct GotoTargetsArguments <: Outbound
    source::Source
    line::Int
    column::Union{Missing,Int}
end

@dict_readable struct CompletionsArguments <: Outbound
    frameId::Union{Missing,Int}
    text::String
    column::Int
    line::Union{Missing,Int}
end

@dict_readable struct ExceptionInfoArguments <: Outbound
    threadId::Int
end

@dict_readable struct ReadMemoryArguments <: Outbound
    memoryReference::String
    offset::Union{Missing,Int}
    count::Int
end

@dict_readable struct DisassembleArguments <: Outbound
    memoryReference::String
    offset::Union{Missing,Int}
    instructionOffset::Union{Missing,Int}
    instructionCount::Int
    resolveSymbols::Union{Missing,Bool}
end

@dict_readable struct BreakpointLocationsArguments <: Outbound
    source::Source
    line::Int
    column::Union{Missing,Int}
    endLine::Union{Missing,Int}
    endColumn::Union{Missing,Int}
end

@dict_readable struct BreakpointLocationsResponseArguments <: Outbound
    breakpoints::Vector{BreakpointLocation}
end
