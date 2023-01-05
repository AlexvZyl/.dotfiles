const ChecksumAlgorithm = String

@dict_readable struct ExceptionBreakpointsFilter <: Outbound
    filter::String
    label::String
    default::Union{Missing,Bool}
end

@dict_readable struct ColumnDescriptor <: Outbound
    attributeName::String
    label::String
    format::Union{Missing,String}
    type::Union{Missing,String} # default: "string"
    width::Union{Missing,Int}
end

@dict_readable struct Capabilities <: Outbound
    supportsConfigurationDoneRequest::Union{Missing,Bool}
    supportsFunctionBreakpoints::Union{Missing,Bool}
    supportsConditionalBreakpoints::Union{Missing,Bool}
    supportsHitConditionalBreakpoints::Union{Missing,Bool}
    supportsEvaluateForHovers::Union{Missing,Bool}
    exceptionBreakpointFilters::Vector{ExceptionBreakpointsFilter}
    supportsStepBack::Union{Missing,Bool}
    supportsSetVariable::Union{Missing,Bool}
    supportsRestartFrame::Union{Missing,Bool}
    supportsGotoTargetsRequest::Union{Missing,Bool}
    supportsStepInTargetsRequest::Union{Missing,Bool}
    supportsCompletionsRequest::Union{Missing,Bool}
    supportsModulesRequest::Union{Missing,Bool}
    additionalModuleColumns::Vector{ColumnDescriptor}
    supportedChecksumAlgorithms::Vector{ChecksumAlgorithm}
    supportsRestartRequest::Union{Missing,Bool}
    supportsExceptionOptions::Union{Missing,Bool}
    supportsValueFormattingOptions::Union{Missing,Bool}
    supportsExceptionInfoRequest::Union{Missing,Bool}
    supportTerminateDebuggee::Union{Missing,Bool}
    supportsDelayedStackTraceLoading::Union{Missing,Bool}
    supportsLoadedSourcesRequest::Union{Missing,Bool}
    supportsLogPoints::Union{Missing,Bool}
    supportsTerminateThreadsRequest::Union{Missing,Bool}
    supportsSetExpression::Union{Missing,Bool}
    supportsTerminateRequest::Union{Missing,Bool}
    supportsDataBreakpoints::Union{Missing,Bool}
    supportsReadMemoryRequest::Union{Missing,Bool}
    supportsDisassembleRequest::Union{Missing,Bool}
end

@dict_readable struct Message <: Outbound
    id::Int
    format::String
    variables::Union{Missing,Dict{String,String}}
    sendTelemetry::Union{Missing,Bool}
    showUser::Union{Missing,Bool}
    url::Union{Missing,String}
    urlLabel::Union{Missing,String}
end

@dict_readable struct DAModule <: Outbound
    id::Union{Int,String}
    name::String
    path::Union{Missing,String}
    isOptimized::Union{Missing,Bool}
    isUserCode::Union{Missing,Bool}
    version::Union{Missing,String}
    symbolStatus::Union{Missing,String}
    dateTimeStamp::Union{Missing,String}
    addressRange::Union{Missing,String}
end

@dict_readable struct ModulesViewDescriptor <: Outbound
    columns::Vector{ColumnDescriptor}
end

@dict_readable struct Thread <: Outbound
    id::Int
    name::String
end

@dict_readable struct Checksum <: Outbound
    algorithm::ChecksumAlgorithm
    checksum::String
end

@dict_readable struct Source <: Outbound
    name::Union{Missing,String}
    path::Union{Missing,String}
    sourceReference::Union{Missing,Int}
    presentationHint::Union{Missing,String}
    origin::Union{Missing,String}
    sources::Union{Missing,Vector{Source}}
    adapterData::Union{Missing,Any}
    checksums::Union{Missing,Vector{Checksum}}
end

@dict_readable struct StackFrame <: Outbound
    id::Int
    name::String
    source::Union{Missing,Source}
    line::Int
    column::Int
    endLine::Union{Missing,Int}
    endColum::Union{Missing,Int}
    instructionPointerReference::Union{Missing,String}
    moduleId::Union{Missing,Int,String}
    presentationHint::Union{Missing,String}
end

