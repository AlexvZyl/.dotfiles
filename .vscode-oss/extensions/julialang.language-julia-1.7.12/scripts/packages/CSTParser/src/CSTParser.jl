module CSTParser
global debug = true

using Tokenize
import Base: length, first, last, getindex, setindex!
import Tokenize.Tokens
import Tokenize.Tokens: RawToken, AbstractToken, iskeyword, isliteral, isoperator, untokenize
import Tokenize.Lexers: Lexer, peekchar, iswhitespace

export ParseState, parse_expression

include("lexer.jl")
include("spec.jl")
include("utils.jl")
include("recovery.jl")
include("components/internals.jl")
include("components/keywords.jl")
include("components/lists.jl")
include("components/operators.jl")
include("components/strings.jl")
include("conversion.jl")
include("display.jl")
include("interface.jl")
include("iterate.jl")

"""
    parse_expression(ps)

Parses an expression until `closer(ps) == true`. Expects to enter the
`ParseState` the token before the the beginning of the expression and ends
on the last token.

Acceptable starting tokens are:
+ A keyword
+ An opening parentheses or brace.
+ An operator.
+ An instance (e.g. identifier, number, etc.)
+ An `@`.

"""
function parse_expression(ps::ParseState, esc_on_error = false)
    if kindof(ps.nt) === Tokens.ENDMARKER
        ret = mErrorToken(ps, UnexpectedToken)
    elseif (esc_on_error && ps.nt.kind == Tokens.ERROR)
        ret = EXPR(:errortoken, 0, 0)
    elseif kindof(ps.nt) ∈ term_c && !(kindof(ps.nt) === Tokens.END && ps.closer.square)
        if ps.closer.square && kindof(ps.nt) === Tokens.RSQUARE
            ret = mErrorToken(ps, UnexpectedToken)
        else
            ret = mErrorToken(ps, EXPR(next(ps)), UnexpectedToken)
        end
    else
        next(ps)
        if iskeyword(kindof(ps.t)) && kindof(ps.t) != Tokens.DO
            ret = parse_kw(ps)
        elseif kindof(ps.t) === Tokens.LPAREN
            ret = parse_paren(ps)
        elseif kindof(ps.t) === Tokens.LSQUARE
            ret = @closer ps :for_generator @default ps parse_array(ps)
        elseif kindof(ps.t) === Tokens.LBRACE
            ret = @default ps @closebrace ps parse_braces(ps)
        elseif isinstance(ps.t) || isoperator(ps.t)
            if both_symbol_and_op(ps.t)
                ret = EXPR(:IDENTIFIER, ps)
            else
                @static if VERSION < v"1.6"
                    # https://github.com/JuliaLang/julia/pull/37583
                    ret = INSTANCE(ps)
                else
                    if ps.t.dotop && closer(ps) && !isassignmentop(ps.t)
                        # Split dotted operator into dot-call
                        v = val(ps.t, ps)[2:end]
                        dot = EXPR(:OPERATOR, 1, 1, ".")
                        op = EXPR(:OPERATOR, ps.nt.startbyte - ps.t.startbyte - 1, ps.t.endbyte - ps.t.startbyte, v)
                        ret = EXPR(dot, EXPR[op], nothing)
                    else
                        ret = INSTANCE(ps)
                    end
                end
            end
            if is_colon(ret) && !(iscomma(ps.nt) || kindof(ps.ws) == SemiColonWS)
                ret = parse_unary(ps, ret)
            elseif isoperator(ret) && assign_prec(valof(ret)) && !isunaryop(ret)
                ret = mErrorToken(ps, ret, UnexpectedAssignmentOp)
            end
        elseif kindof(ps.t) === Tokens.AT_SIGN
            ret = parse_macrocall(ps)
        else
            ret = mErrorToken(ps, INSTANCE(ps), UnexpectedToken)
        end
        ret = parse_compound_recur(ps, ret)
    end
    return ret
end

function parse_compound_recur(ps, ret)
    !closer(ps) ? parse_compound_recur(ps, parse_compound(ps, ret)) : ret
end

