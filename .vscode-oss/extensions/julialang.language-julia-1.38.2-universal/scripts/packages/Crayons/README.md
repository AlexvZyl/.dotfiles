<h1 align="center">
    <img width="400" src="logo.png" alt="crayons">
    <br>
</h1>

> Colored and styled strings for terminals.

[![Build Status](https://travis-ci.org/KristofferC/Crayons.jl.svg?branch=master)](https://travis-ci.org/KristofferC/Crayons.jl) [![codecov](https://codecov.io/gh/KristofferC/Crayons.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/KristofferC/Crayons.jl)

*Crayons* is a package that makes it simple to write strings in different colors and styles to terminals.
It supports the 16 system colors, both the 256 color and 24 bit true color extensions, and the different text styles available to terminals.
The package is designed to perform well, have no dependencies and load fast (about 10 ms load time after precompilation).


## Installation

```jl
import Pkg; Pkg.add("Crayons")
```

## Usage

### Creating `Crayon`s

A `Crayon` is created with the keyword only constructor:

```julia
Crayon(foreground,
       background,
       reset,
       bold,
       faint,
       italics,
       underline,
       blink,
       negative,
       conceal,
       strikethrough)
```

The `foreground` and `background` argument can be of three types:

* A `Symbol` representing a color.
  The available colors are `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `light_gray`, `default`, `dark_gray`, `light_red`, `light_green`, `light_yellow`, `light_blue`, `light_magenta`, `light_cyan` and `white`.
  To see the colors in action, try `Crayons.test_system_colors()`.
  These colors are supported by almost all terminals.
* An `Integer` between 0 and 255.
  This will use the 256 color ANSI escape codes.
  To see what number corresponds to what color and if your terminal supports 256 colors, use `Crayons.test_256_colors(shownumbers::Bool=true)`.
* A `Tuple` of three `Integer`s, all between 0 and 255.
  This will be interpreted as a `(r, g, b)` 24 bit color.
  To test your terminals support for 24 bit colors, use `Crayons.test_24bit_colors(shownumbers::Bool=false)`.
  The support for this is currently quite limited but is being improved in terminals continuously, see [here](https://gist.github.com/XVilka/8346728).
* A `UInt32` representing a color given in hexadecimal format.
  Will be converted to the corresponding RGB format.

The other keyword arguments are all of `Bool` type and determine whether the corresponding style should be explicitly enabled or disabled:

* `reset` — reset all styles and colors to default
* `bold` — bold text, also brighten the colors on some terminals
* `faint` — faint text, not widely supported
* `italics` — italic text, not widely supported
* `underline` — underlined text
* `blink` — blinking text
* `negative` — swap the foreground and background
* `conceal`— hides the text, not widely supported
* `strikethrough` — horizontal line through the middle of the text, not widely supported.

To see text with the different styles active, use `Crayons.test_styles()`

By using the symbol `:nothing` for any of the keyword arguments, that color or style is inactive and is thus neither actively enable or disabled.

For convenience, `Crayon`s for the foreground / background version of the 16 system colors as well as the different styles are pre-made and can be found in the `Crayons.Box` module.
They have the name `<COLOR_NAME>_<BG/FG>` for the foreground/background colors and `<STYLE>` for the different styles (note the uppercase).
Calling `using` on the `Crayons.Box` module will bring all these into global scope.

#### String macros

`Crayon`s can also be created in a terser way using the [string macro](https://docs.julialang.org/en/stable/manual/metaprogramming/#Non-Standard-String-Literals-1) `crayon`.
These are written using `crayon"[[fg:]<col>] [bg:<col>] ([[!]<style>] ...")` where:
* text inside a square bracket is optional
* `<col>` is a color given as a hexadecimal number, `(r,g,b)` tuple (no spaces), a number 0-255, or one of the 16 named colors.
* `<style>` is one of the styles.
* `!` means that the style is explicitly disabled.
* `(<style> ...)` means a repeated number of styles, spearated by spaces.

A few examples of using the string macros and the equivalent constructor is shown below

```julia
crayon"red" # Crayon(foreground = :red)
crayon"bg:(255,0,255)" # Crayon(background = (255, 0, 255))
crayon"!bold underline 0xff00ff" # Crayon(bold = false, underline = true, foreground = 0xff00ff)
crayon"#0000ff" # Crayon(foreground = 0x0000ff)
```


### Using the `Crayon`s

The process of printing colored and styled text using *Crayons* is simple.
By printing a `Crayon` to the terminal, the correct code sequences are sent to the terminal such that subsequent printed text takes on the color and style of the printed `Crayon`.
For example, try running the code below in the REPL:

```julia
print(Crayon(foreground = :red), "In red. ", Crayon(bold = true), "Red and bold")
print(Crayon(foreground = 208, background = :red, bold = true), "Orange bold on red")
print(Crayon(negative = true, underline = true, bold = true), "Underlined inverse bold")
print(Crayon(foreground = (100, 100, 255), background = (255, 255, 0)), "Bluish on yellow")

using Crayons.Box
print(GREEN_FG, "This is in green")
print(BOLD, GREEN_FG, BLUE_BG, "Bold green on blue")
```

It is also possible to use *call overloading* on created `Crayon`s.
The `Crayon` can be called with strings and other `Crayon`s and the colors and styles will correctly nest.
Correct end sequences will als be printed so the colors and styles are disabled outside the call scope.
This functionality is perhaps more clearly shown with some examples:


```julia
using Crayons.Box
print(UNDERLINE("This is underlined."), " But this is not")
print(RED_FG("Hello ", BLUE_BG("world"), "!!!"), "!!!")
print(GREEN_BG("We ",
          UNDERLINE("are ",
              MAGENTA_FG("nesting "),
          "some "),
      "colors")
     )
```

**Note:** In order for the color sequences to be printed, the Julia REPL needs to have colors activated,
either by Julia automatically detecting terminal support or by starting Julia with the `--color=yes` argument.
Alternatively, if the environment variable `FORCE_COLOR` exist, or `Crayons.force_color(::Bool)` has been enabled,
color sequences are printed no matter what. Also, since relatively few terminals support full 24-bit colors,
it is possible to activate 256 color mode which converts the 24-bit crayon to a 256 color crayon when printed.
This is done by either defining the variable environment `FORCE_256_COLORS` or by calling `Crayons.force_256_colors(::Bool)`.
In addition, some systems have problems even with 256 colors, it is possible to convert to one of the 16 system colors
by defining the variable `FORCE_SYSTEM_COLORS` or by calling `Crayons.force_system_colors(::Bool)`. Note that 16 colors (8 + 8 light versions) is a quite small colorspace so the conversion is unlikely to be very good.

## Merging `Crayon`s

Two or more `Crayon`s can be merged resulting in a new `Crayon` with all the properties of the merged ones.
This is done with the function `merge(crayons::Crayon...)` or by multiplying `Crayon`s using `*`.
If two `Crayon`s specify the same property then the property of the last `Crayon` in the argument list is used:

```julia
using Crayons.Box
r_fg = Crayon(foreground = :red)
g_bg = Crayon(background = :green)
merged = merge(r_fg, g_bg)
print(merged, "Red foreground on green background!")
print(r_fg * g_bg * Crayons.Box.BOLD, "Bold Red foreground on green background!")
# Also with call overloading and nesting
print(GREEN_FG(
          "I am a green line ",
          BOLD * BLUE_FG * UNDERLINE(
              "with a bold underlined blue substring"
          ),
          " that becomes green again!"
     ))
```

## Misc

The function `inv` on a `Crayon` returns a `Crayon` that undos what the `Crayon` in the argument to `inv` does.
As an example, `inv(Crayon(bold = true))` returns a `Crayon` that disables bold.

## Advanced nesting of colors and styles

If you want to nest colors and styles through function calls there is the `ColorStack` type.
Simply `push!` `Crayon`s onto the stack, print text to the stack, and then `pop!` the `Crayons` off.
The stack will keep track of what `Crayon` is currently active.
It is used just like a `Crayon`:

```julia
stack = CrayonStack()
print(stack, "normal text")
print(push!(stack, Crayon(foreground = :red)), "in red")
print(push!(stack, Crayon(foreground = :blue)), "in blue")
print(pop!(stack), "in red again")
print(pop!(stack), "normal text")
```
A `CrayonStack` can also be created in `incremental` mode by calling `CrayonStack(incremental = true)`.
In that case, the `CrayonStack` will only print the changes that are needed to go from the previous text state to the new state,
which results in less color codes being printed.
However, note that this means that the `CrayonStack` need to be printed to the output buffer for **all** changes that are made to it
(i.e. both when `push!` and `pop!` are used).
The example below shows a working example where all the changes to the stack are printed and another example, which gives wrong result,
since one change is not printed.
Both the examples below work correctly if `incremental = false`.

```julia
# Does work
io = IOBuffer()
stack = CrayonStack(incremental = true)
print(io, push!(stack, Crayon(foreground = :red)))
print(io, push!(stack, Crayon(foreground = :red)))
print(io, stack, "This will be red")
print(takebuf_string(io))

# Does not work
io = IOBuffer()
stack = CrayonStack(incremental = true)
push!(stack, Crayon(foreground = :red)) # <- not printing the stack even though we modify it!
print(io, push!(stack, Crayon(foreground = :red)))
print(io, stack, "This will not be red")
print(takebuf_string(io))
```

The reason why the last example did not work is because the stack notices that there is no change of text state on the second call to `push!`, since the foreground was just kept red.
Failing to print the stack after the first `push!` meant that the terminal state and the stack state got out of sync.

### Related packages:

https://github.com/Aerlinger/AnsiColor.jl

### Author

Kristoffer Carlsson — [@KristofferC](https://github.com/KristofferC)

