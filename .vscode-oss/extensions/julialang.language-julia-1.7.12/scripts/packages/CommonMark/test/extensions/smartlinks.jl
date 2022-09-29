@testset "Smart Links" begin
    function handler(::MIME"text/html", obj::CommonMark.Link, node::CommonMark.Node, env)
        name, _ = splitext(obj.destination)
        obj = deepcopy(obj)
        obj.destination = join([env["root"], "$name.html"], "/")
        return obj
    end
    handler(mime, obj, node, env) = obj

    p = Parser()
    env = Dict("root" => "/root", "smartlink-engine" => handler)

    ast = p("[link](url.md)")
    @test html(ast, env) == "<p><a href=\"/root/url.html\">link</a></p>\n"
    @test latex(ast, env) == "\\href{url.md}{link}\\par\n"
    @test term(ast, env) == " \e[34;4mlink\e[39;24m\n"
    @test markdown(ast, env) == "[link](url.md)\n"

    ast = p("![link](url.img)")
    @test html(ast, env) == "<p><img src=\"url.img\" alt=\"link\" /></p>\n"
    @test latex(ast, env) == "\\begin{figure}\n\\centering\n\\includegraphics[max width=\\linewidth]{url.img}\n\\caption{link}\n\\end{figure}\n\\par\n"
    @test term(ast, env) == " \e[32mlink\e[39m\n"
    @test markdown(ast, env) == "![link](url.img)\n"
end
