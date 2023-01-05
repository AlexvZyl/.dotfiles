using CommonMark, Test, JSON, Pkg.TOML, Mustache, YAML

@testset "CommonMark" begin
    # Ensure no method ambiguities.
    @test isempty(Test.detect_ambiguities(Base, Core, CommonMark; recursive = true))

    # Do we pass the CommonMark spec -- version 0.29.0.
    @testset "Spec" begin
        for case in JSON.Parser.parsefile(joinpath(@__DIR__, "spec.json"))
            p = Parser()
            ast = p(case["markdown"])
            @test case["html"] == html(ast)
            # The following just make sure we don't throw on the other
            # rendering. Proper tests are found below.
            latex(ast)
            term(ast)
        end
    end

    include("spec.jl")
    include("ast.jl")
    include("parsing.jl")
    include("writers.jl")
    include("extensions.jl")
    include("templates.jl")
    include("integration.jl")

    # Basics: just make sure the parsing and rendering doesn't throw or hang.
    @testset "Samples" begin
        for (root, dirs, files) in walkdir(joinpath(@__DIR__, "samples"))
            for file in files
                if endswith(file, ".md")
                    name = joinpath(root, file)
                    expected = replace(read(splitext(name)[1] * ".html", String), "\r\n" => "\n")

                    p = Parser()
                    ast = p(read(name, String))

                    @testset "$file" begin
                        @test html(ast) == expected
                        # TODO: just renders, no checks.
                        latex(ast)
                        term(ast)
                    end
                end
            end
        end
    end
end
