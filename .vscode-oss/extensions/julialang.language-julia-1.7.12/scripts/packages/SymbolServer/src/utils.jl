using Pkg

@static if VERSION < v"1.1"
    const PackageEntry = Vector{Dict{String,Any}}
else
    using Pkg.Types: PackageEntry
end

@static if isdefined(Base, :parsed_toml)
    parsed_toml(args...) = Base.parsed_toml(args...)
else
    parsed_toml(file) = Pkg.TOML.parsefile(file)
end

"""
    manifest(c::Pkg.Types.Context)
Retrieves the UUID -> PackageEntry map from the manifest of a Context.
"""
function manifest(c::Pkg.Types.Context)
    m = c.env.manifest
    if m isa Dict
        return m
    else
        return m.deps
    end
end

"""
    read_manifest(manifest_filename)

Read the manifest from the path and return the UUID -> PackageEntry map.
If the file can't be read, return `nothing`.
"""
function read_manifest(manifest_filename)
    try
        m = Pkg.API.read_manifest(manifest_filename)
        if m isa Dict
            return m
        else
            return m.deps
        end
    catch err
        @warn "Could not load manifest." exception=(err, catch_backtrace())
        return nothing
    end
end

"""
    project(c::Pkg.Types.Context)
Retrieves the project of a Context.
"""
project(c::Pkg.Types.Context) = c.env.project

"""
    isinproject(context, package::Union{String,UUID})
Checks whether a package is in the dependencies of a given context, e.g. is directly loadable.
"""
function isinproject end

"""
    isinmanifest(context, package::Union{String,UUID})
Checks whether a package is in the manifest of a given context, e.g. is either directly loadable or is a dependency of an loadable package.
"""
function isinmanifest end

@static if VERSION < v"1.1"
    isinmanifest(context::Pkg.Types.Context, module_name::String) = module_name in keys(manifest(context))
    isinmanifest(context::Pkg.Types.Context, uuid::UUID) = any(get(p[1], "uuid", "") == string(uuid) for (u, p) in manifest(context))
    isinmanifest(manifest::Dict{String,Any}, uuid::AbstractString) = any(get(p[1], "uuid", "") == uuid for (u, p) in manifest)
    isinmanifest(manifest::Dict{String,Any}, uuid::UUID) = isinmanifest(manifest, string(uuid))

    isinproject(context::Pkg.Types.Context, package_name::String) = haskey(deps(project(context)), package_name)
    isinproject(context::Pkg.Types.Context, package_uuid::UUID) = any(u == package_uuid for (n, u) in deps(project(context)))

    function packageuuid(c::Pkg.Types.Context, name::String)
        for pkg in manifest(c)
            if first(pkg) == name
                return UUID(last(pkg)[1]["uuid"])
            end
        end
    end
    packageuuid(pkg::Pair{Any,Any}) = last(pkg) isa String ? UUID(last(pkg)) : UUID(first(last(pkg))["uuid"])
    packageuuid(pkg::Pair{String,Any}) = last(pkg) isa String ? UUID(last(pkg)) : UUID(first(last(pkg))["uuid"])

    packagename(pkg::Pair{String,Any})::String = first(pkg)
    function packagename(c::Pkg.Types.Context, uuid)
        for (n, p) in manifest(c)
            if get(first(p), "uuid", "") == string(uuid)
                return n
            end
        end
        return nothing
    end
    function packagename(manifest::Dict{String,Any}, uuid::String)
        for (n, p) in manifest
            if get(first(p), "uuid", "") == string(uuid)
                return n
            end
        end
        return nothing
    end
    packagename(manifest::Dict{String,Any}, uuid::UUID) = packagename(manifest, string(uuid))

    function deps(uuid::UUID, c::Pkg.Types.Context)
        if any(p[1]["uuid"] == string(uuid) for (n, p) in manifest(c))
            return manifest(c)[string(uuid)][1].deps
        else
            return Dict{Any,Any}()
        end
    end
    deps(d::Dict{String,Any}) = get(d, "deps", Dict{String,Any}())
    deps(pe::PackageEntry) = get(pe[1], "deps", Dict{String,Any}())
    path(pe::PackageEntry) = get(pe[1], "path", nothing)
    version(pe::PackageEntry) = get(pe[1], "version", nothing)
    tree_hash(pe) = get(pe[1], "git-tree-sha1", nothing)

    frommanifest(c::Pkg.Types.Context, uuid) = frommanifest(manifest(c), uuid)

    function frommanifest(manifest::Dict{String,Any}, uuid)
        for p in values(manifest)
            if get(first(p), "uuid", "") == string(uuid)
                return (p)
            end
        end
        return nothing
    end
    is_package_deved(manifest, uuid) = get(first([p[2][1] for p in manifest if get(p[2][1], "uuid", "") == string(uuid)]), "path", "") != ""
