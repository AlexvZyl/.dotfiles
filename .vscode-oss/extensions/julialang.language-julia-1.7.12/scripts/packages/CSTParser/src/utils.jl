"""
closer(ps::ParseState)

A magical function determining whether the parsing of an expression should continue or
stop.
"""
function closer(ps::ParseState)
    kindof(ps.nt) === Tokens.ENDMARKER ||
    (ps.closer.newline && kindof(ps.ws) == NewLineWS && !iscomma(ps.t)) ||
    (ps.closer.semicolon && kindof(ps.ws) == SemiColonWS) ||
    (isoperator(ps.nt) && precedence(ps.nt) <= ps.closer.precedence) ||
    (kindof(ps.nt) === Tokens.WHERE && ps.closer.precedence == LazyAndOp) ||
    (ps.closer.inwhere && kindof(ps.nt) === Tokens.WHERE) ||
    (ps.closer.inwhere && ps.closer.ws && kindof(ps.t) === Tokens.RPAREN && isoperator(ps.nt) && precedence(ps.nt) < DeclarationOp) ||
    (ps.closer.precedence > WhereOp && (
        (kindof(ps.nt) === Tokens.LPAREN && !(kindof(ps.t) === Tokens.EX_OR)) ||
        kindof(ps.nt) === Tokens.LBRACE ||
        kindof(ps.nt) === Tokens.LSQUARE ||
        (kindof(ps.nt) === Tokens.STRING && isemptyws(ps.ws)) ||
        ((kindof(ps.nt) === Tokens.RPAREN || kindof(ps.nt) === Tokens.RSQUARE) && isidentifier(ps.nt))
    )) ||
    (iscomma(ps.nt) && ps.closer.precedence > AssignmentOp) ||
    kindof(ps.nt) === Tokens.ENDMARKER ||
    (ps.closer.comma && iscomma(ps.nt)) ||
    (ps.closer.tuple && (iscomma(ps.nt) || isassignmentop(ps.nt))) ||
    (kindof(ps.nt) === Tokens.FOR && ps.closer.precedence > -1) ||
    (ps.closer.block && kindof(ps.nt) === Tokens.END) ||
    (ps.closer.paren && kindof(ps.nt) === Tokens.RPAREN) ||
    (ps.closer.brace && kindof(ps.nt) === Tokens.RBRACE) ||
    (ps.closer.square && kindof(ps.nt) === Tokens.RSQUARE) ||
    # tilde parsing in vect exprs needs to be special cased because `~` has assignment precedence
    (@static VERSION < v"1.4" ?
        false :
        ((ps.closer.insquare || ps.closer.inmacro) && kindof(ps.nt) === Tokens.APPROX && !isemptyws(ps.ws) && isemptyws(ps.nws))
    ) ||
    kindof(ps.nt) === Tokens.ELSEIF ||
    kindof(ps.nt) === Tokens.ELSE ||
    kindof(ps.nt) === Tokens.CATCH ||
    kindof(ps.nt) === Tokens.FINALLY ||
    (ps.closer.ifop && isoperator(ps.nt) && (precedence(ps.nt) <= 0 || kindof(ps.nt) === Tokens.COLON)) ||
    (ps.closer.range && (kindof(ps.nt) === Tokens.FOR || iscomma(ps.nt) || kindof(ps.nt) === Tokens.IF)) ||
    (ps.closer.ws && !isemptyws(ps.ws) &&
        !iscomma(ps.nt) &&
        !iscomma(ps.t) &&
        !(!ps.closer.inmacro && kindof(ps.nt) === Tokens.FOR) &&
        !(kindof(ps.nt) === Tokens.DO) &&
        !(
            (isbinaryop(ps.nt) && !(ps.closer.wsop && isemptyws(ps.nws) && isunaryop(ps.nt) && precedence(ps.nt) > 7)) ||
            (isunaryop(ps.t) && kindof(ps.ws) == WS && kindof(ps.lt) !== CSTParser.Tokens.COLON)
        )) ||
    (ps.closer.unary && (kindof(ps.t) in (Tokens.INTEGER, Tokens.FLOAT, Tokens.RPAREN, Tokens.RSQUARE, Tokens.RBRACE) && isidentifier(ps.nt)))
