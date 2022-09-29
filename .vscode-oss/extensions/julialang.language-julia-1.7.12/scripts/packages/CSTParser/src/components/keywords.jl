"""
    parse_kw(ps::ParseState)

Dispatch function for when the parser has reached a keyword.
"""
function parse_kw(ps::ParseState)
    k = kindof(ps.t)
    if ps.closer.precedence == 20 && ps.lt.kind === Tokens.EX_OR && k !== Tokens.END
        return EXPR(:IDENTIFIER, ps)
    end
    if k === Tokens.IF
        return @default ps @closer ps :block parse_if(ps)
    elseif k === Tokens.LET
        return @default ps @closer ps :block parse_blockexpr(ps, :let)
    elseif k === Tokens.TRY
        return @default ps @closer ps :block parse_try(ps)
    elseif k === Tokens.FUNCTION
        return @default ps @closer ps :block parse_blockexpr(ps, :function)
    elseif k === Tokens.MACRO
        return @default ps @closer ps :block parse_blockexpr(ps, :macro)
    elseif k === Tokens.BEGIN
        @static if VERSION < v"1.4"
            return @default ps @closer ps :block parse_blockexpr(ps, :begin)
        else
            if ps.closer.inref
                ret = EXPR(ps)
            else
                return @default ps @closer ps :block parse_blockexpr(ps, :begin)
            end
        end
    elseif k === Tokens.QUOTE
        return @default ps @nocloser ps :inref @closer ps :block parse_blockexpr(ps, :quote)
    elseif k === Tokens.FOR
        return @default ps @closer ps :block parse_blockexpr(ps, :for)
    elseif k === Tokens.WHILE
        return @default ps @closer ps :block parse_blockexpr(ps, :while)
    elseif k === Tokens.BREAK
        return EXPR(ps)
    elseif k === Tokens.CONTINUE
        return EXPR(ps)
    elseif k === Tokens.IMPORT
        return parse_imports(ps)
    elseif k === Tokens.IMPORTALL
        # Old keyword..
        return EXPR(:IDENTIFIER, ps)
    elseif k === Tokens.USING
        return parse_imports(ps)
    elseif k === Tokens.EXPORT
        return parse_export(ps)
    elseif k === Tokens.MODULE
        return @default ps @closer ps :block parse_blockexpr(ps, :module)
    elseif k === Tokens.BAREMODULE
        return @default ps @closer ps :block parse_blockexpr(ps, :baremodule)
    elseif k === Tokens.CONST
        return @default ps parse_const(ps)
    elseif k === Tokens.GLOBAL
        return @default ps parse_local_global(ps, false)
    elseif k === Tokens.LOCAL
        return @default ps parse_local_global(ps)
    elseif k === Tokens.RETURN
        return @default ps parse_return(ps)
    elseif k === Tokens.END
        if ps.closer.square
            ret = EXPR(ps)
        else
            ret = mErrorToken(ps, EXPR(:IDENTIFIER, ps), UnexpectedToken)
        end
        return ret
    elseif k === Tokens.ELSE || k === Tokens.ELSEIF || k === Tokens.CATCH || k === Tokens.FINALLY
        return mErrorToken(ps, EXPR(:IDENTIFIER, ps), UnexpectedToken)
    elseif k === Tokens.ABSTRACT
        return @default ps parse_abstract(ps)
    elseif k === Tokens.PRIMITIVE
        return @default ps parse_primitive(ps)
    elseif k === Tokens.TYPE
        return EXPR(:IDENTIFIER, ps)
    elseif k === Tokens.STRUCT
        enable!(ps, ParserFlags.AllowConstWithoutAssignment)
        ret = @default ps @closer ps :block parse_blockexpr(ps, :struct)
        disable!(ps, ParserFlags.AllowConstWithoutAssignment)
        return ret
    elseif k === Tokens.MUTABLE
        return @default ps @closer ps :block parse_mutable(ps)
    elseif k === Tokens.OUTER
        return EXPR(:IDENTIFIER, ps)
    else
        return mErrorToken(ps, Unknown)
    end
end

function parse_const(ps::ParseState)
    kw = EXPR(ps)
    lt = ps.lt
    nt = ps.nt
    arg = parse_expression(ps)
    allow_no_assignment = has_flag(ps, ParserFlags.AllowConstWithoutAssignment) ||
        has_flag(ps, ParserFlags.InQuote) && (kindof(nt) === Tokens.GLOBAL || kindof(lt) === Tokens.GLOBAL)
    if !allow_no_assignment && !(isassignment(unwrapbracket(arg)) || (headof(arg) === :global && length(arg.args) > 0 && isassignment(unwrapbracket(arg.args[1]))))
        arg = mErrorToken(ps, arg, ExpectedAssignment)
    end
    ret = EXPR(:const, EXPR[arg], EXPR[kw])
    return ret
