module Crayons

export Crayon, CrayonStack, merge, @crayon_str

include("crayon.jl")
include("downcasts.jl")
include("crayon_stack.jl")
include("crayon_wrapper.jl")
include("test_prints.jl")
include("logo.jl")
include("consts.jl")
include("macro.jl")

end # module

