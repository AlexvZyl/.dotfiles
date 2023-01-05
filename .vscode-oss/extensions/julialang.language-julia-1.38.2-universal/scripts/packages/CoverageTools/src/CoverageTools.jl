module CoverageTools

export process_folder, process_file
export clean_folder, clean_file
export process_cov, amend_coverage_from_src!
export get_summary
export analyze_malloc, merge_coverage_counts
export FileCoverage

# The unit for line counts. Counts can be >= 0 or nothing, where
# the nothing means it doesn't make sense to have a count for this
# line (e.g. a comment), but 0 means it could have run but didn't.
const CovCount = Union{Nothing,Int}

"""
FileCoverage

Represents coverage info about a file, including the filename, the source
code itself, and a `Vector` of run counts for each line. If the
line was expected to be run the count will be an `Int` >= 0. Other lines
such as comments will have a count of `nothing`.
"""
mutable struct FileCoverage
    filename::AbstractString
    source::AbstractString
    coverage::Vector{CovCount}
end

"""
    get_summary(fcs)

Summarize results from a single `FileCoverage` instance or a `Vector` of
them, returning a 2-tuple with the covered lines and total lines.
"""
function get_summary end

function get_summary(fc::FileCoverage)
    if !isempty(fc.coverage)
        cov_lines = sum(x -> x !== nothing && x > 0, fc.coverage)
        tot_lines = sum(x -> x !== nothing, fc.coverage)
    else
        cov_lines = 0
        tot_lines = 0
    end
    return cov_lines, tot_lines
end

function get_summary(fcs::Vector{FileCoverage})
    cov_lines, tot_lines = 0, 0
    for fc in fcs
        c, t = get_summary(fc)
        cov_lines += c
        tot_lines += t
    end
    return cov_lines, tot_lines
end

"""
    merge_coverage_counts(a1::Vector{CovCount}, a2::Vector{CovCount}) -> Vector{CovCount}

Given two vectors of line coverage counts, sum together the results,
preseving null counts if both are null.
"""
function merge_coverage_counts(a1::Vector{CovCount},
                               a2::Vector{CovCount})
    n = max(length(a1), length(a2))
    a = Vector{CovCount}(undef, n)
    for i in 1:n
        a1v = isassigned(a1, i) ? a1[i] : nothing
        a2v = isassigned(a2, i) ? a2[i] : nothing
        a[i] = a1v === nothing ? a2v :
               a2v === nothing ? a1v :
               a1v + a2v
    end
    return a
end

"""
    merge_coverage_counts(as::Vector{CovCount}...) -> Vector{CovCount}

Given vectors of line coverage counts, sum together the results,
preseving null counts if both are null.
"""
function merge_coverage_counts(as::Vector{FileCoverage}...)
    source_files = FileCoverage[]
    seen = Dict{AbstractString, FileCoverage}()
    for a in as
        for a in a
            if a.filename in keys(seen)
                coverage = seen[a.filename]
                if isempty(coverage.source)
                    coverage.source = a.source
                end
                coverage.coverage = merge_coverage_counts(coverage.coverage, a.coverage)
            else
                coverage = FileCoverage(a.filename, a.source, a.coverage)
                seen[a.filename] = coverage
                push!(source_files, coverage)
            end
        end
    end
    return source_files
end

"""
    process_cov(filename, folder) -> Vector{CovCount}

Given a filename for a Julia source file, produce an array of
line coverage counts by reading in all matching .{pid}.cov files.
"""
function process_cov(filename, folder)
    # Find all coverage files in the folder that match the file we
    # are currently working on
    files = readdir(folder)
    files = map!(file -> joinpath(folder, file), files, files)
    filter!(file -> occursin(filename, file) && occursin(".cov", file), files)
    # If there are no coverage files...
    if isempty(files)
        # ... we will assume that, as there is a .jl file, it was
        # just never run. We'll report the coverage as all null.
        @info """CoverageTools.process_cov: Coverage file(s) for $filename do not exist.
                                          Assuming file has no coverage."""
        nlines = countlines(filename)
        return fill!(Vector{CovCount}(undef, nlines), nothing)
    end
    # Keep track of the combined coverage
    full_coverage = CovCount[]
    for file in files
        @info "CoverageTools.process_cov: processing $file"
        coverage = CovCount[]
        for line in eachline(file)
            # Columns 1:9 contain the coverage count
            cov_segment = line[1:9]
            # If coverage is NA, there will be a dash
            push!(coverage, cov_segment[9] == '-' ? nothing : parse(Int, cov_segment))
        end
        full_coverage = merge_coverage_counts(full_coverage, coverage)
    end
    return full_coverage
end

