function setup_server(env = dirname(SymbolServer.Pkg.Types.Context().env.project_file), depot = first(SymbolServer.Pkg.depots()), cache = joinpath(dirname(pathof(SymbolServer)), "..", "store"))
    server = StaticLint.FileServer()
    ssi = SymbolServerInstance(depot, cache)
    _, server.symbolserver = SymbolServer.getstore(ssi, env)
    server.symbol_extends  = SymbolServer.collect_extended_methods(server.symbolserver)
    server
end

"""
    lint_string(s, server; gethints = false)

Parse a string and run a semantic pass over it. This will mark scopes, bindings,
references, and lint hints. An annotated `EXPR` is returned or, if `gethints = true`,
it is paired with a collected list of errors/hints.
"""
function lint_string(s::String, server = setup_server(); gethints = false)
    empty!(server.files)
    f = File("", s, CSTParser.parse(s, true), nothing, server)
    env = getenv(f, server)
    setroot(f, f)
    setfile(server, "", f)
    semantic_pass(f)
    check_all(f.cst, LintOptions(), env)
    if gethints
        return f.cst, [(x, string(haserror(x) ? LintCodeDescriptions[x.meta.error] : "Missing reference", " at offset ", offset)) for (offset, x) in collect_hints(f.cst, env)]
    else
        return f.cst
    end
end

"""
    lint_file(rootpath, server)

Read a file from disc, parse and run a semantic pass over it. The file should be the
root of a project, e.g. for this package that file is `src/StaticLint.jl`. Other files
in the project will be loaded automatically (calls to `include` with complicated arguments
are not handled, see `followinclude` for details). A `FileServer` will be returned
containing the `File`s of the package.
"""
function lint_file(rootpath, server = setup_server(); gethints = false)
    empty!(server.files)
    root = loadfile(server, rootpath)
    semantic_pass(root)
    for f in values(server.files)
        check_all(f.cst, LintOptions(), getenv(f, server))
    end
    if gethints
        hints = []
        for (p,f) in server.files
            append!(hints, [(x, string(haserror(x) ? LintCodeDescriptions[x.meta.error] : "Missing reference", " at offset ", offset, " of ", p)) for (offset, x) in collect_hints(f.cst, getenv(f, server))])
        end
        return root, hints
    else
        return root
    end
end
