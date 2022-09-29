using LoweredCodeUtils
using Test

# @testset "Ambiguity" begin
#     @test isempty(detect_ambiguities(LoweredCodeUtils, LoweredCodeUtils.JuliaInterpreter, Base, Core))
# end

include("signatures.jl")
include("codeedges.jl")
