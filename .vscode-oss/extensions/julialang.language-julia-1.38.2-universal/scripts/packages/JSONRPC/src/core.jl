struct JSONRPCError <: Exception
    code::Int
    msg::AbstractString
    data::Any
end

function Base.showerror(io::IO, ex::JSONRPCError)
    error_code_as_string = if ex.code == -32700
        "ParseError"
    elseif ex.code == -32600
        "InvalidRequest"
    elseif ex.code == -32601
        "MethodNotFound"
    elseif ex.code == -32602
        "InvalidParams"
    elseif ex.code == -32603
        "InternalError"
    elseif ex.code == -32099
        "serverErrorStart"
    elseif ex.code == -32000
        "serverErrorEnd"
    elseif ex.code == -32002
        "ServerNotInitialized"
    elseif ex.code == -32001
        "UnknownErrorCode"
    elseif ex.code == -32800
        "RequestCancelled"
	elseif ex.code == -32801
        "ContentModified"
    else
        "Unkonwn"
    end

    print(io, error_code_as_string)
    print(io, ": ")
    print(io, ex.msg)
    if ex.data !== nothing
        print(io, " (")
        print(io, ex.data)
        print(io, ")")
    end
end

mutable struct JSONRPCEndpoint{IOIn <: IO,IOOut <: IO}
    pipe_in::IOIn
    pipe_out::IOOut

    out_msg_queue::Channel{Any}
    in_msg_queue::Channel{Any}

    outstanding_requests::Dict{String,Channel{Any}}

    err_handler::Union{Nothing,Function}

    status::Symbol

    read_task::Union{Nothing,Task}
    write_task::Union{Nothing,Task}
end

JSONRPCEndpoint(pipe_in, pipe_out, err_handler = nothing) =
    JSONRPCEndpoint(pipe_in, pipe_out, Channel{Any}(Inf), Channel{Any}(Inf), Dict{String,Channel{Any}}(), err_handler, :idle, nothing, nothing)

function write_transport_layer(stream, response)
    response_utf8 = transcode(UInt8, response)
    n = length(response_utf8)
    write(stream, "Content-Length: $n\r\n\r\n")
    write(stream, response_utf8)
    flush(stream)
end

function read_transport_layer(stream)
    header_dict = Dict{String,String}()
    line = chomp(readline(stream))
    # Check whether the socket was closed
    if line == ""
        return nothing
    end
    while length(line) > 0
        h_parts = split(line, ":")
        header_dict[chomp(h_parts[1])] = chomp(h_parts[2])
        line = chomp(readline(stream))
    end
    message_length = parse(Int, header_dict["Content-Length"])
    message_str = String(read(stream, message_length))
    return message_str
end

Base.isopen(x::JSONRPCEndpoint) = x.status != :closed && isopen(x.pipe_in) && isopen(x.pipe_out)

function Base.run(x::JSONRPCEndpoint)
    x.status == :idle || error("Endpoint is not idle.")

    x.write_task = @async try
        try
            for msg in x.out_msg_queue
                if isopen(x.pipe_out)
                    write_transport_layer(x.pipe_out, msg)
                else
                    # TODO Reconsider at some point whether this should be treated as an error.
                    break
                end
            end
        finally
            close(x.out_msg_queue)
        end
    catch err
        bt = catch_backtrace()
        if x.err_handler !== nothing
            x.err_handler(err, bt)
        else
            Base.display_error(stderr, err, bt)
        end
    end

    x.read_task = @async try
        try
            while true
                message = read_transport_layer(x.pipe_in)

                if message === nothing || x.status == :closed
                    break
                end

                message_dict = JSON.parse(message)

                if haskey(message_dict, "method")
                    try
                        put!(x.in_msg_queue, message_dict)
                    catch err
                        if err isa InvalidStateException
                            break
                        else
                            rethrow(err)
                        end
                    end
                else
                    # This must be a response
                    id_of_request = message_dict["id"]

                    channel_for_response = x.outstanding_requests[id_of_request]
                    put!(channel_for_response, message_dict)
                end
            end
        finally
            close(x.in_msg_queue)
        end
    catch err
        bt = catch_backtrace()
        if x.err_handler !== nothing
            x.err_handler(err, bt)
        else
            Base.display_error(stderr, err, bt)
        end
    end

    x.status = :running
end

function send_notification(x::JSONRPCEndpoint, method::AbstractString, params)
    check_dead_endpoint!(x)

    message = Dict("jsonrpc" => "2.0", "method" => method, "params" => params)

    message_json = JSON.json(message)

    put!(x.out_msg_queue, message_json)

    return nothing
end

function send_request(x::JSONRPCEndpoint, method::AbstractString, params)
    check_dead_endpoint!(x)

    id = string(UUIDs.uuid4())
    message = Dict("jsonrpc" => "2.0", "method" => method, "params" => params, "id" => id)

    response_channel = Channel{Any}(1)
    x.outstanding_requests[id] = response_channel

    message_json = JSON.json(message)

    put!(x.out_msg_queue, message_json)

    response = take!(response_channel)

    if haskey(response, "result")
        return response["result"]
    elseif haskey(response, "error")
        error_code = response["error"]["code"]
        error_msg = response["error"]["message"]
        error_data = get(response["error"], "data", nothing)
        throw(JSONRPCError(error_code, error_msg, error_data))
    else
        throw(JSONRPCError(0, "ERROR AT THE TRANSPORT LEVEL", nothing))
    end
end

function get_next_message(endpoint::JSONRPCEndpoint)
    check_dead_endpoint!(endpoint)

    msg = take!(endpoint.in_msg_queue)

    return msg
end

function Base.iterate(endpoint::JSONRPCEndpoint, state = nothing)
    check_dead_endpoint!(endpoint)

    try
        return take!(endpoint.in_msg_queue), nothing
    catch err
        if err isa InvalidStateException
            return nothing
        else
            rethrow(err)
        end
    end
end

function send_success_response(endpoint, original_request, result)
    check_dead_endpoint!(endpoint)

    response = Dict("jsonrpc" => "2.0", "id" => original_request["id"], "result" => result)

    response_json = JSON.json(response)

    put!(endpoint.out_msg_queue, response_json)
end

function send_error_response(endpoint, original_request, code, message, data)
    check_dead_endpoint!(endpoint)

    response = Dict("jsonrpc" => "2.0", "id" => original_request["id"], "error" => Dict("code" => code, "message" => message, "data" => data))

    response_json = JSON.json(response)

    put!(endpoint.out_msg_queue, response_json)
end

function Base.close(endpoint::JSONRPCEndpoint)
    flush(endpoint)

    endpoint.status = :closed
    isopen(endpoint.in_msg_queue) && close(endpoint.in_msg_queue)
    isopen(endpoint.out_msg_queue) && close(endpoint.out_msg_queue)

    fetch(endpoint.write_task)
    # TODO we would also like to close the read Task
    # But unclear how to do that without also closing
    # the socket, which we don't want to do
    # fetch(endpoint.read_task)
end

function Base.flush(endpoint::JSONRPCEndpoint)
    check_dead_endpoint!(endpoint)

    while isready(endpoint.out_msg_queue)
        yield()
    end
end

function check_dead_endpoint!(endpoint)
    status = endpoint.status
    status === :running && return
    error("Endpoint is not running, the current state is $(status).")
end