"""
    parse_compound(ps::ParseState, ret::EXPR)

Attempts to parse a compound expression given the preceding expression `ret`.
"""
function parse_compound(ps::ParseState, ret::EXPR)
    if kindof(ps.nt) === Tokens.FOR
        ret = parse_generator(ps, ret)
    elseif kindof(ps.nt) === Tokens.DO
        ret = @default ps @closer ps :block parse_do(ps, ret)
    elseif isajuxtaposition(ps, ret)
        if disallowednumberjuxt(ret)
            ret = mErrorToken(ps, ret, CannotJuxtapose)
        end
        ret = parse_operator(ps, ret, EXPR(:OPERATOR, 0, 0, "*"))
    elseif issuffixableliteral(ps, ret)
        if isnumberliteral(ps.nt)
            arg = mLITERAL(next(ps))
            push!(ret, arg)
        else
            arg = EXPR(:IDENTIFIER, next(ps))
            push!(ret, EXPR(:STRING, arg.fullspan, arg.span, val(ps.t, ps)))
        end
    elseif (isidentifier(ret) || is_getfield(ret)) && isemptyws(ps.ws) && isprefixableliteral(ps.nt)
        ret = parse_prefixed_string_cmd(ps, ret)
    elseif kindof(ps.nt) === Tokens.LPAREN
        no_ws = !isemptyws(ps.ws)
        ret = @closer ps :for_generator @closeparen ps parse_call(ps, ret)
        if no_ws && !isunarycall(ret)
            ret = mErrorToken(ps, ret, UnexpectedWhiteSpace)
        end
    elseif kindof(ps.nt) === Tokens.LBRACE
        if isemptyws(ps.ws)
            ret = @default ps @nocloser ps :inwhere @closebrace ps parse_curly(ps, ret)
        else
            ret = mErrorToken(ps, (@default ps @nocloser ps :inwhere @closebrace ps parse_curly(ps, ret)), UnexpectedWhiteSpace)
        end
    elseif kindof(ps.nt) === Tokens.LSQUARE && isemptyws(ps.ws) && !isoperator(ret)
        ret = @closer ps :for_generator @default ps @nocloser ps :block parse_ref(ps, ret)
    elseif iscomma(ps.nt)
        ret = parse_tuple(ps, ret)
    elseif isunaryop(ret) && kindof(ps.nt) != Tokens.EQ
        ret = parse_unary(ps, ret)
    elseif isoperator(ps.nt)
        op = EXPR(:OPERATOR, next(ps))
        ret = parse_operator(ps, ret, op)
    elseif is_prime(ret.head)
        # prime operator followed by an identifier has an implicit multiplication
        nextarg = @precedence ps TimesOp parse_expression(ps)
        ret = EXPR(:call, EXPR[EXPR(:OPERATOR, 0, 0, "*"), ret, nextarg], nothing)
# ###############################################################################
# Everything below here is an error
# ###############################################################################
    else
        ps.errored = true
        if kindof(ps.nt) in (Tokens.RPAREN, Tokens.RSQUARE, Tokens.RBRACE)
            nextarg = mErrorToken(ps, EXPR(next(ps)), Unknown)
        else
            nextarg = try
                parse_expression(ps)
            catch err
                if err isa StackOverflowError
                    throw(error(string(ps, "\nsize: ", ps.l.io.size)))
                end
                mErrorToken(ps, ret, Unknown)
            end
        end
        ret = EXPR(:errortoken, EXPR[ret, nextarg], nothing)
    end
    return ret
end

"""
    parse_paren(ps, ret)

Parses an expression starting with a `(`.
"""
function parse_paren(ps::ParseState)
    args = EXPR[]
    trivia = EXPR[EXPR(ps)]
    @closeparen ps @default ps @nocloser ps :inwhere parse_comma_sep(ps, args, trivia, false, true, true, insert_params_at = 1)
    if length(args) == 1 && length(trivia) == 1 && ((kindof(ps.ws) !== SemiColonWS || headof(args[1]) === :block) && headof(args[1]) !== :parameters)
        accept_rparen(ps, trivia)
        ret = EXPR(:brackets, args, trivia)
    elseif VERSION < v"1.5" && length(args) == 1 && args[1].head === :parameters && isempty(args[1].args)
        accept_rparen(ps, trivia)
        pop!(args)
        push!(args, EXPR(:block, EXPR[], nothing))
        ret = EXPR(:brackets, args, trivia)
    else
        accept_rparen(ps, trivia)
        ret = EXPR(:tuple, args, trivia)
    end
    return ret
end

"""
    parse(str, cont = false)

Parses the passed string. If `cont` is true then will continue parsing until the end of the string returning the resulting expressions in a TOPLEVEL block.
"""
function parse(str::String, cont=false)
    ps = ParseState(str)
    x, _ = parse(ps, cont)
    return x
