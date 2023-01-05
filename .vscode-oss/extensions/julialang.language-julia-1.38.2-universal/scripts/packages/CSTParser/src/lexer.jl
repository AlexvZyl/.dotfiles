const EmptyWS = Tokens.EMPTY_WS
const SemiColonWS = Tokens.SEMICOLON_WS
const NewLineWS = Tokens.NEWLINE_WS
const WS = Tokens.WS
const EmptyWSToken = RawToken(EmptyWS, (0, 0), (0, 0), -1, -1)

mutable struct Closer
    newline::Bool
    semicolon::Bool
    tuple::Bool
    comma::Bool
    paren::Bool
    brace::Bool
    inmacro::Bool
    insquare::Bool
    inref::Bool
    inwhere::Bool
    square::Bool
    block::Bool
    ifop::Bool
    range::Bool
    ws::Bool
    wsop::Bool
    unary::Bool
    for_generator::Bool
    precedence::Int
end
Closer() = Closer(true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, -1)

mutable struct ParseState
    l::Lexer{Base.GenericIOBuffer{Array{UInt8,1}},RawToken}
    done::Bool # Remove this
    lt::RawToken
    t::RawToken
    nt::RawToken
    nnt::RawToken
    lws::RawToken
    ws::RawToken
    nws::RawToken
    nnws::RawToken
    closer::Closer
    errored::Bool
    flags::UInt64
end
function ParseState(str::Union{IOBuffer,String})
    ps = ParseState(tokenize(str, RawToken), false, RawToken(), RawToken(), RawToken(), RawToken(), RawToken(), RawToken(), RawToken(), RawToken(), Closer(), false, 0)
    return next(next(ps))
end

function ParseState(str::Union{IOBuffer,String}, loc::Int)
    ps = ParseState(str)
    prevpos = position(ps)
    while ps.nt.startbyte < loc
        next(ps)
        prevpos = loop_check(ps, prevpos)
    end
    return ps
end

module ParserFlags
    const AllowConstWithoutAssignment = 0x1
    const InQuote = 0x2
end

enable!(ps::ParseState, flag::Integer) = ps.flags |= flag
disable!(ps::ParseState, flag::Integer) = ps.flags &= ~flag
has_flag(ps::ParseState, flag::Integer) = ps.flags & flag > 0

function Base.show(io::IO, ps::ParseState)
    println(io, "ParseState at $(position(ps.l.io))")
    println(io, "last    : ", kindof(ps.lt), " ($(ps.lt))", "    ($(wstype(ps.lws)))")
    println(io, "current : ", kindof(ps.t), " ($(ps.t))", "    ($(wstype(ps.ws)))")
    println(io, "next    : ", kindof(ps.nt), " ($(ps.nt))", "    ($(wstype(ps.nws)))")
end
peekchar(ps::ParseState) = peekchar(ps.l)
if !applicable(Base.peek, Tuple{IOBuffer, Char})
    function _peek(s::IO, ::Type{T}) where T
        mark(s)
        try read(s, T)::T
        finally
            reset(s)
        end
    end
    peekchar(io) = _peek(io, Char)
else
    peekchar(io) = peek(io, Char)
end

wstype(t::AbstractToken) = kindof(t) == EmptyWS ? "empty" :
                    kindof(t) == NewLineWS ? "ws w/ newline" :
                    kindof(t) == SemiColonWS ? "ws w/ semicolon" : "ws"

function next(ps::ParseState)
    #  shift old tokens
    ps.lt = ps.t
    ps.t = ps.nt
    ps.nt = ps.nnt
    ps.lws = ps.ws
    ps.ws = ps.nws
    ps.nws = ps.nnws

    ps.nnt = Tokenize.Lexers.next_token(ps.l)

    # combines whitespace, comments and semicolons
    if iswhitespace(peekchar(ps.l)) || peekchar(ps.l) == '#' || peekchar(ps.l) == ';'
        ps.nnws = lex_ws_comment(ps.l, readchar(ps.l))
    else
        ps.nnws = EmptyWSToken
    end

    return ps
end

function Base.seek(ps::ParseState, offset)
    seek(ps.l, offset)
    next(next(ps))
end

