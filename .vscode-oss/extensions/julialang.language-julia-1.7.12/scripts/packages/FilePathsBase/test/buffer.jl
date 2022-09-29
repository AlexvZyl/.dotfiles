using FilePathsBase: FileBuffer

@testset "FileBuffer Tests" begin
    @testset "read" begin
        p = p"../README.md"
        io = FileBuffer(p)
        try
            @test isopen(io)
            @test isreadable(io)
            @test !iswritable(io)
            @test !eof(io)
            @test position(io) == 0
            @test read(p) == read(io)
            @test eof(io)
            @test position(io) == length(read(p))
            seekstart(io)
            @test position(io) == 0
            @test !eof(io)
            @test read(p, String) == read(io, String)
            @test eof(io)
        finally
            close(io)
            @test !isopen(io)
        end

        io = FileBuffer(p)
        try
            for b in read(p)
                @test read(io, UInt8) == b
            end
            @test eof(io)
        finally
            close(io)
        end

        @test readavailable(FileBuffer(p)) == readavailable(IOBuffer(read(p)))

        # issue #126: data on first read
        mktemp(SystemPath) do p, _
            write(p, "testing")
            io = FilePathsBase.FileBuffer(p)
            @test read(io, 4) == UInt8['t', 'e', 's', 't']
        end
    end

    @testset "seek" begin
        p = p"../README.md"
        io = FileBuffer(p)
        try
            @test position(io) == 0
            @test position(seekend(io)) > 0
            @test position(seekstart(io)) == 0
            @test position(seek(io, 5)) == 5
            @test position(skip(io, 10)) == 15
        finally
            close(io)
        end
    end

    @testset "populate" begin
        funcs = (
            :seek => io -> seek(io, 1),
            :skip => io -> skip(io, 1),
            :seekend => seekend,
            :eof => eof,
        )

        @testset "$name" for (name, f) in funcs
            p = p"../README.md"
            buffer = FileBuffer(p)
            try
                f(buffer)
                @test buffer.io.size > 0
            finally
                close(buffer)
            end
        end
    end

    @testset "write" begin
        mktmpdir() do d
            p1 = absolute(p"../README.md")

            cd(d) do
                p2 = p"README.md"
                cp(p1, p2)

                io = FileBuffer(p2; read=true,write=true)
                try
                    @test isopen(io)
                    @test isreadable(io)
                    @test iswritable(io)
                    @test !eof(io)
                    @test position(io) == 0
                    @test read(p1) == read(io)
                    @test eof(io)
                    write(io, "\nHello")
                    write(io, " World!\n")
                    flush(io)

                    @test position(io) == length(read(p1)) + 14
                    txt1 = read(p1, String)
                    txt2 = read(p2, String)
                    @test txt1 != txt2
                    @test occursin(txt1, txt2)
                    @test occursin("Hello World!", txt2)
                finally
                    close(io)
                    @test !isopen(io)
                end

                rm(p2)

                io = FileBuffer(p2; read=true,write=true)
                try
                    write(io, read(p1))
                    flush(io)

                    @test position(io) == length(read(p1))
                    seekstart(io)
                    @test position(io) == 0
                    for b in read(p1)
                        write(io, b)
                    end
                    flush(io)
                    @test read(p1) == read(p2)
                finally
                    close(io)
                end
            end
        end
    end

    @testset "eof" begin
        mktemp(SystemPath) do p, _
            io = FileBuffer(p; write=true)
            @test eof(io)
            write(io, "Hey")
            flush(io)
            @test eof(io)
            seekstart(io)
            @test !eof(io)
            read(io)
            @test eof(io)
        end
    end

    @testset "Custom Types" begin
        jlso = JLSOFile(:msg => "Hello World!")
        mktmpdir() do d
            cd(d) do
                write(p"hello_world.jlso", jlso)
                new_jlso = read(p"hello_world.jlso", JLSOFile)
                @test new_jlso[:msg] == "Hello World!"

                rm(p"hello_world.jlso")
                data = IOBuffer()
                write(data, jlso)
                open(p"hello_world.jlso", "w") do io
                    for x in take!(data)
                        write(io, x)
                    end
                end


                open(p"hello_world.jlso") do io
                    data = UInt8[]
                    push!(data, read(io, UInt8))

                    while !eof(io)
                        push!(data, read(io, UInt8))
                    end

                    new_jlso = read(IOBuffer(data), JLSOFile)
                    @test new_jlso[:msg] == "Hello World!"
                end
            end
        end
    end
end
