@testset "Admonitions" begin
    p = Parser()
    enable!(p, AdmonitionRule())

    text =
    """
    !!! warning

        text
    """
    ast = p(text)

    @test html(ast) == "<div class=\"admonition warning\"><p class=\"admonition-title\">Warning</p>\n<p>text</p>\n</div>"
    @test latex(ast) == "\\begin{admonition@warning}{Warning}\ntext\\par\n\\end{admonition@warning}\n"
    @test term(ast) == " \e[33;1m┌ Warning ────────────────────────────────────────────────────────────────────\e[39;22m\n \e[33;1m│\e[39;22m text\n \e[33;1m└─────────────────────────────────────────────────────────────────────────────\e[39;22m\n"
    @test markdown(ast) == "!!! warning\n    \n    text\n"

    text =
    """
    !!! warning

    \ttext
    """
    ast = p(text)

    @test html(ast) == "<div class=\"admonition warning\"><p class=\"admonition-title\">Warning</p>\n<p>text</p>\n</div>"
    @test latex(ast) == "\\begin{admonition@warning}{Warning}\ntext\\par\n\\end{admonition@warning}\n"
    @test term(ast) == " \e[33;1m┌ Warning ────────────────────────────────────────────────────────────────────\e[39;22m\n \e[33;1m│\e[39;22m text\n \e[33;1m└─────────────────────────────────────────────────────────────────────────────\e[39;22m\n"
    @test markdown(ast) == "!!! warning\n    \n    text\n"

    text =
    """
    !!! info "Custom Title"

        text
    """
    ast = p(text)

    @test html(ast) == "<div class=\"admonition info\"><p class=\"admonition-title\">Custom Title</p>\n<p>text</p>\n</div>"
    @test latex(ast) == "\\begin{admonition@info}{Custom Title}\ntext\\par\n\\end{admonition@info}\n"
    @test term(ast) == " \e[36;1m┌ Custom Title ───────────────────────────────────────────────────────────────\e[39;22m\n \e[36;1m│\e[39;22m text\n \e[36;1m└─────────────────────────────────────────────────────────────────────────────\e[39;22m\n"
    @test markdown(ast) == "!!! info \"Custom Title\"\n    \n    text\n"

    p = enable!(Parser(), [AdmonitionRule(), AttributeRule()])

    text =
    """
    {#id}
    !!! warning

        text
    """
    ast = p(text)

    @test html(ast) == "<div class=\"admonition warning\" id=\"id\"><p class=\"admonition-title\">Warning</p>\n<p>text</p>\n</div>"
    @test latex(ast) == "\\protect\\hypertarget{id}{}\n\\begin{admonition@warning}{Warning}\ntext\\par\n\\end{admonition@warning}\n"
end
