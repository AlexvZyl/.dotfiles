# Operator hierarchy
const AssignmentOp  = 1
const ConditionalOp = 2
const ArrowOp       = 3
const LazyOrOp      = 4
const LazyAndOp     = 5
const ComparisonOp  = 6
const PipeOp        = 7
const ColonOp       = 8
const PlusOp        = 9
@static if Base.operator_precedence(:<<) == 12
    const BitShiftOp    = 10
    const TimesOp       = 11
    const RationalOp    = 12
else
    const TimesOp       = 10
    const RationalOp    = 11
    const BitShiftOp    = 12
end
const PowerOp       = 13
const DeclarationOp = 14
const WhereOp       = 15
const DotOp         = 16
const PrimeOp       = 16
const DddotOp       = 7
const AnonFuncOp    = 14

@enum(ErrorKind,
    UnexpectedToken,
    CannotJuxtapose,
    UnexpectedWhiteSpace,
    UnexpectedNewLine,
    ExpectedAssignment,
    UnexpectedAssignmentOp,
    MissingConditional,
    MissingCloser,
    MissingColon, # We didn't get a colon (`:`) when we expected to while parsing a `?` expression.
    InvalidIterator,
    StringInterpolationWithTrailingWhitespace,
    InvalidChar,
    EmptyChar,
    InvalidString,
    Unknown,
    SignatureOfFunctionDefIsNotACall,
    MalformedMacroName)

"""
`EXPR` represents Julia expressions overlaying a span of bytes in the source
text. The full span starts at the first syntactically significant token and
includes any trailing whitespace/comments.

Iterating or directly indexing `EXPR` results in a sequence of child `EXPR` in
source order, including most syntax trivia but not including whitespace,
comments and semicolons.

The fields of `EXPR` are:

* `head` represents the type of the expression
  - For internal tree nodes it usually matches the associated `Expr`'s head
    field. But not always because there's some additional heads, for example
    `:brackets` for grouping parentheses, `:globalrefdoc`, `:quotenode`, etc
  - For leaf nodes (ie, individual tokens), it's capitalized. Eg,
    `:INTEGER` for integer tokens, `:END` for `end`, `:LPAREN` for `[`,
    etc.
  - For syntactic operators such as `=` and `<:` (which have the operator
    itself as the expression head in normal `Expr`), the head is an `EXPR`.

* `args` are the significant subexpressions, in the order used by `Base.Expr`.
   For leaf nodes, this is `nothing`.

* `trivia` are any nontrivial tokens which are trivial after parsing.
  - This includes things like the parentheses in `(1 + 2)`, and the
    keywords in `begin x end`
  - Whitespace and comments are not included in `trivia`

* `fullspan` is the total number of bytes of text covered by this expression,
  including any trailing whitespace or comment trivia.

* `span` is the number of bytes of text covered by the syntactically
    relevant part of this expression (ie, not including trailing whitespace
    or comment trivia).

* `val` is the source text covered by `span`

* `parent` is the parent node in the expression tree, or `Nothing` for the root.

* `meta` contains metadata. This includes some ad-hoc information supplied by
  the parser. (But can also be used downstream in linting or static analysis.)

Whitespace, comments and semicolons are not represented explicitly. Rather,
they're tacked onto the end of leaf tokens in `args` or `trivia`, in the last
`fullspan-span` bytes of the token.
"""
mutable struct EXPR
    head::Union{Symbol,EXPR}
    args::Union{Nothing,Vector{EXPR}}
    trivia::Union{Nothing,Vector{EXPR}}
    fullspan::Int
    span::Int
    val::Union{Nothing,String}
    parent::Union{Nothing,EXPR}
    meta
end

function EXPR(head::Union{Symbol,EXPR}, args::Vector{EXPR}, trivia::Union{Vector{EXPR},Nothing}, fullspan::Int, span::Int)
    ex = EXPR(head, args, trivia, fullspan, span, nothing, nothing, nothing)
    if head isa EXPR
        setparent!(head, ex)
    end
    for c in args
        setparent!(c, ex)
    end
    if trivia isa Vector{EXPR}
        for c in trivia
            setparent!(c, ex)
        end
    end
    ex