@dict_readable struct Scope <: Outbound
    name::String
    presentationHint::Union{Missing,String}
    variablesReference::Int
    namedVariables::Union{Missing,Int}
    indexedVariables::Union{Missing,Int64}
    expensive::Bool
    source::Union{Missing,Source}
    line::Union{Missing,Int}
    column::Union{Missing,Int}
    endLine::Union{Missing,Int}
    endColum::Union{Missing,Int}
end

@dict_readable struct VariablePresentationHint <: Outbound
    kind::Union{Missing,String}
    attributes::Union{Missing,Vector{String}}
    visibility::Union{Missing,String}
end

@dict_readable struct Variable <: Outbound
    name::String
    value::String
    type::Union{Missing,String}
    presentatonHint::Union{Missing,VariablePresentationHint}
    evaluateName::Union{Missing,String}
    variablesReference::Int
    namedVariables::Union{Missing,Int}
    indexedVariables::Union{Missing,Int64}
    memoryReference::Union{Missing,String}
end


@dict_readable struct SourceBreakpoint <: Outbound
    line::Int
    column::Union{Missing,Int}
    condition::Union{Missing,String}
    hitCondition::Union{Missing,String}
    logMessage::Union{Missing,String}
end

@dict_readable struct FunctionBreakpoint <: Outbound
    name::String
    condition::Union{Missing,String}
    hitCondition::Union{Missing,String}
end

const DataBreakpointAccessType = String

@dict_readable struct DataBreakpoint <: Outbound
    dataId::String
    accessType::Union{Missing,DataBreakpointAccessType}
    condition::Union{Missing,String}
    hitCondition::Union{Missing,String}
end

@dict_readable struct Breakpoint <: Outbound
    id::Union{Missing,Int}
    verified::Bool
    message::Union{Missing,String}
    source::Union{Missing,Source}
    line::Union{Missing,Int}
    column::Union{Missing,Int}
    endLine::Union{Missing,Int}
    endColumn::Union{Missing,Int}
end

function Breakpoint(verified::Bool)
    return Breakpoint(
        missing,
        verified,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing
    )
end


@dict_readable struct StepInTarget <: Outbound
    id::Int
    label::String
end

@dict_readable struct GotoTarget <: Outbound
    id::Int
    label::String
    line::Int
    column::Union{Missing,Int}
    endLine::Union{Missing,Int}
    endColumn::Union{Missing,Int}
    instructionPointerReference::Union{Missing,String}
end

const CompletionItemType = String

@dict_readable struct CompletionItem <: Outbound
    label::String
    text::Union{Missing,String}
    type::CompletionItemType
    start::Union{Missing,Int}
    length::Union{Missing,Int}
end

@dict_readable struct ValueFormat <: Outbound
    hex::Union{Missing,Bool}
end

@dict_readable struct StackFrameFormat <: Outbound
    parameters::Union{Missing,Bool}
    parameterTypes::Union{Missing,Bool}
    parameterNames::Union{Missing,Bool}
    parameterValues::Union{Missing,Bool}
    line::Union{Missing,Bool}
    # module::Union{Missing,Bool}
    includeAll::Union{Missing,Bool}
end


const ExceptionBreakMode = String
ExceptionBreakModes = ["never", "always", "unhandled", "userUnhandled"]

@dict_readable struct ExceptionPathSegment <: Outbound
    negate::Union{Missing,Bool}
    names::Vector{String}
end

@dict_readable struct ExceptionOptions <: Outbound
    path::Union{Missing,Vector{ExceptionPathSegment}}
    breakMode::ExceptionBreakMode
end

@dict_readable struct ExceptionDetails <: Outbound
    message::Union{Missing,String}
    typeName::Union{Missing,String}
    fullTypeName::Union{Missing,String}
    evaluateName::Union{Missing,String}
    stackTrace::Union{Missing,String}
    innerException::Union{Missing,Vector{ExceptionDetails}}
end

@dict_readable struct DisassembledInstruction <: Outbound
    address::String
    instructionBytes::Union{Missing,String}
    instruction::String
    symbol::Union{Missing,String}
    location::Union{Missing,Source}
    line::Union{Missing,Int}
    column::Union{Missing,Int}
    endLine::Union{Missing,Int}
    endColumn::Union{Missing,Int}
end

@dict_readable struct BreakpointLocation <: Outbound
    line::Int
    column::Union{Missing,Int}
    endLine::Union{Missing,Int}
    endColumn::Union{Missing,Int}
end
