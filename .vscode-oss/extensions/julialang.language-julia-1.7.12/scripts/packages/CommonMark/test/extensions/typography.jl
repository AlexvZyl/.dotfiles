@testset "Typography" begin
    p = Parser()
    enable!(p, TypographyRule())

    text = "\"Double quotes\", 'single quotes', ellipses...., and-- dashes---"
    ast = p(text)

    @test html(ast) == "<p>“Double quotes”, ‘single quotes’, ellipses…., and– dashes—</p>\n"
    @test latex(ast) == "“Double quotes”, ‘single quotes’, ellipses…., and– dashes—\\par\n"
    @test term(ast) == " “Double quotes”, ‘single quotes’, ellipses…., and– dashes—\n"
    @test markdown(ast) == "“Double quotes”, ‘single quotes’, ellipses…., and– dashes—\n"
end
