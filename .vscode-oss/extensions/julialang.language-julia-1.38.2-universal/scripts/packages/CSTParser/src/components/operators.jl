precedence(op::Int) = op < Tokens.end_assignments ?  AssignmentOp :
                       op < Tokens.end_pairarrow ? 2 :
                       op < Tokens.end_conditional ? ConditionalOp :
                       op < Tokens.end_arrow ?       ArrowOp :
                       op < Tokens.end_lazyor ?      LazyOrOp :
                       op < Tokens.end_lazyand ?     LazyAndOp :
                       op < Tokens.end_comparison ?  ComparisonOp :
                       op < Tokens.end_pipe ?        PipeOp :
                       op < Tokens.end_colon ?       ColonOp :
                       op < Tokens.end_plus ?        PlusOp :
                       op < Tokens.end_bitshifts ?   BitShiftOp :
                       op < Tokens.end_times ?       TimesOp :
                       op < Tokens.end_rational ?    RationalOp :
                       op < Tokens.end_power ?       PowerOp :
                       op < Tokens.end_decl ?        DeclarationOp :
                       op < Tokens.end_where ?       WhereOp : DotOp

precedence(kind::Tokens.Kind) = kind === Tokens.DDDOT ? DddotOp :
                        kind < Tokens.begin_assignments ? 0 :
                        kind < Tokens.end_assignments ?   AssignmentOp :
                        kind < Tokens.end_pairarrow ?   2 :
                       kind < Tokens.end_conditional ?    ConditionalOp :
                       kind < Tokens.end_arrow ?          ArrowOp :
                       kind < Tokens.end_lazyor ?         LazyOrOp :
                       kind < Tokens.end_lazyand ?        LazyAndOp :
                       kind < Tokens.end_comparison ?     ComparisonOp :
                       kind < Tokens.end_pipe ?           PipeOp :
                       kind < Tokens.end_colon ?          ColonOp :
                       kind < Tokens.end_plus ?           PlusOp :
                       kind < Tokens.end_bitshifts ?      BitShiftOp :
                       kind < Tokens.end_times ?          TimesOp :
                       kind < Tokens.end_rational ?       RationalOp :
                       kind < Tokens.end_power ?          PowerOp :
                       kind < Tokens.end_decl ?           DeclarationOp :
                       kind < Tokens.end_where ?          WhereOp :
                       kind < Tokens.end_dot ?            DotOp :
                       kind === Tokens.ANON_FUNC ? AnonFuncOp :
                       kind === Tokens.PRIME ?             PrimeOp : 20

precedence(x) = 0
precedence(x::AbstractToken) = precedence(kindof(x))
precedence(x::EXPR) = error()#precedence(kindof(x))

isoperator(x) = false
isoperator(t::AbstractToken) = isoperator(kindof(t))


isunaryop(op) = false
isunaryop(op::EXPR) = isoperator(op) && ((valof(op) == "<:" ||
                                          valof(op) == ">:" ||
                                          valof(op) == "+" ||
                                          valof(op) == "-" ||
                                          valof(op) == "!" ||
                                          valof(op) == "~" ||
                                          valof(op) == "¬" ||
                                          valof(op) == "&" ||
                                          valof(op) == "√" ||
                                          valof(op) == "∛"  ||
                                          valof(op) == "∜"  ||
                                          valof(op) == "::" ||
                                          valof(op) == "\$" ||
                                          valof(op) == ":" ||
                                          valof(op) == "⋆" ||
                                          valof(op) == "±" ||
                                          valof(op) == "∓") ||
                        (length(valof(op)) == 2 && valof(op)[1] == '.' && (valof(op)[2] == '+' ||
                                                                           valof(op)[2] == '-' ||
                                                                           valof(op)[2] == '!' ||
                                                                           valof(op)[2] == '~' ||
                                                                           valof(op)[2] == '¬' ||
                                                                           valof(op)[2] == '√' ||
                                                                           valof(op)[2] == '∛' ||
                                                                           valof(op)[2] == '∜' ||
                                                                           valof(op)[2] == '⋆' ||
                                                                           valof(op)[2] == '±' ||
                                                                           valof(op)[2] == '∓')))
isunaryop(t::AbstractToken) = isunaryop(kindof(t))
@static if VERSION < v"1.2.0"
    isunaryop(kind::Tokens.Kind) = kind === Tokens.ISSUBTYPE ||
                    kind === Tokens.ISSUPERTYPE ||
                    kind === Tokens.PLUS ||
                    kind === Tokens.MINUS ||
                    kind === Tokens.NOT ||
                    kind === Tokens.APPROX ||
                    kind === Tokens.NOT_SIGN ||
                    kind === Tokens.AND ||
                    kind === Tokens.SQUARE_ROOT ||
                    kind === Tokens.CUBE_ROOT ||
                    kind === Tokens.QUAD_ROOT ||
                    kind === Tokens.DECLARATION ||
                    kind === Tokens.EX_OR ||
                    kind === Tokens.COLON
else
    isunaryop(kind::Tokens.Kind) = kind === Tokens.ISSUBTYPE ||
                    kind === Tokens.ISSUPERTYPE ||
                    kind === Tokens.PLUS ||
                    kind === Tokens.MINUS ||
                    kind === Tokens.NOT ||
                    kind === Tokens.APPROX ||
                    kind === Tokens.NOT_SIGN ||
                    kind === Tokens.AND ||
                    kind === Tokens.SQUARE_ROOT ||
                    kind === Tokens.CUBE_ROOT ||
                    kind === Tokens.QUAD_ROOT ||
                    kind === Tokens.DECLARATION ||
                    kind === Tokens.EX_OR ||
                    kind === Tokens.COLON ||
                    kind === Tokens.STAR_OPERATOR
end

isunaryandbinaryop(t) = false
isunaryandbinaryop(t::AbstractToken) = isunaryandbinaryop(kindof(t))
@static if VERSION < v"1.2.0"
    isunaryandbinaryop(kind::Tokens.Kind) = kind === Tokens.PLUS ||
                            kind === Tokens.MINUS ||
                            kind === Tokens.EX_OR ||
                            kind === Tokens.ISSUBTYPE ||
                            kind === Tokens.ISSUPERTYPE ||
                            kind === Tokens.AND ||
                            kind === Tokens.APPROX ||
                            kind === Tokens.DECLARATION ||
                            kind === Tokens.COLON
