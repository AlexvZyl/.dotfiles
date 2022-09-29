using Test

@static if VERSION >= v"1.9.0-"
    @testset "Check builtin.jl consistency" begin
        builtins_path = joinpath(@__DIR__, "..", "src", "builtins.jl")
        old_builtins = read(builtins_path, String)
        include("../bin/generate_builtins.jl")
        new_builtins = read(builtins_path, String)
        print(builtins_path, old_builtins)
        @test old_builtins == new_builtins
    end
end
