mutable struct ListData
    type::Symbol
    tight::Bool
    bullet_char::Char
    start::Int
    delimiter::String
    padding::Int
    marker_offset::Int
    ListData(indent=0) = new(:bullet, true, ' ', 1, "", 0, indent)
end

mutable struct Item <: AbstractBlock
    list_data::ListData
    Item() = new(ListData())
end

mutable struct List <: AbstractBlock
    list_data::ListData
    List() = new(ListData())
end

is_container(::List) = true
is_container(::Item) = true

function parse_list_marker(parser::Parser, container::Node)
    if parser.indent ≥ 4
        return nothing
    end
    rest = SubString(parser.buf, parser.next_nonspace)
    data = ListData(parser.indent)
    m = Base.match(reBulletListMarker, rest)
    if m !== nothing
        data.type = :bullet
        data.bullet_char = m.match[1]
    else
        m2 = Base.match(reOrderedListMarker, rest)
        if m2 !== nothing && (!(container.t isa Paragraph) || m2.captures[1] == "1")
            m = m2
            data.type = :ordered
            data.start = Base.parse(Int, m.captures[1])
            data.delimiter = m.captures[2]
        else
            return nothing
        end
    end

    # Make sure we have spaces after.
    nextc = get(parser.buf, parser.next_nonspace + length(m.match), '\0')
    if nextc ∉ ('\0', '\t', ' ')
        return nothing
    end

    # If it interrupts paragraph make sure first line isn't blank.
    if container.t isa Paragraph && !occursin(reNonSpace, SubString(parser.buf, parser.next_nonspace + length(m.match)))
        return nothing
    end

    # We've got a match so advance offset and calculate padding.
    advance_next_nonspace(parser)  # ... to start of marker.
    advance_offset(parser, length(m.match), true)  # ... to end of marker.
    spaces_start_col = parser.column
    spaces_start_offset = parser.pos
    while true
        advance_offset(parser, 1, true)
        nextc = get(parser.buf, parser.pos, '\0')
        if parser.column - spaces_start_col < 5 && is_space_or_tab(nextc)
            nothing
        else
            break
        end
    end
    blank_item = get(parser.buf, parser.pos, nothing) === nothing
    spaces_after_marker = parser.column - spaces_start_col
    if spaces_after_marker ≥ 5 || spaces_after_marker < 1 || blank_item
        data.padding = length(m.match) + 1
        parser.column = spaces_start_col
        parser.pos = spaces_start_offset
        if is_space_or_tab(get(parser.buf, parser.pos, '\0'))
            advance_offset(parser, 1, true)
        end
    else
        data.padding = length(m.match) + spaces_after_marker
    end
    return data
end

function lists_match(list_data::ListData, item_data::ListData)
    return list_data.type == item_data.type &&
        list_data.delimiter == item_data.delimiter &&
        list_data.bullet_char == item_data.bullet_char
end

accepts_lines(::List) = false

continue_(::List, ::Parser, ::Node) = 0

function finalize(::List, parser::Parser, block::Node)
    item = block.first_child
    while !isnull(item)
        # Check for non-final list item ending with blank line.
        if ends_with_blank_line(item) && !isnull(item.nxt)
            block.t.list_data.tight = false
            break
        end
        # Recurse into children of list item, to see if there are spaces between any.
        subitem = item.first_child
        while !isnull(subitem)
            if ends_with_blank_line(subitem) && (!isnull(item.nxt) || !isnull(subitem.nxt))
                block.t.list_data.tight = false
                break
            end
            subitem = subitem.nxt
        end
        item = item.nxt
    end
    return nothing
end

can_contain(::List, t) = t isa Item

accepts_lines(::Item) = false

function continue_(::Item, parser::Parser, container::Node)
    if parser.blank
        if isnull(container.first_child)
            # Blank line after empty list item.
            return 1
        else
            advance_next_nonspace(parser)
        end
    elseif parser.indent ≥ (container.t.list_data.marker_offset + container.t.list_data.padding)
        advance_offset(parser, container.t.list_data.marker_offset + container.t.list_data.padding, true)
    else
        return 1
    end
    return 0
end

finalize(::Item, ::Parser, ::Node) = nothing

can_contain(::Item, t) = !(t isa Item)

function list_item(parser::Parser, container::Node)
    if  (!parser.indented || container.t isa List)
        data = parse_list_marker(parser, container)
        if data !== nothing
            close_unmatched_blocks(parser)
            # Add the list if needed.
            if !(parser.tip.t isa List) || !lists_match(container.t.list_data, data)
                container = add_child(parser, List(), parser.next_nonspace)
                container.t.list_data = data
            end
            # Add the list item.
            container = add_child(parser, Item(), parser.next_nonspace)
            container.t.list_data = data
            return 1
        end
    end
    return 0
end

struct ListItemRule end
block_rule(::ListItemRule) = Rule(list_item, 7, "1234567890-+*")
