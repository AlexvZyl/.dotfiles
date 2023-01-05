
# Originally from Pkg.Operations.sandbox

"""
    TestEnv.activate([pkg])

Activate the test enviroment of `pkg` (defaults to current enviroment).
"""
function activate(pkg::AbstractString=current_pkg_name())
    outer_tmp = mktempdir()

    ctx, pkgspec = ctx_and_pkgspec(pkg)
    get_test_dir(ctx, pkgspec)  # HACK: a side effect of this is to fix pkgspec
    with_dependencies_loadable_at_toplevel(ctx, pkgspec; might_need_to_resolve=true) do localctx
        cp(localctx.env.project_file, joinpath(outer_tmp, "Project.toml"))
        cp(localctx.env.manifest_file, joinpath(outer_tmp, "Manifest.toml"))
    end
    Pkg.activate(outer_tmp)
end