else
    isunaryandbinaryop(kind::Tokens.Kind) = kind === Tokens.PLUS ||
                            kind === Tokens.MINUS ||
                            kind === Tokens.EX_OR ||
                            kind === Tokens.ISSUBTYPE ||
                            kind === Tokens.ISSUPERTYPE ||
                            kind === Tokens.AND ||
                            kind === Tokens.APPROX ||
                            kind === Tokens.DECLARATION ||
                            kind === Tokens.COLON ||
                            kind === Tokens.STAR_OPERATOR
end

isbinaryop(op) = false
isbinaryop(op::EXPR) = isoperator(op) && !(valof(op) == "√" ||
    valof(op) == "∛" ||
    valof(op) == "∜" ||
    valof(op) == "!" ||
    valof(op) == "¬")
isbinaryop(t::AbstractToken) = isbinaryop(kindof(t))
isbinaryop(kind::Tokens.Kind) = isoperator(kind) &&
                    !(kind === Tokens.SQUARE_ROOT ||
                    kind === Tokens.CUBE_ROOT ||
                    kind === Tokens.QUAD_ROOT ||
                    kind === Tokens.NOT ||
                    kind === Tokens.NOT_SIGN)

function non_dotted_op(t::AbstractToken)
    k = kindof(t)
    return (k === Tokens.COLON_EQ ||
            k === Tokens.PAIR_ARROW ||
            k === Tokens.EX_OR_EQ ||
            k === Tokens.CONDITIONAL ||
            k === Tokens.LAZY_OR ||
            k === Tokens.LAZY_AND ||
            k === Tokens.ISSUBTYPE ||
            k === Tokens.ISSUPERTYPE ||
            k === Tokens.LPIPE ||
            k === Tokens.RPIPE ||
            k === Tokens.EX_OR ||
            k === Tokens.COLON ||
            k === Tokens.DECLARATION ||
            k === Tokens.IN ||
            k === Tokens.ISA ||
            k === Tokens.WHERE ||
            (isunaryop(k) && !isbinaryop(k) && !(k === Tokens.NOT)))
end
isdotted(x::EXPR) = valof(x) isa String && length(valof(x)) > 1 && valof(x)[1] === '.' && !(valof(x) == "..." || valof(x) == "..")

issyntaxcall(op) = false
function issyntaxcall(op::EXPR)
    v = valof(op)
    if v[1] == '.' && length(v) > 1 && assign_prec(v[2:end]) && v[2] !== '~'
        return true
    end
    assign_prec(v) && !(v == "~" || v == ".~" || v == "=>") ||
    v == "-->" ||
    v == "||" ||
    v == ".||" ||
    v == "&&" ||
    v == ".&&" ||
    v == "<:" ||
    v == ">:" ||
    v == ":" ||
    v == "::" ||
    v == "." ||
    v == "..." ||
    v == "'" ||
    v == "where" ||
    v == "->"
end


issyntaxunarycall(op) = false
function issyntaxunarycall(op::EXPR)
    v = valof(op)
    !isdotted(op) && (v == "\$" || v == "&" || v == "::" || v == "..." || v == "'" || v == "<:" || v == ">:")
end



LtoR(prec::Int) = AssignmentOp ≤ prec ≤ LazyAndOp || prec == PowerOp


"""
    parse_unary(ps)

Having hit a unary operator at the start of an expression return a call.
"""
function parse_unary(ps::ParseState, op::EXPR)
    if is_colon(op)
        ret = parse_unary_colon(ps, op)
    elseif should_negate_number_literal(ps, op)
        arg = mLITERAL(next(ps))
        ret = EXPR(literalmap(kindof(ps.t)), op.fullspan + arg.fullspan, (op.fullspan + arg.span), string(is_plus(op) ? "+" : "-", val(ps.t, ps)))
    else
        prec = valof(op) == "::" ? DeclarationOp :
                valof(op) == "&" ? DeclarationOp :
                valof(op) == "\$" ? 20 : PowerOp
        arg = @closer ps :unary @precedence ps prec parse_expression(ps)
        if issyntaxunarycall(op)
            ret = EXPR(op, EXPR[arg], nothing)
        else
            ret = EXPR(:call, EXPR[op, arg], nothing)
        end
    end
    return ret
end

function parse_unary_colon(ps::ParseState, op::EXPR)
    op = requires_no_ws(op, ps)
    if Tokens.iskeyword(kindof(ps.nt)) && op.span == op.fullspan
        ret = EXPR(:quotenode, EXPR[EXPR(:IDENTIFIER, next(ps))], EXPR[op])
    elseif isidentifier(ps.nt)
        id = INSTANCE(next(ps))
        if VERSION > v"1.3.0-" && valof(id) == "var" && isemptyws(ps.ws) && (ps.nt.kind === Tokens.STRING || ps.nt.kind === Tokens.TRIPLE_STRING)
            # Special case for :var"sdf"
            arg = parse_string_or_cmd(next(ps), id)
            id = EXPR(:NONSTDIDENTIFIER, EXPR[id, arg], nothing)
        end
        ret = EXPR(:quotenode, EXPR[id], EXPR[op])
    elseif Tokens.begin_literal < kindof(ps.nt) < Tokens.CHAR ||
            isoperator(kindof(ps.nt)) || isidentifier(ps.nt) || kindof(ps.nt) === Tokens.TRUE || kindof(ps.nt) === Tokens.FALSE
        ret = EXPR(:quotenode, EXPR[INSTANCE(next(ps))], EXPR[op])
    elseif closer(ps)
        ret = op
    else
        prev_errored = ps.errored
        enable!(ps, ParserFlags.InQuote)
        arg = @precedence ps 20 @nocloser ps :inref parse_expression(ps)
        disable!(ps, ParserFlags.InQuote)
        if isbracketed(arg) && headof(arg.args[1]) === :errortoken && errorof(arg.args[1]) === UnexpectedAssignmentOp
            ps.errored = prev_errored
            arg.args[1] = arg.args[1].args[1]
            setparent!(arg.args[1], arg)
        end
        # TODO: need special conversion where arg is a n-bracketed terminal (not keywords)
        unwrapped = unwrapbracket(arg)
        if isoperator(unwrapped) || isidentifier(unwrapped) || isliteral(unwrapped)
            ret = EXPR(:quotenode, EXPR[arg], EXPR[op])
        elseif arg.head == :tuple && length(arg.args) == 1 && arg.args[1].head == :parameters && arg.args[1].args !== nothing && length(arg.args[1].args) == 0 && arg.span > 3
            block = EXPR(:BLOCK, EXPR[], EXPR[])
            block.span = arg.span
            block.fullspan = arg.fullspan
            ret = EXPR(:quote, EXPR[block], EXPR[op])
        else
            ret = EXPR(:quote, EXPR[arg], EXPR[op])
        end
    end
    return ret
