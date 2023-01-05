abstract type TableComponent <: AbstractBlock end

is_container(::TableComponent) = true
accepts_lines(::TableComponent) = false
finalize(table::TableComponent, parser::Parser, node::Node) = nothing
can_contain(::TableComponent, ::Any) = false

struct Table <: TableComponent
    spec::Vector{Symbol}
    Table(spec) = new(spec)
end

continue_(table::Table, parser::Parser, container::Node) = 0

struct TableHeader <: TableComponent
end

struct TableBody <: TableComponent
end

continue_(table::TableBody, parser::Parser, container::Node) = 1

struct TableRow <: TableComponent
end

contains_inlines(::TableRow) = true

struct TableCell <: TableComponent
    align::Symbol
    header::Bool
    column::Int
end

contains_inlines(::TableCell) = true

function gfm_table(parser::Parser, container::Node)
    if !parser.indented
        if container.t isa Paragraph
            header = container.literal
            spec_str = SubString(parser.buf, parser.next_nonspace)
            if valid_table_spec(spec_str)
                # Parse the table spec line.
                spec = parse_table_spec(spec_str)
                table = Node(Table(spec), container.sourcepos)
                # Build header row with cells for each column.
                head = Node(TableHeader(), container.sourcepos)
                append_child(table, head)
                row = Node(TableRow(), container.sourcepos)
                row.literal = header
                append_child(head, row)
                # Insert the empty body for the table.
                body = Node(TableBody(), container.sourcepos)
                append_child(table, body)
                # Splice the newly created table in place of the paragraph.
                insert_after(container, table)
                unlink(container)
                parser.tip = table
                advance_offset(parser, length(parser.buf) - parser.pos + 1, false)
                return 2
            end
        end
        if container.t isa Table
            line = SubString(parser.buf, parser.next_nonspace)
            if valid_table_row(line)
                row = Node(TableRow(), container.sourcepos)
                append_child(container.last_child, row)
                row.literal = line
                advance_offset(parser, length(parser.buf) - parser.pos + 1, false)
                return 2
            end
        end
    end
    return 0
end

valid_table_row(str) = startswith(str, '|')
valid_table_spec(str) = !occursin(r"[^\|:\- ]", str)

function parse_table_spec(str)
    map(eachmatch(r"\|([ ]*[: ]?[-]+[ :]?[ ]*)\|", str; overlap=true)) do match
        str = strip(match[1])
        left, right = str[1] === ':', str[end] === ':'
        center = left && right
        align = center ? :center : right ? :right : :left
        return align
    end
end

struct TableRule
    pipes::Vector{Node}
    TableRule() = new([])
end

block_rule(::TableRule) = Rule(gfm_table, 0.5, "|")

struct TablePipe <:AbstractInline end

inline_rule(rule::TableRule) = Rule(0, "|") do parser, block
    block.t isa TableRow || return false
    @assert read(parser, Char) == '|'
    eof(parser) && return true # Skip last pipe.
    pipe = Node(TablePipe())
    append_child(block, pipe)
    push!(rule.pipes, pipe)
    return true
end

# Low priority since this *must* happen after nested structure of emphasis and
# links is determined. 100 should do fine.
inline_modifier(rule::TableRule) = Rule(100) do parser, block
    block.t isa TableRow || return
    isheader = block.parent.t isa TableHeader
    spec = block.parent.parent.t.spec
    max_cols = length(spec)
    col = 1
    cells = Node[]
    while !isempty(rule.pipes)
        pipe = popfirst!(rule.pipes)
        if pipe.parent === block
            # Top-level pipe must be replaced with a table cell containing
            # everything up until the next pipe.
            cell = Node(TableCell(spec[min(col, max_cols)], isheader, col))
            n = pipe.nxt
            elems = Node[]
            # Find all nodes between this pipe and the next.
            while !isnull(n) && !(n.t isa TablePipe)
                push!(elems, n)
                n = n.nxt
            end
            total = length(elems)
            for (nth, elem) in enumerate(elems)
                # Strip surronding whitespace in each cell.
                lit = elem.literal
                lit = (nth === 1 && elem.t isa Text) ? lstrip(lit) : lit
                lit = (nth === total && elem.t isa Text) ? rstrip(lit) : lit
                elem.literal = lit
                append_child(cell, elem)
            end
            push!(cells, cell)
            unlink(pipe)
            col += 1
        else
            # Replace nested pipes with text literals since they can't
            # demarcate a cell boarder.
            pipe.t = Text()
            pipe.literal = "|"
        end
    end
    if length(cells) < max_cols
        # Add addtional cells in this row is below number in spec.
        extra = (length(cells)+1):max_cols
        append!(cells, (Node(TableCell(:left, isheader, n)) for n in extra))
    end
    for (nth, cell) in enumerate(cells)
        # Drop additional cells if they are longer that the spec.
        nth ≤ length(spec) ? append_child(block, cell) : unlink(cell)
    end
end

#
# Writers
#

# HTML

write_html(::Table, rend, n, ent) = tag(rend, ent ? "table" : "/table", ent ? attributes(rend, n) : [])
write_html(::TableHeader, rend, node, enter) = tag(rend, enter ? "thead" : "/thead")
write_html(::TableBody, rend, node, enter) = tag(rend, enter ? "tbody" : "/tbody")
write_html(::TableRow, rend, node, enter) = tag(rend, enter ? "tr" : "/tr")

