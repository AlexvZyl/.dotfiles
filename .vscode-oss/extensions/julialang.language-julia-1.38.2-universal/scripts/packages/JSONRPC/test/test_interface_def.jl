@testset "Interface Definition" begin

    @test_throws ErrorException Foo()

    a = Foo(fieldA=1, fieldB="A")

    @test a.fieldA == 1
    @test a.fieldB == "A"
    @test a.fieldC === missing
    @test a.fieldD === missing

    b = Foo(fieldA=1, fieldB="A", fieldC="B", fieldD="C")

    @test b.fieldA == 1
    @test b.fieldB == "A"
    @test b.fieldC == "B"
    @test b.fieldD == "C"

    @test Foo(JSON.parse(JSON.json(a))) == a
    @test Foo(JSON.parse(JSON.json(b))) == b

    c = Foo2(fieldA=nothing, fieldB=[1,2])

    @test c.fieldA === nothing
    @test c.fieldB == [1,2]
    @test Foo2(JSON.parse(JSON.json(c))) == c

    d = Foo2(fieldA=3, fieldB=[1,2])
    @test d.fieldA === 3
    @test d.fieldB == [1,2]
    @test Foo2(JSON.parse(JSON.json(d))) == d
end