end

"""
    @closer ps rule body

Continues parsing closing on `rule`.
"""
macro closer(ps, opt, body)
    quote
        local tmp1 = getfield($(esc(ps)).closer, $opt)
        setfield!($(esc(ps)).closer, $opt, true)
        out = $(esc(body))
        setfield!($(esc(ps)).closer, $opt, tmp1)
        out
    end
end

"""
    @nocloser ps rule body

Continues parsing not closing on `rule`.
"""
macro nocloser(ps, opt, body)
    quote
        local tmp1 = getfield($(esc(ps)).closer, $opt)
        setfield!($(esc(ps)).closer, $opt, false)
        out = $(esc(body))
        setfield!($(esc(ps)).closer, $opt, tmp1)
        out
    end
end

macro closeparen(ps, body)
    quote
        local tmp1 = $(esc(ps)).closer.paren
        $(esc(ps)).closer.paren = true
        out = $(esc(body))
        $(esc(ps)).closer.paren = tmp1
        out
    end
end

macro closesquare(ps, body)
    quote
        local tmp1 = $(esc(ps)).closer.square
        $(esc(ps)).closer.square = true
        out = $(esc(body))
        $(esc(ps)).closer.square = tmp1
        out
    end
end
macro closebrace(ps, body)
    quote
        local tmp1 = $(esc(ps)).closer.brace
        $(esc(ps)).closer.brace = true
        out = $(esc(body))
        $(esc(ps)).closer.brace = tmp1
        out
    end
end

"""
    @precedence ps prec body

Continues parsing binary operators until it hits a more loosely binding
operator (with precdence lower than `prec`).
"""
macro precedence(ps, prec, body)
    quote
        local tmp1 = $(esc(ps)).closer.precedence
        $(esc(ps)).closer.precedence = $(esc(prec))
        out = $(esc(body))
        $(esc(ps)).closer.precedence = tmp1
        out
    end
end


# Closer_TMP and ancillary functions help reduce code generation
struct Closer_TMP
    newline::Bool
    semicolon::Bool
    inmacro::Bool
    tuple::Bool
    comma::Bool
    insquare::Bool
    range::Bool
    ifop::Bool
    ws::Bool
    wsop::Bool
    unary::Bool
    precedence::Int
end

@noinline function create_tmp(c::Closer)
    Closer_TMP(c.newline,
        c.semicolon,
        c.inmacro,
        c.tuple,
        c.comma,
        c.insquare,
        c.range,
        c.ifop,
        c.ws,
        c.wsop,
        c.unary,
        c.precedence)
end

@noinline function update_from_tmp!(c::Closer, tmp::Closer_TMP)
    c.newline = tmp.newline
    c.semicolon = tmp.semicolon
    c.inmacro = tmp.inmacro
    c.tuple = tmp.tuple
    c.comma = tmp.comma
    c.insquare = tmp.insquare
    c.range = tmp.range
    c.ifop = tmp.ifop
    c.ws = tmp.ws
    c.wsop = tmp.wsop
    c.unary = tmp.unary
    c.precedence = tmp.precedence
end


@noinline function update_to_default!(c::Closer)
    c.newline = true
    c.semicolon = true
    c.inmacro = false
    c.tuple = false
    c.comma = false
    c.insquare = false
    c.range = false
    c.ifop = false
    c.ws = false
    c.wsop = false
    c.unary = false
    c.precedence = -1
end


"""
    @default ps body

Parses the next expression using default closure rules.
"""
macro default(ps, body)
    quote
        TMP = create_tmp($(esc(ps)).closer)
        update_to_default!($(esc(ps)).closer)
        out = $(esc(body))
        update_from_tmp!($(esc(ps)).closer, TMP)
        out
    end
end


