@testset "Math" begin
    p = Parser()
    enable!(p, MathRule())

    # Inline
    text = "Some ``math``."
    ast = p(text)

    @test html(ast) == "<p>Some <span class=\"math tex\">\\(math\\)</span>.</p>\n"
    @test latex(ast) == "Some \\(math\\).\\par\n"
    @test term(ast) == " Some \e[35mmath\e[39m.\n"
    @test markdown(ast) == "Some ``math``.\n"

    ast = p("`x`")
    @test html(ast) == "<p><code>x</code></p>\n"

    # Display
    text = "```math\nmath\n```"
    ast = p(text)

    @test html(ast) == "<div class=\"display-math tex\">\\[math\\]</div>"
    @test latex(ast) == "\\begin{equation*}\nmath\n\\end{equation*}\n"
    @test term(ast) == "   \e[35m│\e[39m \e[90mmath\e[39m\n"
    @test markdown(ast) == "```math\nmath\n```\n"

    p = enable!(Parser(), [MathRule(), AttributeRule()])
    text = "Some ``math``{key='value'}."
    ast = p(text)

    @test html(ast) == "<p>Some <span class=\"math tex\" key=\"value\">\\(math\\)</span>.</p>\n"

    text =
    """
    {#id}
    ```math
    math
    ```
    """
    ast = p(text)

    @test html(ast) == "<div class=\"display-math tex\" id=\"id\">\\[math\\]</div>"
    @test latex(ast) == "\\protect\\hypertarget{id}{}\\begin{equation*}\nmath\n\\end{equation*}\n"

    # Dollar math
    p = enable!(Parser(), DollarMathRule())

    text = raw"Some $math$."
    ast = p(text)
    @test html(ast) == "<p>Some <span class=\"math tex\">\\(math\\)</span>.</p>\n"
    @test latex(ast) == "Some \\(math\\).\\par\n"
    @test markdown(ast) == "Some ``math``.\n"
    @test term(ast) == " Some \e[35mmath\e[39m.\n"

    text = raw"$$display math$$"
    ast = p(text)
    @test html(ast) == "<div class=\"display-math tex\">\\[display math\\]</div>"
    @test latex(ast) == "\\begin{equation*}\ndisplay math\n\\end{equation*}\n"
    @test markdown(ast) == "```math\ndisplay math\n```\n"
    @test term(ast) == "   \e[35m│\e[39m \e[90mdisplay math\e[39m\n"
end
