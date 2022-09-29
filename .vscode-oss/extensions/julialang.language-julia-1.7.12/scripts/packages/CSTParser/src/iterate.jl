module Iterating
using ..CSTParser: EXPR, headof, hastrivia, isoperator, valof, isstringliteral, is_exor, is_lparen, is_rparen

function Base.getindex(x::EXPR, i)
    try
        a = _getindex(x, i)
        if a === nothing
            error("indexing error for $(x.head) expression at $i")
        end
        return a
    catch
        rethrow()
        error("indexing error for $(x.head) expression at $i. args: $(x.args !== nothing ? headof.(x.args) : []) trivia: $(x.trivia !== nothing ? headof.(x.trivia) : [])")
    end
end

function _getindex(x::EXPR, i)
    if headof(x) === :abstract
        _abstract(x, i)
    elseif headof(x) === :as
        odda_event(x, i)
    elseif headof(x) === :block
        _block(x, i)
    elseif headof(x) === :braces
        _braces(x, i)
    elseif headof(x) === :brackets
        oddt_evena(x, i)
    elseif headof(x) === :call
        _call(x, i)
    elseif headof(x) === :comparison || headof(x) === :file
        x.args[i]
    elseif headof(x) === :comprehension
        tat(x, i)
    elseif headof(x) === :const
        _const(x, i)
    elseif headof(x) === :curly
        _curly(x, i)
    elseif headof(x) === :do
        odda_event(x, i)
    elseif headof(x) === :elseif
        _elseif(x, i)
    elseif headof(x) === :errortoken
        x.args[i]
    elseif headof(x) === :export
        oddt_evena(x, i)
    elseif headof(x) === :filter
        _filter(x, i)
    elseif headof(x) === :flatten
        _flatten(x, i)
    elseif headof(x) === :for
        taat(x, i)
    elseif headof(x) === :function || headof(x) === :macro
        _function(x, i)
    elseif headof(x) === :generator
        odda_event(x, i)
    elseif headof(x) === :global || headof(x) === :local
        _global(x, i)
    elseif headof(x) === :if
        if isoperator(first(x.trivia)) # ternary op
            odda_event(x, i)
        else
            _if(x, i)
        end
    elseif headof(x) === :kw
        _kw(x, i)
    elseif headof(x) === :let
        taat(x, i)
    elseif headof(x) === :return
        oddt_evena(x, i)
    elseif headof(x) === :macrocall
        _macrocall(x, i)
    elseif headof(x) === :module
        _module(x, i)
    elseif headof(x) === :outer
        ta(x, i)
    elseif headof(x) === :parameters
        if length(x.args) > 1 && headof(x.args[1]) === :parameters
            if i == length(x)
                x.args[1]
            elseif iseven(i)
                x.trivia[div(i, 2)]
            else
                x.args[div(i + 1, 2) + 1]
            end
        elseif length(x.args) > 1 && headof(x.args[2]) === :parameters
            if i == length(x)
                x.args[2]
            elseif i == 1
                x.args[1]
            elseif isodd(i)
                x.args[div(i + 1, 2) + 1]
            else
                x.trivia[div(i, 2)]
            end
        else
            odda_event(x, i)
        end
        # if hastrivia(x)
        #     odda_event(x, i)
        # else
        #     x.args[i]
        # end
    elseif headof(x) === :primitive
        _primitive(x, i)
    elseif headof(x) === :quote
        _quote(x, i)
    elseif headof(x) === :quotenode
        _quotenode(x, i)
    elseif headof(x) === :ref
        _call(x, i)
    elseif headof(x) === :row || headof(x) === :nrow
        x.args[i]
    elseif headof(x) === :string
        _string(x, i)
    elseif headof(x) === :struct
        _struct(x, i)
    elseif headof(x) === :toplevel
        x.args[i]
    elseif headof(x) === :try
        _try(x, i)
    elseif headof(x) === :tuple
        _tuple(x, i)
    elseif headof(x) === :typed_comprehension
        odda_event(x, i)
    elseif headof(x) === :typed_vcat || headof(x) === :typed_hcat || headof(x) === :typed_ncat
        _typed_vcat(x, i)
    elseif headof(x) === :using || headof(x) === :import
        _using(x, i)
    elseif headof(x) === :vcat || headof(x) === :hcat || headof(x) === :ncat || headof(x) === :bracescat
        _vcat(x, i)
    elseif headof(x) === :vect
        _vect(x, i)
    elseif headof(x) === :where
        _where(x, i)
    elseif headof(x) === :while
        taat(x, i)
    elseif isoperator(headof(x))
        if valof(headof(x)) == ":"
            _colon_in_using(x, i)
        elseif valof(headof(x)) == "."
            _dot(x, i)
        elseif valof(headof(x)) == "=" && hastrivia(x)
            # a loop that has been lowered from in/∈ to = at parse time
            if i == 1
                x.args[1]
            elseif i == 2
                x.trivia[1]
            elseif i == 3
                x.args[2]
            end
        elseif valof(headof(x)) == "->" && headof(x).fullspan == 0
            # anon function as used in a 'do' block
            if i == 1
                x.args[1]
            else
                x.args[2]
            end
        elseif length(x) == 2 && (valof(headof(x)) == "\$" || valof(headof(x)) == "::" || valof(headof(x)) == "<:" || valof(headof(x)) == ">:"  || valof(headof(x)) == "&")
            if i == 1
                x.head
            else
                x.args[1]
            end
        elseif !hastrivia(x)
            if i == 1
                x.args[1]
            elseif i == 2
                x.head
            elseif i == 3
                x.args[2]
            end
        else
            if i == 1
                x.head
            elseif i == 2
                x.trivia[1]
            elseif i == length(x)
                last(x.trivia)
            elseif isodd(i)
                x.args[div(i+1, 2) - 1]
            else
                x.trivia[div(i, 2)]
            end
        end
    else
        error("Indexing $x at $i")
    end