isajuxtaposition(ps::ParseState, ret::EXPR) = ((isnumber(ret) && (isidentifier(ps.nt) || kindof(ps.nt) === Tokens.LPAREN || kindof(ps.nt) === Tokens.CMD || kindof(ps.nt) === Tokens.STRING || kindof(ps.nt) === Tokens.TRIPLE_STRING)) ||
        ((is_prime(ret.head) && isidentifier(ps.nt)) ||
        ((kindof(ps.t) === Tokens.RPAREN || kindof(ps.t) === Tokens.RSQUARE) && (isidentifier(ps.nt) || kindof(ps.nt) === Tokens.CMD)) ||
        ((kindof(ps.t) === Tokens.STRING || kindof(ps.t) === Tokens.TRIPLE_STRING) && (kindof(ps.nt) === Tokens.STRING || kindof(ps.nt) === Tokens.TRIPLE_STRING)))) || ((kindof(ps.t) in (Tokens.INTEGER, Tokens.FLOAT) || kindof(ps.t) in (Tokens.RPAREN, Tokens.RSQUARE, Tokens.RBRACE)) && isidentifier(ps.nt)) ||
        (isnumber(ret) && ps.closer.inref && (ps.nt.kind === Tokens.END || ps.nt.kind === Tokens.BEGIN))

"""
    has_error(ps::ParseState)
    has_error(x::EXPR)

Determine whether a parsing error occured while processing text with the given
`ParseState`, or exists as a (sub) expression of `x`.
"""
function has_error(x::EXPR)
    return headof(x) == :errortoken || (x.args !== nothing && any(has_error, x.args)) || (x.trivia !== nothing && any(has_error, x.trivia))
end
has_error(ps::ParseState) = ps.errored

using Base.Meta

"""
    compare(x,y)

Recursively checks whether two Base.Expr are the same. Returns unequal sub-
expressions.
"""
compare(x, y) = x == y ? true : (x, y)

function compare(x::Expr, y::Expr)
    if x == y
        return true
    else
        if x.head != y.head
            return (x, y)
        end
        if length(x.args) != length(y.args)
            return (x.args, y.args)
        end
        for i = 1:length(x.args)
            t = compare(x.args[i], y.args[i])
            if t != true
                return t
            end
        end
    end
end

# code for updating CST
"""
    firstdiff(s0::AbstractString, s1::AbstractString)

Returns the last byte index, i, for which s0 and s1 are the same such that:
    `s0[1:i] == s1[1:i]`
"""
function firstdiff(s0::AbstractString, s1::AbstractString)
    minlength = min(sizeof(s0), sizeof(s1))
    @inbounds for i in 1:minlength
        if codeunits(s0)[i] !== codeunits(s1)[i]
            return i - 1 # This could return a non-commencing byte of a multi-byte unicode sequence.
        end
    end
    return minlength
end

"""
    revfirstdiff(s0::AbstractString, s1::AbstractString)

Reversed version of firstdiff but returns two indices, one for each string.
"""
function revfirstdiff(s0::AbstractString, s1::AbstractString)
    minlength = min(sizeof(s0), sizeof(s1))
    @inbounds for i in 0:minlength - 1
        if codeunits(s0)[end - i] !== codeunits(s1)[end - i]
            return sizeof(s0) - i, sizeof(s1) - i# This could return a non-commencing byte of a multi-byte unicode sequence.
        end
    end
    return 1, 1
end

"""
    find_arg_at(x, i)

Returns the index of the node of `x` within which the byte offset `i` falls.
"""
function find_arg_at(x::CSTParser.EXPR, i)
    @assert i <= x.fullspan
    offset = 0
    for (cnt, a) in enumerate(x.args)
        if i <= offset + a.fullspan
            return cnt
        end
        offset += a.fullspan
    end
    error("$(x.head) with fullspan: $(x.fullspan) at $i")
end

comp(x, y) = x == y
function comp(x::CSTParser.EXPR, y::CSTParser.EXPR)
    comp(x.head, y.head) &&
    x.span == y.span &&
    x.fullspan == y.fullspan &&
    x.val == y.val &&
    length(x) == length(y) &&
    all(comp(x[i], y[i]) for i = 1:length(x))
