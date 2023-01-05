function cleanup_coverage_files(pid)
    # clean up coverage files for source code
    dir, _, files = first(walkdir(normpath(@__DIR__, "..", "..", "src")))
    for file in files
        reg = Regex(string(".+\\.jl\\.$pid\\.cov"))
        if occursin(reg, file)
            rm(joinpath(dir, file))
        end
    end

    # clean up coverage files for this file
    dir, _, files = first(walkdir(@__DIR__))
    for file in files
        reg = Regex(string("coverage_example\\.jl\\.$pid\\.cov"))
        if occursin(reg, file)
            rm(joinpath(dir, file))
        end
    end
end

# using DiffUtils

let
    local pid
    try
        @testset "code coverage" begin
            io = IOBuffer()
            filepath = normpath(@__DIR__, "coverage_example.jl")
            cmd = `$(Base.julia_cmd()) --startup=no --project=$(dirname(dirname(@__DIR__)))
                --code-coverage=user $filepath`
            p = run(pipeline(cmd; stdout=io); wait=false)
            pid = Libc.getpid(p)
            wait(p)
            out = String(take!(io))
            @test out == "1 2 fizz 4 "

            dir, _, files = first(walkdir(@__DIR__))
            i = findfirst(contains(r"coverage_example\.jl\.\d+\.cov"), files)
            i === nothing && error("no coverage files found in $dir: $files")
            cov_file = joinpath(dir, files[i])
            cov_data = read(cov_file, String)
            expected = read(joinpath(dir, "coverage_example.jl.cov"), String)
            if Sys.iswindows()
                cov_data = replace(cov_data, "\r\n" => "\n")
                expected = replace(cov_data, "\r\n" => "\n")
            end

            # if cov_data != expected
            #     DiffUtils.diff(cov_data, expected)
            # end
            @test cov_data == expected
        end
    finally
        if @isdefined(pid)
            # clean up generated files
            cleanup_coverage_files(pid)
        end
    end
end
