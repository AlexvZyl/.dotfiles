@testset "show" begin
    x = CSTParser.parse("a + (b*c) - d")
    @test sprint(show, x) ===
    "  1:13  call\n  1:2    OP: -\n  3:12   call\n  3:4     OP: +\n  5:6     a\n  7:12    brackets\n  7:9      call\n  7:7       OP: *\n  8:8       b\n  9:9       c\n 13:13   d"
end