else
    isinmanifest(context::Pkg.Types.Context, module_name::String) = any(p.name == module_name for (u, p) in manifest(context))
    isinmanifest(context::Pkg.Types.Context, uuid::UUID) = haskey(manifest(context), uuid)
    isinmanifest(manifest::Dict{UUID,PackageEntry}, uuid::UUID) = haskey(manifest, uuid)

    isinproject(context::Pkg.Types.Context, package_name::String) = haskey(deps(project(context)), package_name)
    isinproject(context::Pkg.Types.Context, package_uuid::UUID) = any(u == package_uuid for (n, u) in deps(project(context)))

    function packageuuid(c::Pkg.Types.Context, name::String)
        for pkg in manifest(c)
            if last(pkg).name == name
                return first(pkg)
            end
        end
    end
    packageuuid(pkg::Pair{String,UUID}) = last(pkg)
    packageuuid(pkg::Pair{UUID,PackageEntry}) = first(pkg)

    packagename(pkg::Pair{UUID,PackageEntry})::String = last(pkg).name
    packagename(c::Pkg.Types.Context, uuid::UUID) = manifest(c)[uuid].name
    packagename(manifest::Dict{UUID,PackageEntry}, uuid::UUID) = manifest[uuid].name

    function deps(uuid::UUID, c::Pkg.Types.Context)
        if haskey(manifest(c), uuid)
            return deps(manifest(c)[uuid])
        else
            return Dict{String,Base.UUID}()
        end
    end
    deps(pe::PackageEntry) = pe.deps
    deps(proj::Pkg.Types.Project) = proj.deps
    deps(pkg::Pair{String,UUID}, c::Pkg.Types.Context) = deps(packageuuid(pkg), c)
    path(pe::PackageEntry) = pe.path
    version(pe::PackageEntry) = pe.version
    version(pe::Pair{UUID,PackageEntry}) = last(pe).version
    frommanifest(c::Pkg.Types.Context, uuid) = manifest(c)[uuid]
    frommanifest(manifest::Dict{UUID,PackageEntry}, uuid) = manifest[uuid]
    tree_hash(pe::PackageEntry) = VERSION >= v"1.3" ? pe.tree_hash : get(pe.other, "git-tree-sha1", nothing)

    is_package_deved(manifest, uuid) = manifest[uuid].path !== nothing
end

function sha2_256_dir(path, sha=zeros(UInt8, 32))
    (uperm(path) & 0x04) != 0x04 && return
    startswith(path, ".") && return
    if isfile(path) && endswith(path, ".jl")
        s1 = open(path) do f
            sha2_256(f)
        end
        sha .+= s1
    elseif isdir(path)
        for f in readdir(path)
            sha = sha2_256_dir(joinpath(path, f), sha)
        end
    end
    return sha
end

function sha_pkg(pe::PackageEntry)
    path(pe) isa String && isdir(path(pe)) && isdir(joinpath(path(pe), "src")) ? sha2_256_dir(joinpath(path(pe), "src")) : nothing
end

function _doc(binding::Base.Docs.Binding)
    try
        sig = Union{}
        if Base.Docs.defined(binding)
            result = Base.Docs.getdoc(Base.Docs.resolve(binding), sig)
            result === nothing || return string(result)
        end
        results, groups = Base.Docs.DocStr[], Base.Docs.MultiDoc[]
    # Lookup `binding` and `sig` for matches in all modules of the docsystem.
        for mod in Base.Docs.modules
            dict = Base.Docs.meta(mod)::IdDict{Any,Any}
            if haskey(dict, binding)
                multidoc = dict[binding]
                push!(groups, multidoc)
                for msig in multidoc.order
                    sig <: msig && push!(results, multidoc.docs[msig])
                end
            end
        end
        if isempty(results)
            for group in groups, each in group.order
                push!(results, group.docs[each])
            end
        end
        md = try
            Base.Docs.catdoc(map(Base.Docs.parsedoc, results)...)
        catch
            nothing
        end
        return md === nothing ? "" : string(md)
    catch
        return ""
    end
