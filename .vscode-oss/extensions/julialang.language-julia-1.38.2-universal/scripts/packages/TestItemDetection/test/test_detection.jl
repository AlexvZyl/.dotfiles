@testitem "@testitem macro missing all args" begin
    import CSTParser

    code = CSTParser.parse("""@testitem
    """)

    test_items = []
    errors = []
    TestItemDetection.find_test_items_detail!(code, test_items, errors)

    @test length(test_items) == 0
    @test length(errors) == 1

    @test errors[1] == (error="Your @testitem is missing a name and code block.", range=1:9)
end

@testitem "Wrong type for name" begin
    import CSTParser

    code = CSTParser.parse("""@testitem :foo
    """)

    test_items = []
    errors = []
    TestItemDetection.find_test_items_detail!(code, test_items, errors)

    @test length(test_items) == 0
    @test length(errors) == 1

    @test errors[1] == (error="Your @testitem must have a first argument that is of type String for the name.", range=1:14)
end

@testitem "Code block missing" begin
    import CSTParser

    code = CSTParser.parse("""@testitem "foo"
    """)

    test_items = []
    errors = []
    TestItemDetection.find_test_items_detail!(code, test_items, errors)

    @test length(test_items) == 0
    @test length(errors) == 1

    @test errors[1] == (error="Your @testitem is missing a code block argument.", range=1:15)
end

@testitem "Final arg not a code block" begin
    import CSTParser

    code = CSTParser.parse("""@testitem "foo" 3
    """)

    test_items = []
    errors = []
    TestItemDetection.find_test_items_detail!(code, test_items, errors)

    @test length(test_items) == 0
    @test length(errors) == 1

    @test errors[1] == (error="The final argument of a @testitem must be a begin end block.", range=1:17)
end

@testitem "None kw arg" begin
    import CSTParser

    code = CSTParser.parse("""@testitem "foo" bar begin end
    """)

    test_items = []
    errors = []
    TestItemDetection.find_test_items_detail!(code, test_items, errors)

    @test length(test_items) == 0
    @test length(errors) == 1

    @test errors[1] == (error="The arguments to a @testitem must be in keyword format.", range=1:29)
end

@testitem "Duplicate kw arg" begin
    import CSTParser

    code = CSTParser.parse("""@testitem "foo" default_imports=true default_imports=false begin end
    """)

    test_items = []
    errors = []
    TestItemDetection.find_test_items_detail!(code, test_items, errors)

    @test length(test_items) == 0
    @test length(errors) == 1

    @test errors[1] == (error="The keyword argument default_imports cannot be specified more than once.", range=1:68)
end

@testitem "Incomplete kw arg" begin
    import CSTParser

    code = CSTParser.parse("""@testitem "foo" default_imports= begin end
    """)

    test_items = []
    errors = []
    TestItemDetection.find_test_items_detail!(code, test_items, errors)

    @test length(test_items) == 0
    @test length(errors) == 1

    @test errors[1] == (error="The final argument of a @testitem must be a begin end block.", range=1:42)
end

@testitem "Wrong default_imports type kw arg" begin
    import CSTParser

    code = CSTParser.parse("""@testitem "foo" default_imports=4 begin end
    """)

    test_items = []
    errors = []
    TestItemDetection.find_test_items_detail!(code, test_items, errors)

    @test length(test_items) == 0
    @test length(errors) == 1

    @test errors[1] == (error="The keyword argument default_imports only accepts bool values.", range=1:43)
end

@testitem "non vector arg for tags kw" begin
    import CSTParser

    code = CSTParser.parse("""@testitem "foo" tags=4 begin end
    """)

    test_items = []
    errors = []
    TestItemDetection.find_test_items_detail!(code, test_items, errors)

    @test length(test_items) == 0
    @test length(errors) == 1

    @test errors[1] == (error="The keyword argument tags only accepts a vector of symbols.", range=1:32)
end

@testitem "Wrong types in tags kw arg" begin
    import CSTParser

    code = CSTParser.parse("""@testitem "foo" tags=[4, 8] begin end
    """)

    test_items = []
    errors = []
    TestItemDetection.find_test_items_detail!(code, test_items, errors)

    @test length(test_items) == 0
    @test length(errors) == 1

    @test errors[1] == (error="The keyword argument tags only accepts a vector of symbols.", range=1:37)
end

@testitem "Unknown keyword arg" begin
    import CSTParser

    code = CSTParser.parse("""@testitem "foo" bar=true begin end
    """)

    test_items = []
    errors = []
    TestItemDetection.find_test_items_detail!(code, test_items, errors)

    @test length(test_items) == 0
    @test length(errors) == 1

    @test errors[1] == (error="Unknown keyword argument.", range=1:34)
end

@testitem "All parts correctly there" begin
    import CSTParser

    code = CSTParser.parse("""@testitem "foo" tags=[:a, :b] default_imports=true begin println() end
    """)

    test_items = []
    errors = []
    TestItemDetection.find_test_items_detail!(code, test_items, errors)

    @test length(test_items) == 1
    @test length(errors) == 0

    @test test_items[1] == (name="foo", range=1:70, code_range=57:67, option_default_imports=true, option_tags=[:a, :b])
end
