struct AutoIdentifierRule
    refs::IdDict{Node,Dict{String,Int}}
    AutoIdentifierRule(refs=IdDict()) = new(refs)
end

reset_rule!(r::AutoIdentifierRule) = (empty!(r.refs); nothing)

block_modifier(rule::AutoIdentifierRule) = Rule(100) do parser, block
    # Add heading IDs to those without any preset by AttributeRule.
    if block.t isa Heading && !haskey(block.meta, "id")
        block.meta["id"] = slugify(block.literal)
    end
    # Then make sure all IDs for the current AutoIdentifierRule are unique using a counter.
    if haskey(block.meta, "id")
        counter = get!(() -> Dict{String,Int}(), rule.refs, parser.doc)
        id = block.meta["id"]
        counter[id] = get!(counter, id, 0) + 1
        block.meta["id"] = counter[id] == 1 ? id : "$id-$(counter[id] - 1)"
    end
    return nothing
end

# Modelled on pandoc's algorithm.
function slugify(str::AbstractString)
    str = lowercase(str)
    str = replace(str, r"\p{Z}+" => "-")
    str = replace(str, r"[^\p{L}\p{N}\-]+" => "")
    str = lstrip(c -> isnumeric(c) || ispunct(c), str)
    return isempty(str) ? "section" : str
end
