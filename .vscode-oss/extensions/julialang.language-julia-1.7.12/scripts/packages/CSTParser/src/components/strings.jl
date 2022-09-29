function longest_common_prefix(prefixa, prefixb)
    maxplength = min(sizeof(prefixa), sizeof(prefixb))
    maxplength == 0 && return ""
    idx = findfirst(i -> (prefixa[i] != prefixb[i]), 1:maxplength)
    idx = idx === nothing ? maxplength : idx - 1
    prefixa[1:idx]
end

function skip_to_nl(str, idxend)
    while (idxend < sizeof(str)) && str[idxend] != '\n'
        idxend = nextind(str, idxend)
    end
    idxend > sizeof(str) ? prevind(str, idxend) : idxend
end

tostr(buf::IOBuffer) = _unescape_string(String(take!(buf)))

"""
parse_string_or_cmd(ps)

When trying to make an `INSTANCE` from a string token we must check for
interpolating operators.
"""
function parse_string_or_cmd(ps::ParseState, prefixed=false)
    sfullspan = ps.nt.startbyte - ps.t.startbyte
    sspan = 1 + ps.t.endbyte - ps.t.startbyte

    istrip = (kindof(ps.t) === Tokens.TRIPLE_STRING) || (kindof(ps.t) === Tokens.TRIPLE_CMD)
    iscmd = kindof(ps.t) === Tokens.CMD || kindof(ps.t) === Tokens.TRIPLE_CMD

    lcp = nothing
    exprs_to_adjust = []
    function adjust_lcp(expr::EXPR, last=false)
        if isliteral(expr)
            push!(exprs_to_adjust, expr)
            str = valof(expr)
            (isempty(str) || (lcp !== nothing && isempty(lcp))) && return
            (last && str[end] == '\n') && return (lcp = "")
            idxstart, idxend = 2, 1
            prevpos = idxend
            while nextind(str, idxend) - 1 < sizeof(str) && (lcp === nothing || !isempty(lcp))
                idxend = skip_to_nl(str, idxend)
                idxstart = nextind(str, idxend)
                prevpos1 = idxend
                while nextind(str, idxend) - 1 < sizeof(str)
                    c = str[nextind(str, idxend)]
                    if c == ' ' || c == '\t'
                        idxend += 1
                    elseif c == '\n'
                        # All whitespace lines in the middle are ignored
                        idxend += 1
                        idxstart = idxend + 1
                    else
                        prefix = str[idxstart:idxend]
                        lcp = lcp === nothing ? prefix : longest_common_prefix(lcp, prefix)
                        break
                    end
                    if idxend <= prevpos1
                        throw(CSTInfiniteLoop("Infinite loop in adjust_lcp"))
                    else
                        prevpos1 = idxend
                    end
                end
                if idxend < prevpos
                    throw(CSTInfiniteLoop("Infinite loop in adjust_lcp"))
                else
                    prevpos = idxend
                end
            end
            if idxstart != nextind(str, idxend)
                prefix = str[idxstart:idxend]
                lcp = lcp === nothing ? prefix : longest_common_prefix(lcp, prefix)
            end
        end
    end

    isinterpolated = false
    shoulddropleadingnewline = true
    erroredonlast = false

    t_str = val(ps.t, ps)
    if istrip && length(t_str) == 6
        if iscmd
            return wrapwithcmdmacro(EXPR(:TRIPLESTRING , sfullspan, sspan, ""))
        else
            return EXPR(:TRIPLESTRING, sfullspan, sspan, "")
        end
    elseif length(t_str) == 2
        if iscmd
            return wrapwithcmdmacro(EXPR(:STRING , sfullspan, sspan, ""))
        else
            return EXPR(:STRING, sfullspan, sspan, "")
        end
    elseif prefixed != false
        _val = istrip ? t_str[4:prevind(t_str, sizeof(t_str), 3)] : t_str[2:prevind(t_str, sizeof(t_str))]
        if iscmd
            _val = replace(_val, "\\\\" => "\\")
            _val = replace(_val, "\\`" => "`")
        else
            _val = unescape_prefixed(_val)
        end
        expr = EXPR(istrip ? :TRIPLESTRING : :STRING, sfullspan, sspan, _val)
        if istrip
            adjust_lcp(expr, true)
            ret = EXPR(:string, EXPR[expr], nothing, sfullspan, sspan)
        else
            return iscmd ? wrapwithcmdmacro(expr) : expr
        end
    else
        ret = EXPR(:string, EXPR[], EXPR[], sfullspan, sspan)
        input = IOBuffer(t_str)
        startbytes = istrip ? 3 : 1
        seek(input, startbytes)
        b = IOBuffer()
        prevpos = position(input)
        while !eof(input)
            c = read(input, Char)
            if c == '\\'
                write(b, c)
                write(b, read(input, Char))
            elseif c == '$'
                isinterpolated = true
                lspan = position(b)
                str = String(take!(b))
                ex = EXPR(:STRING, lspan + startbytes, lspan + startbytes, str)
                if position(input) == (istrip ? 3 : 1) + 1
                    # Need to add empty :STRING at start to account for \"
                    pushtotrivia!(ret, ex)
                elseif !isempty(str)
                    push!(ret, ex)
                end
                !iscmd && _rm_escaped_newlines(ex)
                istrip && adjust_lcp(ex)
                startbytes = 0
                op = EXPR(:OPERATOR, 1, 1, "\$")
                if peekchar(input) == '('
                    skip(input, 1) # skip past '('
                    lpfullspan = -position(input)
                    if iswhitespace(peekchar(input)) || peekchar(input) === '#'
                        read_ws_comment(input, readchar(input))
                    end
                    lparen = EXPR(:LPAREN, lpfullspan + position(input) + 1, 1)
                    rparen = EXPR(:RPAREN, 1, 1)

                    prev_input_size = input.size
                    input.size = input.size - (istrip ? 3 : 1)
                    # We're reusing a portion of the string from `ps` so we need to make sure `ps1` knows where the end of the string is.
                    ps1 = ParseState(input)

                    if kindof(ps1.nt) === Tokens.RPAREN
                        push!(ret, EXPR(:errortoken, EXPR[], nothing))
                        pushtotrivia!(ret, op)
                        pushtotrivia!(ret, lparen)
                        pushtotrivia!(ret, rparen)
                        seek(input, ps1.nt.startbyte + 1)
                    else
                        interp_val = @closer ps1 :paren parse_expression(ps1, true)
                        # parse_string_or_cmd unwraps STRING expressions (see below),
                        # but that's not supposed to happen in interpolations, so we rewrap them here:
                        if interp_val.head === :STRING
                            interp_val = EXPR(:string, [interp_val])
                        end

                        push!(ret, interp_val)
                        pushtotrivia!(ret, op)
                        pushtotrivia!(ret, lparen)
                        if kindof(ps1.nt) === Tokens.RPAREN
                            # Need to check the parenthese were actually closed.
                            pushtotrivia!(ret, rparen)
                            seek(input, ps1.nt.startbyte + 1)
                        else
                            pushtotrivia!(ret, EXPR(:RPAREN, 0, 0))
                            seek(input, ps1.nt.startbyte) # We don't skip ahead one as there wasn't a closing paren
                        end
                    end
                    # Compared to flisp/JuliaParser, we have an extra lookahead token,
                    # so we need to back up one here
                    input.size = prev_input_size
                elseif Tokenize.Lexers.iswhitespace(peekchar(input)) || peekchar(input) === '#'
                    pushtotrivia!(ret, op)
                    push!(ret, mErrorToken(ps, StringInterpolationWithTrailingWhitespace))
                elseif sspan == position(input) + (istrip ? 3 : 1)
                    # Error. We've hit the end of the string
                    pushtotrivia!(ret, op)
                    push!(ret, mErrorToken(ps, StringInterpolationWithTrailingWhitespace))
                else
                    pos = position(input)
                    ps1 = ParseState(input)
                    next(ps1)
                    if kindof(ps1.t) === Tokens.WHITESPACE
                        error("Unexpected whitespace after \$ in String")
                    else
                        # foo in $foo is always parsed as an identifier by Julia,
                        # no matter whether it actually is a keyword
                        t = EXPR(:IDENTIFIER, ps1)
                    end
                    # Attribute trailing whitespace to the string
                    t = adjustspan(t)
                    push!(ret, t)
                    pushtotrivia!(ret, op)
                    seek(input, pos + t.fullspan)
                end
            else
                write(b, c)
            end
            prevpos = loop_check(input, prevpos)
        end

        # handle last String section
        lspan = position(b)
        if erroredonlast
            ex = EXPR(istrip ? :TRIPLESTRING : :STRING, (istrip ? 3 : 1) + (ps.nt.startbyte - ps.t.endbyte - 1), istrip ? 3 : 1, "")
            pushtotrivia!(ret, ex)
        elseif b.size == 0
            ex = mErrorToken(ps, Unknown)
            push!(ret, ex)
        else
            str = String(take!(b))

            # This is for error handling only.
            u_str = try
                _unescape_string(str)
            catch err
                return mErrorToken(ps, ret, InvalidString)
            end
            if istrip
                str = str[1:prevind(str, lastindex(str), 3)]
                # only mark non-interpolated triple u_strings
                ex = EXPR(length(ret) == 0 ? :TRIPLESTRING : :STRING, lspan + ps.nt.startbyte - ps.t.endbyte - 1 + startbytes, lspan + startbytes, str)
                # find lcp for escaped string
                !iscmd && _rm_escaped_newlines(ex)
                adjust_lcp(ex, true)
                # we only want to drop the leading new line if it's a literal newline, not if it's `\n`
                if startswith(str, "\\n")
                    shoulddropleadingnewline = false
                end
            else
                str = str[1:prevind(str, lastindex(str))]
                ex = EXPR(:STRING, lspan + ps.nt.startbyte - ps.t.endbyte - 1 + startbytes, lspan + startbytes, str)
            end
            if isempty(str)
                pushtotrivia!(ret, ex)
            else
                push!(ret, ex)
            end
        end
        if iscmd
            str = istrip ?
                t_str[nextind(t_str, 1, 3):prevind(t_str, sizeof(t_str), 3)] :
                t_str[nextind(t_str, 1, 1):prevind(t_str, sizeof(t_str))]
            # remove common prefix:
            if lcp !== nothing
                str = replace(str, "\n$lcp" => "\n")
            end
            # the literal can have escaped '`'s, so let's remove those to get the actual content:
            str = replace(str, "\\`" => "`")
            # remove starting new line:
            if startswith(str, "\n")
                str = str[2:end]
            end
            # save original string into metadata
            ret.meta = str
        end
    end

    single_string_T = (:STRING, :TRIPLESTRING, literalmap(kindof(ps.t)))
    if istrip
        if lcp !== nothing && !isempty(lcp)
            for expr in exprs_to_adjust
                for (i, a) in enumerate(ret.args)
                    if expr == a
                        ret.args[i].val = replace(valof(expr), "\n$lcp" => "\n")
                        break
                    end
                end
            end
        end
        # Drop leading newline
        if !isempty(ret.args) && isliteral(ret.args[1]) && headof(ret.args[1]) in single_string_T &&
                !isempty(valof(ret.args[1])) && valof(ret.args[1])[1] == '\n' && shoulddropleadingnewline
            ret.args[1] = dropleadingnewline(ret.args[1])
        end
    end

    if (length(ret.args) == 1 && isliteral(ret.args[1]) && headof(ret.args[1]) in single_string_T) && !isinterpolated
        unwrapped = ret.args[1]
        if iscmd && ret.meta !== nothing
            unwrapped.val = ret.meta
        end
        ret = unwrapped
    end
    if !iscmd && prefixed == false
        _rm_escaped_newlines(ret)
        _unescape_string_expr(ret)
    end
    update_span!(ret)

    return iscmd ? wrapwithcmdmacro(ret) : ret