end

function parse_local_global(ps::ParseState, islocal = true)
    kw = EXPR(ps)
    if ps.nt.kind === Tokens.CONST
        arg1 = parse_const(next(ps))
        EXPR(:const, EXPR[EXPR(islocal ? :local : :global, arg1.args, EXPR[kw])], arg1.trivia)
    else
        args, trivia = EXPR[], EXPR[kw]
        arg = parse_expression(ps)
        if isassignment(unwrapbracket(arg))
            push!(args, arg)
        elseif arg.head === :tuple
            append!(args, arg.args)
            append!(trivia, arg.trivia)
        else
            push!(args, arg)
        end
        EXPR(islocal ? :local : :global, args, trivia)
    end
end


function parse_return(ps::ParseState)
    kw = EXPR(ps)
    # Note to self: Nothing could be treated as implicit and added
    # during conversion to Expr.
    arg = closer(ps) ? EXPR(:NOTHING, 0, 0, "") : @precedence ps AssignmentOp - 1 parse_expression(ps)

    return EXPR(:return, EXPR[arg], EXPR[kw])
end

function parse_abstract(ps::ParseState)
    if kindof(ps.nt) === Tokens.TYPE
        kw1 = EXPR(ps)
        kw2 = EXPR(next(ps))
        sig = @closer ps :block parse_expression(ps)
        ret = EXPR(:abstract, EXPR[sig], EXPR[kw1, kw2, accept_end(ps)])
    else
        ret = EXPR(:IDENTIFIER, ps)
    end
    return ret
end

function parse_primitive(ps::ParseState)
    if kindof(ps.nt) === Tokens.TYPE
        kw1 = EXPR(ps)
        kw2 = EXPR(next(ps))
        sig = @closer ps :ws @closer ps :wsop parse_expression(ps)
        arg = @closer ps :block parse_expression(ps)
        ret = EXPR(:primitive, EXPR[sig, arg], EXPR[kw1, kw2, accept_end(ps)])
    else
        ret = EXPR(:IDENTIFIER, ps)
    end
    return ret
end

function parse_mutable(ps::ParseState)
    if kindof(ps.nt) === Tokens.STRUCT
        kw = EXPR(ps)
        next(ps)

        enable!(ps, ParserFlags.AllowConstWithoutAssignment)
        ret = parse_blockexpr(ps, :mutable)
        disable!(ps, ParserFlags.AllowConstWithoutAssignment)

        pushfirst!(ret.trivia, setparent!(kw, ret))
        update_span!(ret)
    else
        ret = EXPR(:IDENTIFIER, ps)
    end
    return ret
end

function parse_imports(ps::ParseState)
    kw = EXPR(ps)
    allow_as = is_import(kw)
    kwt = allow_as ? :import : :using

    arg = parse_dot_mod(ps, false, allow_as)
    if !iscomma(ps.nt) && !iscolon(ps.nt)
        ret = EXPR(kwt, EXPR[arg], EXPR[kw])
    elseif iscolon(ps.nt)
        ret = EXPR(kwt, EXPR[EXPR(EXPR(:OPERATOR, next(ps)), EXPR[arg])], EXPR[kw])

        arg = parse_dot_mod(ps, true, true)
        push!(ret.args[1], arg)
        prevpos = position(ps)
        while iscomma(ps.nt)
            pushtotrivia!(ret.args[1], accept_comma(ps))
            arg = parse_dot_mod(ps, true, true)
            push!(ret.args[1], arg)
            prevpos = loop_check(ps, prevpos)
        end
        update_span!(ret)
    else
        ret = EXPR(kwt, EXPR[arg], EXPR[kw])
        prevpos = position(ps)
        while iscomma(ps.nt)
            pushtotrivia!(ret, accept_comma(ps))
            arg = parse_dot_mod(ps, false, allow_as)
            push!(ret, arg)
            prevpos = loop_check(ps, prevpos)
        end
    end

    return ret
end

function parse_export(ps::ParseState)
    args = EXPR[]
    trivia = EXPR[EXPR(ps)]
    push!(args, parse_importexport_item(ps))

    prevpos = position(ps)
    while iscomma(ps.nt)
        push!(trivia, EXPR(next(ps)))
        arg = parse_importexport_item(ps)
        push!(args, arg)
        prevpos = loop_check(ps, prevpos)
    end

    return EXPR(:export, args, trivia)
end

