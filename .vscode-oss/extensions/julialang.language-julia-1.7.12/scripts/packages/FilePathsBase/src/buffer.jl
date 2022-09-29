"""
    FileBuffer <: IO

A generic buffer type to provide an IO interface for none IO based path types.

NOTES:
- All `read` operations will read the entire file into the internal buffer at once.
  Subsequent calls to `read` will only operate on the internal buffer and will not access
  the filepath.
- All `write` operations will only write to the internal buffer and `flush`/`close` are
  required to update the filepath contents.
"""
struct FileBuffer <: IO
    path::AbstractPath
    io::IOBuffer
    read::Bool
    write::Bool
    create::Bool
end

function FileBuffer(
    fp::AbstractPath; read=true, write=false, create=false, truncate=false, append=false
)
    buffer = FileBuffer(fp, IOBuffer(), read, write, create)

    # If we're wanting to append data then we we need to prepopulate the internal buffer
    if write && append
        _read(buffer)
        seekend(buffer)
    end

    return buffer
end

Base.isopen(buffer::FileBuffer) = isopen(buffer.io)
Base.isreadable(buffer::FileBuffer) = buffer.read
Base.iswritable(buffer::FileBuffer) = buffer.write
Base.readavailable(buffer::FileBuffer) = read(buffer)
Base.seek(buffer::FileBuffer, n::Integer) = (_read(buffer); seek(buffer.io, n))
Base.skip(buffer::FileBuffer, n::Integer) = (_read(buffer); skip(buffer.io, n))
Base.seekstart(buffer::FileBuffer) = seekstart(buffer.io)
Base.seekend(buffer::FileBuffer) = (_read(buffer); seekend(buffer.io))
Base.position(buffer::FileBuffer) = position(buffer.io)
Base.eof(buffer::FileBuffer) = (_read(buffer); eof(buffer.io))

function _read(buffer::FileBuffer)
    # If our IOBuffer is empty then populate it with the
    # filepath contents
    if buffer.io.size == 0
        write(buffer.io, read(buffer.path))
        seekstart(buffer.io)
    end
end

function Base.read(buffer::FileBuffer)
    isreadable(buffer) || throw(ArgumentError("read failed, FileBuffer is not readable"))
    _read(buffer)
    seekstart(buffer)
    read(buffer.io)
end

function Base.read(buffer::FileBuffer, ::Type{String})
    isreadable(buffer) || throw(ArgumentError("read failed, FileBuffer is not readable"))
    _read(buffer)
    seekstart(buffer)
    read(buffer.io, String)
end

function Base.read(buffer::FileBuffer, ::Type{UInt8})
    if buffer.io.size == 0
        write(buffer.io, read(buffer.path))
        seekstart(buffer)
    end
    read(buffer.io, UInt8)
end

#=
NOTE: We need to define multiple methods because of ambiguity error with base IO methods.
=#
function Base.write(buffer::FileBuffer, x::Vector{UInt8})
    iswritable(buffer) || throw(ArgumentError("write failed, FileBuffer is not writeable"))
    write(buffer.io, x)
end

function Base.write(buffer::FileBuffer, x::String)
    iswritable(buffer) || throw(ArgumentError("write failed, FileBuffer is not writeable"))
    write(buffer.io, x)
end

function Base.write(buffer::FileBuffer, x::UInt8)
    iswritable(buffer) || throw(ArgumentError("write failed, FileBuffer is not writeable"))
    write(buffer.io, x)
end

function Base.flush(buffer::FileBuffer)
    if iswritable(buffer)
        seekstart(buffer)
        write(buffer.path, read(buffer.io))
    end
end

function Base.close(buffer::FileBuffer)
    flush(buffer)
    close(buffer.io)
end
