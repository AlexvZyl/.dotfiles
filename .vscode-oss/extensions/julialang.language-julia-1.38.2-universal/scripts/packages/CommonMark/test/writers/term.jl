@testset "Terminal" begin
    p = Parser()

    test = function(text, expected)
        ast = p(text)
        @test term(ast) == expected
    end

    # Code blocks.
    test(
        "`code`",
        " \e[36mcode\e[39m\n"
    )
    # Inline HTML.
    test(
        "<em>text</em>",
        " \e[90m<em>\e[39mtext\e[90m</em>\e[39m\n"
    )
    # Links.
    test(
        "[link](url)",
        " \e[34;4mlink\e[39;24m\n"
    )
    # Images.
    test(
        "![link](url)",
        " \e[32mlink\e[39m\n"
    )
    # Emphasis.
    test(
        "*text*",
        " \e[3mtext\e[23m\n"
    )
    # Strong.
    test(
        "**text**",
        " \e[1mtext\e[22m\n"
    )
    # Headings.
    test(
        "# h1",
        " \e[34;1m#\e[39;22m h1\n"
    )
    test(
        "## h2",
        " \e[34;1m##\e[39;22m h2\n"
    )
    test(
        "### h3",
        " \e[34;1m###\e[39;22m h3\n"
    )
    test(
        "#### h4",
        " \e[34;1m####\e[39;22m h4\n"
    )
    test(
        "##### h5",
        " \e[34;1m#####\e[39;22m h5\n"
    )
    test(
        "###### h6",
        " \e[34;1m######\e[39;22m h6\n"
    )
    # Block quotes.
    test(
        "> quote",
        " \e[1m│\e[22m quote\n"
    )
    test(
        ">",
        " \e[1m│\e[22m\n",
    )
    # Lists.
    test(
        "1. one\n2. 5. five\n   6. six\n3. three\n4. four\n",
        "  1. one\n  \n  2.  5. five\n      \n      6. six\n  \n  3. three\n  \n  4. four\n"
    )
    test(
        "- - - - - - - item",
        "  ●  ○  ▶  ▷  ■  □  □ item\n"
    )
    test(
        "  - ",
        "  ● \n",
    )
    test(
        "1. ",
        "  1. \n",
    )
    test(
        "  - one\n  *\n  + three\n",
        "  ● one\n \n  ● \n \n  ● three\n",
    )
    test(
        "1. one\n2.\n3. three",
        "  1. one\n  \n  2. \n  \n  3. three\n",
    )

    # Thematic Breaks.
    test(
        "***",
        " \e[90m═════════════════════════════════════ § ═════════════════════════════════════\e[39m\n"
    )
    # Code blocks.
    test(
        """
        ```
        code
        ```
        """,
        "   \e[36m│\e[39m \e[90mcode\e[39m\n"
    )
end
