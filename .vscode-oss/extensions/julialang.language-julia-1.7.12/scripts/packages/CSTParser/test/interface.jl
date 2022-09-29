
@testset "function defs" begin
    @test CSTParser.defines_function(CSTParser.parse("function f end"))
    @test CSTParser.defines_function(CSTParser.parse("function f() end"))
    @test CSTParser.defines_function(CSTParser.parse("function f()::T end"))
    @test CSTParser.defines_function(CSTParser.parse("function f(x::T) where T end"))
    @test CSTParser.defines_function(CSTParser.parse("function f{T}() end"))
    @test CSTParser.defines_function(CSTParser.parse("f(x) = x"))
    @test CSTParser.defines_function(CSTParser.parse("f(x)::T = x"))
    @test CSTParser.defines_function(CSTParser.parse("f{T}(x)::T = x"))
    @test CSTParser.defines_function(CSTParser.parse("f{T}(x)::T = x"))
    @test CSTParser.defines_function(CSTParser.parse("*(x,y) = x"))
    @test CSTParser.defines_function(CSTParser.parse("*(x,y)::T = x"))
    @test CSTParser.defines_function(CSTParser.parse("!(x::T)::T = x"))
    @test CSTParser.defines_function(CSTParser.parse("a + b = a"))
    @test CSTParser.defines_function(CSTParser.parse("a/b = x"))
    @test !CSTParser.defines_function(CSTParser.parse("a.b = x"))
end

@testset "datatype defs" begin
    @test CSTParser.defines_struct(CSTParser.parse("struct T end"))
    @test CSTParser.defines_struct(CSTParser.parse("mutable struct T end"))
    @test CSTParser.defines_mutable(CSTParser.parse("mutable struct T end"))
    @test CSTParser.defines_abstract(CSTParser.parse("abstract type T end"))
    # @test CSTParser.defines_abstract(CSTParser.parse("abstract T"))
    @test CSTParser.defines_primitive(CSTParser.parse("primitive type a b end"))
end

@testset "get_name" begin
    @test valof(CSTParser.get_name(CSTParser.parse("struct T end"))) == "T"
    @test valof(CSTParser.get_name(CSTParser.parse("struct T{T} end"))) == "T"
    @test valof(CSTParser.get_name(CSTParser.parse("struct T <: T end"))) == "T"
    @test valof(CSTParser.get_name(CSTParser.parse("struct T{T} <: T end"))) == "T"

    @test valof(CSTParser.get_name(CSTParser.parse("mutable struct T end"))) == "T"
    @test valof(CSTParser.get_name(CSTParser.parse("mutable struct T{T} end"))) == "T"
    @test valof(CSTParser.get_name(CSTParser.parse("mutable struct T <: T end"))) == "T"
    @test valof(CSTParser.get_name(CSTParser.parse("mutable struct T{T} <: T end"))) == "T"

    @test valof(CSTParser.get_name(CSTParser.parse("abstract type T end"))) == "T"
    @test valof(CSTParser.get_name(CSTParser.parse("abstract type T{T} end"))) == "T"
    @test valof(CSTParser.get_name(CSTParser.parse("abstract type T <: T end"))) == "T"
    @test valof(CSTParser.get_name(CSTParser.parse("abstract type T{T} <: T end"))) == "T"
    # NEEDS FIX: v0.6 dep
    # @test CSTParser.get_name(CSTParser.parse("abstract T")).val == "T"
    # @test CSTParser.get_name(CSTParser.parse("abstract T{T}")).val == "T"
    # @test CSTParser.get_name(CSTParser.parse("abstract T <: T")).val == "T"
    # @test CSTParser.get_name(CSTParser.parse("abstract T{T} <: T")).val == "T"

    @test valof(CSTParser.get_name(CSTParser.parse("function f end"))) == "f"
    @test valof(CSTParser.get_name(CSTParser.parse("function f() end"))) == "f"
    @test valof(CSTParser.get_name(CSTParser.parse("function f()::T end"))) == "f"
    @test valof(CSTParser.get_name(CSTParser.parse("function f(x::T) where T end"))) == "f"
    @test valof(CSTParser.get_name(CSTParser.parse("function f{T}() end"))) == "f"

    # Operators
    @test CSTParser.str_value(CSTParser.get_name(CSTParser.parse("function +() end"))) == "+"
    @test CSTParser.str_value(CSTParser.get_name(CSTParser.parse("function (+)() end"))) == "+"
    @test CSTParser.str_value(CSTParser.get_name(CSTParser.parse("+(x,y) = x"))) == "+"
    @test CSTParser.str_value(CSTParser.get_name(CSTParser.parse("+(x,y)::T = x"))) == "+"
    @test CSTParser.str_value(CSTParser.get_name(CSTParser.parse("!(x)::T = x"))) == "!"
    @test CSTParser.str_value(CSTParser.get_name(CSTParser.parse("!(x) = x"))) == "!"
end


# @testset "get_sig_params" begin
#     f = x -> CSTParser.str_value.(CSTParser.get_args(CSTParser.parse(x)))
#     @test f("function f(a) end") == ["a"]
#     @test f("function f(a::T) end") == ["a"]
#     @test f("function f(a,b) end") == ["a", "b"]
#     @test f("function f(a::T,b::T) end") == ["a", "b"]
#     @test f("function f(a::T,b::T) where T end") == ["a", "b"]
#     @test f("function f{T}(a::T,b::T) where T end") == ["a", "b"]
#     @test f("function f{T}(a::T,b::T;c = 1) where T end") == ["a", "b", "c"]

#     @test f("a -> a") == ["a"]
#     @test f("a::T -> a") == ["a"]
#     @test f("(a::T) -> a") == ["a"]
#     @test f("(a,b) -> a") == ["a", "b"]

#     @test f("map(1:10) do a
#         a
#     end") == ["a"]
#     @test f("map(1:10) do a,b
#         a
#     end") == ["a", "b"]
# end

@testset "has_error" begin
    # Just an error token
    @test CSTParser.has_error(CSTParser.parse(","))
    # A nested ErrorToken
    @test CSTParser.has_error(CSTParser.parse("foo(bar(\"\$ x\"))"))
    # Not an error
    @test !CSTParser.has_error(CSTParser.parse("foo(bar(\"\$x\"))"))
end