end

"""
    parse_doc(ps::ParseState)

Used for top-level parsing - attaches documentation (such as this) to expressions.
"""
function parse_doc(ps::ParseState)
    if (kindof(ps.nt) === Tokens.STRING || kindof(ps.nt) === Tokens.TRIPLE_STRING) && !isemptyws(ps.nws)
        doc = mLITERAL(next(ps))
        if kindof(ps.nt) === Tokens.ENDMARKER || kindof(ps.nt) === Tokens.END || ps.t.endpos[1] + 1 < ps.nt.startpos[1]
            ret = doc
        elseif isbinaryop(ps.nt) && !closer(ps)
            ret = parse_compound_recur(ps, doc)
        else
            ret = parse_expression(ps)
            ret = EXPR(:macrocall, EXPR[EXPR(:globalrefdoc, 0, 0), EXPR(:NOTHING, 0, 0), doc, ret], nothing)
        end
    else
        ret = parse_expression(ps)
    end
    if _continue_doc_parse(ps, ret)
        push!(ret, parse_expression(ps))
    end
    return ret
end

function parse(ps::ParseState, cont=false)
    if ps.l.io.size == 0
        return (cont ? EXPR(:file, EXPR[]) : nothing), ps
    end
    last_line = 0
    curr_line = 0

    if cont
        top = EXPR(:file, EXPR[], nothing)
        if kindof(ps.nt) === Tokens.WHITESPACE || kindof(ps.nt) === Tokens.COMMENT
            next(ps)
            push!(top, EXPR(:NOTHING, ps.nt.startbyte, ps.nt.startbyte, ""))
        elseif kindof(ps.nt) === Tokens.SEMICOLON
            next(ps)
            push!(top, EXPR(:toplevel, EXPR[EXPR(:NOTHING, ps.nt.startbyte, ps.nt.startbyte, "")]))
        end

        prevpos = position(ps)
        while kindof(ps.nt) !== Tokens.ENDMARKER
            curr_line = ps.nt.startpos[1]
            ret = parse_doc(ps)
            # join semicolon sep items
            if curr_line == last_line && headof(last(top.args)) === :toplevel
                push!(last(top.args), ret)
                top.fullspan += ret.fullspan
                top.span = top.fullspan - (ret.fullspan - ret.span)
            elseif kindof(ps.ws) == SemiColonWS
                push!(top, EXPR(:toplevel, EXPR[ret]))
            else
                push!(top, ret)
            end
            last_line = curr_line
            kindof(ps.nt) === Tokens.ENDMARKER && break # don't do loop check if eof
            prevpos = loop_check(ps, prevpos)
        end
    else
        if kindof(ps.nt) === Tokens.WHITESPACE || kindof(ps.nt) === Tokens.COMMENT
            next(ps)
            top = EXPR(:NOTHING, ps.nt.startbyte, ps.nt.startbyte, "")
        elseif !(ps.done || kindof(ps.nt) === Tokens.ENDMARKER)
            last_line = current_line(ps)
            if ps.nt.kind === Tokens.SEMICOLON
                next(ps)
                top = EXPR(:toplevel, EXPR[EXPR(:NOTHING, ps.nt.startbyte, ps.nt.startbyte, "")])
            else
                top = parse_doc(ps)
            end
            if kindof(ps.ws) == SemiColonWS# && curr_line == last_line
                top = EXPR(:toplevel, EXPR[top], nothing)
                prevpos = position(ps)
                while kindof(ps.ws) == SemiColonWS && current_line(ps) == last_line && kindof(ps.nt) != Tokens.ENDMARKER
                    last_line = current_line(ps)
                    ret = parse_doc(ps)
                    push!(top, ret)
                    prevpos = loop_check(ps, prevpos)
                end
            end
        else
            top = EXPR(:errortoken, EXPR[], nothing, 0, 0)
        end
    end

    return top, ps
end

function _continue_doc_parse(ps::ParseState, x::EXPR)
    kindof(ps.nt) !== Tokens.ENDMARKER &&
    headof(x) === :macrocall &&
    valof(x.args[1]) == "@doc" &&
    length(x.args) < 4 &&
    ps.t.endpos[1] + 1 == ps.nt.startpos[1]
end

include("precompile.jl")
_precompile()
end
