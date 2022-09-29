module LoweredCodeUtils

# We use a code structure where all `using` and `import`
# statements in the package that load anything other than
# a Julia base or stdlib package are located in this file here.
# Nothing else should appear in this file here, apart from
# the `include("packagedef.jl")` statement, which loads what
# we would normally consider the bulk of the package code.
# This somewhat unusual structure is in place to support
# the VS Code extension integration.

using JuliaInterpreter
using JuliaInterpreter: SSAValue, SlotNumber, Frame
using JuliaInterpreter: @lookup, moduleof, pc_expr, step_expr!, is_global_ref, is_quotenode_egal, whichtt,
                        next_until!, finish_and_return!, get_return, nstatements, codelocation, linetable,
                        is_return, lookup_return, is_GotoIfNot, is_ReturnNode

include("packagedef.jl")

end # module
