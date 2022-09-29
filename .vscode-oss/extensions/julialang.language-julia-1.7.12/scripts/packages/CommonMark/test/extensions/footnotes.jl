@testset "Footnotes" begin
    p = Parser()
    enable!(p, FootnoteRule())

    # Links
    text = "text[^1]"
    ast = p(text)

    @test html(ast) == "<p>text<a href=\"#footnote-1\" class=\"footnote\">1</a></p>\n"
    @test latex(ast) == "text\\par\n" # No definition so not displayed in LaTeX.
    @test term(ast) == " text\e[31m[^1]\e[39m\n"
    @test markdown(ast) == "text[^1]\n"

    # Definitions
    text = "[^1]: text"
    ast = p(text)

    @test html(ast) == "<div class=\"footnote\" id=\"footnote-1\"><p class=\"footnote-title\">1</p>\n<p>text</p>\n</div>"
    @test latex(ast) == "" # Definitions vanish in LaTeX since they are inlined.
    @test term(ast) == " \e[31m┌ [^1] ───────────────────────────────────────────────────────────────────────\e[39m\n \e[31m│\e[39m text\n \e[31m└─────────────────────────────────────────────────────────────────────────────\e[39m\n"
    @test markdown(ast) == "[^1]: text\n"

    text = "text[^1].\n\n[^1]: text"
    ast = p(text)
    @test latex(ast) == "text\\footnote{text\\par\n\\label{fn:1}}.\\par\n"
    @test markdown(ast) == "text[^1].\n\n[^1]: text\n"

    p = enable!(Parser(), [FootnoteRule(), AttributeRule()])

    text = "text[^1]{#id}"
    ast = p(text)

    @test html(ast) == "<p>text<a href=\"#footnote-1\" class=\"footnote\" id=\"id\">1</a></p>\n"

    text =
    """
    {key="value"}
    [^1]: text
    """
    ast = p(text)

    @test html(ast) == "<div class=\"footnote\" id=\"footnote-1\" key=\"value\"><p class=\"footnote-title\">1</p>\n<p>text</p>\n</div>"

    text =
    """
    text[^1]{#id}.

    {key="value"}
    [^1]: text
    """
    ast = p(text)
    @test html(ast) == "<p>text<a href=\"#footnote-1\" class=\"footnote\" id=\"id\">1</a>.</p>\n<div class=\"footnote\" id=\"footnote-1\" key=\"value\"><p class=\"footnote-title\">1</p>\n<p>text</p>\n</div>"
    @test latex(ast) == "text\\protect\\hypertarget{id}{}\\footnote{text\\par\n\\label{fn:1}}.\\par\n"

    text = "[^1]:\n\n    text"
    ast = p(text)

    @test html(ast) == "<div class=\"footnote\" id=\"footnote-1\"><p class=\"footnote-title\">1</p>\n<p>text</p>\n</div>"
    @test latex(ast) == "" # Definitions vanish in LaTeX since they are inlined.
    @test term(ast) == " \e[31m┌ [^1] ───────────────────────────────────────────────────────────────────────\e[39m\n \e[31m│\e[39m text\n \e[31m└─────────────────────────────────────────────────────────────────────────────\e[39m\n"
    @test markdown(ast) == "[^1]: text\n"

    text = "[^1]:\n\n\ttext"
    ast = p(text)

    @test html(ast) == "<div class=\"footnote\" id=\"footnote-1\"><p class=\"footnote-title\">1</p>\n<p>text</p>\n</div>"
    @test latex(ast) == "" # Definitions vanish in LaTeX since they are inlined.
    @test term(ast) == " \e[31m┌ [^1] ───────────────────────────────────────────────────────────────────────\e[39m\n \e[31m│\e[39m text\n \e[31m└─────────────────────────────────────────────────────────────────────────────\e[39m\n"
    @test markdown(ast) == "[^1]: text\n"
end