end

function EXPR(head::Union{Symbol,EXPR}, args::Vector{EXPR}, trivia::Union{Vector{EXPR},Nothing} = EXPR[])
    ret = EXPR(head, args, trivia, 0, 0)
    update_span!(ret)
    ret
end

# These methods are for terminal/childless expressions.
@noinline EXPR(head::Union{Symbol,EXPR}, fullspan::Int, span::Int, val = nothing) = EXPR(head, nothing, nothing, fullspan, span, val, nothing, nothing)
@noinline EXPR(head::Union{Symbol,EXPR}, ps::ParseState) = EXPR(head, ps.nt.startbyte - ps.t.startbyte, ps.t.endbyte - ps.t.startbyte + 1, val(ps.t, ps))
@noinline EXPR(ps::ParseState) = EXPR(tokenkindtoheadmap(kindof(ps.t)), ps)

@noinline function mLITERAL(ps::ParseState)
    if kindof(ps.t) === Tokens.STRING || kindof(ps.t) === Tokens.TRIPLE_STRING ||
        kindof(ps.t) === Tokens.CMD || kindof(ps.t) === Tokens.TRIPLE_CMD
        return parse_string_or_cmd(ps)
    else
        v = val(ps.t, ps)
        if kindof(ps.t) === Tokens.CHAR && length(v) > 3 && !(v[2] == '\\' && valid_escaped_seq(v[2:prevind(v, end)]))
            return mErrorToken(ps, EXPR(:CHAR, ps.nt.startbyte - ps.t.startbyte, ps.t.endbyte - ps.t.startbyte + 1, string(v[1:2], '\'')), InvalidChar)
        elseif kindof(ps.t) === Tokens.CHAR && length(v) == 2
            return mErrorToken(ps, EXPR(:CHAR, ps.nt.startbyte - ps.t.startbyte, ps.t.endbyte - ps.t.startbyte + 1, string(v[1:2], '\'')), EmptyChar)
        end
        return EXPR(literalmap(kindof(ps.t)), ps.nt.startbyte - ps.t.startbyte, ps.t.endbyte - ps.t.startbyte + 1, v)
    end
end



span(x::EXPR) = x.span

function update_span!(x::EXPR)
    (x.args isa Nothing || isempty(x.args)) && !hastrivia(x) && return
    x.fullspan = 0
    for i = 1:length(x.args)
        x.fullspan += x.args[i].fullspan
    end
    if hastrivia(x)
        for i = 1:length(x.trivia)
            x.fullspan += x.trivia[i].fullspan
        end
    end
    if x.head isa EXPR
        x.fullspan += x.head.fullspan
        # TODO: special case for trailing unary ops?
    end
    if x.head isa EXPR && isoperator(x.head) && (is_dddot(x.head) || is_prime(x.head))
        # trailing unary operator
        x.span  = x.fullspan - x.head.fullspan + x.head.span
    elseif hastrivia(x) && lastchildistrivia(x)
        x.span = x.fullspan - last(x.trivia).fullspan + last(x.trivia).span
    elseif !isempty(x.args)
        x.span = x.fullspan - last(x.args).fullspan + last(x.args).span
    end
    return
end

function Base.push!(e::EXPR, arg::EXPR)
    e.span = e.fullspan + arg.span
    e.fullspan += arg.fullspan
    setparent!(arg, e)
    push!(e.args, arg)
end

function pushtotrivia!(e::EXPR, arg::EXPR)
    e.span = e.fullspan + arg.span
    e.fullspan += arg.fullspan
    setparent!(arg, e)
    push!(e.trivia, arg)
end

function Base.pushfirst!(e::EXPR, arg::EXPR)
    e.fullspan += arg.fullspan
    setparent!(arg, e)
    pushfirst!(e.args, arg)
