"""
    TestEnv.activate(f, [pkg])

Activate the test enviroment of `pkg` (defaults to current enviroment), and run `f()`,
then deactivate the enviroment.
This is not useful for many people: Julia is not really designed to have the enviroment
being changed while you are executing code.
However, this *is* useful for anyone doing something like making a alternative to
`Pkg.test()`.
Indeed this is basically extracted from what `Pkg.test()` does.
"""
function activate(f, pkg::AbstractString=current_pkg_name())
    ctx, pkgspec = ctx_and_pkgspec(pkg)
    
    get_test_dir(ctx, pkgspec)  # HACK: a side effect of this is to fix pkgspec
    with_dependencies_loadable_at_toplevel(ctx, pkgspec; might_need_to_resolve=true) do localctx
        Pkg.activate(localctx.env.project_file)
        try
            flush(stdout)
            f()
        finally
            Pkg.activate(ctx.env.project_file)
        end
    end
end