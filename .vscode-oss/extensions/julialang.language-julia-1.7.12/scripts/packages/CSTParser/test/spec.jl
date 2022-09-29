using CSTParser: @cst_str, headof, parentof, check_span, EXPR, to_codeobject
jl_parse(s) = CSTParser.remlineinfo!(Meta.parse(s))

function check_parents(x::EXPR)
    if x.args isa Vector{EXPR}
        for a in x.args
            @test a.parent == x
            check_parents(a)
        end
    end
    if x.trivia isa Vector{EXPR}
        for a in x.trivia
            @test a.parent == x
        end
    end
end

function test_iter(ex)
    total = 0
    for x in ex
        @test x isa EXPR
        test_iter(x)
        total += x.fullspan
    end
    if length(ex) > 0
        @test total == ex.fullspan
    end
end

function test_expr(s, head, n, endswithtrivia = false)
    x = CSTParser.parse(s)
    head === nothing || @test headof(x) === head
    @test length(x) === n
    @test x.args === nothing || all(x === parentof(a) for a in x.args)
    @test x.trivia === nothing || all(x === parentof(a) for a in x.trivia)
    @test to_codeobject(x) == jl_parse(s)
    @test isempty(check_span(x))
    check_parents(x)
    test_iter(x)
    @test endswithtrivia ? (x.fullspan-x.span) == (last(x.trivia).fullspan - last(x.trivia).span) : (x.fullspan-x.span) == (last(x.args).fullspan - last(x.args).span)
end


@testset ":local" begin
    test_expr("local a", :local, 2)
end

@testset ":global" begin
    test_expr("global a", :global, 2)
    test_expr("global a, b", :global, 4)
    test_expr("global a, b = 2", :global, 2)
    test_expr("global const a = 1", :const, 2)
    test_expr("global const a = 1, b", :const, 2)
end

@testset ":const" begin
    test_expr("const a = 1", :const, 2)
    test_expr("const global a = 1", :const, 2)
end

@testset ":return" begin
    test_expr("return a", :return, 2)
end

@testset ":abstract" begin
    test_expr("abstract type sig end", :abstract, 4, true)
end

@testset ":primitive" begin
    test_expr("primitive type sig spec end", :primitive, 5, true)
end

@testset ":call" begin
    test_expr("f()", :call, 3, true)
    test_expr("f(a, b)", :call, 6, true)
    test_expr("a + b", :call, 3, false)
end

@testset ":brackets" begin
    test_expr("(a)", :brackets, 3, true)
end

@testset ":begin" begin
    test_expr("begin end", :block, 2, true)
    test_expr("begin a end", :block, 3, true)
    test_expr("quote end", :quote, 3, true)
    test_expr("while cond end", :while, 4, true)
    test_expr("for i = I end", :for, 4, true)
    test_expr("module m end", :module, 5, true)
    test_expr("function f() end", :function, 4, true)
    test_expr("macro f() end", :macro, 4, true)
    test_expr("struct T end", :struct, 5, true)
    test_expr("mutable struct T end", :struct, 6, true)
end

@testset ":export" begin
    test_expr("export a", :export, 2, false)
    test_expr("export a, b", :export, 4, false)
end

@testset ":import" begin
    test_expr("import a", :import, 2, false)
    test_expr("import a, b", :import, 4, false)
    test_expr("import a.b", :import, 2, false)
    test_expr("import a.b, c", :import, 4, false)
    test_expr("import a:b", :import, 2, false)
    test_expr("import a:b.c", :import, 2, false)
    test_expr("import a:b.c, d", :import, 2, false)
end

@testset ":kw" begin
    test_expr("f(a=1)", :call, 4, false)
end

@testset ":tuple" begin
    test_expr("a,b ", :tuple, 3, false)
    test_expr("(a,b) ", :tuple, 5, true)
    test_expr("a,b,c ", :tuple, 5, false)
    test_expr("(a,b),(c) ", :tuple, 3, false)
end

@testset ":curly" begin
    test_expr("x{a}", :curly, 4, true)
    test_expr("x{a,b}", :curly, 6, true)
end

@testset "operators" begin
    test_expr("!a", :call, 2, false)
    test_expr("&a", nothing, 2, false)
    test_expr(":a", :quotenode, 2, false)
    test_expr("a + 1", :call, 3, false)
    test_expr(":(a + 1)", :quote, 2, false)
    test_expr("a ? b : c", :if, 5, false)
    test_expr("a:b", :call, 3, false)
    test_expr("a:b:c", :call, 5, false)
    test_expr("a = b", nothing, 3, false)
    test_expr("a += b", nothing, 3, false)
    test_expr("a < b", :call, 3, false)
    test_expr("a < b < c", :comparison, 5, false)
    test_expr("a^b", :call, 3, false)
    test_expr("!a^b", nothing, 2, false)
    test_expr("a.b", nothing, 3, false)
    test_expr("a.:b", nothing, 3, false)
    test_expr("a + b + c", :call, 5, false)
    test_expr("a where b", :where, 3, false)
    test_expr("a where {b }", :where, 5, true)
    test_expr("a where {b,c }  ", :where, 7, true)
    test_expr("a...", nothing, 2, false)
    @test let x = cst"a... "; x.fullspan - x.span == 1 end
    test_expr("a <: b", nothing, 3, false)

    # https://github.com/julia-vscode/CSTParser.jl/issues/278
    test_expr("*(a)*b*c", :call, 5, false)
    test_expr("+(a)+b+c", :call, 5, false)
    test_expr("(\na +\nb +\nc +\n d\n)", :brackets, 3, true)