"""
    amend_coverage_from_src!(coverage::Vector{CovCount}, srcname)
    amend_coverage_from_src!(fc::FileCoverage)

The code coverage functionality in Julia only reports lines that have been
compiled. Unused functions (or discarded lines) therefore may be incorrectly
recorded as `nothing` but should instead be 0.
This function takes an existing result and updates the coverage vector
in-place to mark source lines that may be inside a function.
"""
amend_coverage_from_src!(coverage::Vector{CovCount}, srcname) = amend_coverage_from_src!(FileCoverage(srcname, read(srcname, String), coverage))
function amend_coverage_from_src!(fc::FileCoverage)
    # The code coverage results produced by Julia itself report some
    # lines as "null" (cannot be run), when they could have been run
    # but were never compiled (thus should be 0).
    # We use the Julia parser to augment the coverage results by identifying this code.
    #
    # To make sure things stay in sync, parse the file position
    # corresponding to each new line
    content, coverage = fc.source, fc.coverage
    linepos = Int[]
    let io = IOBuffer(content)
        while !eof(io)
            push!(linepos, position(io))
            readline(io)
        end
        push!(linepos, position(io))
    end
    pos = 1
    while pos <= length(content)
        # We now want to convert the one-based offset pos into a line
        # number, by looking it up in linepos. But linepos[i] contains the
        # zero-based offset of the start of line i; since pos is
        # one-based, we have to subtract 1 before searching through
        # linepos. The result is a one-based line number; since we use
        # that later on to shift other one-based line numbers, we must
        # subtract 1 from the offset to make it zero-based.
        lineoffset = searchsortedlast(linepos, pos - 1) - 1

        # now we can parse the next chunk of the input
        ast, pos = Meta.parse(content, pos; raise=false)
        isa(ast, Expr) || continue
        if ast.head ∈ (:error, :incomplete)
            line = searchsortedlast(linepos, pos - 1)
            throw(Base.Meta.ParseError("parsing error in $(fc.filename):$line: $(ast.args[1])"))
        end
        flines = function_body_lines(ast, coverage, lineoffset)
        if !isempty(flines)
            flines .+= lineoffset
            for l in flines
                (l > length(coverage)) && resize!(coverage, l)
                if coverage[l] === nothing
                    coverage[l] = 0
                end
            end
        end
    end

    # check for excluded lines
    let io = IOBuffer(content)
        excluded = false
        for (l, line) in enumerate(eachline(io))
            # check for start/stop markers
            if occursin("COV_EXCL_START", line)
                excluded = true
            elseif occursin("COV_EXCL_STOP", line)
                excluded = false
            end

            # also check for line markers
            if excluded || occursin("COV_EXCL_LINE", line)
                coverage[l] = nothing
            end
        end
    end

    nothing
end

"""
    process_file(filename[, folder]) -> FileCoverage

Given a .jl file and its containing folder, produce a corresponding
`FileCoverage` instance from the source and matching coverage files. If the
folder is not given it is extracted from the filename.
"""
function process_file end

function process_file(filename, folder)
    @info "CoverageTools.process_file: Detecting coverage for $filename"
    coverage = process_cov(filename, folder)
    fc = FileCoverage(filename, read(filename, String), coverage)
    if get(ENV, "DISABLE_AMEND_COVERAGE_FROM_SRC", "no") != "yes"
        amend_coverage_from_src!(fc)
    end
    return fc
end
process_file(filename) = process_file(filename, splitdir(filename)[1])

"""
    process_folder(folder="src") -> Vector{FileCoverage}

Process the contents of a folder of Julia source code to collect coverage
statistics for all the files contained within. Will recursively traverse
child folders. Default folder is "src", which is useful for the primary case
where CoverageTools is called from the root directory of a package.
"""
function process_folder(folder="src")
    @info "CoverageTools.process_folder: Searching $folder for .jl files..."
    source_files = FileCoverage[]
    files = readdir(folder)
    for file in files
        fullfile = joinpath(folder, file)
        if isfile(fullfile)
            # Is it a Julia file?
            if splitext(fullfile)[2] == ".jl"
                push!(source_files, process_file(fullfile, folder))
            else
                @debug "CoverageTools.process_folder: Skipping $file, not a .jl file"
            end
        elseif isdir(fullfile)
            # If it is a folder, recursively traverse
            append!(source_files, process_folder(fullfile))
        end
    end
    return source_files
end

# matches julia coverage files with and without the PID
iscovfile(filename) = occursin(r"\.jl\.?[0-9]*\.cov$", filename)
# matches a coverage file for the given sourcefile. They can be full paths
# with directories, but the directories must match
function iscovfile(filename, sourcefile)
    startswith(filename, sourcefile) || return false
    occursin(r"\.jl\.?[0-9]*\.cov$", filename)
end

"""
    clean_folder(folder::AbstractString)

Cleans up all the `.cov` files in the given directory and subdirectories.
Unlike `process_folder` this does not include a default value
for the root folder, requiring the calling code to be more explicit about
which files will be deleted.
"""
function clean_folder(folder::AbstractString)
    files = readdir(folder)
    for file in files
        fullfile = joinpath(folder, file)
        if isfile(fullfile) && iscovfile(file)
            # we have ourselves a coverage file. eliminate it
            @info "Removing $fullfile"
            rm(fullfile)
        elseif isdir(fullfile)
            clean_folder(fullfile)
        end
    end
    nothing
end

"""
    clean_file(filename::AbstractString)

Cleans up all `.cov` files associated with a given source file. This only
looks in the directory of the given file, i.e. the `.cov` files should be
siblings of the source file.
"""
function clean_file(filename::AbstractString)
    folder = splitdir(filename)[1]
    files = readdir(folder)
    for file in files
        fullfile = joinpath(folder, file)
        if isfile(fullfile) && iscovfile(fullfile, filename)
            @info("Removing $(fullfile)")
            rm(fullfile)
        end
    end
end

include("lcov.jl")
include("memalloc.jl")
include("parser.jl")

end # module
