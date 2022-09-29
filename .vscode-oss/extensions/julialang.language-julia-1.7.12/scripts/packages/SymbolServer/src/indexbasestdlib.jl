module SymbolServer

using Pkg, SHA
using Base: UUID

@info "Indexing Julia $VERSION..."

# This path will always be mounted in the docker container in which we are running
store_path = "/symcache"

cache_package_folder_path = joinpath(store_path, "v1", "stdlib")

mkpath(cache_package_folder_path)

module LoadingBay end

include("faketypes.jl")
include("symbols.jl")
include("utils.jl")
include("serialize.jl")
using .CacheStore

# TODO Make this load all the stdlibs and save them

# m = try
#     LoadingBay.eval(:(import $current_package_name))
#     getfield(LoadingBay, current_package_name)
# catch e
#     @info "Could not load package, exiting."
#     exit(10)
# end

# # Get the symbols
# env = getenvtree([current_package_name])
# symbols(env, m)

#  # Strip out paths
# modify_dirs(env[current_package_name], f -> modify_dir(f, pkg_src_dir(Base.loaded_modules[Base.PkgId(current_package_uuid, string(current_package_name))]), "PLACEHOLDER"))

# # There's an issue here - @enum used within CSTParser seems to add a method that is introduced from Enums.jl...

# Pkg.PlatformEngines.probe_platform_engines!()

# mktempdir() do path
#     # Write them to a file
#     open(joinpath(path, filename_with_extension), "w") do io
#         CacheStore.write(io, Package(string(current_package_name), env[current_package_name], current_package_uuid, nothing))
#     end

#     # cp(joinpath(path, filename_with_extension), cache_path)
#     Pkg.PlatformEngines.package(path, cache_path_compressed)
# end

@info "Finished indexing."

end
