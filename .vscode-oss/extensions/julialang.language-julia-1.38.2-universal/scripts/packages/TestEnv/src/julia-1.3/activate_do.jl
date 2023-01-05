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
    if test_dir_has_project_file(ctx, pkgspec)
        sandbox(ctx, pkgspec, pkgspec.path, joinpath(pkgspec.path, "test")) do
            flush(stdout)
            f()
        end
    else
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
end