end

function minimal_reparse(s0, s1, x0 = CSTParser.parse(s0, true), x1 = CSTParser.parse(s1, true); inds = false)
    if has_error(x0)
        return inds ? (1:0, 1:length(x1.args), 1:0) : x1 # Error while re-parsing, so lets return the whole expression instead of patching
    end

    if sizeof(s0) !== x0.fullspan
       error("minimal reparse - original input text length doesn't match the full span of the provided CST.")
        # return inds ? (1:0, 1:length(x1.args), 1:0) : x1
    end

    if has_error(x1)
        return inds ? (1:0, 1:length(x1.args), 1:0) : x1 # Error while re-parsing, so lets return the whole expression instead of patching
    end

    if sizeof(s1) !== x1.fullspan
        error("minimal reparse - new input text length doesn't match the full span of the provided CST.")
         # return inds ? (1:0, 1:length(x1.args), 1:0) : x1
    end
    isempty(x0.args) && return inds ? (1:0, 1:length(x1.args), 1:0) : x1 # Original CST was empty
    x1.fullspan == 0 && return inds ? (1:0, 1:0, 1:0) : x1 # New CST is empty

    i0 = firstdiff(s0, s1)
    i0 > x0.fullspan && return inds ? (1:0, 1:length(x1.args), 1:0) : x1 # Should error?
    i1, i2 = revfirstdiff(s0, s1)
    (i0 > x1.fullspan || i1 > x1.fullspan || i2 > x1.fullspan) && return inds ? (1:0, 1:length(x1.args), 1:0) : x1 # Should error?
    # Find unaffected expressions at start
    # CST should be unaffected (and able to be copied across) up to this point,
    # but we need to check.
    r1 = 1:min(find_arg_at(x0, i0) - 1, length(x0.args), find_arg_at(x1, i0) - 1)
    for i = 1:min(find_arg_at(x0, i0) - 1, find_arg_at(x1, i0) - 1)
        if x0.args[i].fullspan !== x1.args[i].fullspan
            r1 = 1:(i-1)
            break
        end
        r1 = 1:i
    end
    # we can re-use x0.args[r1]

    # assume we'll just use x1.args from here on
    r2 = (last(r1) + 1):length(x1.args)
    r3 = 0:-1

    # though we now check whether there is a sequence at the end of x0.args and
    # x1.args that match
    offset = sizeof(s1)
    for i = 0:min(length(x0.args) - last(r1), length(x0.args), length(x1.args)) - 1
        if !quick_comp(x0.args[end - i], x1.args[end - i]) ||
            offset <= i1 ||
            length(x0.args) - i == last(r1) + 1 ||
            offset - x1.args[end-i].fullspan <= i2 <= offset

            r2 = first(r2):length(x1.args) - i
            r3 = length(x0.args) .+ ((-i + 1):0)
            break
        end
        offset -= x1.args[end - i].fullspan
    end
    inds && return r1, r2, r3
    x2 = CSTParser.EXPR(x0.head, CSTParser.EXPR[
        x0.args[r1]
        x1.args[r2]
        x0.args[r3]
    ], nothing)
    return x2
end

# Quick and very dirty comparison of two EXPR, makes extra effort for :errortokens
function quick_comp(a::EXPR, b::EXPR)
    a.fullspan != b.fullspan && return false
    if headof(a) === :errortoken
        headof(b) !== :errortoken && return false
        if a.args !== nothing
            b.args === nothing && return false
            return length(a.args) == length(b.args) && (length(a.args) == 0 || quick_comp(first(a.args), first(b.args)))
        end
    end
    return comp(headof(a), headof(b))
end

