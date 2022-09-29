# Support functionality for amend_coverage_from_src!

isevaldef(x) = Base.Meta.isexpr(x, :(=)) && Base.Meta.isexpr(x.args[1], :call) &&
               x.args[1].args[1] == :eval

# This detects different types of function declarations:
# - those that use the  `function` keyword;
# - those that are defined as `f = x -> expr`
# - those that are defined as `f() = expr`
# - those that are defined as `f() where {T} = expr`
# - ... and various more
isfuncexpr(ex::Expr) =
    ex.head == :function || ex.head == :-> ||
        Base.is_short_function_def(ex)
isfuncexpr(arg) = false

function_body_lines(ast, coverage, lineoffset) = function_body_lines!(Int[], ast, coverage, lineoffset, false)

function_body_lines!(flines, arg, coverage, lineoffset, infunction) = flines

function function_body_lines!(flines, node::LineNumberNode, coverage, lineoffset, infunction)
    line = node.line
    if infunction
        push!(flines, line)
    end
    flines
end

function function_body_lines!(flines, ast::Expr, coverage::Vector{CovCount}, lineoffset, infunction)
    if ast.head == :line
        line = ast.args[1]
        if infunction
            push!(flines, line)
        end
        return flines
    elseif ast.head == :module
        # Ignore automatically added eval definitions
        args = ast.args[end].args
        if length(args) >= 2 && isevaldef(args[1]) && isevaldef(args[2])
            args = args[3:end]
        end
    else
        args = ast.args
    end

    # Check whether we are looking at a function declaration.
    # Then also make sure we are not looking at a function declaration
    # that does not also define a method by checking the length of
    # ast.args and making sure it is at least length==2. The test for
    # Expr might not be necessary but also can't harm. Note that this works
    # for both function declarations that use the `function` keyword, and
    # declarations of the form `foo() = expr`, in both cases the method
    # body ends up being `ast.args[2]` (if it exists).
    if isfuncexpr(ast) && length(ast.args)>=2 && ast.args[2] isa Expr
        # Only look in function body and ignore the function signature
        # itself. Sometimes function signatures have line nodes inside
        # and we don't want those lines to be identified as runnable code.
        # In this context, ast.args[1] is the function signature and
        # ast.args[2] is the method body
        #
        # now compute all lines in the body of this function, but for now,
        # track them separately from flines
        flines_new = Int[]
        for arg in ast.args[2].args
            function_body_lines!(flines_new, arg, coverage, lineoffset, true)
        end

        # if any of the lines in the body of the function already has
        # coverage, we assume that the function was executed, generally
        # speaking, and so we should *not* apply our heuristic (which is mean
        # to mark functions which were never executed as code, which the
        # coverage data returned by Julia normally does not)
        not_covered(l) = (l + lineoffset > length(coverage) || coverage[l + lineoffset] === nothing)
        if all(not_covered, flines_new)
            append!(flines, flines_new)
        end
    else
        for arg in args
            function_body_lines!(flines, arg, coverage, lineoffset, infunction)
        end
    end

    flines
end
