Expression is used to refer to any `EXPR` object, including those without children (terminals).

```
mutable struct EXPR
    head::Symbol
    args::Union{Nothing,Vector{EXPR}}
    trivia::Union{Nothing,Vector{EXPR}}
    fullspan::Int
    span::Int
    val::Union{Nothing,String}
    parent::Union{Nothing,EXPR}
    meta
end
```
The first two arguments match the representation within `Expr`.
## `head`
The type of expression, equivalent to the head of Expr. Possible heads are a superset of those available for an Expr.

## `args`
As for `Expr`, holds child expressions. Terminal expressions do not hold children.

## `trivia`
Holds terminals specific to the CST representation. Terminal expressions do not hold trivia.

## `fullspan`
The byte size of the expression in the source code text, including trailing white space.

## `span`
As above but excluding trailing white space. (`fullspan - span` is the byte size of trailing white space.)

## `val`
A field to store the textual representation of the token as necessary, otherwise it is set to `nothing`. This is needed for identifiers, operators and literals.


# Heads
An extended group of expression types is used to allow full equivalence of terminal tokens with other expressions. By convention expression heads will match those used in Julia AST (lowercase) and others are capitalised.

## Terminals
Identifier
Nonstdidentifier
Operator

### Punctuation
comma
lparen
rparen
lsquare
rsquare
lbrace
rbrace
atsign
dot
      
### Keywords
abstract
baremodule
begin
break
catch
const
continue
do
else
elseif
end
export
finally
for
function
global
if
import
importall
let
local
macro
module
mutable
new
outer
primitive
quote
return
struct
try
type
using
while

### Literals
:INTEGER,
:BININT,
:HEXINT,
:OCTINT,
:FLOAT,
:STRING,
:TRIPLESTRING,
:CHAR,
:CMD,
:TRIPLECMD,
:NOTHING,
:true,
:false,

# Expressions

##### :const

##### :global
`(args...) (global ,...)`
`(args...) (,...)`
Special handling: `global const expr` is parsed as `const global expr`. In this case both the `const` and `global` keywords are stored wihin the `:const` expression's trivia (the `:global` expression has no trivia).
##### :local
`(args...) (local ,...)`
##### :return
`(body) (return)`
## Datatype declarations
##### :abstract
`(name) (abstract type end)`
##### :primitive
`(name n) (primitive type end)`
##### :struct
`(mut name block) (struct end)`
`(mut name block) (mutable struct end)`
##### :block
`(bodyargs...) (begin end)`
`(bodyargs...) ()`
##### :quote
`(block) (quote end)`
`(block) (:)`
##### :for
`(itrs block) (for end)`
##### :function
`(sig block) (function end)`
`(name) (function end)`
##### :outer
`(arg) (outer)`
##### :braces
`(args...) ({ commas.. })`
##### :curly
`(args...) ({ commas... })`
##### :comparison
`(args...) (commas...)`
##### :(:)
Only used as the head of an expression within `using/import` calls.
##### :if
`(cond block) (if end)`
`(cond block elseif) (if end)`
`(cond block block) (if else end)`
##### :elseif 
`(cond block) (elseif)`
`(cond block block) (elseif else)`
##### :call
##### :string
`(args...)`
##### :if
##### :kw



##### ChainOpCall
##### ColonOpCall
##### Bracescat

##### Do
##### Filter
##### Flatten
##### Generator
##### GlobalRefDoc
##### Let
##### Ref
##### Row
##### Vcat
##### Macro
##### MacroCall
##### MacroName

##### Parameters
##### Quotenode
##### InvisBrackets
##### String
##### Try
##### Tuple
##### File

##### While
##### Module
Trivia: `module`, `end`
##### BareModule
Trivia: `baremodule`, `end`
##### TopLevel
##### Export
##### Import
##### Using
##### Comprehension
##### Dict_Comprehension
##### Typed_Comprehension
##### Hcat
##### Typed_Hcat
##### Typed_Vcat
##### Vect

## Head's not present in `Expr`
:ErrorToken

## Iterators
Iterators of loops are converted to `a = b` if needed in line with the scheme parser. the operator is a facade and the actual operator use  is stored as trivia.


# Decisions
1. For single token keyword expressions (e.g. `break`) do we use the visible token as the head or store it in trivia?