end

@testset ":parameters" begin
    test_expr("f(a;b = 1)", nothing, 5, true)
end

@testset "lists" begin
    @testset ":vect" begin
        test_expr("[]", :vect, 2, true)
        test_expr("[a]", :vect, 3, true)
        test_expr("[a, b]", :vect, 5, true)
        test_expr("[a ]", :vect, 3, true)
    end

    @testset ":vcat" begin
        test_expr("[a\nb]", :vcat, 4, true)
        test_expr("[a;b]", :vcat, 4, true)
        test_expr("[a b\nc d]", :vcat, 4, true)
        test_expr("[a\nc d]", :vcat, 4, true)
        test_expr("[a;c d]", :vcat, 4, true)
    end

    @testset ":hcat" begin
        test_expr("[a b]", :hcat, 4, true)
    end
    @testset ":ref" begin
        test_expr("T[a]", :ref, 4, true)
        test_expr("T[a,b]", :ref, 6, true)
    end
    @testset ":typed_hcat" begin
        test_expr("T[a b]", :typed_hcat, 5, true)
    end
    @testset ":typed_vcat" begin
        test_expr("T[a;b]", :typed_vcat, 5, true)
    end
end

@testset ":let" begin
    test_expr("let\n end", :let, 4, true)
    test_expr("let x = 1 end", :let, 4, true)
    test_expr("let x = 1, y =1  end", :let, 4, true)
end

@testset ":try" begin
    test_expr("try catch end", :try, 6, true)
    test_expr("try a catch end", :try, 6, true)
    test_expr("try catch e end", :try, 6, true)
    test_expr("try a catch e end", :try, 6, true)
    test_expr("try a catch e b end", :try, 6, true)
    test_expr("try a catch e b end", :try, 6, true)
    test_expr("try finally end", :try, 8, true)
    test_expr("try finally a end", :try, 8, true)
    test_expr("try a catch e b finally c end", :try, 8, true)
end

@testset ":macrocall" begin
    test_expr("@m", :macrocall, 2, false)
    test_expr("@m a", :macrocall, 3, false)
    test_expr("@m a b", :macrocall, 4, false)
end

@testset ":if" begin
    test_expr("if c end", :if, 4, true)
    test_expr("if c a end", :if, 4, true)
    test_expr("if c a else end", :if, 6, true)
    test_expr("if c a else b end", :if, 6, true)
    test_expr("if c elseif c end", :if, 5, true)
    test_expr("if c a elseif c b end", :if, 5, true)
    test_expr("if c a elseif c b else d end", :if, 5, true)
end

@testset ":do" begin
    test_expr("f() do x end", :do, 4, true)
    test_expr("f() do x,y end", :do, 4, true)
end

@testset "strings" begin
    test_expr("a\"txt\"", :macrocall, 3, false)
    test_expr("a\"txt\"b", :macrocall, 4, false)
end


@testset ":string" begin
    test_expr("\"\$a\"", :string, 4, false)
    test_expr("\" \$a\"", :string, 4, false)
    test_expr("\" \$a \"", :string, 4, false)
end

@testset ":for" begin
    test_expr("for i = I end", :for, 4, true)
    test_expr("for i in I end", :for, 4, true)
    test_expr("for i ∈ I end", :for, 4, true)
    test_expr("for i ∈ I, j in J end", :for, 4, true)
end

@testset "docs" begin
    test_expr("\"doc\"\nT", :macrocall, 4, false)
end

@testset ":generator" begin
    test_expr("(arg for x in X)", :brackets, 3, true)
    test_expr("(arg for x in X if x)", :brackets, 3, true)
    test_expr("(arg for x in X, y in Y)", :brackets, 3, true)
    test_expr("(arg for x in X, y in Y if x)", :brackets, 3, true)
    test_expr("(arg for x in X for  y in Y)", :brackets, 3, true)
    test_expr("(arg for x in X for  y in Y if x)", :brackets, 3, true)
    test_expr("(arg for x in X for y in Y for z in Z)", :brackets, 3, true)
end

@testset ":cmd" begin
    let s = "``"
        x = CSTParser.parse(s)
        x1 = jl_parse(s)
        @test x1 == to_codeobject(x)
    end
    let s = "`a`"
        x = CSTParser.parse(s)
        x1 = jl_parse(s)
        @test x1 == to_codeobject(x)
    end
    let s = "`a \$a`"
        x = CSTParser.parse(s)
        x1 = jl_parse(s)
        @test x1 == to_codeobject(x)
    end
    test_expr("a``", nothing, 3, false)
    test_expr("a`a`", nothing, 3, false)
end

@testset ":macrocall" begin
    test_expr("@m", :macrocall, 2, false)
    test_expr("@m a", :macrocall, 3, false)
    test_expr("@m(a)", :macrocall, 5, false)
    test_expr("@horner(r) + r", nothing, 3, false)
end

@testset "_str" begin
    test_expr("a\"txt\"", :macrocall, 3, false)
    test_expr("a.b\"txt\"", :macrocall, 3, false)
end
