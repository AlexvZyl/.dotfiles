using CSTParser: @cst_str, headof, valof

function test_iter_spans(x)
    n = 0
    for i = 1:length(x)
        a  = x[i]
        if !(a isa EXPR)
            @info i, headof(x), to_codeobject(x)
        end
        @test a isa EXPR
        test_iter_spans(a)
        n += a.fullspan
    end
    length(x) > 0 && @test n == x.fullspan
end

@testset "iterators" begin
    @testset "const local global return" begin
        @testset "local" begin
            x = cst"local a = 1"
            @test length(x) == 2
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
        end

        @testset "global" begin
            x = cst"global a = 1"
            @test length(x) == 2
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
        end

        @testset "global tuple" begin
            x = cst"global (a = 1,b = 2)"
            @test length(x) == 6
            @test x[1] === x.trivia[1]
            @test x[2] === x.trivia[2]
            @test x[3] === x.args[1]
            @test x[4] === x.trivia[3]
            @test x[5] === x.args[2]
            @test x[6] === x.trivia[4]
        end

        @testset "const" begin
            x = cst"const a = 1"
            @test length(x) == 2
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
        end
        @testset "simple" begin
            x = cst"global const a = 1"
            @test length(x) == 2
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
            @test length(x[2]) == 2
            @test x[2][1] === x.args[1].trivia[1]
            @test x[2][2] === x.args[1].args[1]
        end

        @testset "return" begin
            x = cst"return a"
            @test length(x) == 2
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
        end
    end

    @testset "datatype declarations" begin
        @testset "abstract" begin
            x = cst"abstract type T end"
            @test length(x) == 4
            @test x[1] === x.trivia[1]
            @test x[2] === x.trivia[2]
            @test x[3] === x.args[1]
            @test x[4] === x.trivia[3]
        end
        @testset "primitive" begin
            x = cst"primitive type T N end"
            @test length(x) == 5
            @test x[1] === x.trivia[1]
            @test x[2] === x.trivia[2]
            @test x[3] === x.args[1]
            @test x[4] === x.args[2]
            @test x[5] === x.trivia[3]
        end
        @testset "struct" begin
            x = cst"struct T body end"
            @test length(x) == 5
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
            @test x[3] === x.args[2]
            @test x[4] === x.args[3]
            @test x[5] === x.trivia[2]
        end
        @testset "mutable" begin
            x = cst"mutable struct T body end"
            @test length(x) == 6
            @test x[1] === x.trivia[1]
            @test x[2] === x.trivia[2]
            @test x[3] === x.args[1]
            @test x[4] === x.args[2]
            @test x[5] === x.args[3]
            @test x[6] === x.trivia[3]
        end
    end

    @testset ":quote" begin
        @testset "block" begin
            x = cst"""quote
                            ex1
                            ex2
                        end"""
            @test length(x) == 3
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
            @test x[3] === x.trivia[2]
        end
        @testset "op" begin
            x = cst""":(body + 1)"""
            @test length(x) == 2
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
        end
    end

    @testset ":block" begin
        @testset "begin" begin
            x = cst"""begin
                            ex1
                            ex2
                        end"""
            @test length(x) == 4
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
            @test x[3] === x.args[2]
            @test x[4] === x.trivia[2]
        end
    end
    @testset ":for" begin
        x = cst"""for itr in itr
                        ex1
                        ex2
                    end"""
        @test length(x) == 4
        @test x[1] === x.trivia[1]
        @test x[2] === x.args[1]
        @test x[3] === x.args[2]
        @test x[4] === x.trivia[2]
    end

    @testset ":outer" begin
        x = cst"""for outer itr in itr
                        ex1
                        ex2
                    end""".args[1].args[1]
        @test length(x) == 2
        @test x[1] === x.trivia[1]
        @test x[2] === x.args[1]
    end


    @testset ":function" begin
        @testset "name only" begin
            x = cst"""function name end"""
            @test length(x) == 3
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
            @test x[3] === x.trivia[2]
        end
        @testset "full" begin
            x = cst"""function sig()
                            ex1
                            ex2
                        end"""
            @test length(x) == 4
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
            @test x[3] === x.args[2]
            @test x[4] === x.trivia[2]
        end
    end
    @testset ":braces" begin
        @testset "simple" begin
            x = cst"{a,b,c}"
            @test length(x) == 7
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
            @test x[3] === x.trivia[2]
            @test x[4] === x.args[2]
            @test x[5] === x.trivia[3]
            @test x[6] === x.args[3]
            @test x[7] === x.trivia[4]
        end

        @testset "params" begin
            x = cst"{a,b;c}"
            @test length(x) == 6
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[2]
            @test x[3] === x.trivia[2]
            @test x[4] === x.args[3]
            @test x[5] === x.args[1]
            @test x[6] === x.trivia[3]
        end
    end

    @testset ":curly" begin
        @testset "simple" begin
            x = cst"x{a,b}"
            @test length(x) == 6
            @test x[1] === x.args[1]
            @test x[2] === x.trivia[1]
            @test x[3] === x.args[2]
            @test x[4] === x.trivia[2]
            @test x[5] === x.args[3]
            @test x[6] === x.trivia[3]
        end
        @testset "params" begin
            x = cst"x{a,b;c}"
            @test length(x) == 7
            @test x[1] === x.args[1]
            @test x[2] === x.trivia[1]
            @test x[3] === x.args[3]
            @test x[4] === x.trivia[2]
            @test x[5] === x.args[4]
            @test x[6] === x.args[2]
            @test x[7] === x.trivia[3]
        end
    end

    @testset ":comparison" begin
        x = cst"a < b < c"
        @test length(x) == 5
        @test x[1] === x.args[1]
        @test x[2] === x.args[2]
        @test x[3] === x.args[3]
        @test x[4] === x.args[4]
        @test x[5] === x.args[5]
    end

    @testset ":using" begin
        @testset ":using" begin
            x = cst"using a"
            @test length(x) == 2
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]

            x = cst"using a, b, c"
            @test length(x) == 6
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
            @test x[3] === x.trivia[2]
            @test x[4] === x.args[2]
            @test x[5] === x.trivia[3]
            @test x[6] === x.args[3]

            x = cst"using .a"
            @test length(x) == 2
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]

            x = cst"using a: b, c"
            @test length(x) == 2
            @test x[1] === x.trivia[1]
            @test x[2] === x.args[1]
        end

        @testset ":" begin
            x = cst"using a: b, c".args[1]
            @test length(x) == 5
            @test x[1] === x.args[1]
            @test x[2] === x.head
            @test x[3] === x.args[2]
            @test x[3] === x.args[2]
        end

        @testset "." begin
            x = cst"using a".args[1]
            @test length(x) == 1
            @test x[1] === x.args[1]

            x = cst"using a.b".args[1]
            @test length(x) == 3
            @test x[1] === x.args[1]
            @test x[2] === x.trivia[1]
            @test x[3] === x.args[2]

            x = cst"using ..a.b".args[1]
            @test length(x) == 5
            @test x[1] === x.args[1]
            @test x[2] === x.args[2]
            @test x[3] === x.args[3]
            @test x[4] === x.trivia[1]
            @test x[5] === x.args[4]

            x = cst"using .a.b".args[1]
            @test length(x) == 4
            @test x[1] === x.args[1]
            @test x[2] === x.args[2]
            @test x[3] === x.trivia[1]
            @test x[4] === x.args[3]

            x = cst"using ...a.b".args[1]
            @test length(x) == 6
            @test x[1] === x.args[1]
            @test x[2] === x.args[2]
            @test x[3] === x.args[3]
            @test x[4] === x.args[4]
            @test x[5] === x.trivia[1]
            @test x[6] === x.args[5]
        end
    end

    @testset ":kw" begin
        x = cst"f(a=1)".args[2]
        @test length(x) == 3
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
    end

    @testset ":tuple" begin
        x = cst"a,b"
        @test length(x) == 3
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]

        x = cst"(a,b)"
        @test length(x) == 5
        @test x[1] === x.trivia[1]
        @test x[2] === x.args[1]
        @test x[3] === x.trivia[2]
        @test x[4] === x.args[2]
        @test x[5] === x.trivia[3]

        x = cst"(a,b,)"
        @test length(x) == 6
        @test x[1] === x.trivia[1]
        @test x[2] === x.args[1]
        @test x[3] === x.trivia[2]
        @test x[4] === x.args[2]
        @test x[5] === x.trivia[3]
        @test x[6] === x.trivia[4]
    end

    @testset ":call" begin
        x = cst"f()"
        @test length(x) == 3
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.trivia[2]

        x = cst"f(a)"
        @test length(x) == 4
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
        @test x[4] === x.trivia[2]

        x = cst"f(a,)"
        @test length(x) == 5
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
        @test x[4] === x.trivia[2]
        @test x[5] === x.trivia[3]

        x = cst"f(;)"
        @test length(x) == 4
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
        @test x[4] === x.trivia[2]

        x = cst"f(a, b;c = 1)"
        @test length(x) == 7
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[3]
        @test x[4] === x.trivia[2]
        @test x[5] === x.args[4]
        @test x[6] === x.args[2]
        @test x[7] === x.trivia[3]

        x = cst"f(a, b,;c = 1)"
        @test length(x) == 8
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[3]
        @test x[4] === x.trivia[2]
        @test x[5] === x.args[4]
        @test x[6] === x.trivia[3]
        @test x[7] === x.args[2]
        @test x[8] === x.trivia[4]
    end

    @testset ":where" begin
        x = cst"a where {b,c;d}"
        @test length(x) == 8
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.trivia[2]
        @test x[4] === x.args[3]
        @test x[5] === x.trivia[3]
        @test x[6] === x.args[4]
        @test x[7] === x.args[2]
        @test x[8] === x.trivia[4]
    end

    @testset ":quotenode" begin
        x = cst"a.b".args[2]
        @test length(x) == 1
        @test x[1] === x.args[1]

        x = cst"a.:b".args[2]
        @test length(x) == 2
        @test x[1] === x.trivia[1]
        @test x[2] === x.args[1]
    end

    @testset ":if" begin
        x = cst"if cond end"
        @test length(x) == 4
        @test headof(x[1]) === :IF
        @test x[2] === x.args[1]
        @test x[3] === x.args[2]
        @test headof(x[4]) === :END

        x = cst"if cond else end"
        @test length(x) == 6
        @test headof(x[1]) === :IF
        @test x[2] === x.args[1]
        @test x[3] === x.args[2]
        @test headof(x[4]) === :ELSE
        @test x[5] === x.args[3]
        @test headof(x[6]) === :END

        x = cst"if cond args elseif a end"
        @test length(x) == 5
        @test headof(x[1]) === :IF
        @test x[2] === x.args[1]
        @test x[3] === x.args[2]
        @test headof(x[4]) === :elseif
        @test headof(x[5]) === :END

        x = cst"a ? b : c"
        @test length(x) == 5
        @test valof(x[1]) === "a"
        @test CSTParser.isoperator(x[2])
        @test valof(x[3]) === "b"
        @test CSTParser.isoperator(x[4])
        @test valof(x[5]) === "c"
    end

    @testset ":elseif" begin
        x = cst"if cond elseif c args end".args[3]
        @test length(x) == 3
        @test headof(x[1]) === :ELSEIF
        @test x[2] === x.args[1]
        @test x[3] === x.args[2]

        x = cst"if cond elseif c args else args end".args[3]
        @test length(x) == 5
        @test headof(x[1]) === :ELSEIF
        @test x[2] === x.args[1]
        @test x[3] === x.args[2]
        @test headof(x[4]) === :ELSE
        @test x[5] === x.args[3]
    end

    @testset ":string" begin
        x = cst"\"txt$interp txt\""
        @test length(x) == 4
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
        @test x[4] === x.args[3]

        x = cst"\"txt1 $interp1 txt2 $interp2 txt3\""
        @test length(x) == 7
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
        @test x[4] === x.args[3]
        @test x[5] === x.trivia[2]
        @test x[6] === x.args[4]
        @test x[7] === x.args[5]

        x = cst"\"$interp\""
        @test length(x) == 4
        @test x[1] === x.trivia[1]
        @test x[2] === x.trivia[2]
        @test x[3] === x.args[1]
        @test x[4] === x.trivia[3]

        x = cst"\"$interp txt\""
        @test length(x) == 4
        @test x[1] === x.trivia[1]
        @test x[2] === x.trivia[2]
        @test x[3] === x.args[1]
        @test x[4] === x.args[2]

        x = cst"\"$(interp)\""
        @test length(x) == 6
        @test x[1] === x.trivia[1]
        @test x[2] === x.trivia[2]
        @test x[3] === x.trivia[3]
        @test x[4] === x.args[1]
        @test x[5] === x.trivia[4]
        @test x[6] === x.trivia[5]

        x = cst"\"a$b$c \""
        @test length(x) == 6
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
        @test x[4] === x.trivia[2]
        @test x[5] === x.args[3]

        x = cst"\"$(a)$(b)$(c)d\""
        @test length(x) == 14
        @test x[1] === x.trivia[1]
        @test x[2] === x.trivia[2]
        @test x[3] === x.trivia[3]
        @test x[4] === x.args[1]
        @test x[5] === x.trivia[4]
        @test x[6] === x.trivia[5]
        @test x[7] === x.trivia[6]
        @test x[8] === x.args[2]
        @test x[9] === x.trivia[7]
        @test x[10] === x.trivia[8]
        @test x[11] === x.trivia[9]
        @test x[12] === x.args[3]
        @test x[13] === x.trivia[10]
        @test x[14] === x.args[4]

        x = cst"""
        "$(()$)"
        """
        @test x[6] === x.trivia[5]

        x = cst"\"$(\"\")\""
        @test length(x) == 6
        @test x[1] === x.trivia[1]
        @test x[2] === x.trivia[2]
        @test x[3] === x.trivia[3]
        @test x[4] === x.args[1]
        @test x[5] === x.trivia[4]
        @test x[6] === x.trivia[5]

        x = EXPR(:string, EXPR[cst"\" \"", EXPR(:errortoken, 0, 0), EXPR(:errortoken, 0, 0)], EXPR[cst"$"])
        @test x[4] == x.args[3]
    end

    @testset ":macrocall" begin
        x = cst"@mac a"
        @test length(x) == 3
        @test x[1] === x.args[1]
        @test x[2] === x.args[2]
        @test x[3] === x.args[3]

        x = cst"@mac(a)"
        @test length(x) == 5
        @test x[1] === x.args[1]
        @test x[2] === x.args[2]
        @test x[3] === x.trivia[1]
        @test x[4] === x.args[3]
        @test x[5] === x.trivia[2]

        x = cst"@mac(a, b)"
        @test length(x) == 7
        @test x[1] === x.args[1]
        @test x[2] === x.args[2]
        @test x[3] === x.trivia[1]
        @test x[4] === x.args[3]
        @test x[5] === x.trivia[2]
        @test x[6] === x.args[4]
        @test x[7] === x.trivia[3]

        x = cst"@mac(a; b = 1)"
        @test length(x) == 6
        @test x[1] === x.args[1]
        @test x[2] === x.args[2]
        @test x[3] === x.trivia[1]
        @test x[4] === x.args[4]
        @test x[5] === x.args[3]
        @test x[6] === x.trivia[2]

        x = cst"@mac(a, b; x)"
        @test length(x) == 8
        @test x[1] === x.args[1]
        @test x[2] === x.args[2]
        @test x[3] === x.trivia[1]
        @test x[4] === x.args[4]
        @test x[5] === x.trivia[2]
        @test x[6] === x.args[5]
        @test x[7] === x.args[3]
        @test x[8] === x.trivia[3]
    end

    @testset ":brackets" begin
        x = cst"(x)"
        @test length(x) == 3
        @test x[1] === x.trivia[1]
        @test x[2] === x.args[1]
        @test x[3] === x.trivia[2]
    end

    @testset ":ref" begin
        x = cst"x[i]"
        @test length(x) == 4
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
        @test x[4] === x.trivia[2]

        x = cst"x[i, j]"
        @test length(x) == 6
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
        @test x[4] === x.trivia[2]
        @test x[5] === x.args[3]
        @test x[6] === x.trivia[3]

        x = cst"x[i, j; k = 1]"
        @test length(x) == 7
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[3]
        @test x[4] === x.trivia[2]
        @test x[5] === x.args[4]
        @test x[6] === x.args[2]
        @test x[7] === x.trivia[3]
    end
    @testset ":typed_vcat" begin
        x = cst"x[i;j]"
        @test length(x) == 5
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
        @test x[4] === x.args[3]
        @test x[5] === x.trivia[2]
    end

    @testset ":row" begin
        x = cst"[a b; c d ]".args[1]
        @test length(x) == 2
        @test x[1] === x.args[1]
        @test x[2] === x.args[2]
    end

    @testset ":module" begin
        x = cst"module a end"
        @test length(x) == 5
        @test x[1] === x.trivia[1]
        @test x[2] === x.args[1]
        @test x[3] === x.args[2]
        @test x[4] === x.args[3]
        @test x[5] === x.trivia[2]
    end

    @testset ":export" begin
        x = cst"export a, b, c"
        @test length(x) == 6
        @test x[1] === x.trivia[1]
        @test x[2] === x.args[1]
        @test x[3] === x.trivia[2]
        @test x[4] === x.args[2]
        @test x[5] === x.trivia[3]
        @test x[6] === x.args[3]
    end

    @testset ":parameters" begin
        x = cst"f(a; b=1, c=1, d=1)"[4]
        @test length(x) == 5
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
        @test x[4] === x.trivia[2]
        @test x[5] === x.args[3]
    end

    @testset "lowered iterator" begin
        x = cst"for a in b end".args[1]
        @test length(x) == 3
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
    end

    @testset ":do" begin
        x = cst"f(x) do arg something end"
        @test length(x) == 4
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
        @test x[4] === x.trivia[2]
    end

    @testset ":generator" begin
        x = cst"(a for a in A)".args[1]
        @test length(x) == 3
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]

        x = cst"(a for a in A, b in B)".args[1]
        @test length(x) == 5
        @test x[1] === x.args[1]
        @test x[2] === x.trivia[1]
        @test x[3] === x.args[2]
        @test x[4] === x.trivia[2]
        @test x[5] === x.args[3]
    end

    @testset ":flatten" begin
        function flatten(x)
            if length(x) == 0
                [x]
            else
                vcat([flatten(a) for a in x]...)
            end
        end
        function testflattenorder(s)
            x = CSTParser.parse(s)[2]
            issorted([Base.parse(Int, a.val) for a in flatten(x) if a.head === :INTEGER])
        end

        @test testflattenorder("(1 for 2 in 3)")
        @test testflattenorder("(1 for 2 in 3 for 4 in 5)")
        @test testflattenorder("(1 for 2 in 3, 4 in 5 for 6 in 7)")
        @test testflattenorder("(1 for 2 in 3 for 4 in 5, 6 in 7)")
        @test testflattenorder("(1 for 2 in 3 for 4 in 5, 6 in 7 if 8)")
    end

    @testset ":filter" begin
        x = cst"(a for a in A if a)".args[1].args[2]
        @test length(x) == 3
        @test valof(headof(x[1])) == "="
        @test headof(x[2]) === :IF
        @test valof(x[3]) == "a"
    end

    @testset ":try" begin
        x = cst"try expr catch e end"
        @test length(x) == 6
        @test headof(x[1]) === :TRY
        @test headof(x[2]) === :block
        @test headof(x[3]) === :CATCH
        @test valof(x[4]) == "e"
        @test headof(x[5]) === :block
        @test headof(x[6]) === :END

        x = cst"try expr finally expr2 end"
        @test length(x) == 8
        @test headof(x[1]) === :TRY
        @test headof(x[2]) === :block
        @test headof(x[3]) === :CATCH
        @test x[3].fullspan == 0
        @test headof(x[4]) === :FALSE
        @test headof(x[5]) === :FALSE
        @test headof(x[6]) === :FINALLY
        @test headof(x[7]) === :block
        @test headof(x[8]) === :END

        x = cst"try expr catch err expr2 finally expr3 end"
        @test length(x) == 8
        @test headof(x[1]) === :TRY
        @test headof(x[2]) === :block
        @test headof(x[3]) === :CATCH
        @test valof(x[4]) == "err"
        @test headof(x[5]) === :block
        @test headof(x[6]) === :FINALLY
        @test headof(x[7]) === :block
        @test headof(x[8]) === :END
    end

    @testset ":comprehension" begin
        x = cst"[a for a in A]"
        @test length(x) == 3
        @test headof(x[1]) === :LSQUARE
        @test headof(x[2]) === :generator
        @test headof(x[3]) === :RSQUARE
    end

    @testset ":typed_comprehension" begin
        x = cst"T[a for a in A]"
        @test length(x) == 4
        @test headof(x[1]) === :IDENTIFIER
        @test headof(x[2]) === :LSQUARE
        @test headof(x[3]) === :generator
        @test headof(x[4]) === :RSQUARE
    end

    @testset "unary syntax" begin
        x = cst"<:a"
        @test length(x) == 2
        @test headof(x[1]) === :OPERATOR
        @test headof(x[2]) === :IDENTIFIER

        x = cst">:a"
        @test length(x) == 2
        @test headof(x[1]) === :OPERATOR
        @test headof(x[2]) === :IDENTIFIER

        x = cst"::a"
        @test length(x) == 2
        @test headof(x[1]) === :OPERATOR
        @test headof(x[2]) === :IDENTIFIER

        x = cst"&a"
        @test length(x) == 2
        @test headof(x[1]) === :OPERATOR
        @test headof(x[2]) === :IDENTIFIER

        x = cst"a..."
        @test length(x) == 2
        @test headof(x[1]) === :IDENTIFIER
        @test headof(x[2]) === :OPERATOR

        x = cst"$a"
        @test length(x) == 2
        @test headof(x[1]) === :OPERATOR
        @test headof(x[2]) === :IDENTIFIER
    end
end

@testset "self test" begin
    test_iter_spans(CSTParser.parse(String(read("parser.jl")), true))

    for f in joinpath.(abspath("../src"), readdir("../src"))
        if endswith(f, ".jl")
            test_iter_spans(CSTParser.parse(String(read(f)), true))
        end
    end
end
