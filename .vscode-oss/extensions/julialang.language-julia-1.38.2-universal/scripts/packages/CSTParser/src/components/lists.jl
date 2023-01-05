"""
parse_tuple(ps, ret)

`ret` is followed by a comma so tries to parse the rest of the
tuple.
"""
function parse_tuple end

iserrorwrapped(x, head) = x.head === head || (x.head === :errortoken && length(x.args) > 0 && iserrorwrapped(x.args[1], head))

function parse_tuple(ps::ParseState, ret::EXPR)
    op = EXPR(next(ps))
    if istuple(ret) && !(length(ret.trivia) > 1 && iserrorwrapped(last(ret.trivia), :RPAREN))
        if (isassignmentop(ps.nt) && kindof(ps.nt) != Tokens.APPROX)
            pushtotrivia!(ret, op)
        elseif closer(ps)
            @static if VERSION > v"1.1-"
                pushtotrivia!(ret, mErrorToken(ps, op, Unknown))
            else
                pushtotrivia!(ret, op)
            end
        else
            nextarg = @closer ps :tuple parse_expression(ps)
            if !(is_lparen(first(ret.trivia)))
                pushtotrivia!(ret, op)
                push!(ret, nextarg)
            else
                ret = EXPR(:tuple, EXPR[ret, nextarg], EXPR[op])
            end
        end
    else
        if (isassignmentop(ps.nt) && kindof(ps.nt) != Tokens.APPROX)
            ret = EXPR(:tuple, EXPR[ret], EXPR[op])
        elseif closer(ps)
            @static if VERSION > v"1.1-"
                ret = mErrorToken(ps, EXPR(:tuple, EXPR[ret], EXPR[op]), Unknown)
            else
                ret = EXPR(:tuple, EXPR[ret], EXPR[op])
            end
        else
            nextarg = @closer ps :tuple parse_expression(ps)
            ret = EXPR(:tuple, EXPR[ret, nextarg], EXPR[op])
        end
    end
    return ret
end

# XXX: Avert thine eyes.
function count_semicolons(ps, check_newline = true)
    dims = 0
    has_newline = false
    old_pos = position(ps.l.io)
    seek(ps.l.io, ps.ws.startbyte)
    while true
        c = readchar(ps.l.io)
        if c == ';'
            dims += 1
        elseif check_newline && c == '\n'
            # technically, only trailing newlines are allowed; we're a bit more lenient here
            has_newline = true
        else
            dims == 0 || break
        end
    end
    seek(ps.l.io, old_pos)
    return dims == 2 && has_newline ? 0 : dims
end

"""
    parse_array(ps)
Having hit '[' return either:
+ A vect
+ A vcat
+ A ncat
+ A comprehension
+ An array (vcat of hcats)
"""
function parse_array(ps::ParseState, isref = false)
    args = EXPR[]
    trivia = EXPR[EXPR(ps)]
    # [] or [;;;]
    if kindof(ps.nt) === Tokens.RSQUARE
        dims = 0
        if kindof(ps.ws) == SemiColonWS
            dims = count_semicolons(ps, false)
        end
        push!(trivia, accept_rsquare(ps))
        if dims > 0
            ret = EXPR(:ncat, args, trivia)
            pushfirst!(ret, EXPR(Symbol(dims), 0, 0, ""))
            return ret
        else
            return EXPR(:vect, args, trivia)
        end
    else
        ret = parse_array_outer(ps::ParseState, trivia, isref)
        pushtotrivia!(ret, accept_rsquare(ps))

        return ret
    end
end

binding_power(ps, nl = true) =
    if kindof(ps.ws) == SemiColonWS
        -count_semicolons(ps, nl)
    elseif kindof(ps.ws) == NewLineWS
        -1
    elseif kindof(ps.ws) == WS
        0
    else
        1
    end