end
Base.iterate(x::EXPR) = length(x) == 0 ? nothing : (x[1], 1)
Base.iterate(x::EXPR, s) = s < length(x) ? (x[s + 1], s + 1) : nothing
Base.firstindex(x::EXPR) = 1
Base.lastindex(x::EXPR) = x.args === nothing ? 0 : length(x)

# Base.setindex!(x::EXPR, val, i) = Base.setindex!(x.args, val, i)
# Base.first(x::EXPR) = x.args === nothing ? nothing : first(x.args)
# Base.last(x::EXPR) = x.args === nothing ? nothing : last(x.args)


function ta(x, i)
    if i == 1
        x.trivia[1]
    elseif i == 2
        x.args[1]
    end
end
function tat(x, i)
    if i == 1
        x.trivia[1]
    elseif i == 2
        x.args[1]
    elseif i == 3
        x.trivia[2]
    end
end

function taat(x, i)
    if i == 1
        x.trivia[1]
    elseif i == 2
        x.args[1]
    elseif i == 3
        x.args[2]
    elseif i == 4
        x.trivia[2]
    end
end


function oddt_evena(x, i)
    if isodd(i)
        x.trivia[div(i + 1, 2)]
    else
        x.args[div(i, 2)]
    end
end

function odda_event(x, i)
    if isodd(i)
        x.args[div(i + 1, 2)]
    else
        x.trivia[div(i, 2)]
    end
end


function _const(x, i)
    if length(x.trivia) === 1
        ta(x, i)
    elseif length(x.trivia) === 2
        #global const
        if i < 3
            x.trivia[i]
        elseif i == 3
            x.args[1]
        end
    end
end

function _global(x, i)
    if length(x.trivia) > length(x.args) # probably :tuple
        if i <= 2
            x.trivia[i]
        elseif isodd(i)
            x.args[div(i - 1, 2)]
        else
            x.trivia[div(i - 2, 2) + 2]
        end
    else
        if hastrivia(x) && (headof(first(x.trivia)) === :GLOBAL || headof(first(x.trivia)) === :LOCAL)
            oddt_evena(x, i)
        else
            odda_event(x, i)
        end
    end
end

function _abstract(x, i)
    if i < 3
        x.trivia[i]
    elseif i == 3
        x.args[1]
    elseif i == 4
        x.trivia[3]
    end
end

function _primitive(x, i)
    if i < 3
        x.trivia[i]
    elseif i == 3
        x.args[1]
    elseif i == 4
        x.args[2]
    elseif i == 5
        x.trivia[3]
    end
end

function _struct(x, i)
    if length(x.trivia) == 2
        if i == 1
            x.trivia[1]
        elseif 1 < i < 5
            x.args[i - 1]
        elseif i == 5
            x.trivia[2]
        end
    elseif length(x.trivia) == 3 # mutable
        if i < 3
            x.trivia[i]
        elseif 2 < i < 6
            x.args[i - 2]
        elseif i == 6
            x.trivia[3]
        end
    end