"""
check_span(x, neq = [])

Recursively checks whether the span of an expression equals the sum of the span
of its components. Returns a vector of failing expressions.
"""
function check_span(x::EXPR, neq = [])
    (ispunctuation(x) || isidentifier(x) || iskeyword(x) || isoperator(x) || isliteral(x) || headof(x) == :string) && return neq

    s = 0
    if x.args !== nothing
        for a in x.args
            check_span(a, neq)
            s += a.fullspan
        end
    end
    if hastrivia(x)
        for a in x.trivia
            check_span(a, neq)
            s += a.fullspan
        end
    end
    if x.head isa EXPR
        s += x.head.fullspan
    end
    if length(x) > 0 && s != x.fullspan
        push!(neq, x)
    end
    neq
end

function speed_test()
    dir = dirname(Base.find_source_file("essentials.jl"))
    println("speed test : ", @timed(for i = 1:5
        parse(read(joinpath(dir, "essentials.jl"), String), true);
        parse(read(joinpath(dir, "abstractarray.jl"), String), true);
    end)[2])
end

"""
    str_value(x)

Attempt to get a string representation of a nodeless expression.
"""
function str_value(x)
    if headof(x) === :IDENTIFIER || isliteral(x)
        return valof(x)
    elseif isidentifier(x)
        valof(x.args[2])
    elseif isoperator(x)
        return string(to_codeobject(x))
    else
        return ""
    end
end

_unescape_string(s::AbstractString) = sprint(_unescape_string, s, sizehint=lastindex(s))
function _unescape_string(io, s::AbstractString)
    a = Iterators.Stateful(s)
    for c in a
        if !isempty(a) && c == '\\'
            c = popfirst!(a)
            if c == 'x' || c == 'u' || c == 'U'
                n = k = 0
                m = c == 'x' ? 2 :
                    c == 'u' ? 4 : 8
                while (k += 1) <= m && !isempty(a)
                    nc = Base.peek(a)
                    n = '0' <= nc <= '9' ? n << 4 + nc - '0' :
                        'a' <= nc <= 'f' ? n << 4 + nc - 'a' + 10 :
                        'A' <= nc <= 'F' ? n << 4 + nc - 'A' + 10 : break
                    popfirst!(a)
                end
                if k == 1
                    # throw(ArgumentError("invalid $(m == 2 ? "hex (\\x)" :
                    #                         "unicode (\\u)") escape sequence used in $(repr(s))"))
                    # push error to ParseState?
                    # This matches Meta.parse at least
                    print(io, "\\x")
                else
                    if m == 2 # \x escape sequence
                        write(io, UInt8(n))
                    else
                        print(io, Char(n))
                    end
                end
            elseif '0' <= c <= '7'
                k = 1
                n = c - '0'
                while (k += 1) <= 3 && !isempty(a)
                    c  = Base.peek(a)
                    n = ('0' <= c <= '7') ? n << 3 + c - '0' : break
                    popfirst!(a)
                end
                if n > 255
                    # throw(ArgumentError("octal escape sequence out of range"))
                    # push error to ParseState?
                    n = 255
                end
                write(io, UInt8(n))
            else
                print(io, c == 'a' ? '\a' :
                          c == 'b' ? '\b' :
                          c == 't' ? '\t' :
                          c == 'n' ? '\n' :
                          c == 'v' ? '\v' :
                          c == 'f' ? '\f' :
                          c == 'r' ? '\r' :
                          c == 'e' ? '\e' : c)
            end
        else
            print(io, c)
        end
    end
end

function valid_escaped_seq(s::AbstractString)
    l = length(s)
    l == 0 && return false # zero length chars are always invalid
    l == 1 && return true # length-one chars are always valid to Julia's parser
    a = Iterators.Stateful(s)
    if popfirst!(a) == '\\'
        c = popfirst!(a)
        if c === 'x' || c === 'u' || c === 'U'
            maxiter = c === 'x' ? 2 : c === 'u' ? 4 : 8
            0 < length(a) <= maxiter || return false
            n = 0
            while !isempty(a)
                nc = popfirst!(a)
                n = '0' <= nc <= '9' ? n << 4 + (nc - '0') :
                    'a' <= nc <= 'f' ? n << 4 + (nc - 'a' + 10) :
                    'A' <= nc <= 'F' ? n << 4 + (nc - 'A' + 10) : return false
            end
            return n <= 0x10ffff
        elseif '0' <= c <= '7'
            length(a) <= 3 || return false
            n = c - '0'
            while !isempty(a)
                nc = popfirst!(a)
                n = ('0' <= c <= '7') ? n << 3 + nc - '0' : return false
            end
            return n < 128
        else
            @static if VERSION < v"1.1.0"
                c = string(c)
            end
            return ncodeunits(c) == 1 && isempty(a)
        end
    end
    return false
