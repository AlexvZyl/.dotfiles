
# Originally from Pkg.Operations.sandbox

"""
    TestEnv.activate([pkg])

Activate the test enviroment of `pkg` (defaults to current enviroment).
"""
function activate(pkg::AbstractString=current_pkg_name())
    outer_tmp = mktempdir()

    ctx, pkgspec = ctx_and_pkgspec(pkg)
    if test_dir_has_project_file(ctx, pkgspec)
        local final_dir
        sandbox(ctx, pkgspec, pkgspec.path, sandbox_mutable_dir(pkgspec)) do
            flush(stdout)
            final_dir = dirname(Base.active_project())
            cp(joinpath(final_dir, "Project.toml"), joinpath(outer_tmp, "Project.toml"))
            cp(joinpath(final_dir, "Manifest.toml"), joinpath(outer_tmp, "Manifest.toml"))
        end
        # Trick the cache into not realizing that the directory was deleted
        mv(outer_tmp, final_dir)
        Pkg.activate(final_dir)
    else
        with_dependencies_loadable_at_toplevel(ctx, pkgspec; might_need_to_resolve=true) do localctx
            flush(stdout)
            cp(localctx.env.project_file, joinpath(outer_tmp, "Project.toml"))
            cp(localctx.env.manifest_file, joinpath(outer_tmp, "Manifest.toml"))
        end
        Pkg.activate(outer_tmp)
    end
end

