@testset "LaTeX" begin
    p = Parser()

    test = function(text, expected)
        ast = p(text)
        @test latex(ast) == expected
    end

    # Code blocks.
    test(
        "`code`",
        "\\texttt{code}\\par\n",
    )
    # Inline HTML.
    test(
        "<em>text</em>",
        "text\\par\n"
    )
    # Links.
    test(
        "[link](url)",
        "\\href{url}{link}\\par\n"
    )
    # Images.
    test(
        "![link](url)",
        "\\begin{figure}\n\\centering\n\\includegraphics[max width=\\linewidth]{url}\n\\caption{link}\n\\end{figure}\n\\par\n"
    )
    # Emphasis.
    test(
        "*text*",
        "\\textit{text}\\par\n"
    )
    # Strong.
    test(
        "**text**",
        "\\textbf{text}\\par\n"
    )
    # Headings.
    test(
        "# h1",
        "\\section{h1}\n"
    )
    test(
        "## h2",
        "\\subsection{h2}\n"
    )
    test(
        "### h3",
        "\\subsubsection{h3}\n"
    )
    test(
        "#### h4",
        "\\paragraph{h4}\n"
    )
    test(
        "##### h5",
        "\\subparagraph{h5}\n"
    )
    test(
        "###### h6",
        "\\subsubparagraph{h6}\n"
    )
    # Block quotes.
    test(
        "> quote",
        "\\begin{quote}\nquote\\par\n\\end{quote}\n"
    )
    # Lists.
    test(
        "- item",
        "\\begin{itemize}\n\\setlength{\\itemsep}{0pt}\n\\setlength{\\parskip}{0pt}\n\\item\nitem\\par\n\\end{itemize}\n"
    )
    test(
        "1. item",
        "\\begin{enumerate}\n\\def\\labelenumi{\\arabic{enumi}.}\n\\setcounter{enumi}{0}\n\\setlength{\\itemsep}{0pt}\n\\setlength{\\parskip}{0pt}\n\\item\nitem\\par\n\\end{enumerate}\n"
    )
    test(
        "3. item",
        "\\begin{enumerate}\n\\def\\labelenumi{\\arabic{enumi}.}\n\\setcounter{enumi}{2}\n\\setlength{\\itemsep}{0pt}\n\\setlength{\\parskip}{0pt}\n\\item\nitem\\par\n\\end{enumerate}\n"
    )
    test(
        "- item\n- item",
        "\\begin{itemize}\n\\setlength{\\itemsep}{0pt}\n\\setlength{\\parskip}{0pt}\n\\item\nitem\\par\n\\item\nitem\\par\n\\end{itemize}\n"
    )
    test(
        "1. item\n2. item",
        "\\begin{enumerate}\n\\def\\labelenumi{\\arabic{enumi}.}\n\\setcounter{enumi}{0}\n\\setlength{\\itemsep}{0pt}\n\\setlength{\\parskip}{0pt}\n\\item\nitem\\par\n\\item\nitem\\par\n\\end{enumerate}\n"
    )
    test(
        "- item\n\n- item",
        "\\begin{itemize}\n\\item\nitem\\par\n\\item\nitem\\par\n\\end{itemize}\n"
    )

    # Thematic Breaks.
    test(
        "***",
        "\\par\\bigskip\\noindent\\hrulefill\\par\\bigskip\n"
    )
    # Code blocks.
    test(
        """
            code
        """,
        "\\begin{verbatim}\ncode\n\\end{verbatim}\n"
    )
    test(
        """
        ```
        code
        ```
        """,
        "\\begin{lstlisting}\ncode\n\\end{lstlisting}\n"
    )
    # Escapes.
    test(
        "^~\\&%\$#_{}",
        "\\^{}{\\textasciitilde}\\&\\%\\\$\\#\\_\\{\\}\\par\n"
    )
end