end

function Base.pop!(e::EXPR)
    arg = pop!(e.args)
    e.fullspan -= arg.fullspan
    if isempty(e.args)
        e.span = 0
    else
        e.span = e.fullspan - last(e.args).fullspan + last(e.args).span
    end
    arg
end

function Base.append!(e::EXPR, args::Vector{EXPR})
    append!(e.args, args)
    for arg in args
        setparent!(arg, e)
    end
    update_span!(e)
end

function Base.append!(a::EXPR, b::EXPR)
    append!(a.args, b.args)
    for arg in b.args
        setparent!(arg, a)
    end
    a.fullspan += b.fullspan
    a.span = a.fullspan + last(b.span)
end


function INSTANCE(ps::ParseState)
    if isidentifier(ps.t)
        return EXPR(:IDENTIFIER, ps)
    elseif isliteral(ps.t)
        return mLITERAL(ps)
    elseif iskeyword(ps.t)
        return EXPR(ps)
    elseif isoperator(ps.t)
        return EXPR(:OPERATOR, ps)
    elseif ispunctuation(ps.t)
        return EXPR(ps)
    elseif kindof(ps.t) === Tokens.ERROR
        ps.errored = true
        return EXPR(:errortoken, nothing, nothing, ps.nt.startbyte - ps.t.startbyte, ps.t.endbyte - ps.t.startbyte + 1, val(ps.t, ps), nothing, Unknown)
    else
        return mErrorToken(ps, Unknown)
    end
end

function mErrorToken(ps::ParseState, k::ErrorKind)
    ps.errored = true
    return EXPR(:errortoken, EXPR[], nothing, 0, 0, nothing, nothing, k)
end
function mErrorToken(ps::ParseState, x::EXPR, k)
    ps.errored = true
    ret = EXPR(:errortoken, EXPR[x], nothing, x.fullspan, x.span, nothing, nothing, k)
    setparent!(ret.args[1], ret)
    return ret
end


headof(x::EXPR) = x.head
valof(x::EXPR) = x.val
kindof(t::Tokens.AbstractToken) = t.kind
parentof(x::EXPR) = x.parent
errorof(x::EXPR) = errorof(x.meta)
errorof(x) = x

function setparent!(c, p)
    c.parent = p
    return c
end
hastrivia(x::EXPR) = x.trivia !== nothing && length(x.trivia) > 0

function lastchildistrivia(x::EXPR)

    if headof(x) === :string
        isstringliteral(last(x.trivia)) && sizeof(valof(last(x.trivia))) < last(x.trivia).span
        # This section checks whether last trivia stringliteral has a span that accounts for closing quotation mark(s)
    else
        hastrivia(x) && (last(x.trivia).head in (:END, :RPAREN, :RSQUARE, :RBRACE) || (x.head in (:parameters, :tuple) && length(x.args) <= length(x.trivia)))
    end
end

function Base.length(x::EXPR)
    headof(x) === :NONSTDIDENTIFIER && return 0
    headof(x) === :flatten && return length(Iterating._flatten_lhs(x))
    n = x.args === nothing ? 0 : length(x.args)
    n += x.trivia === nothing ? 0 : length(x.trivia)
    x.head isa EXPR && !(x.head.span === 0) && (n += 1)
    return n
end

function literalmap(k::Tokens.Kind)
    if k === Tokens.INTEGER
        return :INTEGER
    elseif k === Tokens.BIN_INT
        return :BININT
    elseif k === Tokens.HEX_INT
        return :HEXINT
    elseif k === Tokens.OCT_INT
        return :OCTINT
    elseif k === Tokens.FLOAT
        return :FLOAT
    elseif k === Tokens.STRING
        return :STRING
    elseif k === Tokens.TRIPLE_STRING
        return :TRIPLESTRING
    elseif k === Tokens.CHAR
        return :CHAR
    elseif k === Tokens.CMD
        return :CMD
    elseif k === Tokens.TRIPLE_CMD
        return :TRIPLECMD
    elseif k === Tokens.TRUE
        return :TRUE
    elseif k === Tokens.FALSE
        return :FALSE
    end