"""
    parse_blockexpr_sig(ps::ParseState, head)

Utility function to parse the signature of a block statement (i.e. any statement preceding
the main body of the block). Returns `nothing` in some cases (e.g. `begin end`)
"""
function parse_blockexpr_sig(ps::ParseState, head)
    if head === :struct || head == :mutable || head === :while
        return @closer ps :ws parse_expression(ps)
    elseif head === :for
        iters, trivia = EXPR[], EXPR[]
        parse_iterators(ps, iters, trivia)
        if length(iters) == 1
            return first(iters)
        else
            return EXPR(:block, iters, trivia)
        end
    elseif head === :function || head === :macro
        sig = @closer ps :inwhere @closer ps :ws parse_expression(ps)
        if convertsigtotuple(sig)
            sig = EXPR(:tuple, sig.args, sig.trivia)
        end
        prevpos = position(ps)
        while kindof(ps.nt) === Tokens.WHERE && kindof(ps.ws) != Tokens.NEWLINE_WS
            sig = @closer ps :inwhere @closer ps :ws parse_operator_where(ps, sig, INSTANCE(next(ps)), false)
            prevpos = loop_check(ps, prevpos)
        end
        return sig
    elseif head === :let
        if isendoflinews(ps.ws)
            return EXPR(:block, EXPR[], nothing)
        else
            arg = @closer ps :comma @closer ps :ws parse_expression(ps)
            if iscomma(ps.nt) || !(is_wrapped_assignment(arg) || isidentifier(arg))
                arg = EXPR(:block, EXPR[arg])
                prevpos = position(ps)
                while iscomma(ps.nt)
                    pushtotrivia!(arg, accept_comma(ps))
                    nextarg = @closer ps :comma @closer ps :ws parse_expression(ps)
                    push!(arg, nextarg)
                    prevpos = loop_check(ps, prevpos)
                end
            end
            return arg
        end
    elseif head === :do
        args, trivia = EXPR[], EXPR[]
        prevpos = position(ps)
        @closer ps :comma @closer ps :block while !closer(ps)
            push!(args, @closer ps :ws a = parse_expression(ps))
            if kindof(ps.nt) === Tokens.COMMA
                push!(trivia, accept_comma(ps))
            elseif @closer ps :ws closer(ps)
                break
            end
            prevpos = loop_check(ps, prevpos)
        end
        return EXPR(:tuple, args, trivia)
    elseif head === :module || head === :baremodule
        return if isidentifier(ps.nt)
            if is_nonstd_identifier(ps)
                parse_nonstd_identifier(ps)
            else
                EXPR(:IDENTIFIER, next(ps))
            end
        else
            @precedence ps 15 @closer ps :ws parse_expression(ps)
        end
    end
    return nothing
end

function parse_do(ps::ParseState, pre::EXPR)
    args, trivia = EXPR[pre], EXPR[EXPR(next(ps))]
    args1, trivia1 = EXPR[], EXPR[]

    @closer ps :comma @closer ps :block while !closer(ps)
        push!(args1, @closer ps :ws a = parse_expression(ps))
        if kindof(ps.nt) === Tokens.COMMA
            push!(trivia1, accept_comma(ps))
        elseif @closer ps :ws closer(ps)
            break
        else
            # we've errored, let's add a dummy comma
            push!(trivia1, EXPR(:COMMA, 0, 0))
        end
    end
    blockargs = parse_block(ps, EXPR[], (Tokens.END,))
    push!(args, (EXPR(EXPR(:OPERATOR, 0, 0, "->"), EXPR[EXPR(:tuple, args1, trivia1), EXPR(:block, blockargs, nothing)])))
    push!(trivia, accept_end(ps))
    return EXPR(:do, args, trivia)
end

"""
    parse_blockexpr(ps::ParseState, head)

General function for parsing block expressions comprised of a series of statements
terminated by an `end`.
"""
function parse_blockexpr(ps::ParseState, head)
    kw = EXPR(ps)
    sig = parse_blockexpr_sig(ps, head)
    blockargs = parse_block(ps, EXPR[], (Tokens.END,), docable(head))
    if head === :begin
        EXPR(:block, blockargs, EXPR[kw, accept_end(ps)])
    elseif sig === nothing
        EXPR(head, EXPR[EXPR(:block, blockargs, nothing)], EXPR[kw, accept_end(ps)])
    elseif (head === :function || head === :macro) && is_either_id_op_interp(sig)
        if isempty(blockargs)
            EXPR(head, EXPR[sig], EXPR[kw, accept_end(ps)])
        else
            sig = mErrorToken(ps, sig, SignatureOfFunctionDefIsNotACall)
            EXPR(head, EXPR[sig, EXPR(:block, blockargs, nothing)], EXPR[kw, accept_end(ps)])
        end
    elseif head === :mutable
        EXPR(:struct, EXPR[EXPR(:TRUE, 0, 0), sig, EXPR(:block, blockargs, nothing)], EXPR[kw, accept_end(ps)])
    elseif head === :module
        EXPR(head, EXPR[EXPR(:TRUE, 0, 0), sig, EXPR(:block, blockargs, nothing)], EXPR[kw, accept_end(ps)])
    elseif head === :baremodule
        EXPR(:module, EXPR[EXPR(:FALSE, 0, 0), sig, EXPR(:block, blockargs, nothing)], EXPR[kw, accept_end(ps)])
    elseif head === :struct
        EXPR(head, EXPR[EXPR(:FALSE, 0, 0), sig, EXPR(:block, blockargs, nothing)], EXPR[kw, accept_end(ps)])
    else
        EXPR(head, EXPR[sig, EXPR(:block, blockargs, nothing)], EXPR[kw, accept_end(ps)])
    end
