using TableTraits
using IteratorInterfaceExtensions
using Test

@testset "TableTraits" begin

    table_array = [(a = 1,), (a = 2,)]
    any_table_array = Any[(a = 1,), (a = 2,)]
    other_array = [1,2,3]
    without_eltype = (i for i in table_array)

    @test isiterabletable(table_array)
    @test !isiterabletable(other_array)
    @test isiterabletable(without_eltype) === missing
    @test isiterabletable(any_table_array) === missing
    @test !supports_get_columns_copy(table_array)
    @test !supports_get_columns_view(table_array)
    @test !supports_get_columns_copy_using_missing(table_array)

end
