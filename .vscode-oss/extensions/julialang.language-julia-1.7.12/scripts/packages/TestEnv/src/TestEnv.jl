module TestEnv

@static if VERSION < v"1.1"
    include("julia-1.0/TestEnv.jl")
elseif VERSION < v"1.2"
    include("julia-1.1/TestEnv.jl")
elseif VERSION < v"1.3"
    include("julia-1.2/TestEnv.jl")
elseif VERSION < v"1.4"
    include("julia-1.3/TestEnv.jl")
elseif VERSION < v"1.7"
    include("julia-1.4/TestEnv.jl")
elseif VERSION < v"1.8"
    include("julia-1.7/TestEnv.jl")
elseif VERSION < v"1.9"
    include("julia-1.8/TestEnv.jl")
else
    include("julia-1.9/TestEnv.jl")
end

end