end


"""
    parse_if(ps, nested=false)

Parse an `if` block.
"""
function parse_if(ps::ParseState, nested = false)
    args = EXPR[]
    trivia = EXPR[EXPR(ps)]

    push!(args, isendoflinews(ps.ws) ? mErrorToken(ps, MissingConditional) : @closer ps :ws parse_expression(ps))
    push!(args, EXPR(:block, parse_block(ps, EXPR[], (Tokens.END, Tokens.ELSE, Tokens.ELSEIF)), nothing))

    elseblockargs = EXPR[]
    if kindof(ps.nt) === Tokens.ELSEIF
        push!(args, parse_if(next(ps), true))
    end
    elsekw = kindof(ps.nt) === Tokens.ELSE
    if kindof(ps.nt) === Tokens.ELSE
        push!(trivia, EXPR(next(ps)))
        parse_block(ps, elseblockargs)
    end

    # Construction
    if !(isempty(elseblockargs) && !elsekw)
        push!(args, EXPR(:block, elseblockargs, nothing))
    end
    !nested && push!(trivia, accept_end(ps))

    return EXPR(nested ? :elseif : :if, args, trivia)
end


function parse_try(ps::ParseState)
    kw = EXPR(ps)
    args = EXPR[]
    trivia = EXPR[kw]
    tryblockargs = parse_block(ps, EXPR[], (Tokens.END, Tokens.CATCH, Tokens.ELSE, Tokens.FINALLY))
    push!(args, EXPR(:block, tryblockargs, nothing))

    #  catch block
    if kindof(ps.nt) === Tokens.CATCH
        push!(trivia, EXPR(next(ps)))
        # catch closing early
        if kindof(ps.nt) === Tokens.FINALLY || kindof(ps.nt) === Tokens.END
            caught = EXPR(:FALSE, 0, 0, "")
            catchblock = EXPR(:block, EXPR[])
        else
            if isendoflinews(ps.ws)
                caught = EXPR(:FALSE, 0, 0, "")
            else
                caught = @closer ps :ws parse_expression(ps)
            end

            catchblockargs = parse_block(ps, EXPR[], (Tokens.END, Tokens.FINALLY, Tokens.ELSE))
            if !(is_either_id_op_interp(caught) || headof(caught) === :FALSE)
                pushfirst!(catchblockargs, caught)
                caught = EXPR(:FALSE, 0, 0, "")
            end
            catchblock = EXPR(:block, catchblockargs, nothing)
        end
    else
        push!(trivia, EXPR(:CATCH, 0, 0))
        caught = EXPR(:FALSE, 0, 0, "")
        catchblock = EXPR(:block, EXPR[], nothing)
    end
    push!(args, caught)
    push!(args, catchblock)

    else_trivia = else_arg = nothing
    # else block
    if kindof(ps.nt) === Tokens.ELSE
        if isempty(catchblock.args)
            args[3] = EXPR(:block, 0, 0, "")
        end
        else_trivia = EXPR(next(ps))
        else_arg = EXPR(:block, parse_block(ps, EXPR[], (Tokens.FINALLY,Tokens.END)))
    end

    has_finally = false
    if kindof(ps.nt) === Tokens.FINALLY
        has_finally = true
        if isempty(catchblock.args) && else_trivia === nothing
            args[3] = EXPR(:FALSE, 0, 0, "")
        end
        push!(trivia, EXPR(next(ps)))
        push!(args, EXPR(:block, parse_block(ps)))
    end

    if else_trivia !== nothing
        if !has_finally
            push!(trivia, EXPR(:FALSE, 0, 0, ""))
            push!(args, EXPR(:FALSE, 0, 0, ""))
        end
        push!(trivia, else_trivia)
        push!(args, else_arg)
    end

    push!(trivia, accept_end(ps))
    return EXPR(:try, args, trivia)
end