end

"""
    disallowednumberjuxt(ret::EXPR)

Does this number literal end in a decimal and so cannot precede a paren for
implicit multiplication?
"""
disallowednumberjuxt(ret::EXPR) = isnumber(ret) && last(valof(ret)) == '.'


nexttokenstartsdocstring(ps::ParseState) = isidentifier(ps.nt) && val(ps.nt, ps) == "doc" && (kindof(ps.nnt) === Tokens.STRING || kindof(ps.nnt) === Tokens.TRIPLE_STRING)



"""
    _do_kw_convert(ps::ParseState, a::EXPR)

Should `a` be converted to a keyword-argument expression?
"""
_do_kw_convert(ps::ParseState, a::EXPR) = !ps.closer.brace && isassignment(a)

"""
    _kw_convert(ps::ParseState, a::EXPR)

Converted an assignment expression to a keyword-argument expression.
"""
_kw_convert(x::EXPR) = EXPR(:kw, EXPR[x.args[1], x.args[2]], EXPR[x.head], x.fullspan, x.span)

"""
    convertsigtotuple(sig::EXPR)

When parsing a function or macro signature, should it be converted to a tuple?
"""
convertsigtotuple(sig::EXPR) = isbracketed(sig) && !(istuple(sig.args[1]) || (headof(sig.args[1]) === :block) || issplat(sig.args[1]))

"""
    docable(head)

When parsing a block of expressions, can documentation be attached? Prefixed docs at the
top-level are handled within `parse(ps::ParseState, cont = false)`.
"""
docable(head) = head === :begin || head === :module || head === :baremodule || head === :quote


should_negate_number_literal(ps::ParseState, op::EXPR) = (is_plus(op) || is_minus(op)) && (kindof(ps.nt) === Tokens.INTEGER || kindof(ps.nt) === Tokens.FLOAT) && isemptyws(ps.ws) && kindof(ps.nnt) != Tokens.CIRCUMFLEX_ACCENT


"""
    can_become_comparison(x::EXPR)

Is `x` a binary comparison call (e.g. `a < b`) that can be extended to include more
arguments?
"""
can_become_comparison(x::EXPR) = (isoperator(x.head) && comp_prec(valof(x.head)) && length(x.args) > 1) || (x.head === :call && isoperator(x.args[1]) && comp_prec(valof(x.args[1])) && length(x.args) > 2 && !hastrivia(x))

"""
    can_become_chain(x::EXPR, op::EXPR)

Is `x` a binary call for `+` or `*` that can be extended to include more
arguments?
"""
can_become_chain(x::EXPR, op::EXPR) = isbinarycall(x) && (is_star(op) || is_plus(op)) && valof(op) == valof(x.args[2]) && !isdotted(x.args[2]) && x.args[2].span > 0


macro cst_str(x)
    CSTParser.parse(x)
end

function issuffixableliteral(ps::ParseState, x::EXPR)
    # prefixed string/cmd macros can be suffixed by identifiers or numeric literals
    (isidentifier(ps.nt) || isnumberliteral(ps.nt) || isbool(ps.nt)) && isemptyws(ps.ws) && ismacrocall(x) && (valof(x.args[1]) isa String && (endswith(valof(x.args[1]), "_str") || endswith(valof(x.args[1]), "_cmd")))
end

function loop_check(ps, prevpos)
    if position(ps) <= prevpos && ps.nt.kind !== Tokens.ENDMARKER
        throw(CSTInfiniteLoop("Infinite loop at $ps"))
    else
        position(ps)
    end
end
