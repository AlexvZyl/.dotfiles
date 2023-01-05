@testset "Mode Tests" begin
    m = Mode(
        user=(READ + WRITE + EXEC),
        group=(READ + EXEC),
        other=EXEC
    )

    x = executable(:ALL)
    r = readable(:USER, :GROUP)
    w = writable(:USER)

    @test string(m) == "-rwxr-x--x"
    @test string(x) == "---x--x--x"
    @test string(r) == "-r--r-----"
    @test string(w) == "--w-------"

    @test Mode("-rwxr-x--x") == m
    @test Mode("---x--x--x") == x
    @test Mode("-r--r-----") == r
    @test Mode("--w-------") == w
    @test Mode("-rw-r-----") == m - x
    @test Mode("--wx--x--x") == m - r
    @test Mode("-r-xr-x--x") == m - w

    @test isexecutable(x, :USER)
    @test isexecutable(x, :GROUP)
    @test isexecutable(x, :OTHER)
    @test isexecutable(x, :ALL)

    @test iswritable(w, :USER)
    @test !iswritable(w, :GROUP)
    @test !iswritable(w, :OTHER)
    @test !iswritable(w, :ALL)

    @test isreadable(r, :USER)
    @test isreadable(r, :GROUP)
    @test !isreadable(r, :OTHER)
    @test !isreadable(r, :ALL)

    @test x + r + w == m

    @test string(m - x) == "-rw-r-----"
    @test string(m - r) == "--wx--x--x"
    @test string(m - w) == "-r-xr-x--x"

    # Since our arbitrary mode
    # only has the permission bits set
    # the following functions should all return false.
    @test !isdir(m)
    @test !isfile(m)
    @test !islink(m)
    @test !issocket(m)
    @test !isfifo(m)
    @test !ischardev(m)
    @test !isblockdev(m)
end
