block_rule(::Any) = nothing
block_modifier(::Any) = nothing
inline_rule(::Any) = nothing
inline_modifier(::Any) = nothing

struct Rule
    fn::Function
    priority::Float64
    triggers::String

    Rule(fn, priority, triggers="") = new(fn, priority, triggers)
end

function enable!(p::AbstractParser, fn, rule::Rule)
    p.priorities[rule.fn] = rule.priority
    for trigger in (isempty(rule.triggers) ? "\0" : rule.triggers)
        λs = get_funcs(p, fn, trigger)
        if rule.fn ∉ λs
            push!(λs, rule.fn)
            sort!(λs; by=λ->p.priorities[λ])
        end
    end
    return p
end
enable!(p::AbstractParser, fn, ::Nothing) = p
enable!(p::AbstractParser, fn, rules::Union{Tuple,Vector}) = (foreach(r -> enable!(p, fn, r), rules); p)
enable!(p::AbstractParser, fn, rule) = enable!(p, fn, fn(rule))

function enable!(p::AbstractParser, rule)
    enable!(p, inline_rule, rule)
    enable!(p, inline_modifier, rule)
    enable!(p, block_rule, rule)
    enable!(p, block_modifier, rule)
    push!(p.rules, rule)
    return p
end

enable!(p::AbstractParser, rules::Union{Tuple, Vector}) = (foreach(r -> enable!(p, r), rules); p)

get_funcs(p, ::typeof(block_rule), c)  = get!(() -> Function[], p.block_starts, c)
get_funcs(p, ::typeof(inline_rule), c) = get!(() -> Function[], p.inline_parser.inline_parsers, c)

get_funcs(p, ::typeof(block_modifier), _)  = p.modifiers
get_funcs(p, ::typeof(inline_modifier), _) = p.inline_parser.modifiers

function disable!(p::AbstractParser, rules::Union{Tuple, Vector})
    empty!(p.priorities)
    empty!(p.block_starts)
    empty!(p.modifiers)
    empty!(p.inline_parser.inline_parsers)
    empty!(p.inline_parser.modifiers)
    filter!(f -> f ∉ rules, p.rules)
    return enable!(p, copy(p.rules))
end
disable!(p::AbstractParser, rule) = disable!(p, [rule])

reset_rules!(p::AbstractParser) = (foreach(reset_rule!, p.rules); p)
reset_rule!(rule) = nothing
