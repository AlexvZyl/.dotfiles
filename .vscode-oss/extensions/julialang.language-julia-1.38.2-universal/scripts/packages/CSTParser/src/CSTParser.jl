module CSTParser

using Tokenize
import Tokenize.Tokens
import Tokenize.Tokens: RawToken, AbstractToken, iskeyword, isliteral, isoperator, untokenize
import Tokenize.Lexers: Lexer, peekchar, iswhitespace, readchar, emit, emit_error,  accept_batch, eof

include("packagedef.jl")

end