end

_lookup(vr::FakeUnion, depot::EnvStore, cont=false) = nothing
_lookup(vr::FakeTypeName, depot::EnvStore, cont=false) = _lookup(vr.name, depot, cont)
_lookup(vr::FakeUnionAll, depot::EnvStore, cont=false) = _lookup(vr.body, depot, cont)
function _lookup(vr::VarRef, depot::EnvStore, cont=false)
    if vr.parent === nothing
        if haskey(depot, vr.name)
            val = depot[vr.name]
            if cont && val isa VarRef
                return _lookup(val, depot, cont)
            else
                return val
            end
        else
            return nothing
        end
    else
        par = _lookup(vr.parent, depot, cont)
        if par !== nothing && par isa ModuleStore && haskey(par, vr.name)
            val = par[vr.name]
            if cont && val isa VarRef
                return _lookup(val, depot, cont)
            else
                return val
            end
        else
            return nothing
        end
    end
end

maybe_lookup(x, env) = x isa VarRef ? _lookup(x, env, true) : x

"""
    maybe_getfield(k::Symbol , m::ModuleStore, server)

Try to get `k` from `m`. This includes: unexported variables, and variables
exported by modules used within `m`.
"""
function maybe_getfield(k::Symbol, m::ModuleStore, envstore)
    if haskey(m.vals, k)
        return m.vals[k]
    else
        for v in m.used_modules
            !haskey(m.vals, v) && continue
            submod = m.vals[v]
            if submod isa ModuleStore && k in submod.exportednames && haskey(submod.vals, k)
                return submod.vals[k]
            elseif submod isa VarRef
                submod = _lookup(submod, envstore, true)
                if submod isa ModuleStore && k in submod.exportednames && haskey(submod.vals, k)
                    return submod.vals[k]
                end
            end
        end
    end
end

function issubmodof(m::Module, M::Module)
    if m == M
        return true
    elseif parentmodule(m) === m
        return false
    elseif parentmodule(m) == M
        return true
    else
        return issubmodof(parentmodule(m), M)
    end
end

function Base.print(io::IO, f::FunctionStore)
    println(io, f.name, " is a Function.")
    nm = length(f.methods)
    println(io, "# $nm method", nm == 1 ? "" : "s", " for function ", f.name)
    for i = 1:nm
        print(io, "[$i] ")
        println(io, f.methods[i])
    end
end

const JULIA_DIR = normpath(joinpath(Sys.BINDIR, Base.DATAROOTDIR, "julia"))

function Base.print(io::IO, m::MethodStore)
    print(io, m.name, "(")
    for i = 1:length(m.sig)
        if m.sig[i][1] != Symbol("#unused#")
            print(io, m.sig[i][1])
        end
        print(io, "::", m.sig[i][2])
        i != length(m.sig) && print(io, ", ")
    end
    print(io, ")")
    path = replace(m.file, JULIA_DIR => "")
    print(io, " in ", m.mod, " at ", path, ':', m.line)
end

function Base.print(io::IO, t::DataTypeStore)
    print(io, t.name, " <: ", t.super)
    for i = 1:length(t.fieldnames)
        print(io, "\n  ", t.fieldnames[i], "::", t.types[i])
    end
end

Base.print(io::IO, m::ModuleStore) = print(io, m.name)
Base.print(io::IO, x::GenericStore) = print(io, x.name, "::", x.typ)

extends_methods(f) = false
extends_methods(f::FunctionStore) = f.name != f.extends
get_top_module(vr::VarRef) = vr.parent === nothing ? vr.name : get_top_module(vr.parent)

# Sorting is the main performance of calling `names`
unsorted_names(m::Module; all::Bool=false, imported::Bool=false) =
    ccall(:jl_module_names, Array{Symbol,1}, (Any, Cint, Cint), m, all, imported)

