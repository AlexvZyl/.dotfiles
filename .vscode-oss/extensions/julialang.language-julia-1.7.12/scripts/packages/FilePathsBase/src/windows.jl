"""
    WindowsPath()
    WindowsPath(str)

Represents a windows path (e.g., `C:\\User\\Documents`)
"""
struct WindowsPath <: SystemPath
    segments::Tuple{Vararg{String}}
    root::String
    drive::String
    separator::String

    function WindowsPath(
        segments::Tuple, root::String, drive::String, separator::String=WIN_PATH_SEPARATOR
    )
        return new(Tuple(Iterators.filter(!isempty, segments)), root, drive, separator)
    end
end

function _win_splitdrive(fp::String)
    m = match(r"^([^\\]+:|\\\\[^\\]+\\[^\\]+|\\\\\?\\UNC\\[^\\]+\\[^\\]+|\\\\\?\\[^\\]+:|)(.*)$", fp)
    String(m.captures[1]), String(m.captures[2])
end

WindowsPath() = WindowsPath(tuple(), "", "")

function WindowsPath(segments::Tuple; root="", drive="", separator="\\")
    return WindowsPath(segments, root, drive, separator)
end

function Base.tryparse(::Type{WindowsPath}, str::AbstractString)
    isempty(str) && WindowsPath(tuple("."), "", "")

    if startswith(str, "\\\\?\\")
        @debug("The \\\\?\\ prefix is currently not supported.")
        return nothing
    end

    str = replace(str, POSIX_PATH_SEPARATOR => WIN_PATH_SEPARATOR)

    if startswith(str, "\\\\")
        @debug("UNC paths are currently not supported.")
        return nothing
    elseif startswith(str, "\\")
        tokenized = split(str, WIN_PATH_SEPARATOR)

        return WindowsPath(tuple(String.(tokenized[2:end])...), WIN_PATH_SEPARATOR, "")
    elseif occursin(":", str)
        l_drive, l_path = _win_splitdrive(str)

        tokenized = split(l_path, WIN_PATH_SEPARATOR)

        l_root = isempty(tokenized[1]) ? WIN_PATH_SEPARATOR : ""

        if isempty(tokenized[1])
            tokenized = tokenized[2:end]
        end

        if !isempty(l_drive) || !isempty(l_root)
            tokenized = tuple(tokenized...)
        end

        return WindowsPath(tuple(String.(tokenized)...), l_root, l_drive)
    else
        tokenized = split(str, WIN_PATH_SEPARATOR)

        return WindowsPath(tuple(String.(tokenized)...), "", "")
    end
end

function Base.:(==)(a::WindowsPath, b::WindowsPath)
    return lowercase.(a.segments) == lowercase.(b.segments) &&
        lowercase(a.root) == lowercase(b.root) &&
        lowercase(a.drive) == lowercase(b.drive)
end

function Base.show(io::IO, fp::WindowsPath)
    print(io, "p\"")
    if isabsolute(fp)
        print(io, replace(fp.anchor, "\\" => "/"))
    end
    print(io, join(fp.segments, "/"))
    print(io, "\"")
end

isabsolute(fp::WindowsPath) = (!isempty(fp.drive) || !isempty(fp.root))