end

function parse_operator_eq(ps::ParseState, ret::EXPR, op::EXPR)
    nextarg = @precedence ps AssignmentOp - LtoR(AssignmentOp) parse_expression(ps)

    if is_func_call(ret) && !(isbeginorblock(nextarg))
        nextarg = EXPR(:block, EXPR[nextarg], nothing)
    end
    if issyntaxcall(op)
        ret = EXPR(op, EXPR[ret, nextarg], nothing)
    else
        ret = EXPR(:call, EXPR[op, ret, nextarg], nothing)
    end
    return ret
end

# Parse conditionals

isconditional(x::EXPR) = headof(x) === :if && hastrivia(x) && isoperator(first(x.trivia))
function parse_operator_cond(ps::ParseState, ret::EXPR, op::EXPR)
    ret = requires_ws(ret, ps)
    op = requires_ws(op, ps)
    nextarg = @closer ps :ifop parse_expression(ps)
    if kindof(ps.nt) !== Tokens.COLON
        op2 = mErrorToken(ps, EXPR(:OPERATOR, 0, 0, ":"), MissingColon)
        nextarg2 = mErrorToken(ps, Unknown)
        return EXPR(:if, EXPR[ret, nextarg, nextarg2], EXPR[op, op2])
    else
        op2 = requires_ws(EXPR(:OPERATOR, next(ps)), ps)
    end

    nextarg2 = @closer ps :comma @precedence ps 0 parse_expression(ps)

    return EXPR(:if, EXPR[ret, nextarg, nextarg2], EXPR[op, op2])
end

# Parse comparisons
function parse_comp_operator(ps::ParseState, ret::EXPR, op::EXPR)
    nextarg = @precedence ps ComparisonOp - LtoR(ComparisonOp) parse_expression(ps)

    if headof(ret) === :comparison
        push!(ret, op)
        push!(ret, nextarg)
    elseif can_become_comparison(ret)
        if isoperator(headof(ret))
            ret = EXPR(:comparison, EXPR[ret.args[1], ret.head, ret.args[2], op, nextarg], nothing)
        else
            ret = EXPR(:comparison, EXPR[ret.args[2], ret.args[1], ret.args[3], op, nextarg], nothing)
        end
    elseif issyntaxcall(op)
        ret = EXPR(op, EXPR[ret, nextarg], nothing)
    else
        ret = EXPR(:call, EXPR[op, ret, nextarg], nothing)
    end
    return ret
end

# Parse ranges
function parse_operator_colon(ps::ParseState, ret::EXPR, op::EXPR)
    if isnewlinews(ps.ws) && !ps.closer.paren
        op = mErrorToken(ps, op, UnexpectedNewLine)
    end
    nextarg = @precedence ps ColonOp - LtoR(ColonOp) parse_expression(ps)

    if isbinarycall(ret) && is_colon(ret.args[1])
        ret.trivia = EXPR[]
        pushtotrivia!(ret, op)
        push!(ret, nextarg)
    else
        ret = EXPR(:call, EXPR[op, ret, nextarg], nothing)
    end
    return ret
end

# Parse power (special case for preceding unary ops)
function parse_operator_power(ps::ParseState, ret::EXPR, op::EXPR)
    nextarg = @precedence ps PowerOp - LtoR(PowerOp) @closer ps :inwhere parse_expression(ps)

    if isunarycall(ret)
        # TODO: this smells wrong
        nextarg = EXPR(:call, EXPR[op, ret.args[2], nextarg], nothing)
        ret = EXPR(:call, EXPR[ret.args[1], nextarg], nothing)
    else
        ret = EXPR(:call, EXPR[op, ret, nextarg], nothing)
    end
    return ret
end

# parse where
function parse_operator_where(ps::ParseState, ret::EXPR, op::EXPR, setscope=true)
    nextarg = @precedence ps LazyAndOp @closer ps :inwhere parse_expression(ps)
    if headof(nextarg) === :braces
        pushfirst!(nextarg.args, ret)
        pushfirst!(nextarg.trivia, op)
        ret = EXPR(:where, nextarg.args,nextarg.trivia)
    else
        ret = EXPR(:where, EXPR[ret, nextarg], EXPR[op])
    end
    return ret
end

function rewrite_macrocall_quotenode(op, ret, nextarg)
    mname = EXPR(op, EXPR[ret, EXPR(:quotenode, EXPR[nextarg.args[1]], nothing)], nothing)
    ret = EXPR(:macrocall, EXPR[mname], nextarg.trivia)
    for i = 2:length(nextarg.args)
        push!(ret, nextarg.args[i])
    end
    return ret
end

