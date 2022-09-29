# delete any present coverage files
let
    dir, _, files = first(walkdir(@__DIR__))
    for file in files
        if occursin(r"coverage_example\.jl\.\d+\.cov", file)
            rm(joinpath(dir, file))
        end
    end
end

@testset "code coverage" begin
    out = read(`$(Base.julia_cmd()) --startup=no --project=$(dirname(dirname(@__DIR__))) --code-coverage=user
                $(joinpath(@__DIR__(), "coverage_example.jl"))`, String)
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
    @test cov_data == expected
end