## recursive_copy
#
# `deepcopy` is reliable but incredibly slow. Its slowness comes from two factors:
# - generically iterating over, e.g., `fieldnames(typeof(x))` rather than having a method
#   optimized for each struct type
# - its care to protect against circular depenency graphs
# When you don't need to worry about cycles, you can do much better by defining your own function.

recursive_copy(x) = deepcopy(x)

recursive_copy(::Nothing) = nothing

recursive_copy(s::Symbol) = s

recursive_copy(c::Char) = c

recursive_copy(str::String) = str

recursive_copy(x::Number) = x

recursive_copy(p::Pair) = typeof(p)(recursive_copy(p.first), recursive_copy(p.second))

recursive_copy(A::Array) = eltype(A)[recursive_copy(a) for a in A]

recursive_copy(d::Dict) = typeof(d)(recursive_copy(p) for p in d)


recursive_copy(ref::VarRef) = VarRef(recursive_copy(ref.parent), ref.name)

recursive_copy(tn::FakeTypeName) = FakeTypeName(recursive_copy(tn.name), recursive_copy(tn.parameters))

recursive_copy(tb::FakeTypeofBottom) = tb

recursive_copy(u::FakeUnion) = FakeUnion(recursive_copy(u.a), recursive_copy(u.b))

recursive_copy(tv::FakeTypeVar) = FakeTypeVar(tv.name, recursive_copy(tv.lb), recursive_copy(tv.ub))

recursive_copy(ua::FakeUnionAll) = FakeUnionAll(recursive_copy(ua.var), recursive_copy(ua.body))

@static if !(Vararg isa Type)
    function recursive_copy(va::FakeTypeofVararg)
        if isdefined(va, :N)
            FakeTypeofVararg(recursive_copy(va.T), va.N)
        elseif isdefined(va, :T)
            FakeTypeofVararg(recursive_copy(va.T))
        else
            FakeTypeofVararg()
        end
    end
end

recursive_copy(m::ModuleStore) = ModuleStore(recursive_copy(m.name), recursive_copy(m.vals), m.doc,
                                             m.exported, copy(m.exportednames), copy(m.used_modules))

recursive_copy(p::Package) = Package(p.name,
                                     recursive_copy(p.val),
                                     p.uuid,
                                     recursive_copy(p.sha))

recursive_copy(ms::MethodStore) = MethodStore(ms.name,
                                              ms.mod,
                                              ms.file,
                                              ms.line,
                                              recursive_copy(ms.sig),
                                              copy(ms.kws),
                                              recursive_copy(ms.rt))

recursive_copy(dts::DataTypeStore) = DataTypeStore(recursive_copy(dts.name),
                                                   recursive_copy(dts.super),
                                                   recursive_copy(dts.parameters),
                                                   recursive_copy(dts.types),
                                                   recursive_copy(dts.fieldnames),
                                                   recursive_copy(dts.methods),
                                                   dts.doc,
                                                   dts.exported)

recursive_copy(fs::FunctionStore) = FunctionStore(recursive_copy(fs.name),
                                                  recursive_copy(fs.methods),
                                                  fs.doc,
                                                  recursive_copy(fs.extends),
                                                  fs.exported)

recursive_copy(gs::GenericStore) = GenericStore(recursive_copy(gs.name),
                                                recursive_copy(gs.typ),
                                                gs.doc,
                                                gs.exported)


# Tools for modifying source location
# env = getenvtree([:somepackage])
# symbols(env, somepackage)
# m = env[:somepackage]
# To strip actual src path:
# modify_dirs(m, f -> modify_dir(f, pkg_src_dir(somepackage), "PLACEHOLDER"))
# To replace the placeholder:
# modify_dirs(m, f -> modify_dir(f, "PLACEHOLDER", new_src_dir))
function modify_dirs(m::ModuleStore, f)
    for (k, v) in m.vals
        if v isa FunctionStore
            m.vals[k] = FunctionStore(v.name, MethodStore[MethodStore(m.name, m.mod, f(m.file), m.line, m.sig, m.kws, m.rt) for m in v.methods], v.doc, v.extends, v.exported)
        elseif v isa DataTypeStore
            m.vals[k] = DataTypeStore(v.name, v.super, v.parameters, v.types, v.fieldnames, MethodStore[MethodStore(m.name, m.mod, f(m.file), m.line, m.sig, m.kws, m.rt) for m in v.methods], v.doc, v.exported)
        elseif v isa ModuleStore
            modify_dirs(v, f)
        end
    end