function write_html(cell::TableCell, rend, node, enter)
    tag_name = cell.header ? "th" : "td"
    tag(rend, enter ? "$tag_name align=\"$(cell.align)\"" : "/$tag_name")
end

# LaTeX

function write_latex(table::Table, rend, node, enter)
    if enter
        print(rend.buffer, "\\begin{longtable}[]{@{}")
        join(rend.buffer, (string(align)[1] for align in table.spec))
        println(rend.buffer, "@{}}")
    else
        println(rend.buffer, "\\end{longtable}")
    end
end

function write_latex(::TableHeader, rend, node, enter)
    if enter
        println(rend.buffer, "\\hline")
    else
        println(rend.buffer, "\\hline")
        println(rend.buffer, "\\endfirsthead")
    end
end

function write_latex(::TableBody, rend, node, enter)
    if !enter
        println(rend.buffer, "\\hline")
    end
end

function write_latex(::TableRow, rend, node, enter)
    enter ? nothing : println(rend.buffer, "\\tabularnewline")
end

function write_latex(::TableCell, rend, node, enter)
    if !enter && node.parent.last_child !== node
        print(rend.buffer, " & ")
    end
end

# Term

function write_term(table::Table, rend, node, enter)
    if enter
        cells, widths = calculate_columns_widths(table, node) do node
            length(replace(term(node), r"\e\[[0-9]+(?:;[0-9]+)*m" => ""))
        end
        rend.context[:cells] = cells
        rend.context[:widths] = widths

        print_margin(rend)
        print(rend.format.buffer, "┏━")
        join(rend.format.buffer, ("━"^w for w in widths), "━┯━")
        println(rend.format.buffer, "━┓")
    else
        print_margin(rend)
        print(rend.format.buffer, "┗━")
        join(rend.format.buffer, ("━"^w for w in rend.context[:widths]), "━┷━")
        println(rend.format.buffer, "━┛")

        delete!(rend.context, :cells)
        delete!(rend.context, :widths)
    end
    return nothing
end

function write_term(::TableHeader, rend, node, enter)
    if !enter
        print_margin(rend)
        print(rend.format.buffer, "┠─")
        join(rend.format.buffer, ("─"^w for w in rend.context[:widths]), "─┼─")
        println(rend.format.buffer, "─┨")
    end
    return nothing
end

write_term(::TableBody, rend, node, enter) = nothing

function write_term(::TableRow, rend, node, enter)
    if enter
        print_margin(rend)
        print(rend.format.buffer, "┃ ")
    else
        println(rend.format.buffer, " ┃")
    end
    return nothing
end

function write_term(cell::TableCell, rend, node, enter)
    if haskey(rend.context, :widths)
        pad = rend.context[:widths][cell.column] - rend.context[:cells][node]
        if enter
            if cell.align == :left
            elseif cell.align == :right
                print(rend.format.buffer, ' '^pad)
            elseif cell.align == :center
                left = Int(round(pad/2, RoundDown))
                print(rend.format.buffer, ' '^left)
            end
        else
            if cell.align == :left
                print(rend.format.buffer, ' '^pad)
            elseif cell.align == :right
            elseif cell.align == :center
                right = Int(round(pad/2, RoundUp))
                print(rend.format.buffer, ' '^right)
            end
            if !isnull(node.nxt)
                print(rend.format.buffer, " │ ")
            end
        end
    end
    return nothing
end

# Markdown

function write_markdown(table::Table, w::Writer, node, enter)
    if enter
        cells, widths = calculate_columns_widths(node -> length(markdown(node)), table, node)
        w.context[:cells] = cells
        w.context[:widths] = widths
    else
        delete!(w.context, :cells)
        delete!(w.context, :widths)
        linebreak(w, node)
    end
    return nothing
end

function write_markdown(::TableHeader, w, node, enter)
    if enter
    else
        spec = node.parent.t.spec
        print_margin(w)
        literal(w, "|")
        for (width, align) in zip(w.context[:widths], spec)
            literal(w, align in (:left, :center)  ? ":" : " ")
            literal(w, "-"^width)
            literal(w, align in (:center, :right) ? ":" : " ")
            literal(w, "|")
        end
        cr(w)
    end
    return nothing
end

write_markdown(::TableBody, w, node, enter) = nothing

function write_markdown(::TableRow, w, node, enter)
    if enter
        print_margin(w)
        literal(w, "| ")
    else
        literal(w, " |")
        cr(w)
    end
    return nothing
end

function write_markdown(cell::TableCell, w, node, enter)
    if haskey(w.context, :widths)
        if !enter
            padding = w.context[:widths][cell.column] - w.context[:cells][node]
            literal(w, " "^padding)
            isnull(node.nxt) || literal(w, " | ")
        end
    end
    return nothing
end

# Utilities.

function calculate_columns_widths(width_func, table, node)
    cells, widths = Dict{Node,Int}(), ones(Int, length(table.spec))
    index = 0
    for (n, enter) in node
        if enter
            if n.t isa TableRow
                index = 0
            elseif n.t isa TableCell
                index += 1
                cell = width_func(n)
                widths[index] = max(widths[index], cell)
                cells[n] = cell
            end
        end
    end
    return cells, widths
end
