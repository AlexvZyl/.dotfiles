# CSTParser

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://www.julia-vscode.org/CSTParser.jl/dev)
[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Run CI on master](https://github.com/julia-vscode/CSTParser.jl/actions/workflows/jlpkgbutler-ci-master-workflow.yml/badge.svg)](https://github.com/julia-vscode/CSTParser.jl/actions/workflows/jlpkgbutler-ci-master-workflow.yml)
[![codecov](https://codecov.io/gh/julia-vscode/CSTParser.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/julia-vscode/CSTParser.jl)

A parser for Julia using [Tokenize](https://github.com/JuliaLang/Tokenize.jl/) that aims to extend the built-in parser by providing additional meta information along with the resultant AST.

## Installation and Usage
```julia
using Pkg
Pkg.add("CSTParser")
```
```julia
using CSTParser
CSTParser.parse("x = y + 123")
```
**Documentation**: [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://www.julia-vscode.org/CSTParser.jl/dev)


### Structure
`CSTParser.EXPR` are broadly equivalent to `Base.Expr` in structure. The key differences are additional fields to store, for each expression:
* trivia tokens such as punctuation or keywords that are not stored as part of the AST but are needed for the CST representation;
* the span measurements for an expression;
* the textual representation of the token (only needed for certain tokens including identifiers (symbols), operators and literals);
* the parent expression, if present; and
* any other meta information (this field is untyped and is used within CSTParser to hold errors).

All `.head` values used in `Expr` are used in `EXPR`. Unlike in AST, tokens (terminal expressions with no child expressions) are stored as `EXPR` and additional head types are used to distinguish between different types of token. These possible head values include:

```
:IDENTIFIER
:NONSTDIDENTIFIER (e.g. var"id")
:OPERATOR

# Punctuation
:COMMA
:LPAREN
:RPAREN
:LSQUARE
:RSQUARE
:LBRACE
:RBRACE
:ATSIGN
:DOT

# Keywords
:ABSTRACT
:BAREMODULE
:BEGIN
:BREAK
:CATCH
:CONST
:CONTINUE
:DO
:ELSE
:ELSEIF
:END
:EXPORT
:FINALLY
:FOR
:FUNCTION
:GLOBAL
:IF
:IMPORT
:LET
:LOCAL
:MACRO
:MODULE
:MUTABLE
:NEW
:OUTER
:PRIMITIVE
:QUOTE
:RETURN
:STRUCT
:TRY
:TYPE
:USING
:WHILE

# Literals
:INTEGER
:BININT (0b0)
:HEXINT (0x0)
:OCTINT (0o0)
:FLOAT
:STRING
:TRIPLESTRING
:CHAR
:CMD
:TRIPLECMD
:NOTHING 
:TRUE
:FALSE
```

The ordering of `.args` members matches that in `Base.Expr` and members of `.trivia` are stored in the order in which they appear in text. 

