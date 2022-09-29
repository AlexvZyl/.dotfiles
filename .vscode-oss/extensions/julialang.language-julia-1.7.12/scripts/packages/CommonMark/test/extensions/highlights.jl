@testset "Highlights" begin
    highlighter(::MIME"text/html", node) = "NO HTML HIGHLIGHTING"
    highlighter(::MIME"text/latex", node) = "NO LATEX HIGHLIGHTING"
    highlighter(::MIME"text/plain", node) = "NO TERM HIGHLIGHTING"

    p = Parser()
    env = Dict("syntax-highlighter" => highlighter)

    ast = p(
        """
        ```julia
        code
        ```
        """
    )
    @test html(ast, env) == "<pre><code class=\"language-julia\">NO HTML HIGHLIGHTING</code></pre>\n"
    @test latex(ast, env) == "\\begin{lstlisting}\nNO LATEX HIGHLIGHTING\n\\end{lstlisting}\n"
    @test term(ast, env) == "   \e[36m│\e[39m \e[90mNO TERM HIGHLIGHTING\e[39m\n"
    @test markdown(ast, env) == "```julia\ncode\n```\n"
end
