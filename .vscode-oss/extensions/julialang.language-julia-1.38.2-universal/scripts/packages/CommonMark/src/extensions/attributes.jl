struct AttributeRule
    nodes::Vector{Node}
    AttributeRule() = new([])
end

struct Attributes <: AbstractBlock
    dict::Dict{String,Any}
    block::Bool
end

is_container(::Attributes) = false
accepts_lines(::Attributes) = false
continue_(::Attributes, ::Parser, ::Node) = 1
finalize(::Attributes, ::Parser, ::Node) = nothing
can_contain(::Attributes, t) = false

function parse_block_attributes(parser::Parser, container::Node)
    # Block attributes mustn't appear directly after another attribute block.
    if !parser.indented && (isnull(container.last_child) || !(container.last_child.t isa Attributes))
        dict, literal = try_parse_attributes(parser)
        if dict !== nothing
            advance_next_nonspace(parser)
            advance_offset(parser, length(literal), false)
            close_unmatched_blocks(parser)
            child = add_child(parser, Attributes(dict, true), parser.next_nonspace)
            child.literal = literal
            advance_offset(parser, length(parser) - position(parser) + 1, false)
            return 2
        end
    end
    return 0
end

block_rule(::AttributeRule) = Rule(parse_block_attributes, 1, "{")

inline_rule(rule::AttributeRule) = Rule(1, "{") do parser, block
    isnull(block.first_child) && return false # Can't have inline attribute as first in block.
    dict, literal = try_parse_attributes(parser)
    dict === nothing && return false
    node = Node(Attributes(dict, false))
    node.literal = literal
    push!(rule.nodes, node)
    append_child(block, node)
    return true
end

function try_parse_attributes(parser::AbstractParser)
    start_mark = pos = position(parser)
    while peek(parser, Char) === ' '
        # Consume leading spaces.
        read(parser, Char)
    end
    @assert read(parser, Char) === '{'
    valid = false
    dict = Dict{String,Any}()
    key = ""
    while !eof(parser)
        pos = position(parser)
        char = read(parser, Char)
        if char === '}'
            valid = key == ""
            break
        elseif isspace(char)
            continue
        elseif char === '='
            isempty(key) && break
        elseif char === ':'
            key = "element"
        elseif char === '#'
            key = "id"
        elseif char === '.'
            key = "class"
        elseif isletter(char) || isnumeric(char) || char in "-_"
            mark = pos
            while !eof(parser)
                pos = position(parser)
                char = peek(parser, Char)
                if isletter(char) || isnumeric(char) || char in "-_"
                    read(parser, Char)
                else
                    break
                end
            end
            word = chop(String(bytes(parser, mark, pos)); tail=1)
            if isempty(key)
                # Keys can't start with a number.
                startswith(word, r"[0-9]") && break
                key = word
                # Check for empty attribute syntax.
                if !startswith(parser, r"\s*=")
                    dict[key] = ""
                    key = ""
                end
            else
                if key == "class"
                    push!(get!(() -> String[], dict, key), word)
                else
                    dict[key] = word
                end
                key = ""
            end
        elseif char in "'\""
            # Simple strings, no escaping done.
            delimiter = char
            mark = pos
            while !eof(parser)
                pos = position(parser)
                char = read(parser, Char)
                if char === delimiter
                    break
                end
            end
            if isempty(key)
                # Strings can't be keys, so fail to parse.
                break
            else
                str = chop(String(bytes(parser, mark, pos)); head=1, tail=1)
                if key == "class"
                    push!(get!(() -> String[], dict, key), str)
                else
                    dict[key] = str
                end
                key = ""
            end
        end
    end
    if valid
        literal = String(bytes(parser, start_mark, pos))
        return dict, literal
    else
        seek(parser, start_mark)
        return nothing, ""
    end
end

block_modifier(::AttributeRule) = Rule(1) do parser, node
    if node.t isa Attributes && !isnull(node.nxt)
        node.nxt.t isa Attributes || (node.nxt.meta = node.t.dict)
    end
    return nothing
end

inline_modifier(rule::AttributeRule) = Rule(1) do parser, block
    while !isempty(rule.nodes)
        node = pop!(rule.nodes)
        if !isnull(node.prv) && !(node.prv.t isa Attributes)
            node.prv.meta = node.t.dict
        end
    end
end

# Writers.

write_html(::Attributes, w, n, ent) = nothing
write_latex(::Attributes, w, n, ent) = nothing
write_term(::Attributes, w, n, ent) = nothing

function write_markdown(at::Attributes, w, n, ent)
    if ent
        at.block && print_margin(w)
        literal(w, n.literal, at.block ? "\n" : "")
    end
end
