function accept_rparen(ps)
    if kindof(ps.nt) === Tokens.RPAREN
        return EXPR(next(ps))
    else
        return mErrorToken(ps, EXPR(:RPAREN, 0, 0), UnexpectedToken)
    end
end
accept_rparen(ps::ParseState, args) = push!(args, accept_rparen(ps))

function accept_rsquare(ps)
    if kindof(ps.nt) === Tokens.RSQUARE
        return EXPR(next(ps))
    else
        return mErrorToken(ps, EXPR(:RSQUARE, 0, 0), UnexpectedToken)
    end
end
accept_rsquare(ps::ParseState, args) = push!(args, accept_rsquare(ps))

function accept_rbrace(ps)
    if kindof(ps.nt) === Tokens.RBRACE
        return EXPR(next(ps))
    else
        return mErrorToken(ps, EXPR(:RBRACE, 0, 0), UnexpectedToken)
    end
end
accept_rbrace(ps::ParseState, args) = push!(args, accept_rbrace(ps))

function accept_end(ps::ParseState)
    if kindof(ps.nt) === Tokens.END
        return EXPR(next(ps))
    else
        return mErrorToken(ps, EXPR(:END, 0, 0), UnexpectedToken)
    end
end
accept_end(ps::ParseState, args) = push!(args, accept_end(ps))

function accept_comma(ps)
    if iscomma(ps.nt)
        return EXPR(next(ps))
    else
        return EXPR(:RPAREN, 0, 0)
    end
end
accept_comma(ps::ParseState, args) = push!(args, accept_comma(ps))

function requires_ws(x, ps)
    if x.span == x.fullspan
        return mErrorToken(ps, x, Unknown)
    else
        return x
    end
end

function requires_no_ws(x, ps)
    if !(kindof(ps.nt) === Tokens.RPAREN ||
        kindof(ps.nt) === Tokens.RBRACE ||
        kindof(ps.nt) === Tokens.RSQUARE || kindof(ps.nt) === Tokens.END) && x.span != x.fullspan
        return mErrorToken(ps, x, UnexpectedWhiteSpace)
    else
        return x
    end
end
