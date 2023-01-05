# JuliaInterpreter

This package implements an [interpreter](https://en.wikipedia.org/wiki/Interpreter_(computing)) for Julia code.
Normally, Julia compiles your code when you first execute it; using JuliaInterpreter you can
avoid compilation and execute the expressions that define your code directly.
Interpreters have a number of applications, including support for stepping debuggers.

## Use as an interpreter

Using this package as an interpreter is straightforward:

```jldoctest demo1
julia> using JuliaInterpreter

julia> list = [1, 2, 5]
3-element Vector{Int64}:
 1
 2
 5

julia> sum(list)
8

julia> @interpret sum(list)
8
```

## Breakpoints

You can interrupt execution by setting breakpoints.
You can set breakpoints via packages that explicitly target debugging,
like [Juno](https://junolab.org/), [Debugger](https://github.com/JuliaDebug/Debugger.jl), and
[Rebugger](https://github.com/timholy/Rebugger.jl).
But all of these just leverage the core functionality defined in JuliaInterpreter,
so here we'll illustrate it without using any of these other packages.

Let's set a conditional breakpoint, to be triggered any time one of the elements in the
argument to `sum` is bigger than 4:

```jldoctest demo1; filter = r"in Base at .*$"
julia> bp = @breakpoint sum([1, 2]) any(x->x>4, a);
```

Note that in writing the condition, we used `a`, the name of the argument to the relevant
method of `sum`. Conditionals should be written using a combination of argument and parameter
names of the method into which you're inserting a breakpoint; you can also use any
globally-available name (as used here with the `any` function).

Now let's see what happens:

```jldoctest demo1; filter = [r"in Base at .*$", r"[^\d]\d\d\d[^\d]"]
julia> @interpret sum([1,2,3])  # no element bigger than 4, breakpoint should not trigger
6

julia> frame, bpref = @interpret sum([1,2,5])  # should trigger breakpoint
(Frame for sum(a::AbstractArray; dims, kw...) in Base at reducedim.jl:873
c 1* 873  1 ─      nothing
  2  873  │   %2 = ($(QuoteNode(NamedTuple)))()
  3  873  │   %3 = Base.pairs(%2)
⋮
a = [1, 2, 5], breakpoint(sum(a::AbstractArray; dims, kw...) in Base at reducedim.jl:873, line 873))
```

`frame` is described in more detail on the next page; for now, suffice it to say
that the `c` in the leftmost column indicates the presence of a conditional breakpoint
upon entry to `sum`. `bpref` is a reference to the breakpoint of type [`BreakpointRef`](@ref).
The breakpoint `bp` we created can be manipulated at the command line

```jldoctest demo1; filter = [r"in Base at .*$", r"[^\d]\d\d\d[^\d]"]
julia> disable(bp)

julia> @interpret sum([1,2,5])
8

julia> enable(bp)

julia> @interpret sum([1,2,5])
(Frame for sum(a::AbstractArray; dims, kw...) in Base at reducedim.jl:873
c 1* 873  1 ─      nothing
  2  873  │   %2 = ($(QuoteNode(NamedTuple)))()
  3  873  │   %3 = Base.pairs(%2)
⋮
a = [1, 2, 5], breakpoint(sum(a::AbstractArray; dims, kw...) in Base at reducedim.jl:873, line 873))
```

[`disable`](@ref) and [`enable`](@ref) allow you to turn breakpoints off and on without losing any
conditional statements you may have provided; [`remove`](@ref) allows a permanent removal of
the breakpoint. You can use `remove()` to remove all breakpoints in all methods.

[`@breakpoint`](@ref) allows you to optionally specify a line number at which the breakpoint
is to be set. You can also use a functional form, [`breakpoint`](@ref), to specify file/line
combinations or that you want to break on entry to *any* method of a particular function.
At present, note that some of this functionality requires that you be running
[Revise.jl](https://github.com/timholy/Revise.jl).

It is, in addition, possible to halt execution when otherwise an error would be thrown.
This functionality is enabled using [`break_on`](@ref) and disabled with [`break_off`](@ref):

```jldoctest demo1; filter=r"none:\d"
julia> function f_outer()
           println("before error")
           f_inner()
           println("after error")
       end;

julia> f_inner() = error("inner error");

julia> break_on(:error)

julia> fr, pc = @interpret f_outer()
before error
(Frame for f_outer() in Main at none:1
  1  2  1 ─      Base.println("before error")
  2* 3  │        f_inner()
  3  4  │   %3 = Base.println("after error")
  4  4  └──      return %3
callee: f_inner() in Main at none:1, breakpoint(error(s::AbstractString) in Base at error.jl:33, line 33, ErrorException("inner error")))

julia> leaf(fr)
Frame for error(s::AbstractString) in Base at error.jl:33
  1  33  1 ─ %1 = ($(QuoteNode(ErrorException)))(s)
  2* 33  │   %2 = Core.throw(%1)
  3  33  └──      return %2
s = "inner error"
caller: f_inner() in Main at none:1

julia> typeof(pc)
BreakpointRef

julia> pc.err
ErrorException("inner error")

julia> break_off(:error)

julia> @interpret f_outer()
before error
ERROR: inner error
Stacktrace:
[...]
```

Finally, you can set breakpoints using [`@bp`](@ref):

```jldoctest demo1; filter=r"none:\d"
julia> function myfunction(x, y)
           a = 1
           b = 2
           x > 3 && @bp
           return a + b + x + y
       end
myfunction (generic function with 1 method)

julia> @interpret myfunction(1, 2)
6

julia> @interpret myfunction(5, 6)
(Frame for myfunction(x, y) in Main at none:1
⋮
  3  4  │   %3 = x > 3
  4  4  └──      goto #3 if not %3
b 5* 4  2 ─      nothing
  6  4  └──      goto #3
  7  5  3 ┄ %7 = a + b + x + y
⋮
x = 5
y = 6
b = 2
a = 1, breakpoint(myfunction(x, y) in Main at none:1, line 4))
```

Here the breakpoint is marked with a `b` indicating that it is an unconditional breakpoint.
Because we placed it inside the condition `x > 3`, we've achieved a conditional outcome.

When using `@bp` in source-code files, the use of Revise is recommended,
since it allows you to add breakpoints, test code, and then remove the breakpoints from the
code without restarting Julia.

## `debug_command`

You can control execution of frames via [`debug_command`](@ref).
Authors of debugging applications should target `debug_command` for their interaction
with JuliaInterpreter.

## Hooks
Consider if you were building a debugging application with a GUI component which displays a dot in the text editor margin where a breakpoint is.
If a user creates a breakpoint not via your GUI, but rather via a command in the REPL etc.
then you still wish to keep your GUI up to date.
How to do this? The answer is hooks.


JuliaInterpreter has experimental support for having  a hook, or callback function invoked
whenever the set of all breakpoints is changed.
Hook functions are setup by invoking the [`JuliaInterpreter.on_breakpoints_updated`](@ref) function.

To return to our example of keeping GUI up to date, the hooks would look something like this:
```julia
using JuliaInterpreter
using JuliaInterpreter: AbstractBreakpoint, update_states!, on_breakpoints_updated

breakpoint_gui_elements = Dict{AbstractBreakpoint, MarginDot}()
# ...
function breakpoint_gui_hook(::typeof(breakpoint), bp::AbstractBreakpoint)
    bp_dot = MarginDot(bp)
    draw(bp_dot)
    breakpoint_gui_elements[bp] = bp_dot
end

function breakpoint_gui_hook(::typeof(remove), bp::AbstractBreakpoint)
    bp_dot = pop!(breakpoint_gui_elements, bp)
    undraw(bp_dot)
end

function breakpoint_gui_hook(::typeof(update_states!), bp::AbstractBreakpoint)
    is_enabled = bp.enabled[]
    bp_dot = breakpoint_gui_elements[bp]
    set_fill!(bp_dot, is_enabled ? :blue : :grey)
end

on_breakpoints_updated(breakpoint_gui_hook)
```
