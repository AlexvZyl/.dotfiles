using JuliaInterpreter
using Test

@test isempty(detect_ambiguities(JuliaInterpreter, Base, Core))

if !isdefined(@__MODULE__, :read_and_parse)
    include("utils.jl")
end

Core.eval(JuliaInterpreter, :(debug_recycle() = true))

@testset "Main tests" begin
    include("core.jl")
    include("interpret.jl")
    include("toplevel.jl")
    include("limits.jl")
    include("eval_code.jl")
    include("breakpoints.jl")
    VERSION >= v"1.8.0-DEV.370" && include("code_coverage/code_coverage.jl")
    remove()
    include("debug.jl")
end