Base.position(ps::ParseState) = ps.nt.startbyte

current_line(ps::ParseState) = ps.nt.startpos[1]
"""
    lex_ws_comment(l::Lexer, c)

Having hit an initial whitespace/comment/semicolon continues collecting similar
`Chars` until they end. Returns a WS token with an indication of newlines/ semicolons. Indicating a semicolons takes precedence over line breaks as the former is equivalent to the former in most cases.
"""
function read_ws_comment(l, c::Char)
    newline = c == '\n'
    semicolon = c == ';'
    if c == '#'
        newline = read_comment(l)
    else
        newline, semicolon = read_ws(l, newline, semicolon)
    end
    while iswhitespace(peekchar(l)) || peekchar(l) == '#' || peekchar(l) == ';'
        c = readchar(l)
        if c == '#'
            read_comment(l)
            newline = newline || peekchar(l) == '\n'
            semicolon = semicolon || peekchar(l) == ';'
        elseif c == ';'
            semicolon = true
        else
            newline |= c == '\n'
            newline, semicolon = read_ws(l, newline, semicolon)
        end
    end
    return newline, semicolon
end

function lex_ws_comment(l::Lexer, c::Char)
    newline, semicolon = read_ws_comment(l, c)
    return emit(l, semicolon ? SemiColonWS :
                   newline ? NewLineWS : WS)
end


function read_ws(l, newline, semicolon)
    while iswhitespace(peekchar(l))
        c = readchar(l)
        c == '\n' && (newline = true)
        c == ';' && (semicolon = true)
    end
    return newline, semicolon
end

function read_comment(l)
    if peekchar(l) != '='
        while true
            pc = peekchar(l)
            if pc == '\n' || eof(pc)
                return true
            end
            readchar(l)
        end
    else
        c = readchar(l) # consume the '='
        n_start, n_end = 1, 0
        while true
            if eof(c)
                return false
            end
            nc = readchar(l)
            if c == '#' && nc == '='
                n_start += 1
            elseif c == '=' && nc == '#'
                n_end += 1
            end
            if n_start == n_end
                return false
            end
            c = nc
        end
    end
end

# Functions relating to tokens
isemptyws(t::AbstractToken) = kindof(t) == EmptyWS
isnewlinews(t::AbstractToken) = kindof(t) === NewLineWS
isendoflinews(t::AbstractToken) = kindof(t) == SemiColonWS || kindof(t) == NewLineWS
@inline val(token::AbstractToken, ps::ParseState) = String(ps.l.io.data[token.startbyte + 1:token.endbyte + 1])
both_symbol_and_op(t::AbstractToken) = kindof(t) === Tokens.WHERE || kindof(t) === Tokens.IN || kindof(t) === Tokens.ISA
isprefixableliteral(t::AbstractToken) = (kindof(t) === Tokens.STRING || kindof(t) === Tokens.TRIPLE_STRING || kindof(t) === Tokens.CMD || kindof(t) === Tokens.TRIPLE_CMD)
isassignmentop(t::AbstractToken) = Tokens.begin_assignments < kindof(t) < Tokens.end_assignments

isidentifier(t::AbstractToken) = kindof(t) === Tokens.IDENTIFIER
isliteral(t::AbstractToken) = Tokens.begin_literal < kindof(t) < Tokens.end_literal
isbool(t::AbstractToken) =  Tokens.TRUE ≤ kindof(t) ≤ Tokens.FALSE
iscomma(t::AbstractToken) =  kindof(t) === Tokens.COMMA
iscolon(t::AbstractToken) =  kindof(t) === Tokens.COLON
iskeyword(t::AbstractToken) = Tokens.iskeyword(kindof(t))
isinstance(t::AbstractToken) = isidentifier(t) || isliteral(t) || isbool(t) || iskeyword(t)
ispunctuation(t::AbstractToken) = iscomma(t) || kindof(t) === Tokens.END || Tokens.LSQUARE ≤ kindof(t) ≤ Tokens.RPAREN || kindof(t) === Tokens.AT_SIGN
isnumberliteral(t::AbstractToken) = isliteral(t) && (Tokens.INTEGER ≤ kindof(t) ≤ Tokens.FLOAT)
