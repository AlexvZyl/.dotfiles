function lowercase_drive(a)
    if length(a) >= 2 && a[2] == ':'
        return lowercase(a[1]) * a[2:end]
    else
        return a
    end
end

const SRC_DIR = joinpath(Sys.BINDIR, "..", "..", "base")
const RELEASE_DIR = joinpath(Sys.BINDIR, "..", "share", "julia", "base")
basepath(file) = normpath(joinpath((@static isdir(SRC_DIR) ? SRC_DIR : RELEASE_DIR), file))

maybe_quote(x) = (isa(x, Expr) || isa(x, Symbol)) ? QuoteNode(x) : x

# all calls in the current frame and the same "line"
calls_on_line(state, args...) = calls_on_line(state.frame, args...)
calls_on_line(::Nothing, args...) = []
function calls_on_line(frame::JuliaInterpreter.Frame, line=nothing)
    if line === nothing
        loc = JuliaInterpreter.whereis(frame)
        if loc === nothing
            return []
        end
        line = loc[2]
    end

    src = frame.framecode.src

    exprs = []
    for pc in frame.pc:length(src.codelocs)
        loc = JuliaInterpreter.whereis(frame, pc)

        if loc === nothing || loc[2] > line
            return exprs
        end

        expr = JuliaInterpreter.pc_expr(src, pc)
        if Meta.isexpr(expr, :call)
            new_expr = Expr(:call)
            for arg in expr.args
                push!(new_expr.args, maybe_quote(arg))
            end
            push!(exprs, (pc = pc, expr = string("%", pc, " = ", prettyprint_expr(new_expr, src))))
        elseif Meta.isexpr(expr, :(=))
            push!(exprs, (pc = pc, expr = prettyprint_expr(expr.args[2], src)))
        end
    end

    return exprs
end

function prettyprint_expr(expr, src)
    io = IOBuffer()
    prettyprint_expr(io, expr, src)
    return String(take!(io))
end

function prettyprint_expr(io, expr, src)
    if Meta.isexpr(expr, :call)
        for (i, ex) in enumerate(expr.args)
            if ex isa QuoteNode
                print(io, ex.value)
            elseif ex isa JuliaInterpreter.SlotNumber || ex isa Core.SlotNumber
                print(io, src.slotnames[ex.id])
            elseif ex isa JuliaInterpreter.SSAValue || ex isa Core.SSAValue
                print(io, '%', ex.id)
            else
                prettyprint_expr(io, ex, src)
            end
            if i == 1
                print(io, '(')
            elseif i == length(expr.args)
                print(io, ')')
            else
                print(io, ", ")
            end
        end
    else
        show(io, expr)
    end
end

# all calls in the current frame after (and including) the current pc
calls_in_frame(state) = calls_in_frame(state.frame)
calls_in_frame(::Nothing) = []
function calls_in_frame(frame::JuliaInterpreter.Frame)
    exprs = []
    for pc in frame.pc:length(frame.framecode.src.codelocs)
        expr = JuliaInterpreter.pc_expr(frame, pc)
        if Meta.isexpr(expr, :call)
            push!(exprs, (pc = pc, expr = expr))
        elseif Meta.isexpr(expr, :(=))
            expr = expr.args[2]
            push!(exprs, (pc = pc, expr = expr))
        end
    end
    exprs
end

mutable struct LimitIO{IO_t<:IO} <: IO
    io::IO_t
    maxbytes::Int
    n::Int
end
LimitIO(io::IO, maxbytes) = LimitIO(io, maxbytes, 0)

struct LimitIOException <: Exception end

function Base.write(io::LimitIO, v::UInt8)
    io.n > io.maxbytes && throw(LimitIOException())
    io.n += write(io.io, v)
end

function remove_ansi_control_chars(str::String)
    replace(str, r"(\x9B|\x1B\[)[0-?]*[ -\/]*[@-~]" => "")
end

function sprintlimited(args...; func = show, limit::Int = 1000, ellipsis::AbstractString = "…", color = false)
    io = IOBuffer()
    ioctx = IOContext(LimitIO(io, limit - length(ellipsis)), :limit => true, :color => color, :displaysize => (30, 64))

    try
        Base.invokelatest(func, ioctx, args...)
    catch err
        if err isa LimitIOException
            print(io, ellipsis)
        else
            rethrow(err)
        end
    end

    str = filter(isvalid, String(take!(io)))

    return color ? str : remove_ansi_control_chars(str)
end