end

function _block(x, i)
    if hastrivia(x) # We have a begin block
        if headof(x.trivia[1]) === :BEGIN
            if i == 1
                x.trivia[1]
            elseif 1 < i < length(x)
                x.args[i - 1]
            elseif i == length(x)
                x.trivia[2]
            end
        elseif headof(x.trivia[1]) === :COMMA # comma sep list as in :let block or iterators
            odda_event(x, i)
        end
    else
        x.args[i]
    end
end

function _quote(x, i)
    if x.trivia !== nothing && length(x.trivia) == 1
        if i == 1
            x.trivia[1]
        elseif i == 2
            x.args[1]
        end
    elseif x.trivia !== nothing && length(x.trivia) == 2
        tat(x, i)
    elseif x.trivia === nothing
        x.args[i]
    else
        error()
    end
end

function _quotenode(x, i)
    if hastrivia(x)
        if i == 1
            x.trivia[1]
        elseif i == 2
            x.args[1]
        end
    elseif i == 1
        x.args[1]
    end
end

function _function(x, i)
    if length(x.args) == 1
        tat(x, i)
    else length(x.args) == 2
        taat(x, i)
    end
end

function _braces(x, i)
    if length(x.args) > 0 && headof(x.args[1]) === :parameters
        if i == 1
            x.trivia[1]
        elseif i == length(x)
            last(x.trivia)
        elseif i == length(x) - 1
            x.args[1]
        elseif iseven(i)
            x.args[div(i, 2) + 1]
        else
            x.trivia[div(i + 1, 2)]
        end
    else
        if i == length(x)
            last(x.trivia)
        else
            oddt_evena(x, i)
        end
    end
end

function _curly(x, i)
    if i == 1
        x.args[1]
    elseif i == length(x)
        last(x.trivia)
    elseif length(x.args) > 1 && headof(x.args[2]) === :parameters
        if i == length(x) - 1
            x.args[2]
        elseif isodd(i)
            x.args[div(i + 1, 2) + 1]
        else
            x.trivia[div(i, 2)]
        end
    else
        if isodd(i)
            x.args[div(i + 1, 2)]
        else
            x.trivia[div(i, 2)]
        end
    end
end

function _using(x, i)
    oddt_evena(x, i)
end

function _colon_in_using(x, i)
    if i == 1
        x.args[1]
    elseif i == 2
        x.head
    elseif isodd(i)
        x.args[div(i + 1, 2)]
    else
        x.trivia[div(i, 2) - 1]
    end
end

function count_continuous(f, itr)
    cnt = 0
    for x in itr
        !f(x) && break
        cnt += 1
    end
    return cnt
end

function _dot(x, i)
    if x.head.span == 0 # Empty dot op, in using statement
        ndots = count_continuous(a -> valof(a) == ".", x.args)
        if i <= ndots
            x.args[i]
        elseif iseven(ndots)
            if isodd(i)
                x.args[ndots + div(i - ndots + 1, 2)]
            else
                x.trivia[div(i - ndots, 2)]
            end
        else
            if iseven(i)
                x.args[ndots + div(i - ndots + 1, 2)]
            else
                x.trivia[div(i - ndots, 2)]
            end
        end
    elseif length(x) == 2
        if i == 1
            x.head
        elseif i == 2
            x.args[1]
        end
    else
        if i == 1
            x.args[1]
        elseif i == 2
            x.head
        elseif i == 3
            x.args[2]
        end
    end
end

function _call(x, i)
    if isoperator(x.args[1])
        if length(x) == 2 # unary op call
            x.args[i]
        elseif length(x) == 3 && !hastrivia(x)# binary
            if i == 1
                x.args[2]
            elseif i == 2
                x.args[1]
            elseif i == 3
                x.args[3]
            end
        elseif hastrivia(x) && headof(x.trivia[1]) === :LPAREN # op call w/ brackets
            _curly(x, i)
        else # chained call: a + b + c + d + ...
            if i == 1
                x.args[2]
            elseif i == 2
                x.args[1]
            elseif i == 3
                x.args[3]
            elseif hastrivia(x)
                if iseven(i)
                    x.trivia[div(i - 2, 2)]
                else
                    x.args[div(i - 3, 2) + 3]
                end
            end
        end
    elseif hastrivia(x)
        _curly(x, i)
    else
        x.args[i]
    end
end

function _kw(x, i)
    if i == 1
        x.args[1]
    elseif i == 2
        x.trivia[1]
    elseif i == 3
        x.args[2]
    end
