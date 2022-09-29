#######################################################################
# Debugging IJulia

# in the Jupyter front-end, enable verbose output via IJulia.set_verbose()
verbose = false
"""
    set_verbose(v=true)

This function enables (or disables, for `set_verbose(false)`) verbose
output from the IJulia kernel, when called within a running notebook.
This consists of log messages printed to the terminal window where
`jupyter` was launched, displaying information about every message sent
or received by the kernel.   Used for debugging IJulia.
"""
function set_verbose(v::Bool=true)
    global verbose = v
end


# set this to false for debugging, to disable stderr redirection
"""
The IJulia kernel captures all [stdout and stderr](https://en.wikipedia.org/wiki/Standard_streams)
output and redirects it to the notebook.   When debugging IJulia problems,
however, it can be more convenient to *not* capture stdout and stderr output
(since the notebook may not be functioning). This can be done by editing
`IJulia.jl` to set `capture_stderr` and/or `capture_stdout` to `false`.
"""
const capture_stdout = true
const capture_stderr = true


include("init.jl")
include("stdio.jl")
include("display.jl")
include("execute_request.jl")
include("inline.jl")
