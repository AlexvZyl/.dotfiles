@testset "Multiple Extensions" begin
    extensions = [
        AdmonitionRule(),
        AttributeRule(),
        AutoIdentifierRule(),
        CitationRule(),
        FootnoteRule(),
        FrontMatterRule(yaml=YAML.load),
        MathRule(),
        RawContentRule(),
        TableRule(),
        TypographyRule(),
    ]
    p = enable!(Parser(), extensions)
    ast = open(p, joinpath(@__DIR__, "integration.md"))
    @test !isempty(html(ast))
    @test !isempty(latex(ast))
    @test !isempty(term(ast))
    @test markdown(ast) == replace(read(joinpath(@__DIR__, "integration_output.md"), String), "\r" => "")
end
