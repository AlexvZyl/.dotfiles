import Base.@deprecate

import Base: real, abs, size

@deprecate real(fp::AbstractPath) canonicalize(fp)
@deprecate abs(fp::AbstractPath) absolute(fp)
@deprecate isabs(fp::AbstractPath) isabsolute(fp)
@deprecate move(src::AbstractPath, dest::AbstractPath; kwargs...) mv(src, dest; kwargs...)
@deprecate remove(fp::AbstractPath; kwargs...) rm(fp; kwargs...)
@deprecate size(fp::AbstractPath) filesize(fp)