end



function tokenkindtoheadmap(k::Tokens.Kind)
    if k == Tokens.COMMA
        :COMMA
    elseif k == Tokens.LPAREN
        :LPAREN
    elseif k == Tokens.RPAREN
        :RPAREN
    elseif k == Tokens.LSQUARE
        :LSQUARE
    elseif k == Tokens.RSQUARE
        :RSQUARE
    elseif k == Tokens.LBRACE
        :LBRACE
    elseif k == Tokens.RBRACE
        :RBRACE
    elseif k == Tokens.AT_SIGN
        :ATSIGN
    elseif k == Tokens.DOT
        :DOT
    elseif k === Tokens.ABSTRACT
        return :ABSTRACT
    elseif k === Tokens.BAREMODULE
        return :BAREMODULE
    elseif k === Tokens.BEGIN
        return :BEGIN
    elseif k === Tokens.BREAK
        return :BREAK
    elseif k === Tokens.CATCH
        return :CATCH
    elseif k === Tokens.CONST
        return :CONST
    elseif k === Tokens.CONTINUE
        return :CONTINUE
    elseif k === Tokens.DO
        return :DO
    elseif k === Tokens.ELSE
        return :ELSE
    elseif k === Tokens.ELSEIF
        return :ELSEIF
    elseif k === Tokens.END
        return :END
    elseif k === Tokens.EXPORT
        return :EXPORT
    elseif k === Tokens.FINALLY
        return :FINALLY
    elseif k === Tokens.FOR
        return :FOR
    elseif k === Tokens.FUNCTION
        return :FUNCTION
    elseif k === Tokens.GLOBAL
        return :GLOBAL
    elseif k === Tokens.IF
        return :IF
    elseif k === Tokens.IMPORT
        return :IMPORT
    elseif k === Tokens.IMPORTALL
        return :importall
    elseif k === Tokens.LET
        return :LET
    elseif k === Tokens.LOCAL
        return :LOCAL
    elseif k === Tokens.MACRO
        return :MACRO
    elseif k === Tokens.MODULE
        return :MODULE
    elseif k === Tokens.MUTABLE
        return :MUTABLE
    elseif k === Tokens.NEW
        return :NEW
    elseif k === Tokens.OUTER
        return :OUTER
    elseif k === Tokens.PRIMITIVE
        return :PRIMITIVE
    elseif k === Tokens.QUOTE
        return :QUOTE
    elseif k === Tokens.RETURN
        return :RETURN
    elseif k === Tokens.STRUCT
        return :STRUCT
    elseif k === Tokens.TRY
        return :TRY
    elseif k === Tokens.TYPE
        return :TYPE
    elseif k === Tokens.USING
        return :USING
    elseif k === Tokens.WHILE
        return :WHILE
    elseif k === Tokens.INTEGER
        return :INTEGER
    elseif k === Tokens.BIN_INT
        return :BININT
    elseif k === Tokens.HEX_INT
        return :HEXINT
    elseif k === Tokens.OCT_INT
        return :OCTINT
    elseif k === Tokens.FLOAT
        return :FLOAT
    elseif k === Tokens.STRING
        return :STRING
    elseif k === Tokens.TRIPLE_STRING
        return :TRIPLESTRING
    elseif k === Tokens.CHAR
        return :CHAR
    elseif k === Tokens.CMD
        return :CMD
    elseif k === Tokens.TRIPLE_CMD
        return :TRIPLECMD
    elseif k === Tokens.TRUE
        return :TRUE
    elseif k === Tokens.FALSE
        return :FALSE
    elseif k === Tokens.ENDMARKER
        return :errortoken
    else
        error("Cannot convert token $k to Expr head")
    end
end
