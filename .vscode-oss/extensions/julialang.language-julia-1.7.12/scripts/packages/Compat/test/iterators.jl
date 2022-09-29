module TestIterators

using Compat.Iterators
using Compat: Compat, Iterators
using Test

# https://github.com/JuliaLang/julia/pull/33437
@testset "takewhile" begin
    @test collect(takewhile(<(4),1:10)) == [1,2,3]
    @test collect(takewhile(<(4),Iterators.countfrom(1))) == [1,2,3]
    @test collect(takewhile(<(4),5:10)) == []
    @test collect(takewhile(_->true,5:10)) == 5:10
    @test collect(takewhile(isodd,[1,1,2,3])) == [1,1]
    @test collect(takewhile(<(2), takewhile(<(3), [1,1,2,3]))) == [1,1]
end

# https://github.com/JuliaLang/julia/pull/33437
@testset "dropwhile" begin
    @test collect(dropwhile(<(4), 1:10)) == 4:10
    @test collect(dropwhile(<(4), 1:10)) isa Vector{Int}
    @test isempty(dropwhile(<(4), []))
    @test collect(dropwhile(_->false,1:3)) == 1:3
    @test isempty(dropwhile(_->true, 1:3))
    @test collect(dropwhile(isodd,[1,1,2,3])) == [2,3]
    @test collect(dropwhile(iseven,dropwhile(isodd,[1,1,2,3]))) == [3]
end

# https://github.com/JuliaLang/julia/pull/34352
@testset "Iterators.map" begin
    @test collect(Iterators.map(string, 1:3)::Base.Generator) == map(string, 1:3)
    @test collect(Iterators.map(tuple, 1:3, 4:6)::Base.Generator) == map(tuple, 1:3, 4:6)
end

@testset "Iterators.filter" begin
    # `Iterators.filter` already existed in Julia 1.0.  We just make
    # sure that it is available under `Compat.Iterators` namespace.
    @test Compat.Iterators.filter === Base.Iterators.filter
end

end  # module
