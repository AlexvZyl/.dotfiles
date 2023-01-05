@testset "Attributes" begin
    p = Parser()
    enable!(p, AttributeRule())

    # Syntax.

    test = function (text, dict)
        ast = p(text)
        @test ast.first_child.t isa CommonMark.Attributes
        @test ast.first_child.t.dict == dict
    end

    test("{}", Dict{String,Any}())
    test("{empty}", Dict{String,Any}("empty" => ""))
    test("{#id}", Dict{String,Any}("id" => "id"))
    test("{empty #id}", Dict{String,Any}("id" => "id", "empty" => ""))
    test("{#id empty}", Dict{String,Any}("id" => "id", "empty" => ""))
    test("{#one #two}", Dict{String,Any}("id" => "two")) # Only last # is kept.
    test("{.class}", Dict{String,Any}("class" => ["class"]))
    test("{empty .class}", Dict{String,Any}("class" => ["class"], "empty" => ""))
    test("{.one.two}", Dict{String,Any}("class" => ["one", "two"])) # All .s are kept.
    test("{:element}", Dict{String,Any}("element" => "element"))
    test("{:element empty}", Dict{String,Any}("element" => "element", "empty" => ""))
    test("{one=two}", Dict{String,Any}("one" => "two"))
    test("{empty one=two other}", Dict{String,Any}("one" => "two", "empty" => "", "other" => ""))
    test("{one=two three='four'}", Dict{String,Any}("one" => "two", "three" => "four"))
    test("{one=two empty three='four'}", Dict{String,Any}("one" => "two", "three" => "four", "empty" => ""))
    test("{one=2 three=4}", Dict{String,Any}("one" => "2", "three" => "4"))
    test("{#id .class one=two three='four'}", Dict{String,Any}("id" => "id", "class" => ["class"], "one" => "two", "three" => "four"))

    # Block metadata attachment.

    test = function (text, T, dict)
        ast = p(text)
        @test ast.first_child.t isa CommonMark.Attributes
        @test ast.first_child.nxt.t isa T
        @test ast.first_child.nxt.meta == dict
        @test text == markdown(ast)
    end
    dict = Dict{String,Any}("id" => "id")

    test(
        """
        {#id}
        # H1
        """,
        CommonMark.Heading,
        dict
    )
    test(
        """
        {#id}
        > blockquote
        """,
        CommonMark.BlockQuote,
        dict
    )
    test(
        """
        {#id}
        ```
        code
        ```
        """,
        CommonMark.CodeBlock,
        dict
    )
    test(
        """
        {#id}
          - one
          - two
          - three
        """,
        CommonMark.List,
        dict
    )
    test(
        """
        {#id}
        paragraph
        """,
        CommonMark.Paragraph,
        dict
    )
    test(
        """
        {#id}
        * * *
        """,
        CommonMark.ThematicBreak,
        dict
    )
    test(
        """
          {.hidden}
          - list
        """,
        CommonMark.List,
        Dict{String,Any}("class" => ["hidden"])
    )

    # Inline metadata attachment.

    test = function (text, T, dict, md=text)
        ast = p(text)
        @test ast.first_child.first_child.t isa T
        @test ast.first_child.first_child.nxt.t isa CommonMark.Attributes
        @test ast.first_child.first_child.meta == dict
        @test md * "\n" == markdown(ast) # Paragraphs add a newline at end.
    end

    test("*word*{#id}", CommonMark.Emph, dict)
    test("[word](url){#id}", CommonMark.Link, dict)
    test("![word](url){#id}", CommonMark.Image, dict)
    test("**word**{#id}", CommonMark.Strong, dict)
    test("`word`{#id}", CommonMark.Code, dict)
    test("<http://www.website.com>{#id}", CommonMark.Link, dict, "[http://www.website.com](http://www.website.com){#id}")

    test = function (input, f, output)
        ast = p(input)
        @test f(ast) == output
    end

    test("{#id}\n# H1", html, "<h1 id=\"id\"><a href=\"#id\" class=\"anchor\"></a>H1</h1>\n")
    test("{.one.two}\n# H1", html, "<h1 class=\"one two\">H1</h1>\n")
    test("{#id}\n# H1", latex, "\\protect\\hypertarget{id}{}\n\\section{H1}\n")

    test("*word*{#id}", html, "<p><em id=\"id\">word</em></p>\n")
    test("*word*{.one.two}", html, "<p><em class=\"one two\">word</em></p>\n")
    test("*word*{#id}", latex, "\\protect\\hypertarget{id}{}\\textit{word}\\par\n")
end
