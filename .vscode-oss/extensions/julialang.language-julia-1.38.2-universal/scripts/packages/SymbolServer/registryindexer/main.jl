@info "Initializing indexing process..."

max_n = 1_000_000
max_versions = 1_000_000
max_tasks = length(ARGS)>1 ? parse(Int, ARGS[2]) : 1

julia_versions = [v"1.7.2"]

using Pkg

Pkg.activate(@__DIR__)
Pkg.instantiate()

using ProgressMeter, Query, JSON, UUIDs, Tar, CodecZlib

function get_all_package_versions(;max_versions=typemax(Int))
    registry_folder_path = joinpath(homedir(), ".julia", "registries", "General")
    registry_path = joinpath(registry_folder_path, "Registry.toml")

    registry_content = Pkg.TOML.parsefile(registry_path)

    packages = registry_content["packages"] |>
        @map({
            name = _[2]["name"],
            uuid = UUID(_[1]),
            path = _[2]["path"]
        }) |>
        @mutate(
            versions = (Pkg.TOML.parsefile(joinpath(registry_folder_path, _.path, "Versions.toml")) |>
                @map(i->{version=VersionNumber(i[1]), treehash=i[2]["git-tree-sha1"]}) |> 
                @orderby_descending(i->i.version) |>
                @take(max_versions) |>
                collect)
        ) |>
        collect

    return packages
end

function get_flattened_package_versions(packages)
    flattened_packageversions = []

    for p in packages
        for v in p.versions
            push!(flattened_packageversions, (;p.name, p.uuid, p.path, version=v.version, treehash=v.treehash))
        end
    end

    return flattened_packageversions
end

function execute(cmd::Base.Cmd)
    out = IOBuffer()
    err = IOBuffer()
    process = run(pipeline(ignorestatus(cmd), stdout=out, stderr=err))

    out_string =String(take!(out))
    err_string = String(take!(err))
    return (stdout = out_string,
            stderr = err_string,
            code = process.exitcode)
end

@info "Indexing started..."

all_packages = get_all_package_versions(max_versions=max_versions)

flattened_packageversions = get_flattened_package_versions(all_packages)

@info "Loaded package versions from registry..."

cache_folder = length(ARGS)>0 ? ARGS[1] : joinpath(@__DIR__, "..", "registryindexcache")

@info "Using the following folder as the cache folder: " cache_folder

rm(joinpath(cache_folder, "logs"), force=true, recursive=true)
mkpath(joinpath(cache_folder, "logs"))
mkpath(joinpath(cache_folder, "logs", "packageloadfailure"))
mkpath(joinpath(cache_folder, "logs", "packageinstallfailure"))
mkpath(joinpath(cache_folder, "logs", "packageindexfailure"))

@info "Building docker image..."

asyncmap(julia_versions) do v
    res = execute(Cmd(`docker build . -t juliavscodesymbolindexer:$v --build-arg JULIA_VERSION=$v -f registryindexer/Dockerfile`, dir=joinpath(@__DIR__, "..")))

    open(joinpath(cache_folder, "logs", "docker_image_create_$(v)_stdout.txt"), "w") do f
        print(f, res.stdout)
    end

    open(joinpath(cache_folder, "logs", "docker_image_create_$(v)_stderr.txt"), "w") do f
        print(f, res.stderr)
    end

    if res.code!=0
        error("Could not create docker image.")
    end
end

@info "Done building docker images."


true || asyncmap(julia_versions) do v
    cache_path = joinpath(cache_folder, "v1", "julia", "v$v.tar.gz")

    if isfile(cache_path)
        # global count_already_cached += 1
    else
        res = execute(`docker run --rm --mount type=bind,source="$cache_folder",target=/symcache juliavscodesymbolindexer:$v julia SymbolServer/src/indexbasestdlib.jl $v`)

        if res.code==10 || res.code==20
            if res.code==10
                # global count_failed_to_load += 1
            elseif res.code==20
                # global count_failed_to_install += 1
            end

            # mktempdir() do path
            #     error_filename = "v$(versionwithoutplus)_$(v.treehash).unavailable"

            #     # Write them to a file
            #     open(joinpath(path, error_filename), "w") do io                    
            #     end
            
            #     Pkg.PlatformEngines.package(path, cache_path)
            # end

            # open(joinpath(cache_folder, "logs", res.code==10 ? "packageloadfailure" : "packageinstallfailure", "log_$(v.name)_v$(versionwithoutplus)_stdout.txt"), "w") do f
            #     print(f, res.stdout)
            # end

            # open(joinpath(cache_folder, "logs", res.code==10 ? "packageloadfailure" : "packageinstallfailure", "log_$(v.name)_v$(versionwithoutplus)_stderr.txt"), "w") do f
            #     print(f, res.stderr)
            # end

            # global status_db

            # push!(status_db, Dict("name"=>v.name, "uuid"=>string(v.uuid), "version"=>string(v.version), "treehash"=>v.treehash, "status"=>res.code==20 ? "install_error" : "load_error", "indexattempts"=>[Dict("juliaversion"=>string(VERSION), "stdout"=>res.stdout, "stderr"=>res.stderr)]))
        elseif res.code==0
            # global count_successfully_cached += 1
        else
            # global count_failed_to_index += 1
            # open(joinpath(cache_folder, "logs", "packageindexfailure", "log_$(v.name)_v$(versionwithoutplus)_stdout.txt"), "w") do f
            #     print(f, res.stdout)
            # end

            # open(joinpath(cache_folder, "logs", "packageindexfailure", "log_$(v.name)_v$(versionwithoutplus)_stderr.txt"), "w") do f
            #     print(f, res.stderr)
            # end
        end
    end