end



pkg_src_dir(m::Module) = dirname(pathof(m))



# replace s1 with s2 at the start of a string
function modify_dir(f, s1, s2)
    # @assert startswith(f, s1)
    # Removed assertion because of Enums issue
    replace(f, s1 => s2)
end


# tools to retrieve cache from the cloud

function get_file_from_cloud(manifest, uuid, environment_path, depot_dir, cache_dir="../cache", download_dir="../downloads/", symbolcache_upstream="https://www.julia-vscode.org/symbolcache")
    paths = get_cache_path(manifest, uuid)
    name = packagename(manifest, uuid)
    link = string(first(splitext(join([symbolcache_upstream, "store/v1/packages", paths...], '/'))), ".tar.gz")

    dest_filepath = joinpath(cache_dir, paths...)
    dest_filepath_unavailable = string(first(splitext(dest_filepath)), ".unavailable")
    download_dir = joinpath(download_dir, first(splitext(last(paths))))
    download_filepath = joinpath(download_dir, last(paths))
    download_filepath_unavailable = string(first(splitext(download_filepath)), ".unavailable")

    @debug "Downloading cache file for $name."
    if isfile(dest_filepath_unavailable)
        @info "Cloud was unable to cache $name in the past, we won't try to retrieve it again."
        return false
    end
    file = try
        if Pkg.PlatformEngines.download_verify_unpack(link, nothing, download_dir)
            mkpath(dirname(dest_filepath))
            if !isfile(download_filepath) && isfile(download_filepath_unavailable)
                mv(download_filepath_unavailable, dest_filepath_unavailable)
                @info "Cloud is unable to cache $name, we won't try to retrieve it again."
                return false
            end
            mv(download_filepath, dest_filepath)
            dest_filepath
        else
            nothing
        end
    catch err
        @info "Couldn't retrieve cache file for $name." exception = err
        return false
    end

    if file === nothing
        @info "Couldn't retrieve cache file for $name."
        return false
    end

    cache = try
        open(file, "r") do io
            CacheStore.read(io)
        end
    catch
        @info "Couldn't read cache file for $name, deleting."
        rm(file)
        return false
    end

    pkg_entry = Base.locate_package(Base.PkgId(uuid, name))
    if pkg_entry !== nothing && isfile(pkg_entry)
        pkg_src = dirname(pkg_entry)
    else
        pkg_root = get_pkg_path(Base.PkgId(uuid, name), environment_path, depot_dir)
        if pkg_root === nothing
            @info "Successfully downloaded and saved $(name), but with placeholder paths"
            return false
        end
        pkg_src = joinpath(pkg_root, "src")
    end

    @debug "Replacing PLACEHOLDER with:" pkg_src
    modify_dirs(cache.val, f -> modify_dir(f, r"^PLACEHOLDER", pkg_src))
    open(file, "w") do io
        CacheStore.write(io, cache)
    end

    @info "Successfully downloaded, scrubbed and saved $(name)"
    return true
end

"""
    validate_disc_store(store_path, manifest)

This returns a list of non-jll packages in the manifest that don't have caches on disc.
"""
function validate_disc_store(store_path, manifest)
    filter(manifest) do pkg
        uuid = packageuuid(pkg)
        endswith(packagename(manifest, uuid), "_jll") && return false

        file_name = joinpath(get_cache_path(manifest, uuid)...)
        yield()
        return !isfile(joinpath(store_path, file_name))
    end
end

function find_project_file(env)
    isdir(env) || return false
    for filename in ("Project.toml", "JuliaProject.toml")
        maybe_project_file = joinpath(env, filename)
        if isfile(maybe_project_file)
            return maybe_project_file
        end
    end
    return false
end

