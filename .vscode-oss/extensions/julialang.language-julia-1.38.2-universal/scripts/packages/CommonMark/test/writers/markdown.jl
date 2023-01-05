@testset "Markdown" begin
    p = Parser()

    test = function(text, expected)
        ast = p(text)
        @test markdown(ast) == expected
        @test markdown(p(markdown(ast))) == expected # Is markdown output round-trip-able?
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
    # Emphasis.
    test(
        "_text_",
        "_text_\n"
    )
    # Strong.
    test(
        "__text__",
        "__text__\n"
    )
    # Emphasis.
    test(
        "_**text**_",
        "_**text**_\n"
    )
    # Strong.
    test(
        "*__text__*",
        "*__text__*\n"
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
    test(
        ">",
        ">\n"
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
    test(
        "  - ",
        "  - ",
    )
    test(
        "1. ",
        " 1. ",
    )
    test(
        "  - one\n  - \n  - three\n",
        "  - one\n  -     \n  - three\n"
    )
    test(
        "1. one\n2.\n3. three",
        " 1. one\n 2.     \n 3. three\n"
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
        "```julia\ncode\n```\n"
    )
    test(
        """
            code
        """,
        "    code\n"
    )
    test(
        """
        ```jldoctest
        julia> a = 1
        1

        julia> b = 2
        2
        ```
        """,
        "```jldoctest\njulia> a = 1\n1\n\njulia> b = 2\n2\n```\n"
    )
    test(
        """
            julia> a = 1
            1

            julia> b = 2
            2
        """,
        "    julia> a = 1\n    1\n\n    julia> b = 2\n    2\n"
    )
    # Escapes.
    test(
        "\\\\",
        "\\\\\n"
    )
    test(
        "\\`x\\`",
        "\\`x\\`\n"
    )
end
