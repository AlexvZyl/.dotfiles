# Public.

function Base.show(io::IO, ::MIME"text/latex", ast::Node, env=Dict{String,Any}())
    writer = Writer(LaTeX(), io, env)
    write_latex(writer, ast)
    return nothing
end
latex(args...) = writer(MIME"text/latex"(), args...)

# Internals.

mime_to_str(::MIME"text/latex") = "latex"

TEMPLATES["latex"] = joinpath(@__DIR__, "templates/latex.mustache")

mutable struct LaTeX
    LaTeX() = new()
end

function write_latex(writer::Writer, ast::Node)
    for (node, entering) in ast
        if entering
            meta = node.meta
            if haskey(meta, "id")
                literal(writer, "\\protect\\hypertarget{", meta["id"], "}{}")
            end
        end
        write_latex(node.t, writer, node, entering)
    end
end

write_latex(::Document, w, node, ent) = nothing

write_latex(::Text, w, node, ent) = latex_escape(w, node.literal)

write_latex(::Backslash, w, node, ent) = nothing

write_latex(::SoftBreak, w, node, ent) = cr(w)
write_latex(::LineBreak, w, node, ent) = cr(w)

function write_latex(::Code, w, node, ent)
    literal(w, "\\texttt{")
    latex_escape(w, node.literal)
    literal(w, "}")
end

write_latex(::HtmlInline, w, node, ent) = nothing

function write_latex(link::Link, w, node, ent)
    if ent
        link = _smart_link(MIME"text/latex"(), link, node, w.env)
        # Link destinations that begin with a # are taken to be internal to the
        # document. LaTeX wants to use a hyperlink rather than an href for
        # these, so branch based on it to allow both types of links to be used.
        # Generating `\url` commands is not supported.
        type, n = startswith(link.destination, '#') ? ("hyperlink", 1) : ("href", 0)
        literal(w, "\\$type{$(chop(link.destination; head=n, tail=0))}{")
    else
        literal(w, "}")
    end
end

function write_latex(image::Image, w, node, ent)
    if ent
        image = _smart_link(MIME"text/latex"(), image, node, w.env)
        cr(w)
        literal(w, "\\begin{figure}\n")
        literal(w, "\\centering\n")
        literal(w, "\\includegraphics[max width=\\linewidth]{", image.destination, "}\n")
        literal(w, "\\caption{")
    else
        literal(w, "}\n")
        literal(w, "\\end{figure}")
        cr(w)
    end
end

write_latex(::Emph, w, node, ent) = literal(w, ent ? "\\textit{" : "}")

write_latex(::Strong, w, node, ent) = literal(w, ent ? "\\textbf{" : "}")

function write_latex(::Paragraph, w, node, ent)
    literal(w, ent ? "" : "\\par\n")
end

function write_latex(::Heading, w, node, ent)
    if ent
        cr(w)
        n = node.t.level
        name = n ≤ 3 ? "sub"^(n-1) * "section" : "sub"^(n-4) * "paragraph"
        literal(w, "\\$name{")
    else
        literal(w, "}")
        cr(w)
    end
end

function write_latex(::BlockQuote, w, node, ent)
    cr(w)
    literal(w, ent ? "\\begin{quote}" : "\\end{quote}")
    cr(w)
end

function write_latex(list::List, w, node, ent)
    cr(w)
    command = list.list_data.type === :bullet ? "itemize" : "enumerate"
    if ent
        literal(w, "\\begin{$command}\n")
        if command == "enumerate"
            literal(w, "\\def\\labelenumi{\\arabic{enumi}.}\n")
            literal(w, "\\setcounter{enumi}{$(list.list_data.start-1)}\n")
        end
        if list.list_data.tight
            literal(w, "\\setlength{\\itemsep}{0pt}\n")
            literal(w, "\\setlength{\\parskip}{0pt}\n")
        end
    else
        literal(w, "\\end{$command}")
    end
    cr(w)
end

function write_latex(::Item, w, node, ent)
    literal(w, ent ? "\\item" : "")
    cr(w)
end

function write_latex(::ThematicBreak, w, node, ent)
    cr(w)
    literal(w, "\\par\\bigskip\\noindent\\hrulefill\\par\\bigskip")
    cr(w)
end

function write_latex(c::CodeBlock, w, node, ent)
    environment = c.is_fenced ? "lstlisting" : "verbatim"
    cr(w)
    literal(w, "\\begin{$environment}")
    cr(w)
    literal(w, _syntax_highlighter(w, MIME("text/latex"), node))
    cr(w)
    literal(w, "\\end{$environment}")
    cr(w)
end

write_latex(::HtmlBlock, w, node, ent) = nothing

let chars = Dict(
        '^'  => "\\^{}",
        '\\' => "{\\textbackslash}",
        '~'  => "{\\textasciitilde}",
    )
    for c in "&%\$#_{}"
        chars[c] = "\\$c"
    end
    global function latex_escape(w::Writer, s::AbstractString)
        for ch in s
            literal(w, get(chars, ch, ch))
        end
    end

    global function latex_escape(s::AbstractString)
        buffer = IOBuffer()
        for ch in s
            write(buffer, get(chars, ch, ch))
        end
        return String(take!(buffer))
    end
end