function parse_operator_dot(ps::ParseState, ret::EXPR, op::EXPR)
    if kindof(ps.nt) === Tokens.LPAREN
        @static if VERSION > v"1.1-"
            iserred = kindof(ps.ws) != Tokens.EMPTY_WS
            sig = @default ps parse_call(ps, ret)
            nextarg = EXPR(:tuple, sig.args[2:end], sig.trivia)
            if iserred
                nextarg = mErrorToken(ps, nextarg, UnexpectedWhiteSpace)
            end
        else
            sig = @default ps parse_call(ps, ret)
            nextarg = EXPR(:tuple, sig.args[2:end], sig.trivia)
        end
    elseif iskeyword(ps.nt) || both_symbol_and_op(ps.nt)
        nextarg = EXPR(:IDENTIFIER, next(ps))
    elseif kindof(ps.nt) === Tokens.COLON
        op2 = EXPR(:OPERATOR, next(ps))
        if kindof(ps.nt) === Tokens.LPAREN
            nextarg = @closeparen ps @precedence ps DotOp - LtoR(DotOp) parse_expression(ps)
            nextarg = EXPR(:quotenode, EXPR[nextarg], EXPR[op2])
        else
            nextarg = @precedence ps DotOp - LtoR(DotOp) parse_unary(ps, op2)
        end
    elseif kindof(ps.nt) === Tokens.EX_OR && kindof(ps.nnt) === Tokens.LPAREN
        op2 = EXPR(:OPERATOR, next(ps))
        nextarg = parse_call(ps, op2)
    else
        nextarg = @precedence ps DotOp - LtoR(DotOp) parse_expression(ps)
    end

    if isidentifier(nextarg) || isinterpolant(nextarg)
        ret = EXPR(op, EXPR[ret, EXPR(:quotenode, EXPR[nextarg], nothing)], nothing)
    elseif headof(nextarg) === :vect || headof(nextarg) === :braces
        ret = EXPR(op, EXPR[ret, EXPR(:quote, EXPR[nextarg], nothing)], nothing)
    elseif headof(nextarg) === :macrocall
        ret = rewrite_macrocall_quotenode(op, ret, nextarg)
    elseif VERSION >= v"1.8.0-" && headof(nextarg) === :do && headof(nextarg.args[1]) === :macrocall
        mcall = rewrite_macrocall_quotenode(op, ret, nextarg.args[1])

        ret = EXPR(:do, EXPR[mcall], nextarg.trivia)
        for i = 2:length(nextarg.args)
            push!(ret, nextarg.args[i])
        end
    else
        ret = EXPR(op, EXPR[ret, nextarg], nothing)
    end
    return ret
end

function parse_operator_anon_func(ps::ParseState, ret::EXPR, op::EXPR)
    arg = @closer ps :comma @precedence ps 0 parse_expression(ps)
    if !isbeginorblock(arg)
        arg = EXPR(:block, EXPR[arg], nothing)
    end
    return EXPR(op, EXPR[ret, arg], nothing)
end

function parse_operator_pair(ps::ParseState, ret::EXPR, op::EXPR)
    arg = @closer ps :comma @precedence ps 0 parse_expression(ps)
    return EXPR(:call, EXPR[op, ret, arg], nothing)
end

function parse_operator(ps::ParseState, ret::EXPR, op::EXPR)
    P = isdotted(op) ? get_prec(valof(op)[2:end]) : get_prec(valof(op))
    if op.val == "*" && op.fullspan == 0 # implicit multiplication has a very high precedence, but lower than ^
        P = RationalOp
    end
    if headof(ret) === :call && (is_plus(ret.args[1]) || is_star(ret.args[1])) &&
          valof(ret.args[1]) == valof(op) && ret.args[1].span > 0 &&
          !(hastrivia(ret) && headof(ret[end]) === :RPAREN)
        # a + b -> a + b + c
        nextarg = @precedence ps P - LtoR(P) parse_expression(ps)
        !hastrivia(ret) && (ret.trivia = EXPR[])
        pushtotrivia!(ret, op)
        push!(ret, nextarg)
        ret = ret
    elseif is_eq(op)
        ret = parse_operator_eq(ps, ret, op)
    elseif is_cond(op)
        ret = parse_operator_cond(ps, ret, op)
    elseif is_colon(op)
        ret = parse_operator_colon(ps, ret, op)
    elseif is_where(op)
        ret = parse_operator_where(ps, ret, op)
    elseif is_anon_func(op)
        ret = parse_operator_anon_func(ps, ret, op)
    elseif is_dot(op)
        ret = parse_operator_dot(ps, ret, op)
    elseif is_dddot(op)
        ret = EXPR(op, EXPR[ret], nothing)
    elseif is_prime(op)
        if isidentifier(ret) || isliteral(ret) ||
                headof(ret) in (
                    :call, :tuple, :brackets, :ref, :vect, :vcat, :hcat, :ncat, :typed_vcat,
                    :typed_hcat, :typed_ncat, :comprehension, :typed_comprehension, :curly,
                    :braces, :braces_cat
                ) ||
                headof(ret) === :do ||
                is_dot(headof(ret)) ||
                is_prime(headof(ret))
            if valof(op) == "'"
                ret = EXPR(op, EXPR[ret], nothing)
            else
                ret = EXPR(:call, EXPR[op, ret], nothing)
            end
        else
            ret = EXPR(:errortoken, EXPR[ret, op])
            ret.meta = UnexpectedToken
        end
    elseif P == ComparisonOp
        ret = parse_comp_operator(ps, ret, op)
    elseif P == PowerOp
        ret = parse_operator_power(ps, ret, op)
    elseif P == 2
        ret = parse_operator_pair(ps, ret, op)
    else
        ltor = valof(op) == "<|" ? true : LtoR(P)
        nextarg = @precedence ps P - ltor parse_expression(ps)
        if issyntaxcall(op)
            ret = EXPR(op, EXPR[ret, nextarg], nothing)
        else
            ret = EXPR(:call, EXPR[op, ret, nextarg], nothing)
        end
    end
    return ret
end

assign_prec(op::String) = get(AllPrecs, op, 0) === AssignmentOp || (length(op) > 1 && op[1] == '.' && assign_prec(op[2:end]))
comp_prec(op::String) = get(AllPrecs, op, 0) === ComparisonOp || (length(op) > 1 && op[1] == '.' && comp_prec(op[2:end]))

# Which ops have different precend when dotted?
# [op for op in Symbol.(keys(CSTParser.AllPrecs)) if Base.isoperator(op) && Base.isoperator(Symbol(".", op)) && Base.operator_precedence(op) !== Base.operator_precedence(Symbol(".", op))]

get_prec(op) = get(AllPrecs, maybe_strip_suffix(op), 0)