"""
    get_pkg_path(pkg::Base.PkgId, env, depot_path)

Find out where a package is installed without having to load it.
"""
function get_pkg_path(pkg::Base.PkgId, env, depot_path)
    project_file = find_project_file(env)
    project_file isa Bool && return nothing
    manifest_file = Base.project_file_manifest_path(project_file)

    d = parsed_toml(manifest_file)
    if get(d, "manifest_format", "0.0") == "2.0"
        entries = get(d, "deps", nothing)
        entries === nothing && return nothing
        entries = map(e -> e[1], values(entries))
    else
        entries = get(d, pkg.name, nothing)
    end
    entries === nothing && return nothing # TODO: allow name to mismatch?
    for entry in entries
        entry = entry::Dict{String,Any}
        uuid = get(entry, "uuid", nothing)::Union{Nothing,String}
        uuid === nothing && continue
        if UUID(uuid) === pkg.uuid
            path = get(entry, "path", nothing)::Union{Nothing,String}
            # this can only be true for explicitly dev'ed packages
            if path !== nothing
                path = normpath(abspath(dirname(manifest_file), path))
                return path
            end
            hash = get(entry, "git-tree-sha1", nothing)::Union{Nothing,String}
            hash === nothing && return nothing
            hash = Base.SHA1(hash)
            # empty default path probably means that we should use the default Julia depots
            if depot_path == ""
                depot_paths = []
                if isdefined(Base, :append_default_depot_path!)
                    Base.append_default_depot_path!(depot_paths)
                else
                    depot_paths = Pkg.depots()
                end
            else
                depot_paths = [depot_path]
            end
            for depot in depot_paths
                # Keep the 4 since it used to be the default
                for slug in (Base.version_slug(pkg.uuid, hash, 4), Base.version_slug(pkg.uuid, hash))
                    path = abspath(depot, "packages", pkg.name, slug)
                    ispath(path) && return path
                end
            end
            return nothing
        end
    end
    return nothing
end

function load_package(c::Pkg.Types.Context, uuid, conn, loadingbay, percentage = missing)
    isinmanifest(c, uuid isa String ? Base.UUID(uuid) : uuid) || return
    pe_name = packagename(c, uuid)

    pid = Base.PkgId(uuid isa String ? Base.UUID(uuid) : uuid, pe_name)
    if pid in keys(Base.loaded_modules)
        conn !== nothing && println(conn, "PROCESSPKG;$pe_name;$uuid;noversion;$percentage")
        loadingbay.eval(:($(Symbol(pe_name)) = $(Base.loaded_modules[pid])))
        m = getfield(loadingbay, Symbol(pe_name))
    else
        m = try
            conn !== nothing && println(conn, "STARTLOAD;$pe_name;$uuid;noversion;$percentage")
            loadingbay.eval(:(import $(Symbol(pe_name))))
            conn !== nothing && println(conn, "STOPLOAD;$pe_name")
            m = getfield(loadingbay, Symbol(pe_name))
        catch
            return
        end
    end
end

function write_cache(uuid, pkg::Package, outpath)
    mkpath(dirname(outpath))
    @info "Now writing to disc $uuid"
    open(outpath, "w") do io
        CacheStore.write(io, pkg)
    end
    outpath
end

"""
    get_cache_path(manifest, uuid)

Returns a vector containing the cache storage path for a package structured: [folder, folder, file].
"""
function get_cache_path(manifest, uuid)
    name = packagename(manifest, uuid)
    pkg_info = frommanifest(manifest, uuid)
    ver = version(pkg_info)
    ver = ver === nothing ? "nothing" : ver
    ver = replace(string(ver), '+'=>'_')
    th = tree_hash(pkg_info)
    th = th === nothing ? "nothing" : th

    [
        string(uppercase(string(name)[1]))
        string(name, "_", uuid)
        string("v", ver, "_", th, ".jstore")
    ]
end

function write_depot(server::Server, ctx, written_caches)
    for (uuid, pkg) in server.depot
        cache_paths = get_cache_path(manifest(ctx), uuid)
        outpath = joinpath(server.storedir, cache_paths...)
        outpath in written_caches && continue

        written_path = write_cache(uuid, pkg, outpath)
        !isempty(written_path) && push!(written_caches, written_path)
    end
end