end

function _unescape_string_expr(expr)
    if headof(expr) === :STRING || headof(expr) === :TRIPLESTRING
        expr.val = _unescape_string(valof(expr))
    else
        for a in expr
            _unescape_string_expr(a)
        end
    end
end

function _rm_escaped_newlines(expr)
    if headof(expr) === :STRING || headof(expr) === :TRIPLESTRING
        expr.val = replace(valof(expr), r"(?<!\\)((?:\\\\)*)\\\n[\s\n]*" => s"\1")
    else
        for a in expr
            _rm_escaped_newlines(a)
        end
    end
end

function adjustspan(x::EXPR)
    x.fullspan = x.span
    return x
end

dropleadingnewline(x::EXPR) = setparent!(EXPR(headof(x), x.fullspan, x.span, valof(x)[2:end]), parentof(x))

wrapwithcmdmacro(x) = EXPR(:macrocall, EXPR[EXPR(:globalrefcmd, 0, 0), EXPR(:NOTHING, 0, 0), x])

"""
    parse_prefixed_string_cmd(ps::ParseState, ret::EXPR)

Parse prefixed strings and commands such as `pre"text"`.
"""
function parse_prefixed_string_cmd(ps::ParseState, ret::EXPR)
    arg = parse_string_or_cmd(next(ps), ret)

    if ret.head === :IDENTIFIER && valof(ret) == "var" && isstringliteral(arg) && VERSION > v"1.3.0-"
        return EXPR(:NONSTDIDENTIFIER, EXPR[ret, arg], nothing)
    elseif headof(arg) === :macrocall && headof(arg.args[1]) === :globalrefcmd
        mname = EXPR(:IDENTIFIER, ret.fullspan, ret.span, string("@", valof(ret), "_cmd")) # NOTE: sizeof(valof(mname)) != mname.span
        return EXPR(:macrocall, EXPR[mname, EXPR(:NOTHING, 0, 0), arg.args[3]], nothing)
    elseif is_getfield(ret)
        if headof(ret.args[2]) === :quote || headof(ret.args[2]) === :quotenode
            str_type = valof(ret.args[2].args[1]) isa String ? valof(ret.args[2].args[1]) : "" # to handle some malformed case
            if str_type == "var" && isstringliteral(arg) && VERSION > v"1.3.0-"
                var = EXPR(:IDENTIFIER, nothing, nothing, 3, 3, "var", ret, nothing)
                ret.args[2].args[1] = setparent!(EXPR(:NONSTDIDENTIFIER, EXPR[var, arg], nothing), ret.args[2])
                setparent!(var, ret.args[2].args[1])
                update_span!(ret.args[2])
                update_span!(ret)
                return ret
            else
                ret.args[2].args[1] = setparent!(EXPR(:IDENTIFIER, ret.args[2].args[1].fullspan, ret.args[2].args[1].span, string("@", str_type, "_str")), ret.args[2])
            end
        else
            str_type = valof(ret.args[2]) isa String ? valof(ret.args[2]) : "" # to handle some malformed case
            ret.args[2] = EXPR(:IDENTIFIER, ret.args[2].fullspan, ret.args[2].span, string("@", str_type, "_str"))
        end

        return EXPR(:macrocall, EXPR[ret, EXPR(:NOTHING, 0, 0), arg], nothing)
    else
        return EXPR(:macrocall, EXPR[EXPR(:IDENTIFIER, ret.fullspan, ret.span, string("@", valof(ret), "_str")), EXPR(:NOTHING, 0, 0), arg], nothing)
    end
end

function unescape_prefixed(str)
    return replace(str, r"(\\)*(?=\"|$)" => s -> s[1:end÷2])
end
