using CSTParser, Test, CSTParser.Tokenize
using CSTParser: parse, remlineinfo!, span, headof, kindof, valof

@testset "CSTParser" begin
    include("spec.jl")
    include("parser.jl")
    include("interface.jl")
    include("display.jl")
    include("iterate.jl")
    if VERSION >= v"1.6"
        include("check_base.jl")
        include("errparse.jl")
    end
end