end

@info "Now computing which of the total $(length(flattened_packageversions)) package versions that exist still need to be indexed..."

unindexed_packageversions = filter(collect(Iterators.take(flattened_packageversions, max_n))) do v
    versionwithoutplus = replace(string(v.version), '+'=>'_')

    cache_path = joinpath(cache_folder, "v1", "packages", string(uppercase(v.name[1])), "$(v.name)_$(v.uuid)", "v$(versionwithoutplus)_$(v.treehash).tar.gz")

    return !isfile(cache_path)
end

p = Progress(min(max_n, length(unindexed_packageversions)), 1)

count_failed_to_load = 0
count_failed_to_index = 0
count_failed_to_install = 0
count_successfully_cached = 0

@info "There are $(length(unindexed_packageversions)) new package/version combinations that need to be indexed. We will index at most $max_n."

statusdb_filename = joinpath(cache_folder, "statusdb.json")

isfile(statusdb_filename) && @info "Loading existing statusdb.json..."

status_db = isfile(statusdb_filename) ? JSON.parsefile(statusdb_filename) : []

@info "Starting the actual indexing process..."

asyncmap(unindexed_packageversions, ntasks=max_tasks) do v
    versionwithoutplus = replace(string(v.version), '+'=>'_')

    cache_path = joinpath(cache_folder, "v1", "packages", string(uppercase(v.name[1])), "$(v.name)_$(v.uuid)")
    mkpath(cache_path)
    cache_path_compressed = joinpath(cache_path, "v$(versionwithoutplus)_$(v.treehash).tar.gz")

    mktempdir() do path
        res = execute(`docker run --rm --mount type=bind,source="$path",target=/symcache juliavscodesymbolindexer:$(first(julia_versions)) julia SymbolServer/src/indexpackage.jl $(v.name) $(v.version) $(v.uuid) $(v.treehash)`)

        if res.code==37 # This is our magic error code that indicates everything worked
            global count_successfully_cached += 1
        else
            if res.code==10
                global count_failed_to_load += 1
            elseif res.code==20
                global count_failed_to_install += 1
            else
                global count_failed_to_index += 1
            end

            # @info res.code

            # @info res.stdout
            # @info res.stderr

            error_filename = "v$(versionwithoutplus)_$(v.treehash).unavailable"

            isfile(joinpath(path, error_filename)) && rm(joinpath(path, error_filename))

            # Write them to a file
            open(joinpath(path, error_filename), "w") do io                    
            end

            open(joinpath(cache_folder, "logs", res.code==10 ? "packageloadfailure" : res.code==20 ? "packageinstallfailure" : "packageindexfailure", "log_$(v.name)_v$(versionwithoutplus)_stdout.txt"), "w") do f
                print(f, res.stdout)
            end

            open(joinpath(cache_folder, "logs", res.code==10 ? "packageloadfailure" : res.code==20 ? "packageinstallfailure" : "packageindexfailure", "log_$(v.name)_v$(versionwithoutplus)_stderr.txt"), "w") do f
                print(f, res.stderr)
            end

            global status_db

            push!(status_db, Dict("name"=>v.name, "uuid"=>string(v.uuid), "version"=>string(v.version), "treehash"=>v.treehash, "status"=>res.code==20 ? "install_error" : res.code==10 ? "load_error" : "index_error", "indexattempts"=>[Dict("juliaversion"=>string(VERSION), "stdout"=>res.stdout, "stderr"=>res.stderr)]))
        end

        # @info "Files to be compressed" path readdir(path, join=true) ispath(cache_path) isfile(cache_path_compressed)

        open(cache_path_compressed, write=true) do tar_gz
            tar = GzipCompressorStream(tar_gz)
            try
                Tar.create(path, tar)
            finally
                close(tar)
            end
        end
    end

    next!(p, showvalues = [
        (:finished_package_count,p.counter+1),
        (:count_successfully_cached, count_successfully_cached),
        (:count_failed_to_install, count_failed_to_install),
        (:count_failed_to_load, count_failed_to_load),
        (:count_failed_to_index, count_failed_to_index),
    ])
end

@info "Now writing statusdb.json..."

open(joinpath(cache_folder, "statusdb.json"), "w") do f
    JSON.print(f, status_db, 4)
end

@info "Indexing finished."
