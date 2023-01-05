# This deletes arbitrary tokens from files and checks that we can still parse them
# and that iteration functions are still correctly ordered.

@testset "invalid jl file parsing" begin
    function trav(x, f = x->nothing)
        f(x)
        for a in x
            trav(a, f)
        end
    end

    function trav1(x, f = x->nothing)
        f(x)
        if x.args !== nothing
            for a in x
                trav(a, f)
            end
        end
    end

    function check_err_parse(s, n = length(s)÷100)
        check_str(s) # parsing works?
        check_itr_order(s) # iteration produces same text?

        ts = collect(tokenize(s))[1:end-1]
        for _ in 1:n
            length(ts) == 1 && return
            deleteat!(ts, rand(1:length(ts)))
            check_str(untokenize(ts))
        end
    end

    function check_str(s)
        x = try
            CSTParser.parse(s, true)
        catch e
            @info "Couldn't parse:"
            @info s
            rethrow(e)
        end
        try
            trav(x)
        catch e
            @info "Couldn't traverse:"
            @info s
            rethrow(e)
        end
        try
            to_codeobject(x)
        catch e
            @info "Couldn't convert:"
            @info s
            rethrow(e)
        end
        if sizeof(s) != x.fullspan
            @info "sizeof(s) != x.fullspan for :"
            println(">>>>>>>>>>>>>>>>>>")
            println(s)
            println("<<<<<<<<<<<<<<<<<<")
        end
        check_itr_order(s, x)
    end

    function get_segs(x)
        offset = 0
        segs = []
        for i = 1:length(x)
            a = x[i]
            push!(segs, offset .+ (1:a.fullspan))
            offset += a.fullspan
        end
        segs
    end

    function check_itr_order(s, x = CSTParser.parse(s, true))
        length(x) == 0 && return
        segs = get_segs(x)
        s0 = join(String(codeunits(s)[seg]) for seg in segs)
        if s0 == s
            for i = 1:length(x)
                if length(x[i]) > 0
                    seg = segs[i]
                    s2 = String(codeunits(s)[seg])
                    check_itr_order(s2, x[i])
                end
            end
        else
            @info "check_itr_order failed: "
            println(">>>>>>>>>>>>>>>>>>")
            println(s)
            println("<<<<<<<<<<<<<<<<<<")
            error()
        end
    end

    comp(x, y) = x == y
    function comp(x::CSTParser.EXPR, y::CSTParser.EXPR)
        comp(x.head, y.head) &&
            x.span == y.span &&
            x.fullspan == y.fullspan &&
            x.val == y.val &&
            length(x) == length(y) &&
            all(comp(x[i], y[i]) for i = 1:length(x))
    end

    function check_reparse(s0, n = length(s0)÷100)
        for _ in 1:n
            x0 = CSTParser.parse(s0, true)
            CSTParser.has_error(x0) && return
            ts = collect(tokenize(s0))[1:end-1]
            length(ts) < 2 && return
            deleteat!(ts, rand(1:length(ts)))
            s1 = untokenize(ts)
            length(ts) < 3 || isempty(s1) && return
            x1 = CSTParser.parse(s1, true)
            x2 = try
                CSTParser.minimal_reparse(s0, s1, x0, x1)
            catch err
                @info "minimal reparse failed with"
                @info "s0:"
                @info s0
                @info "s1:"
                @info s1
                rethrow(err)
            end
            @test comp(x1, x2) ? true : (@info(string("Comparison failed between s0:\n", s0, "\n\n and s1: \n", s1)); false)
            @test try
                join(String(codeunits(s0)[seg]) for seg in get_segs(x0)) == s0
            catch e
                @info "Couldn't reconstruct original text from EXPR segments for:"
                @info s0
                rethrow(e)
            end
            @test try
                join(String(codeunits(s1)[seg]) for seg in get_segs(x1)) == s1
            catch e
                @info "Couldn't reconstruct original text from EXPR segments for:"
                @info s1
                rethrow(e)
            end
            @test join(String(codeunits(s1)[seg]) for seg in get_segs(x2)) == s1
            s0 = s1
        end
    end

    function check_dir(dir, check)
        for (root, _, files) in walkdir(dir)
            for f in files
                f = joinpath(root, f)
                (!isfile(f) || !endswith(f, ".jl")) && continue
                @info "checking $(nameof(check)) against $f"
                s = String(read(f))
                if isvalid(s) && length(s) >0
                    check(s)
                end
            end
        end
        true
    end

    @test check_dir("..", check_err_parse)
    @test check_dir("..", check_reparse)
end