function parse_array_outer(ps::ParseState, trivia, isref)
    args_list = EXPR[]
    trivia_bp = Int[]
    min_bp = 0
    max_bp = -typemax(Int)
    is_start = true
    while kindof(ps.nt) !== Tokens.RSQUARE && kindof(ps.nt) !== Tokens.ENDMARKER
        a = @nocloser ps :semicolon @nocloser ps :newline @closesquare ps @closer ps :insquare @closer ps :ws @closer ps :wsop @closer ps :comma parse_expression(ps)
        if is_start
            args = EXPR[]
            if isref && _do_kw_convert(ps, a)
                a = _kw_convert(a)
            end
            if kindof(ps.nt) === Tokens.RSQUARE
                if headof(a) === :generator || headof(a) === :flatten
                    if isbinarycall(a.args[1]) && is_pairarrow(a.args[1].args[2])
                        return EXPR(:dict_comprehension, EXPR[a], trivia)
                    else
                        return EXPR(:comprehension, EXPR[a], trivia)
                    end
                elseif kindof(ps.ws) == SemiColonWS
                    dims = count_semicolons(ps)
                    push!(args, a)
                    if dims > 1
                        ret = EXPR(:ncat, args, trivia)
                        pushfirst!(ret, EXPR(Symbol(dims), 0, 0, ""))
                        return ret
                    else
                        return EXPR(:vcat, args, trivia)
                    end
                else
                    push!(args, a)
                    return EXPR(:vect, args, trivia)
                end
            elseif iscomma(ps.nt)
                args = EXPR[]
                push!(args, a)
                push!(trivia, accept_comma(ps))
                @closesquare ps parse_comma_sep(ps, args, trivia, isref, insert_params_at = 1)
                return EXPR(:vect, args, trivia)
            elseif kindof(ps.nt) === Tokens.ENDMARKER
                push!(args, a)
                return EXPR(:vect, args, trivia)
            end
        end
        is_start = false

        push!(args_list, a)

        bp = binding_power(ps, max_bp == 0)
        bp < min_bp && (min_bp = bp)
        bp > max_bp && (max_bp = bp)
        if bp <= 0
            push!(trivia_bp, bp)
        end
    end

    if length(trivia_bp) + 1 < length(args_list)
        return EXPR(:hcat, EXPR[EXPR(:errortoken, args_list, nothing)], trivia)
    end

    ret = _process_inner_array(args_list, trivia_bp)
    for t in trivia
        pushtotrivia!(ret, t)
    end

    if ret.head === :nrow
        if min_bp == 0
            popfirst!(ret.args)
            ret.head = :hcat
        elseif min_bp == -1
            popfirst!(ret.args)
            ret.head = :vcat
        else
            ret.head = :ncat
        end
    elseif min_bp == 0
        ret.head = :hcat
    elseif min_bp == -1
        ret.head = :vcat
    end

    return ret
end

function _process_inner_array(args_list, trivia_bp)
    if isempty(trivia_bp)
        if length(args_list) == 1
            arg = first(args_list)
            arg.args = something(arg.args, EXPR[])
            arg.trivia = something(arg.trivia, EXPR[])
            return arg
        else
            return EXPR(:errortoken, EXPR[], EXPR[])
        end
    end
    bp = minimum(trivia_bp)
    if all(==(bp), trivia_bp)
        if bp == 0
            ret = EXPR(:row, EXPR[], EXPR[])
        else
            ret = EXPR(:nrow, copy(args_list), EXPR[])
            pushfirst!(ret, EXPR(Symbol(-bp), 0, 0, ""))
        end
    end
    i = 1
    i0 = 1
    if bp == 0
        ret = EXPR(:row, EXPR[], EXPR[])
    else
        ret = EXPR(:nrow, EXPR[], EXPR[])
        push!(ret, EXPR(Symbol(-bp), 0, 0, ""))
    end
    while true
        i = findnext(==(bp), trivia_bp, i0)
        i === nothing && (i = length(args_list))
        if !checkbounds(Bool, args_list, i0:i) || !checkbounds(Bool, trivia_bp, i0:(i-1))
            return EXPR(:errortoken, args_list, EXPR[])
        end
        inner_args = args_list[i0:i]
        inner_trivia = trivia_bp[i0:(i-1)]
        i0 = i + 1

        push!(ret, _process_inner_array(inner_args, inner_trivia))
        i >= length(args_list) && break
    end
    return ret
end

"""
    parse_ref(ps, ret)

Handles cases where an expression - `ret` - is followed by
`[`. Parses the following bracketed expression and modifies it's
`.head` appropriately.
"""
function parse_ref(ps::ParseState, ret::EXPR)
    next(ps)
    ref = @closer ps :inref @nocloser ps :inwhere parse_array(ps, true)
    if headof(ref) === :vect
        args = EXPR[ret]
        for a in ref.args
            push!(args, a)
        end
        return EXPR(:ref, args, ref.trivia)
    elseif headof(ref) === :hcat
        args = EXPR[ret]
        for a in ref.args
            push!(args, a)
        end
        return EXPR(:typed_hcat, args, ref.trivia)
    elseif headof(ref) === :vcat
        args = EXPR[ret]
        for a in ref.args
            push!(args, a)
        end
        return EXPR(:typed_vcat, args, ref.trivia)
    elseif headof(ref) === :ncat
        args = EXPR[ret]
        for a in ref.args
            push!(args, a)
        end
        return EXPR(:typed_ncat, args, ref.trivia)
    else
        args = EXPR[ret]
        for a in ref.args
            push!(args, a)
        end
        return EXPR(:typed_comprehension, args, ref.trivia)
    end
