@testset "Notebook" begin
    p = Parser()

    test = function(text, expected)
        ast = p(text)
        json = JSON.Parser.parse(notebook(ast))
        @test join(json["cells"][1]["source"]) == expected
    end

    # Code blocks.
    test(
        "`code`",
        "`code`\n"
    )
    # Inline HTML.
    test(
        "<em>text</em>",
        "<em>text</em>\n"
    )
    # Links.
    test(
        "[link](url)",
        "[link](url)\n"
    )
    # Images.
    test(
        "![link](url)",
        "![link](url)\n"
    )
    # Emphasis.
    test(
        "*text*",
        "*text*\n"
    )
    # Strong.
    test(
        "**text**",
        "**text**\n"
    )
    # Headings.
    test(
        "# h1",
        "# h1\n"
    )
    test(
        "## h2",
        "## h2\n"
    )
    test(
        "### h3",
        "### h3\n"
    )
    test(
        "#### h4",
        "#### h4\n"
    )
    test(
        "##### h5",
        "##### h5\n"
    )
    test(
        "###### h6",
        "###### h6\n"
    )
    # Block quotes.
    test(
        "> quote",
        "> quote\n"
    )
    # Lists.
    test(
        "1. one\n2. 5. five\n   6. six\n3. three\n4. four\n",
        " 1. one\n 2.  5. five\n     6. six\n 3. three\n 4. four\n"
    )
    test(
        "- - - - - - - item",
        "  -   +   *   -   +   *   * item\n"
    )
    # Thematic Breaks.
    test(
        "***",
        "* * *\n"
    )
    # Code blocks.
    test(
        """
        ```julia
        code
        ```
        """,
        "code"
    )
    test(
        """
            code
        """,
        "    code\n"
    )
end