end

function _tuple(x, i)
    hasparams = x.args !== nothing && length(x.args) > 0 && headof(x.args[1]) === :parameters
    if hasparams
        if i == 1
            first(x.trivia)
        elseif i == length(x)
            last(x.trivia)
        elseif i == length(x) - 1
            first(x.args)
        elseif isodd(i)
            x.trivia[div(i + 1, 2)]
        else
            x.args[div(i, 2) + 1]
        end
    else
        if isempty(x.args)
            x.trivia[i]
        elseif hastrivia(x)
            if first(x.trivia).head === :LPAREN
                if i == length(x)
                    last(x.trivia)
                else
                    oddt_evena(x, i)
                end
            else
                odda_event(x, i)
            end
        else
            x.args[i]
        end
        # if isempty(x.args)
        #     x.trivia[i]
        # elseif length(x.trivia) == length(x.args) - 1  # No brackets, no trailing comma
        #     odda_event(x, i)
        # elseif length(x.trivia) - 1 == length(x.args) # Brackets, no trailing comma
        #     oddt_evena(x, i)
        # elseif length(x.trivia) - 2 == length(x.args) # Brackets, trailing comma
        #     if i == length(x)
        #         last(x.trivia)
        #     elseif i == length(x) - 1
        #         x.trivia[end-1]
        #     else
        #         oddt_evena(x, i)
        #     end
        # else
        #     odda_event(x, i)
        # end
    end
end

function _if(x, i)
    if length(x) == 4 # if c expr end
        taat(x, i)
    elseif length(x) == 5 # if c expr elseif... end
    if i == 1
        x.trivia[1]
    elseif i == 2
        x.args[1]
    elseif i == 3
        x.args[2]
    elseif i == 4
        x.args[3]
    elseif i == 5
        x.trivia[2]
    end
    elseif length(x) == 6 # if c expr else expr end
        if i == 1
            x.trivia[1]
        elseif i == 2
            x.args[1]
        elseif i == 3
            x.args[2]
        elseif i == 4
            x.trivia[2]
        elseif i == 5
            x.args[3]
        elseif i == 6
            x.trivia[3]
        end
    end
end

function _elseif(x, i)
    if length(x) == 3 || length(x) == 5
        if i == 1
            x.trivia[1]
        elseif i == 2
            x.args[1]
        elseif i == 3
            x.args[2]
        elseif i == 4
            x.trivia[2]
        elseif i == 5
            x.args[3]
        end
    elseif length(x) == 4
        if i == 1
            x.trivia[1]
        else
            x.args[i - 1]
        end
    end
end

function _string(x, i)
    # TODO: this is mega slow
    ai, ti = 1,1
    arg = isstringliteral(x.args[1])# && sizeof(valof(x.args[1])) !== x.args[1].fullspan
    isinterpolant = !arg
    bracket = false
    if hastrivia(x) && (x.trivia[1].head === :STRING || x.trivia[1].head === :TRIPLESTRING) && isempty(x.trivia[1].val)
        if i == 1
            return x.trivia[1]
        end
        arg = false
    end
    if i == length(x) && hastrivia(x) && (last(x.trivia).head === :STRING || last(x.trivia).head === :TRIPLESTRING || last(x.trivia).head === :errortoken) && isempty(last(x.trivia).val)
        return last(x.trivia)
    end
    for j = 1:i
        if j == i
            return arg ? x.args[ai] : x.trivia[ti]
        end

        if arg
            ai += 1
            if isinterpolant
                arg = !bracket
                if ai <= length(x.args) && !(isstringliteral(x.args[ai]) || x.args[ai].head === :errortoken)
                    # interpolated value immediately followed by xor
                    arg = false
                end
                bracket = false
                isinterpolant = false

            else
                arg = false
            end
        else
            if is_exor(x.trivia[ti]) || (x.trivia[ti].head === :errortoken && x.trivia[ti].args[1].head === :OPERATOR && valof(x.trivia[ti].args[1]) == "\$")
                if ti < length(x.trivia) && is_lparen(x.trivia[ti + 1])
                    #
                else
                    isinterpolant = true
                    arg = true
                end
            elseif is_lparen(x.trivia[ti])
                isinterpolant = true
                arg = true
                bracket = true
            elseif is_rparen(x.trivia[ti])
                isinterpolant = false
                arg = !(ai <= length(x.args) && !(isstringliteral(x.args[ai])) || x.args[ai].head == :errortoken)
                bracket = false
            end
            ti += 1
        end
    end
