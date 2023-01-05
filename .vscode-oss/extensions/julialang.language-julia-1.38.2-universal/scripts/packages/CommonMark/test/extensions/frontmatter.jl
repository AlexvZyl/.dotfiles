@testset "Frontmatter" begin
    p = Parser()
    enable!(p, FrontMatterRule(json=JSON.Parser.parse, toml=TOML.parse, yaml=YAML.load))

    test = function (text, expected)
        ast = p(text)
        data = frontmatter(ast)
        @test length(data) == 1
        @test data["field"] == "data"
        @test html(ast) == expected
    end

    # JSON
    test(
        """
        ;;;
        {"field": "data"}
        ;;;
        ;;;
        """,
        "<p>;;;</p>\n"
    )

    # TOML
    test(
        """
        +++
        field = "data"
        +++
        +++
        """,
        "<p>+++</p>\n"
    )

    # YAML
    test(
        """
        ---
        field: data
        ---
        ---
        """,
        "<hr />\n"
    )

    # Unclosed frontmatter. Runs on until EOF.
    text =
    """
    +++
    one = 1
    two = 2
    """
    ast = p(text)
    data = frontmatter(ast)
    @test data["one"] == 1
    @test data["two"] == 2

    # Frontmatter must begin on the first line of the file. Otherwise it's a literal.
    text = "\n+++"
    ast = p(text)
    @test html(ast) == "<p>+++</p>\n"

    text =
    """
    ---
    field: data
    ---
    """
    ast = p(text)
    @test markdown(ast) == "---\nfield: data\n---\n"
    @test markdown(p(markdown(ast))) == markdown(ast)
end