function maybe_strip_suffix(op::String)
    for (i, c) in enumerate(op)
        if Tokenize.Lexers.isopsuffix(c)
            return op[1:prevind(op, i)]
        end
    end
    return op
end

const AllPrecs = Dict(
    "≏" => PlusOp,
    "⤎" => ArrowOp,
    "<:" => ComparisonOp,
    "⫌" => ComparisonOp,
    "⇀" => ArrowOp,
    "≁" => ComparisonOp,
    "⧀" => ComparisonOp,
    "⪎" => ComparisonOp,
    "⪱" => ComparisonOp,
    "↬" => ArrowOp,
    "⇝" => ArrowOp,
    "⩳" => ComparisonOp,
    "⪻" => ComparisonOp,
    "//" => RationalOp,
    "⬿" => ArrowOp,
    "⊅" => ComparisonOp,
    "⋳" => ComparisonOp,
    "≮" => ComparisonOp,
    "\$=" => AssignmentOp,
    "≗" => ComparisonOp,
    "⋗" => ComparisonOp,
    "⩊" => PlusOp,
    "⪵" => ComparisonOp,
    "⋟" => ComparisonOp,
    "⤠" => ArrowOp,
    "≵" => ComparisonOp,
    "⧁" => ComparisonOp,
    "≫" => ComparisonOp,
    "⩫" => ComparisonOp,
    "⪸" => ComparisonOp,
    "⊓" => TimesOp,
    "⭄" => ArrowOp,
    "⇁" => ArrowOp,
    "≀" => TimesOp,
    "⪚" => ComparisonOp,
    "∷" => ComparisonOp,
    "⥪" => ArrowOp,
    "⥔" => PowerOp,
    "⊻" => PlusOp,
    "⩯" => ComparisonOp,
    "↷" => ArrowOp,
    "⇿" => ArrowOp,
    "⪉" => ComparisonOp,
    "⊰" => ComparisonOp,
    "⨟" => TimesOp,
    "⩻" => ComparisonOp,
    "⭋" => ArrowOp,
    "⩒" => PlusOp,
    "-" => PlusOp,
    "−" => PlusOp,
    "⫸" => ComparisonOp,
    "⤒" => PowerOp,
    "+=" => AssignmentOp,
    "↦" => ArrowOp,
    "⊜" => ComparisonOp,
    "|>" => PipeOp,
    "⩀" => TimesOp,
    "⪫" => ComparisonOp,
    "≡" => ComparisonOp,
    "⋹" => ComparisonOp,
    "⤑" => ArrowOp,
    "⥐" => ArrowOp,
    "≭" => ComparisonOp,
    "≼" => ComparisonOp,
    "⥇" => ArrowOp,
    "⋶" => ComparisonOp,
    "⨸" => TimesOp,
    "⩽" => ComparisonOp,
    "⪐" => ComparisonOp,
    "⨥" => PlusOp,
    "∊" => ComparisonOp,
    "⪙" => ComparisonOp,
    "⥢" => ArrowOp,
    "⅋" => TimesOp,
    "⫘" => ComparisonOp,
    "⊂" => ComparisonOp,
    "⩸" => ComparisonOp,
    "⩄" => TimesOp,
    "⤞" => ArrowOp,
    "⫍" => ComparisonOp,
    "⨢" => PlusOp,
    "⊄" => ComparisonOp,
    "≯" => ComparisonOp,
    "===" => ComparisonOp,
    "⬺" => ArrowOp,
    "⪛" => ComparisonOp,
    "⋡" => ComparisonOp,
    "⫀" => ComparisonOp,
    "⨣" => PlusOp,
    "↞" => ArrowOp,
    "⟾" => ArrowOp,
    "⊬" => ComparisonOp,
    "⇌" => ArrowOp,
    "≷" => ComparisonOp,
    "∓" => PlusOp,
    "⪶" => ComparisonOp,
    "⊀" => ComparisonOp,
    "⊛" => TimesOp,
    "⋠" => ComparisonOp,
    "↢" => ArrowOp,
    "⥦" => ArrowOp,
    "⪪" => ComparisonOp,
    "⋌" => TimesOp,
    "⪅" => ComparisonOp,
    "≿" => ComparisonOp,
    ">>=" => AssignmentOp,
    "\$" => PlusOp,
    "≽" => ComparisonOp,
    "⪟" => ComparisonOp,
    "⋆" => TimesOp,
    "±" => PlusOp,
    "⋴" => ComparisonOp,
    "⥧" => ArrowOp,
    "/" => TimesOp,
    "⥕" => PowerOp,
    "." => DotOp,
    "⩢" => PlusOp,
    "⟖" => TimesOp,
    "⪗" => ComparisonOp,
    "≓" => ComparisonOp,
    "⋨" => ComparisonOp,
    "⥜" => PowerOp,
    "⪊" => ComparisonOp,
    "⨽" => TimesOp,
    "⪦" => ComparisonOp,
    "≱" => ComparisonOp,
    "⧷" => TimesOp,
    ">>" => BitShiftOp,
    "⊏" => ComparisonOp,
    "⬴" => ArrowOp,
    "⪴" => ComparisonOp,
    "⁝" => ColonOp,
    "⤘" => ArrowOp,
    "⩜" => TimesOp,
    "￬" => PowerOp,
    "∤" => TimesOp,
    "⩲" => ComparisonOp,
    "⫙" => ComparisonOp,
    "⇵" => PowerOp,
    "⤗" => ArrowOp,
    "⪀" => ComparisonOp,
    "⩬" => ComparisonOp,
    "↫" => ArrowOp,
    "&" => TimesOp,
    "⩺" => ComparisonOp,
    "↚" => ArrowOp,
    "⨇" => TimesOp,
    "⋭" => ComparisonOp,
    "≐" => ComparisonOp,
    "∩" => TimesOp,
    "↓" => PowerOp,
    "⪓" => ComparisonOp,
    "≦" => ComparisonOp,
    "=" => AssignmentOp,
    "∧" => TimesOp,
    "⇇" => ArrowOp,
    "≖" => ComparisonOp,
    "⇸" => ArrowOp,
    "⋙" => ComparisonOp,
    "≚" => ComparisonOp,
    "⇴" => ArrowOp,
    "⬲" => ArrowOp,
    "⥙" => PowerOp,
    "⋢" => ComparisonOp,
    "⫹" => ComparisonOp,
    "⩛" => PlusOp,
    "⋿" => ComparisonOp,
    "⪑" => ComparisonOp,
    "⭉" => ArrowOp,
    "⋎" => PlusOp,
    "⋋" => TimesOp,
    "⇋" => ArrowOp,
    "≴" => ComparisonOp,
    "…" => ColonOp,
    "⪰" => ComparisonOp,
    "↺" => ArrowOp,
    "⪖" => ComparisonOp,
    "⨦" => PlusOp,
    "⬼" => ArrowOp,
    "⤐" => ArrowOp,
    "⊗" => TimesOp,
    "⨮" => PlusOp,
    "⊚" => TimesOp,
    "⥈" => ArrowOp,
    "≣" => ComparisonOp,
    "⋫" => ComparisonOp,
    "≺" => ComparisonOp,
    "⇽" => ArrowOp,
    "⬳" => ArrowOp,
    "⥨" => ArrowOp,
    "⋽" => ComparisonOp,
    "⩟" => TimesOp,
    "⋞" => ComparisonOp,
    "⩖" => PlusOp,
    "⧥" => ComparisonOp,
    "⨝" => TimesOp,
    "⪕" => ComparisonOp,
    "⊟" => PlusOp,
    "⋑" => ComparisonOp,
    "⊲" => ComparisonOp,
    "≟" => ComparisonOp,
    "⫈" => ComparisonOp,
    "⥋" => ArrowOp,
    "⩂" => PlusOp,
    "⥏" => PowerOp,
    "⥩" => ArrowOp,
    "⥑" => PowerOp,
    "⪤" => ComparisonOp,
    "⫖" => ComparisonOp,
    "×" => TimesOp,
    "÷=" => AssignmentOp,
    "⋪" => ComparisonOp,
    "⫓" => ComparisonOp,
    "⫄" => ComparisonOp,
    "⊋" => ComparisonOp,
    "⇆" => ArrowOp,
    "⤌" => ArrowOp,
    "⟹" => ArrowOp,
    "⊖" => PlusOp,
    "⫏" => ComparisonOp,
    "⫷" => ComparisonOp,
    "⪜" => ComparisonOp,
    "⊕" => PlusOp,
    "%=" => AssignmentOp,
    "⊍" => TimesOp,
    "⨤" => PlusOp,
    "≃" => ComparisonOp,
    "⩪" => ComparisonOp,
    "⤉" => PowerOp,
    "⪽" => ComparisonOp,
    "⋓" => PlusOp,
    "⤀" => ArrowOp,
    "∺" => ComparisonOp,
    "⤆" => ArrowOp,
    "⊳" => ComparisonOp,
    "//=" => AssignmentOp,
    "≒" => ComparisonOp,
    "⩦" => ComparisonOp,
    "↶" => ArrowOp,
    "⊡" => TimesOp,
    "⟈" => ComparisonOp,
    "≩" => ComparisonOp,
    "||" => LazyOrOp,
    "↠" => ArrowOp,
    "⥒" => ArrowOp,
    "⨧" => PlusOp,
    "⪧" => ComparisonOp,
    "⨪" => PlusOp,
    "⇹" => ArrowOp,
    "⥛" => ArrowOp,
    "↣" => ArrowOp,
    "⫁" => ComparisonOp,
    "⭊" => ArrowOp,
    "⋜" => ComparisonOp,
    "⪳" => ComparisonOp,
    "⋼" => ComparisonOp,
    "⥍" => PowerOp,
    "⫎" => ComparisonOp,
    "^=" => AssignmentOp,
    "⪢" => ComparisonOp,
    "∪" => PlusOp,
    "⩅" => PlusOp,
    "⬵" => ArrowOp,
    "⬽" => ArrowOp,
    "≬" => ComparisonOp,
    "⧶" => TimesOp,
    "⪡" => ComparisonOp,
    "≶" => ComparisonOp,
    "⇼" => ArrowOp,
    "^" => PowerOp,
    "⇷" => ArrowOp,
    "⋸" => ComparisonOp,
    "⊩" => ComparisonOp,
    "⭀" => ArrowOp,
    "⧴" => ArrowOp,
    "⊷" => ComparisonOp,
    "⤔" => ArrowOp,
    "~" => AssignmentOp,
    "⫒" => ComparisonOp,
    "⩼" => ComparisonOp,
    "⧺" => PlusOp,
    "⧻" => PlusOp,
    ">>>=" => AssignmentOp,
    "⪂" => ComparisonOp,
    "⨻" => TimesOp,
    "⤏" => ArrowOp,
    "⥘" => PowerOp,
    "≕" => AssignmentOp,
    "⥓" => ArrowOp,
    "⨰" => TimesOp,
    "⨺" => PlusOp,
    "⟵" => ArrowOp,
    "⇜" => ArrowOp,
    "<<=" => AssignmentOp,
    "≔" => AssignmentOp,
    "⩋" => TimesOp,
    "⫊" => ComparisonOp,
    "⪠" => ComparisonOp,
    "⥬" => ArrowOp,
    "⥖" => ArrowOp,
    "⪣" => ComparisonOp,
    "↔" => ArrowOp,
    "≥" => ComparisonOp,
    "⧤" => ComparisonOp,
    "⤄" => ArrowOp,
    "⊢" => ComparisonOp,
    "⋛" => ComparisonOp,
    "⩔" => PlusOp,
    "⇶" => ArrowOp,
    "⤇" => ArrowOp,
    "⟽" => ArrowOp,
    "⩵" => ComparisonOp,
    "⬶" => ArrowOp,
    "⩌" => PlusOp,
    "↮" => ArrowOp,
    "⪾" => ComparisonOp,
    "⋕" => ComparisonOp,
    "⥤" => ArrowOp,
    "∋" => ComparisonOp,
    "↽" => ArrowOp,
    "⋇" => TimesOp,
    "⪍" => ComparisonOp,
    "⩃" => TimesOp,
    "⨈" => PlusOp,
    "⋚" => ComparisonOp,
    "⩐" => PlusOp,
    "≾" => ComparisonOp,
    "⋤" => ComparisonOp,
    "∔" => PlusOp,
    "⤈" => PowerOp,
    "⇾" => ArrowOp,
    "⊮" => ComparisonOp,
    "⪩" => ComparisonOp,
    "⬷" => ArrowOp,
    "↪" => ArrowOp,
    "⭇" => ArrowOp,
    "⨨" => PlusOp,
    "⩓" => TimesOp,
    "⤊" => PowerOp,
    "↤" => ArrowOp,
    "⊱" => ComparisonOp,
    "⟼" => ArrowOp,
    "⨴" => TimesOp,
    "⤋" => PowerOp,
    "⊴" => ComparisonOp,
    "≊" => ComparisonOp,
    "⧡" => ComparisonOp,
    "⫆" => ComparisonOp,
    "⋯" => ColonOp,
    "≜" => ComparisonOp,
    "∍" => ComparisonOp,
    "::" => DeclarationOp,
    "⥣" => PowerOp,
    "⪃" => ComparisonOp,
    "⪹" => ComparisonOp,
    "⩴" => AssignmentOp,
    "⥫" => ArrowOp,
    "￫" => ArrowOp,
    ">>>" => BitShiftOp,
    "≢" => ComparisonOp,
    "⊈" => ComparisonOp,
    "≤" => ComparisonOp,
    "⟿" => ArrowOp,
    "⪨" => ComparisonOp,
    "⋖" => ComparisonOp,
    "⫉" => ComparisonOp,
    "⩹" => ComparisonOp,
    "￪" => PowerOp,
    "⊆" => ComparisonOp,
    "!==" => ComparisonOp,
    "⪔" => ComparisonOp,
    "⥎" => ArrowOp,
    "≋" => ComparisonOp,
    "⊁" => ComparisonOp,
    "⋥" => ComparisonOp,
    "⋉" => TimesOp,
    "⨱" => TimesOp,
    "?" => ConditionalOp,
    "⥚" => ArrowOp,
    "⋷" => ComparisonOp,
    "⟒" => ComparisonOp,
    "⫅" => ComparisonOp,
    "⪏" => ComparisonOp,
    "⩕" => TimesOp,
    "⪞" => ComparisonOp,
    ">:" => ComparisonOp,
    "⟗" => TimesOp,
    "⪷" => ComparisonOp,
    "⩎" => TimesOp,
    "⬱" => ArrowOp,
    "⇺" => ArrowOp,
    "⩁" => PlusOp,
    "⥆" => ArrowOp,
    "⊘" => TimesOp,
    "⨼" => TimesOp,
    "⊙" => TimesOp,
    "⊇" => ComparisonOp,
    "⋍" => ComparisonOp,
    "≛" => ComparisonOp,
    "⊒" => ComparisonOp,
    "⋏" => TimesOp,
    "⭁" => ArrowOp,
    "⤂" => ArrowOp,
    "⥄" => ArrowOp,
    "⋝" => ComparisonOp,
    "÷" => TimesOp,
    "⧣" => ComparisonOp,
    "⊞" => PlusOp,
    "⬾" => ArrowOp,
    "⇉" => ArrowOp,
    "⨶" => TimesOp,
    "in" => ComparisonOp,
    "==" => ComparisonOp,
    "⟶" => ArrowOp,
    "⬰" => ArrowOp,
    ":=" => AssignmentOp,
    "⪋" => ComparisonOp,
    "≂" => ComparisonOp,
    "<|" => PipeOp,
    "⥊" => ArrowOp,
    "⪺" => ComparisonOp,
    "≎" => ComparisonOp,
    "≈" => ComparisonOp,
    "∌" => ComparisonOp,
    "⨹" => PlusOp,
    "⪘" => ComparisonOp,
    "⨵" => TimesOp,
    "⦾" => TimesOp,
    "⇒" => ArrowOp,
    ".." => ColonOp,
    "⇛" => ArrowOp,
    "⪿" => ComparisonOp,
    "≹" => ComparisonOp,
    "⋱" => ColonOp,
    "⇎" => ArrowOp,
    "→" => ArrowOp,
    "⥮" => PowerOp,
    "-=" => AssignmentOp,
    "−=" => AssignmentOp,
    "<" => ComparisonOp,
    "⪇" => ComparisonOp,
    "⥗" => ArrowOp,
    "⪈" => ComparisonOp,
    "⨫" => PlusOp,
    "⥞" => ArrowOp,
    "⭂" => ArrowOp,
    "⩠" => TimesOp,
    "\\" => TimesOp,
    "⩿" => ComparisonOp,
    "↑" => PowerOp,
    "≳" => ComparisonOp,
    "⋧" => ComparisonOp,
    "⩧" => ComparisonOp,
    "--" => 0,
    "⪮" => ComparisonOp,
    "⪄" => ComparisonOp,
    "⊎" => PlusOp,
    "⩾" => ComparisonOp,
    "↝" => ArrowOp,
    "⨲" => TimesOp,
    "⊐" => ComparisonOp,
    "⟻" => ArrowOp,
    "⫗" => ComparisonOp,
    "⩞" => TimesOp,
    "⥯" => PowerOp,
    "⪌" => ComparisonOp,
    "≨" => ComparisonOp,
    "⋄" => TimesOp,
    "⪯" => ComparisonOp,
    "⦸" => TimesOp,
    "⫐" => ComparisonOp,
    "↜" => ArrowOp,
    "≧" => ComparisonOp,
    "∉" => ComparisonOp,
    "⤟" => ArrowOp,
    "⋾" => ComparisonOp,
    "￩" => ArrowOp,
    "<<" => BitShiftOp,
    "≞" => ComparisonOp,
    "⩍" => TimesOp,
    "⇄" => ArrowOp,
    "▷" => TimesOp,
    "⋘" => ComparisonOp,
    "≇" => ComparisonOp,
    "⇏" => ArrowOp,
    "⊶" => ComparisonOp,
    "⫇" => ComparisonOp,
    "*" => TimesOp,
    "⩣" => PlusOp,
    "⬸" => ArrowOp,
    "⥥" => PowerOp,
    "≙" => ComparisonOp,
    "*=" => AssignmentOp,
    "≄" => ComparisonOp,
    "⊑" => ComparisonOp,
    "⫑" => ComparisonOp,
    "⩗" => PlusOp,
    "⟷" => ArrowOp,
    "⟱" => PowerOp,
    "≻" => ComparisonOp,
    "⋲" => ComparisonOp,
    "≑" => ComparisonOp,
    "⭈" => ArrowOp,
    "∾" => ComparisonOp,
    "&=" => AssignmentOp,
    "≪" => ComparisonOp,
    "↼" => ArrowOp,
    "⬹" => ArrowOp,
    "∗" => TimesOp,
    "⊣" => ComparisonOp,
    "⫺" => ComparisonOp,
    "⥌" => PowerOp,
    "⋩" => ComparisonOp,
    "≲" => ComparisonOp,
    "≝" => ComparisonOp,
    "⊽" => PlusOp,
    "/=" => AssignmentOp,
    "⋬" => ComparisonOp,
    "⩶" => ComparisonOp,
    "⫛" => TimesOp,
    "=>" => ConditionalOp,
    "⪁" => ComparisonOp,
    "⨩" => PlusOp,
    "⥝" => PowerOp,
    "⩝" => PlusOp,
    "⟕" => TimesOp,
    "⤖" => ArrowOp,
    "⥉" => PowerOp,
    "⩏" => PlusOp,
    "!=" => ComparisonOp,
    "⨳" => TimesOp,
    "≰" => ComparisonOp,
    "⟂" => ComparisonOp,
    "⋐" => ComparisonOp,
    "\\=" => AssignmentOp,
    "⤝" => ArrowOp,
    "⦷" => ComparisonOp,
    "⊔" => PlusOp,
    ">" => ComparisonOp,
    "⥰" => ArrowOp,
    "∽" => ComparisonOp,
    "⋦" => ComparisonOp,
    "⤅" => ArrowOp,
    "⫕" => ComparisonOp,
    "⋺" => ComparisonOp,
    "∈" => ComparisonOp,
    "∙" => TimesOp,
    "⥅" => ArrowOp,
    "⦼" => TimesOp,
    "<=" => ComparisonOp,
    "←" => ArrowOp,
    "isa" => ComparisonOp,
    "⋻" => ComparisonOp,
    "⫔" => ComparisonOp,
    "⋵" => ComparisonOp,
    "⋅" => TimesOp,
    "·" => TimesOp,
    "⨷" => TimesOp,
    "⟰" => PowerOp,
    "∨" => PlusOp,
    "≆" => ComparisonOp,
    "⪥" => ComparisonOp,
    "≍" => ComparisonOp,
    "⪝" => ComparisonOp,
    "⫂" => ComparisonOp,
    "⊻=" => AssignmentOp,
    "⨭" => PlusOp,
    "⋒" => TimesOp,
    "⦿" => TimesOp,
    "≸" => ComparisonOp,
    "⥡" => PowerOp,
    "+" => PlusOp,
    "⇻" => ArrowOp,
    "⥟" => ArrowOp,
    "⟉" => ComparisonOp,
    "⊵" => ComparisonOp,
    "⩰" => ComparisonOp,
    "%" => TimesOp,
    "⫃" => ComparisonOp,
    "∸" => PlusOp,
    "⋣" => ComparisonOp,
    "-->" => ArrowOp,
    "<--" => ArrowOp,
    "<-->" => ArrowOp,
    "∥" => ComparisonOp,
    "∦" => ComparisonOp,
    "⋮" => ColonOp,
    "⪒" => ComparisonOp,
    "⤃" => ArrowOp,
    "⟑" => TimesOp,
    "⩑" => TimesOp,
    "⋰" => ColonOp,
    "⪬" => ComparisonOp,
    "≠" => ComparisonOp,
    "≅" => ComparisonOp,
    "⊼" => TimesOp,
    "⬻" => ArrowOp,
    "⩘" => TimesOp,
    "⭃" => ArrowOp,
    "⥭" => ArrowOp,
    "⤕" => ArrowOp,
    "≘" => ComparisonOp,
    "⇠" => ArrowOp,
    "⟺" => ArrowOp,
    "⪼" => ComparisonOp,
    "⇢" => ArrowOp,
    "↩" => ArrowOp,
    "⋊" => TimesOp,
    "&&" => LazyAndOp,
    "⩚" => TimesOp,
    "⩮" => ComparisonOp,
    "⤓" => PowerOp,
    "⥠" => PowerOp,
    "⤁" => ArrowOp,
    "≌" => ComparisonOp,
    "⭌" => ArrowOp,
    "⇐" => ArrowOp,
    ":" => ColonOp,
    "⇍" => ArrowOp,
    "⩭" => ComparisonOp,
    "↛" => ArrowOp,
    "↻" => ArrowOp,
    "⪲" => ComparisonOp,
    "⇔" => ArrowOp,
    "⪭" => ComparisonOp,
    "⩱" => ComparisonOp,
    "⤍" => ArrowOp,
    "⊃" => ComparisonOp,
    "∝" => ComparisonOp,
    "⊊" => ComparisonOp,
    "⊠" => TimesOp,
    "∘" => TimesOp,
    "⇚" => ArrowOp,
    "⪆" => ComparisonOp,
    "⫋" => ComparisonOp,
    "|" => PlusOp,
    "⊉" => ComparisonOp,
    "∻" => ComparisonOp,
    "≉" => ComparisonOp,
    "⩡" => PlusOp,
    "⨬" => PlusOp,
    "⩷" => ComparisonOp,
    ">=" => ComparisonOp,
    "..." => 0,
    "where" => WhereOp,
    "->" => AnonFuncOp,
    "|=" => AssignmentOp,
    "'" => PrimeOp,
    "!" => 0,
    "√" => 0,
    "∛" => 0,
    "∜" => 0,
    "++" => PlusOp,
    "¬" => 0,
    "¦" => PlusOp,
    "⌿" => TimesOp,
    "⫪" => ComparisonOp,
    "⫫" => ComparisonOp
)