end

function _macrocall(x, i)
    if !hastrivia(x)
        x.args[i]
    else
        if i < 3
            x.args[i]
        elseif i == length(x)
            last(x.trivia)
        elseif length(x.args) > 2 && headof(x.args[3]) === :parameters
            if i == length(x) - 1
                x.args[3]
            elseif i == length(x)
                last(x.trivia)
            elseif isodd(i)
                x.trivia[div(i, 2)]
            else
                x.args[div(i + 1, 2) + 2]
            end
        else
            if isodd(i)
                x.trivia[div(i, 2)]
            else
                x.args[div(i + 1, 2) + 1]
            end
        end
    end
end

function _vect(x, i)
    _braces(x, i)
end

function _vcat(x, i)
    if i == 1
        x.trivia[1]
    elseif i == length(x)
        x.trivia[2]
    elseif (i-1) > length(x.args)
        # TODO Remove once we have figured out what is causing this bug
        error("Illegal indexing into CSTParser. x.head: '$(x.head)', x.trivia: '$(x.trivia)', x.args: '$(x.args)'.")
    else
        x.args[i - 1]
    end
end

function _typed_vcat(x, i)
    if i == 1
        x.args[1]
    elseif i == 2
        x.trivia[1]
    elseif i == length(x)
        x.trivia[2]
    else
        x.args[i - 1]
    end

end

function _module(x, i)
    if i == 1
        x.trivia[1]
    elseif i == 2
        x.args[1]
    elseif i == 3
        x.args[2]
    elseif i == 4
        x.args[3]
    elseif i == 5
        x.trivia[2]
    end
end

function _filter(x, i)
    if i == length(x)
        x.args[1]
    elseif iseven(i)
        x.trivia[div(i, 2)]
    else
        x.args[div(i + 1, 2) + 1]
    end
end

function _try(x, i)
    if i == 1
        x.trivia[1]
    elseif i == 2
        x.args[1]
    elseif length(x) == 6 # try expr catch e expr end
        if i == 3
            x.trivia[2]
        elseif i == 4
            x.args[2]
        elseif i == 5
            x.args[3]
        elseif i == 6
            x.trivia[3]
        end
    elseif length(x) == 7 # try expr catch finally end
        if i == 3
            x.args[2]
        elseif i == 4
            x.args[3]
        elseif i == 5
            x.trivia[2]
        elseif i == 6
            x.args[4]
        elseif i == 7
            x.trivia[3]
        end
    elseif length(x) == 8 # 'try expr catch e expr finally expr end' or 'else end'
        if i == 3
            x.trivia[2]
        elseif i == 4
            x.args[2]
        elseif i == 5
            x.args[3]
        elseif i == 6
            x.trivia[3]
        elseif i == 7
            x.args[4]
        elseif i == 8
            x.trivia[4]
        end
    elseif length(x) == 10 # try expr catch e expr else expr finally expr end
        if i == 3
            x.trivia[2]
        elseif i == 4
            x.args[2]
        elseif i == 5
            x.args[3]
        elseif i == 6
            x.trivia[4]
        elseif i == 7
            x.args[5]
        elseif i == 8
            x.trivia[3]
        elseif i == 9
            x.args[4]
        elseif i == 10
            x.trivia[5]
        end
    end
end

function _where(x, i)
    if i == 1
        x.args[1]
    elseif i == 2
        x.trivia[1]
    elseif i == 3 && length(x) == 3 && length(x.trivia) == 1
        return x.args[2]
    elseif i == length(x)
        last(x.trivia)
    elseif length(x.args) > 1 && headof(x.args[2]) === :parameters
        if i == length(x) - 1
            x.args[2]
        elseif isodd(i)
            x.trivia[div(i + 1, 2)]
        else
            x.args[div(i, 2) + 1]
        end
    else
        oddt_evena(x, i)
    end
end


function _flatten(x, i)
    lhs = _flatten_lhs(x)
    lhs[i]
end

function _flatten_lhs(x, ret = [])
    if x.args[1].head === :generator || x.args[1].head === :flatten
        if headof(x) !== :flatten
            for i = 2:length(x)
                push!(ret, x[i])
            end
        end
        _flatten_lhs(x.args[1], ret)
    else
        for i = 2:length(x)
            push!(ret, x[i])
        end
        pushfirst!(ret, x.args[1])
    end
end

end
