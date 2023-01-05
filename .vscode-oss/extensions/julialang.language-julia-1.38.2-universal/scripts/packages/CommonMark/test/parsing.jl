@testset "Parsing" begin
    # AST metadata via keywords.
    p = Parser()
    ast = p(""; empty=true)
    @test ast.meta["empty"] == true

    # Parsing file contents.
    readme = joinpath(@__DIR__, "../README.md")
    ast = open(p, readme)
    @test ast.meta["source"] == readme
    @test ast.first_child.t isa CommonMark.Heading

    # Parsing contents of a buffer.
    buffer = IOBuffer("# heading")
    ast = p(buffer)
    @test ast.first_child.t isa CommonMark.Heading
    @test markdown(ast) == "# heading\n"

    # Disabling parser rules.
    p = disable!(Parser(), CommonMark.AtxHeadingRule())
    ast = p("# *not a header*")
    @test ast.first_child.t isa CommonMark.Paragraph
    @test ast.first_child.first_child.nxt.t isa CommonMark.Emph
    @test markdown(ast) == "# *not a header*\n"
end
