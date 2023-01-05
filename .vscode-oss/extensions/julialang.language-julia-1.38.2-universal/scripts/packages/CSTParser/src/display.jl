function Base.show(io::IO, x::EXPR, offset = 0, d = 0, er = false)
    T = headof(x)
    c =  T === :errortoken || er ? :red : :normal
    # Print span as 1-based range of the source string. This presentation is
    # simple to understand when strings are presented to CSTParser.parse().
    print(io, lpad(offset + 1, 3), ":", rpad(offset + x.fullspan, 3), " ")
    if isidentifier(x)
        printstyled(io, " "^d, headof(x) == :NONSTDIDENTIFIER ? valof(x.args[2]) : valof(x), color = :yellow)
        x.meta !== nothing && show(io, x.meta)
        print(io)
    elseif isoperator(x)
        printstyled(io, " "^d, "OP: ", valof(x), color = c)
    elseif iskeyword(x)
        printstyled(io, " "^d, headof(x), color = :magenta)
    elseif ispunctuation(x)
        printstyled(io, " "^d, punctuationprinting[headof(x)], color = c)
    elseif isliteral(x)
        printstyled(io, " "^d, "$(headof(x)): ", valof(x) === nothing ? "nothing" : valof(x), color = c)
    else
        printstyled(io, " "^d, T, color=c)
        if x.meta !== nothing
            print(io, "( ")
            show(io, x.meta)
            print(io, ")")
        end
        x.args === nothing && return
        for a in x.args
            println(io)
            show(io, a, offset, d + 1, er)
            offset += a.fullspan
        end
    end
end

const punctuationprinting = Dict(
    :COMMA => ",",
    :LPAREN => "(",
    :RPAREN => ")",
    :LSQUARE => "[",
    :RSQUARE => "]",
    :LBRACE => "{",
    :RBRACE => "}",
    :ATSIGN => "@",
    :DOT => "."
)

struct CSTInfiniteLoop <: Exception
    msg::AbstractString
end

function Base.showerror(io::IO, ex::CSTInfiniteLoop)
    print(io, ex.msg)
end
