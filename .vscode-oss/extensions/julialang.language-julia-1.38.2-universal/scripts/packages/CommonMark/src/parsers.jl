import Base: peek

abstract type AbstractParser end
# .buf, .pos, .len must exist.

Base.String(p::AbstractParser) = String(p.buf)
Base.position(p::AbstractParser) = p.pos
Base.length(p::AbstractParser) = p.len
Base.eof(p::AbstractParser) = position(p) > length(p)
Base.seek(p::AbstractParser, pos) = p.pos = pos
Base.seekstart(p::AbstractParser) = p.pos = 1

Base.peek(p::AbstractParser, ::Type{UInt8}) = p.buf[position(p)]
Base.peek(p::AbstractParser, ::Type{Char}) = String(p.buf)[position(p)]

trypeek(p::AbstractParser, ::Type{UInt8}, default=nothing) = get(p.buf, position(p), default)
trypeek(p::AbstractParser, ::Type{Char}, default=nothing) = get(String(p.buf), thisind(p), default) # TODO thisind

function Base.read(p::AbstractParser, ::Type{T}) where {T<:Union{Char,UInt8}}
    obj = peek(p, T)
    seek(p, nextind(p))
    return obj
end

rest(p::AbstractParser) = SubString(String(p), thisind(p)) # TODO thisind, ALLOCATES lots.

buffer(p::AbstractParser) = _buffer(p.buf)
_buffer(s::AbstractString) = codeunits(s)
_buffer(other) = other

bytes(p::AbstractParser, from, to) = view(buffer(p), from:to)

or(value, default) = value
or(::Nothing, default) = default

prev(p::AbstractParser, ::Type{Char}) = String(p.buf)[prevind(p)]
next(p::AbstractParser, ::Type{Char}) = String(p.buf)[nextind(p)]

prev(p::AbstractParser, ::Type{UInt8}) = p.buf[position(p) - 1]
next(p::AbstractParser, ::Type{UInt8}) = p.buf[position(p) + 1]

tryprev(p::AbstractParser, ::Type{Char}, default=nothing) = get(String(p.buf), prevind(p), default)
trynext(p::AbstractParser, ::Type{Char}, default=nothing) = get(String(p.buf), nextind(p), default)

tryprev(p::AbstractParser, ::Type{UInt8}, default=nothing) = get(p.buf, position(p) - 1, default)
trynext(p::AbstractParser, ::Type{UInt8}, default=nothing) = get(p.buf, position(p) + 1, default)

Base.prevind(p::AbstractParser) = prevind(String(p), position(p))
Base.thisind(p::AbstractParser) = thisind(String(p), position(p))
Base.nextind(p::AbstractParser) = nextind(String(p), position(p))

Base.findnext(f::Function, p::AbstractParser) = findnext(f, String(p), position(p))
Base.findprev(f::Function, p::AbstractParser) = findprev(f, String(p), position(p))

Base.startswith(p::AbstractParser, prefix) = startswith(rest(p), prefix)
Base.occursin(pat, p::AbstractParser) = occursin(pat, rest(p))

Base.match(re::Regex, p::AbstractParser) = match(re, rest(p))

function consume(parser::AbstractParser, m::RegexMatch)
    parser.pos += (m.offset - 1) + m.match.ncodeunits
    return m
end
consume(p::AbstractParser, n::Nothing) = n

function consume(p::AbstractParser, index::Integer)
    seek(p, index)
    seek(p, nextind(p))
    return index
end

dispatch(p::AbstractParser, args...) = dispatch(p.table, args...)

include("parsers/rules.jl")
include("parsers/inlines.jl")
include("parsers/blocks.jl")