end

"""
parse_curly(ps, ret)

Parses the juxtaposition of `ret` with an opening brace. Parses a comma
seperated list.
"""
function parse_curly(ps::ParseState, ret::EXPR)
    args = EXPR[ret]
    trivia = EXPR[EXPR(next(ps))]
    parse_comma_sep(ps, args, trivia, true)
    accept_rbrace(ps, trivia)
    return EXPR(:curly, args, trivia)
end

function parse_braces(ps::ParseState)
    return @default ps @nocloser ps :inwhere parse_barray(ps)
end

function parse_barray(ps::ParseState)
    args = EXPR[]
    trivia = EXPR[EXPR(ps)]

    if kindof(ps.nt) === Tokens.RBRACE
        accept_rbrace(ps, trivia)
        ret = EXPR(:braces, args, trivia)
    else
        first_arg = @nocloser ps :newline @closebrace ps  @closer ps :ws @closer ps :wsop @closer ps :comma parse_expression(ps)
        if kindof(ps.nt) === Tokens.RBRACE
            push!(args, first_arg)
            if kindof(ps.ws) == SemiColonWS
                pushfirst!(args, EXPR(:parameters, EXPR[], nothing))
            end
            accept_rbrace(ps, trivia)
            ret = EXPR(:braces, args, trivia)
        elseif iscomma(ps.nt)
            push!(args, first_arg)
            accept_comma(ps, trivia)
            @closebrace ps parse_comma_sep(ps, args, trivia, true, insert_params_at = 1)
            accept_rbrace(ps, trivia)
            return EXPR(:braces, args, trivia)
        elseif kindof(ps.ws) == NewLineWS
            ret = EXPR(:bracescat, args, trivia)
            push!(ret, first_arg)
            prevpos = position(ps)
            while kindof(ps.nt) != Tokens.RBRACE && kindof(ps.nt) !== Tokens.ENDMARKER
                a = @closebrace ps  parse_expression(ps)
                push!(ret, a)
                prevpos = loop_check(ps, prevpos)
            end
            pushtotrivia!(ret, accept_rbrace(ps))
            return ret
        elseif kindof(ps.ws) == WS || kindof(ps.ws) == SemiColonWS
            first_row = EXPR(:row, EXPR[first_arg])
            prevpos = position(ps)
            while kindof(ps.nt) !== Tokens.RBRACE && kindof(ps.ws) !== NewLineWS && kindof(ps.ws) !== SemiColonWS && kindof(ps.nt) !== Tokens.ENDMARKER
                a = @closebrace ps @closer ps :ws @closer ps :wsop parse_expression(ps)
                push!(first_row, a)
                prevpos = loop_check(ps, prevpos)
            end
            if kindof(ps.nt) === Tokens.RBRACE && kindof(ps.ws) != SemiColonWS
                if length(first_row.args) == 1
                    first_row = EXPR(:bracescat, first_row.args)
                end
                push!(args, first_row)
                push!(trivia, INSTANCE(next(ps)))
                return EXPR(:bracescat, args, trivia)
            else
                if length(first_row.args) == 1
                    first_row = first_row.args[1]
                else
                    first_row = EXPR(:row, first_row.args)
                end
                ret = EXPR(:bracescat, EXPR[first_row], trivia)
                prevpos = position(ps)
                while kindof(ps.nt) != Tokens.RBRACE
                    if kindof(ps.nt) === Tokens.ENDMARKER
                        break
                    end
                    first_arg = @closebrace ps @closer ps :ws @closer ps :wsop parse_expression(ps)
                    push!(ret, EXPR(:row, EXPR[first_arg]))
                    prevpos1 = position(ps)
                    while kindof(ps.nt) !== Tokens.RBRACE && kindof(ps.ws) !== NewLineWS && kindof(ps.ws) !== SemiColonWS && kindof(ps.nt) !== Tokens.ENDMARKER
                        a = @closebrace ps @closer ps :ws @closer ps :wsop parse_expression(ps)
                        push!(last(ret.args), a)
                        prevpos1 = loop_check(ps, prevpos1)
                    end
                    # if only one entry dont use :row
                    if length(last(ret.args).args) == 1
                        ret.args[end] = setparent!(ret.args[end].args[1], ret)
                    end
                    update_span!(ret)
                    prevpos = loop_check(ps, prevpos)
                end
                pushtotrivia!(ret, accept_rbrace(ps))
                update_span!(ret)
                return ret
            end
        else
            ret = EXPR(:braces, args, trivia)
            push!(ret, first_arg)
            pushtotrivia!(ret, accept_rbrace(ps))
        end
    end
    return ret
end
