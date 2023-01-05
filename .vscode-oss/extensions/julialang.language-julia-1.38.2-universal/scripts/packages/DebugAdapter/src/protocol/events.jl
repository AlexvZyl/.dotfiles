@dict_readable struct InitializedEventArguments <: Outbound
end

@dict_readable struct StoppedEventArguments <: Outbound
    reason::String
    description::Union{Missing,String}
    threadId::Union{Missing,Int}
    preserveFocusHint::Union{Missing,Bool}
    text::Union{Missing,String}
    allThreadsStopped::Union{Missing,Bool}
end

@dict_readable struct ContinuedEventArguments <: Outbound
    threadId::Int
    allThreadsContinued::Union{Missing,Bool}
end

@dict_readable struct ExitedEventArguments <: Outbound
    exitCode::Int
end

@dict_readable struct TerminatedEventArguments <: Outbound
    restart::Union{Missing,Any}
end

@dict_readable struct ThreadEventArguments <: Outbound
    reason::String
    threadId::Int
end

@dict_readable struct OutputEventArguments <: Outbound
    category::Union{Missing,String}
    output::String
    variablesReference::Union{Missing,Int}
    source::Union{Missing,Source}
    line::Union{Missing,Int}
    column::Union{Missing,Int}
    data::Union{Missing,Any}
end

@dict_readable struct BreakpointEventArguments <: Outbound
    reason::String
    breakpont::Breakpoint
end

@dict_readable struct ModuleEventArguments <: Outbound
    reason::String
    mod::DAModule
end

@dict_readable struct LoadedSourceEventArguments <: Outbound
    reason::String
    source::Source
end

@dict_readable struct ProcessEventArguments <: Outbound
    name::String
    systemProcessId::Union{Missing,Int}
    isLocalProcess::Union{Missing,Bool}
    startMethod::Union{Missing,String}
    pointerSize::Union{Missing,Int}
end

@dict_readable struct CapabilitiesEventArguments <: Outbound
    capabilities::Capabilities
end
