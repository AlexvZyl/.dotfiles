const NamedVar = Union{Symbol,GlobalRef}

## Phase 1: direct links

# There are 3 types of entities to track: ssavalues (line/statement numbers), slots, and named objects.
# Each entity can have a number of "predecessors" (forward edges), which can be any combination of these
# three entity types. Likewise, each entity can have a number of "successors" (backward edges), also any
# combination of these entity types.
struct Links
    ssas::Vector{Int}
    slots::Vector{Int}
    names::Vector{NamedVar}
end
Links() = Links(Int[], Int[], NamedVar[])

function Base.show(io::IO, l::Links)
    print(io, "ssas: ", showempty(l.ssas),
              ", slots: ", showempty(l.slots),
              ", names: ")
    print(IOContext(io, :typeinfo=>Vector{NamedVar}), showempty(l.names))
    print(io, ';')
end

struct CodeLinks
    ssapreds::Vector{Links}
    ssasuccs::Vector{Links}
    slotpreds::Vector{Links}
    slotsuccs::Vector{Links}
    slotassigns::Vector{Vector{Int}}
    namepreds::Dict{NamedVar,Links}
    namesuccs::Dict{NamedVar,Links}
    nameassigns::Dict{NamedVar,Vector{Int}}
end
function CodeLinks(nlines::Int, nslots::Int)
    makelinks(n) = [Links() for _ = 1:n]

    return CodeLinks(makelinks(nlines),
                     makelinks(nlines),
                     makelinks(nslots),
                     makelinks(nslots),
                     [Int[] for _ = 1:nslots],
                     Dict{NamedVar,Links}(),
                     Dict{NamedVar,Links}(),
                     Dict{NamedVar,Vector{Int}}())
end
function CodeLinks(src::CodeInfo)
    cl = CodeLinks(length(src.code), length(src.slotnames))
    direct_links!(cl, src)
end

function Base.show(io::IO, cl::CodeLinks)
    print(io, "CodeLinks:")
    print_slots(io, cl)
    print_names(io, cl)
    nstmts = length(cl.ssapreds)
    nd = ndigits(nstmts)
    print(io, "\nCode:")
    for i = 1:nstmts
        print(io, '\n', lpad(i, nd), " preds: ")
        show(io, cl.ssapreds[i])
        print(io, '\n', lpad(i, nd), " succs: ")
        show(io, cl.ssasuccs[i])
    end
end

function print_slots(io::IO, cl::CodeLinks)
    nslots = length(cl.slotpreds)
    nd = ndigits(nslots)
    for i = 1:nslots
        print(io, "\nslot ", lpad(i, nd), ':')
        print(io, "\n  preds: ")
        show(io, cl.slotpreds[i])
        print(io, "\n  succs: ")
        show(io, cl.slotsuccs[i])
        print(io, "\n  assign @: ")
        show(io, cl.slotassigns[i])
    end
end

function print_names(io::IO, cl::CodeLinks)
    ukeys = namedkeys(cl)
    for key in ukeys
        print(io, '\n', key, ':')
        if haskey(cl.namepreds, key)
            print(io, "\n  preds: ")
            show(io, cl.namepreds[key])
        end
        if haskey(cl.namesuccs, key)
            print(io, "\n  succs: ")
            show(io, cl.namesuccs[key])
        end
        if haskey(cl.nameassigns, key)
            print(io, "\n  assign @: ")
            show(io, cl.nameassigns[key])
        end
    end
end

const preprinter_sentinel = isdefined(Base.IRShow, :statementidx_lineinfo_printer) ? 0 : typemin(Int32)

if isdefined(Base.IRShow, :show_ir_stmt)
    function print_with_code(preprint, postprint, io::IO, src::CodeInfo)
        src = copy(src)
        JuliaInterpreter.replace_coretypes!(src; rev=true)
        if isdefined(JuliaInterpreter, :reverse_lookup_globalref!)
            JuliaInterpreter.reverse_lookup_globalref!(src.code)
        end
        io = IOContext(io, :displaysize=>displaysize(io))
        used = BitSet()
        cfg = Core.Compiler.compute_basic_blocks(src.code)
        for stmt in src.code
            Core.Compiler.scan_ssa_use!(push!, used, stmt)
        end
        line_info_preprinter = Base.IRShow.lineinfo_disabled
        line_info_postprinter = Base.IRShow.default_expr_type_printer
        preprint(io)
        bb_idx_prev = bb_idx = 1
        for idx = 1:length(src.code)
            preprint(io, idx)
            bb_idx = Base.IRShow.show_ir_stmt(io, src, idx, line_info_preprinter, line_info_postprinter, used, cfg, bb_idx)
            postprint(io, idx, bb_idx != bb_idx_prev)
            bb_idx_prev = bb_idx
        end
        max_bb_idx_size = ndigits(length(cfg.blocks))
        line_info_preprinter(io, " "^(max_bb_idx_size + 2), preprinter_sentinel)
        postprint(io)
        return nothing
    end
else
    function print_with_code(preprint, postprint, io::IO, src::CodeInfo)
        println(io, "No IR statement printer available on this version of Julia, just aligning statements.")
        preprint(io)
        for idx = 1:length(src.code)
            preprint(io, idx)
            print(io, src.code[idx])
            println(io)
            postprint(io, idx, false)
        end
        postprint(io)
    end
end

"""
    print_with_code(io, src::CodeInfo, cl::CodeLinks)

Interweave display of code and links.

!!! compat Julia 1.6
    This function produces dummy output if suitable support is missing in your version of Julia.
"""
function print_with_code(io::IO, src::CodeInfo, cl::CodeLinks)
    function preprint(io::IO)
        print(io, "Slots:")
        print_slots(io, cl)
        print(io, "\nNames:")
        print_names(io, cl)
        println(io)
    end
    preprint(::IO, ::Int) = nothing
    postprint(::IO) = nothing
    postprint(io::IO, idx::Int, bbchanged::Bool) = postprint_linelinks(io, idx, src, cl, bbchanged)

    print_with_code(preprint, postprint, io, src)
end

function postprint_linelinks(io::IO, idx::Int, src::CodeInfo, cl::CodeLinks, bbchanged::Bool)
    printstyled(io, bbchanged ? " " : "│", color=:light_black)
    printstyled(io, "             # ", color=:yellow)
    stmt = src.code[idx]
    if isexpr(stmt, :(=))
        lhs = stmt.args[1]
        if @issslotnum(lhs)
            # id = lhs.id
            # preds, succs = cl.slotpreds[id], cl.slotsuccs[id]
            printstyled(io, "see slot ", lhs.id, '\n', color=:yellow)
        else
            # preds, succs = cl.namepreds[lhs], cl.namesuccs[lhs]
            printstyled(io, "see name ", lhs, '\n', color=:yellow)
        end
    else
        preds, succs = cl.ssapreds[idx], cl.ssasuccs[idx]
        printstyled(io, "preds: ", preds, " succs: ", succs, '\n', color=:yellow)
    end
    return nothing
end


function namedkeys(cl::CodeLinks)
    ukeys = Set{NamedVar}()
    for c in (cl.namepreds, cl.namesuccs, cl.nameassigns)
        for k in keys(c)
            push!(ukeys, k)
        end
    end
    return ukeys
end

function direct_links!(cl::CodeLinks, src::CodeInfo)
    # Utility for when a stmt itself contains a CodeInfo
    function add_inner!(cl::CodeLinks, icl::CodeLinks, idx)
        for (name, _) in icl.nameassigns
            assigns = get(cl.nameassigns, name, nothing)
            if assigns === nothing
                cl.nameassigns[name] = assigns = Int[]
            end
            push!(assigns, idx)
        end
        for (name, _) in icl.namesuccs
            succs = get(cl.namesuccs, name, nothing)
            if succs === nothing
                cl.namesuccs[name] = succs = Links()
            end
            push!(succs.ssas, idx)
        end
    end

    P = Pair{Union{SSAValue,SlotNumber,NamedVar},Links}

    for (i, stmt) in enumerate(src.code)
        if isexpr(stmt, :thunk) && isa(stmt.args[1], CodeInfo)
            icl = CodeLinks(stmt.args[1])
            add_inner!(cl, icl, i)
            continue
        elseif isa(stmt, Expr) && stmt.head ∈ trackedheads
            if stmt.head === :method && length(stmt.args) === 3 && isa(stmt.args[3], CodeInfo)
                icl = CodeLinks(stmt.args[3])
                add_inner!(cl, icl, i)
            end
            name = stmt.args[1]
            if isa(name, Symbol)
                assign = get(cl.nameassigns, name, nothing)
                if assign === nothing
                    cl.nameassigns[name] = assign = Int[]
                end
                push!(assign, i)
                targetstore = get(cl.namepreds, name, nothing)
                if targetstore === nothing
                    cl.namepreds[name] = targetstore = Links()
                end
                target = P(name, targetstore)
                add_links!(target, stmt, cl)
            end
            rhs = stmt
            target = P(SSAValue(i), cl.ssapreds[i])
        elseif isexpr(stmt, :(=))
            # An assignment
            stmt = stmt::Expr
            lhs, rhs = stmt.args[1], stmt.args[2]
            if @issslotnum(lhs)
                lhs = lhs::AnySlotNumber
                id = lhs.id
                target = P(SlotNumber(id), cl.slotpreds[id])
                push!(cl.slotassigns[id], i)
            elseif isa(lhs, NamedVar)
                targetstore = get(cl.namepreds, lhs, nothing)
                if targetstore === nothing
                    cl.namepreds[lhs] = targetstore = Links()
                end
                target = P(lhs, targetstore)
                assign = get(cl.nameassigns, lhs, nothing)
                if assign === nothing
                    cl.nameassigns[lhs] = assign = Int[]
                end
                push!(assign, i)
            else
                error("lhs ", lhs, " not recognized")
            end
        else
            rhs = stmt
            target = P(SSAValue(i), cl.ssapreds[i])
        end
        add_links!(target, rhs, cl)
    end
    return cl
end

function add_links!(target::Pair{Union{SSAValue,SlotNumber,NamedVar},Links}, @nospecialize(stmt), cl::CodeLinks)
    _targetid, targetstore = target
    targetid = _targetid::Union{SSAValue,SlotNumber,NamedVar}
    # Adds bidirectional edges
    if @isssa(stmt)
        stmt = stmt::AnySSAValue
        push!(targetstore, SSAValue(stmt.id))    # forward edge
        push!(cl.ssasuccs[stmt.id], targetid)    # backward edge
    elseif @issslotnum(stmt)
        stmt = stmt::AnySlotNumber
        push!(targetstore, SlotNumber(stmt.id))
        push!(cl.slotsuccs[stmt.id], targetid)
    elseif isa(stmt, Symbol) || isa(stmt, GlobalRef)   # NamedVar
        push!(targetstore, stmt)
        namestore = get(cl.namesuccs, stmt, nothing)
        if namestore === nothing
            cl.namesuccs[stmt] = namestore = Links()
        end
        push!(namestore, targetid)
    elseif isa(stmt, Expr) && stmt.head !== :copyast
        stmt = stmt::Expr
        arng = 1:length(stmt.args)
        if stmt.head === :call
            f = stmt.args[1]
            if !@isssa(f) && !@issslotnum(f)
                # Avoid putting named callees on the namestore
                arng = 2:length(stmt.args)
            end
        end
        for i in arng
            add_links!(target, stmt.args[i], cl)
        end
    elseif is_GotoIfNot(stmt)
        add_links!(target, (stmt::Core.GotoIfNot).cond, cl)
    elseif is_ReturnNode(stmt)
        add_links!(target, (stmt::Core.ReturnNode).val, cl)
    end
    return nothing
end

function Base.push!(l::Links, id)
    if isa(id, SSAValue)
        k = id.id
        k ∉ l.ssas && push!(l.ssas, k)
    elseif isa(id, SlotNumber)
        k = id.id
        k ∉ l.slots && push!(l.slots, k)
    else
        id = id::NamedVar
        id ∉ l.names && push!(l.names, id)
    end
    return id
end

## Phase 2: replacing slot-links with statement-links (and adding name-links to statement-links)

# Now that we know the full set of dependencies, we can safely replace references to names
# by references to the relevant line numbers.

"""
`Variable` holds information about named variables.
Unlike SSAValues, a single Variable can be assigned from multiple code locations.

If `v` is a `Variable`, then
- `v.assigned` is a list of statement numbers on which it is assigned
- `v.preds` is the set of statement numbers upon which this assignment depends
- `v.succs` is the set of statement numbers which make use of this variable

`preds` and `succs` are short for "predecessors" and "successors," respectively.
These are meant in the sense of execution order, not statement number; depending on control-flow,
a variable may have entries in `preds` that are larger than the smallest entry in `assigned`.
"""
struct Variable
    assigned::Vector{Int}
    preds::Vector{Int}
    succs::Vector{Int}
end
Variable() = Variable(Int[], Int[], Int[])

function Base.show(io::IO, v::Variable)
    print(io, "assigned on ", showempty(v.assigned))
    print(io, ", depends on ", showempty(v.preds))
    print(io, ", and used by ", showempty(v.succs))
end

# This will be documented below at the "user-level" constructor.
# preds[i] is the list of predecessors for the `i`th statement in the CodeInfo
# succs[i] is the list of successors for the `i`th statement in the CodeInfo
# byname[name] summarizes this CodeInfo's dependence on Variable `name`.
struct CodeEdges
    preds::Vector{Vector{Int}}
    succs::Vector{Vector{Int}}
    byname::Dict{NamedVar,Variable}
end
CodeEdges(n::Integer) = CodeEdges([Int[] for i = 1:n], [Int[] for i = 1:n], Dict{Union{GlobalRef,Symbol},Variable}())

function Base.show(io::IO, edges::CodeEdges)
    println(io, "CodeEdges:")
    for (name, v) in edges.byname
        print(io, "  ", name, ": ")
        show(io, v)
        println(io)
    end
    n = length(edges.preds)
    nd = ndigits(n)
    for i = 1:n
        println(io, "  statement ", lpad(i, nd), " depends on ", showempty(edges.preds[i]), " and is used by ", showempty(edges.succs[i]))
    end
    return nothing
end


"""
    edges = CodeEdges(src::CodeInfo)

Analyze `src` and determine the chain of dependencies.

- `edges.preds[i]` lists the preceding statements that statement `i` depends on.
- `edges.succs[i]` lists the succeeding statements that depend on statement `i`.
- `edges.byname[v]` returns information about the predecessors, successors, and assignment statements
  for an object `v::$NamedVar`.
"""
function CodeEdges(src::CodeInfo)
    src.inferred && error("supply lowered but not inferred code")
    cl = CodeLinks(src)
    CodeEdges(src, cl)
end

function CodeEdges(src::CodeInfo, cl::CodeLinks)
    # The main task here is to elide the slot-dependencies and convert
    # everything to just ssas & names.

    # Replace/add named intermediates (slot & named-variable references) with statement numbers
    nstmts, nslots = length(src.code), length(src.slotnames)
    marked, slothandled = BitSet(), fill(false, nslots)  # working storage during resolution
    edges = CodeEdges(nstmts)
    emptylink = Links()
    emptylist = Int[]
    for (i, stmt) in enumerate(src.code)
        # Identify line predecents for slots and named variables
        if isexpr(stmt, :(=))
            stmt = stmt::Expr
            lhs = stmt.args[1]
            # Mark predecessors and successors of this line by following ssas & named assignments
            if @issslotnum(lhs)
                lhs = lhs::AnySlotNumber
                # This line assigns a slot. Mark all predecessors.
                id = lhs.id
                linkpreds, linksuccs, listassigns = cl.slotpreds[id], cl.slotsuccs[id], cl.slotassigns[id]
            else
                lhs = lhs::NamedVar
                linkpreds = get(cl.namepreds, lhs, emptylink)
                linksuccs = get(cl.namesuccs, lhs, emptylink)
                listassigns = get(cl.nameassigns, lhs, emptylist)
            end
        else
            linkpreds, linksuccs, listassigns = cl.ssapreds[i], cl.ssasuccs[i], emptylist
        end
        # Assign the predecessors
        # For "named" predecessors, we depend only on their assignments
        empty!(marked)
        fill!(slothandled, false)
        follow_links!(marked, linkpreds, cl.slotpreds, cl.slotassigns, slothandled)
        pushall!(marked, listassigns)
        for key in linkpreds.names
            pushall!(marked, get(cl.nameassigns, key, emptylist))
        end
        delete!(marked, i)
        append!(edges.preds[i], marked)
        # Similarly for successors
        empty!(marked)
        fill!(slothandled, false)
        follow_links!(marked, linksuccs, cl.slotsuccs, cl.slotassigns, slothandled)
        pushall!(marked, listassigns)
        for key in linksuccs.names
            pushall!(marked, get(cl.nameassigns, key, emptylist))
        end
        delete!(marked, i)
        append!(edges.succs[i], marked)
    end
    # Add named variables
    ukeys = namedkeys(cl)
    for key in ukeys
        assigned = get(cl.nameassigns, key, Int[])
        empty!(marked)
        linkpreds = get(cl.namepreds, key, emptylink)
        pushall!(marked, linkpreds.ssas)
        for j in linkpreds.slots
            pushall!(marked, cl.slotassigns[j])
        end
        for key in linkpreds.names
            pushall!(marked, get(cl.nameassigns, key, emptylist))
        end
        preds = append!(Int[], marked)
        empty!(marked)
        linksuccs = get(cl.namesuccs, key, emptylink)
        pushall!(marked, linksuccs.ssas)
        for j in linksuccs.slots
            pushall!(marked, cl.slotassigns[j])
            pushall!(marked, cl.slotsuccs[j].ssas)
        end
        for key in linksuccs.names
            pushall!(marked, get(cl.nameassigns, key, emptylist))
        end
        succs = append!(Int[], marked)
        edges.byname[key] = Variable(assigned, preds, succs)
    end

    return edges
end

# Follow slot links to their non-slot leaves
function follow_links!(marked, l::Links, slotlinks, slotassigns, slothandled)
    pushall!(marked, l.ssas)
    for id in l.slots
        slothandled[id] && continue
        slothandled[id] = true
        pushall!(marked, slotassigns[id])
        follow_links!(marked, slotlinks[id], slotlinks, slotassigns, slothandled)
    end
    return marked
end

"""
    print_with_code(io, src::CodeInfo, edges::CodeEdges)

Interweave display of code and edges.

!!! compat Julia 1.6
    This function produces dummy output if suitable support is missing in your version of Julia.
"""
function print_with_code(io::IO, src::CodeInfo, edges::CodeEdges)
    function preprint(io::IO)
        printstyled(io, "Names:", color=:yellow)
        for (name, var) in edges.byname
            print(io, '\n', name, ": ")
            show(io, var)
        end
        printstyled(io, "\nCode:\n", color=:yellow)
    end
    @static if isdefined(Base.IRShow, :show_ir_stmt)
        preprint(::IO, ::Int) = nothing
    else
        nd = ndigits(length(src.code))
        preprint(io::IO, i::Int) = print(io, lpad(i, nd), "  ")
    end
    postprint(::IO) = nothing
    postprint(io::IO, idx::Int, bbchanged::Bool) = postprint_lineedges(io, idx, edges, bbchanged)

    print_with_code(preprint, postprint, io, src)
end

function postprint_lineedges(io::IO, idx::Int, edges::CodeEdges, bbchanged::Bool)
    printstyled(io, bbchanged ? " " : "│", color=:light_black)
    printstyled(io, "             # ", color=:yellow)
    preds, succs = edges.preds[idx], edges.succs[idx]
    printstyled(io, "preds: ", showempty(preds), ", succs: ", showempty(succs), '\n', color=:yellow)
    return nothing
end

function terminal_preds(i::Int, edges::CodeEdges)
    function terminal_preds!(s, j, edges, covered)
        j ∈ covered && return s
        push!(covered, j)
        preds = edges.preds[j]
        if isempty(preds)
            push!(s, j)
        else
            for p in preds
                terminal_preds!(s, p, edges, covered)
            end
        end
        return s
    end
    s, covered = BitSet(), BitSet()
    push!(covered, i)
    for p in edges.preds[i]
        terminal_preds!(s, p, edges, covered)
    end
    return s
end

"""
    isrequired = lines_required(obj::$NamedVar, src::CodeInfo, edges::CodeEdges)
    isrequired = lines_required(idx::Int,                     src::CodeInfo, edges::CodeEdges)

Determine which lines might need to be executed to evaluate `obj` or the statement indexed by `idx`.
If `isrequired[i]` is `false`, the `i`th statement is *not* required.
In some circumstances all statements marked `true` may be needed, in others control-flow
will end up skipping a subset of such statements, perhaps while repeating others multiple times.

See also [`lines_required!`](@ref) and [`selective_eval!`](@ref).
"""
function lines_required(obj::NamedVar, src::CodeInfo, edges::CodeEdges; kwargs...)
    isrequired = falses(length(edges.preds))
    objs = Set{NamedVar}([obj])
    return lines_required!(isrequired, objs, src, edges; kwargs...)
end

function lines_required(idx::Int, src::CodeInfo, edges::CodeEdges; kwargs...)
    isrequired = falses(length(edges.preds))
    isrequired[idx] = true
    objs = Set{NamedVar}()
    return lines_required!(isrequired, objs, src, edges; kwargs...)
end

"""
    lines_required!(isrequired::AbstractVector{Bool}, src::CodeInfo, edges::CodeEdges;
                    norequire = ())

Like `lines_required`, but where `isrequired[idx]` has already been set to `true` for all statements
that you know you need to evaluate. All other statements should be marked `false` at entry.
On return, the complete set of required statements will be marked `true`.

`norequire` keyword argument specifies statements (represented as iterator of `Int`s) that
should _not_ be marked as a requirement.
For example, use `norequire = LoweredCodeUtils.exclude_named_typedefs(src, edges)` if you're
extracting method signatures and not evaluating new definitions.
"""
function lines_required!(isrequired::AbstractVector{Bool}, src::CodeInfo, edges::CodeEdges; kwargs...)
    objs = Set{NamedVar}()
    return lines_required!(isrequired, objs, src, edges; kwargs...)
end

function exclude_named_typedefs(src::CodeInfo, edges::CodeEdges)
    norequire = BitSet()
    i = 1
    nstmts = length(src.code)
    while i <= nstmts
        stmt = rhs(src.code[i])
        if istypedef(stmt) && !isanonymous_typedef(stmt::Expr)
            r = typedef_range(src, i)
            pushall!(norequire, r)
            i = last(r)+1
        else
            i += 1
        end
    end
    return norequire
end

function lines_required!(isrequired::AbstractVector{Bool}, objs, src::CodeInfo, edges::CodeEdges; norequire = ())
    # Mark any requested objects (their lines of assignment)
    objs = add_requests!(isrequired, objs, edges, norequire)

    # Compute basic blocks, which we'll use to make sure we mark necessary control-flow
    cfg = Core.Compiler.compute_basic_blocks(src.code)  # needed for control-flow analysis

    # We'll mostly use generic graph traversal to discover all the lines we need,
    # but structs are in a bit of a different category (especially on Julia 1.5+).
    # It's easiest to discover these at the beginning.
    typedefs = find_typedefs(src)

    changed = true
    iter = 0
    while changed
        changed = false

        # Handle ssa predecessors
        changed |= add_ssa_preds!(isrequired, src, edges, norequire)

        # Handle named dependencies
        changed |= add_named_dependencies!(isrequired, edges, objs, norequire)

        # Add control-flow
        changed |= add_control_flow!(isrequired, cfg, norequire)

        # So far, everything is generic graph traversal. Now we add some domain-specific information
        changed |= add_typedefs!(isrequired, src, edges, typedefs, norequire)

        iter += 1  # just for diagnostics
    end
    return isrequired
end

function add_requests!(isrequired, objs, edges::CodeEdges, norequire)
    objsnew = Set{NamedVar}()
    for obj in objs
        add_obj!(isrequired, objsnew, obj, edges, norequire)
    end
    return objsnew
end

function add_ssa_preds!(isrequired, src::CodeInfo, edges::CodeEdges, norequire)
    changed = false
    for idx = 1:length(src.code)
        if isrequired[idx]
            changed |= add_preds!(isrequired, idx, edges, norequire)
        end
    end
    return changed
end

function add_named_dependencies!(isrequired, edges::CodeEdges, objs, norequire)
    changed = false
    for (obj, uses) in edges.byname
        obj ∈ objs && continue
        if any(view(isrequired, uses.succs))
            changed |= add_obj!(isrequired, objs, obj, edges, norequire)
        end
    end
    return changed
end

function add_preds!(isrequired, idx, edges::CodeEdges, norequire)
    chngd = false
    preds = edges.preds[idx]
    for p in preds
        isrequired[p] && continue
        p ∈ norequire && continue
        isrequired[p] = true
        chngd = true
        add_preds!(isrequired, p, edges, norequire)
    end
    return chngd
end
function add_succs!(isrequired, idx, edges::CodeEdges, succs, norequire)
    chngd = false
    for p in succs
        isrequired[p] && continue
        p ∈ norequire && continue
        isrequired[p] = true
        chngd = true
        add_succs!(isrequired, p, edges, edges.succs[p], norequire)
    end
    return chngd
end
function add_obj!(isrequired, objs, obj, edges::CodeEdges, norequire)
    chngd = false
    for d in edges.byname[obj].assigned
        d ∈ norequire && continue
        isrequired[d] || add_preds!(isrequired, d, edges, norequire)
        isrequired[d] = true
        chngd = true
    end
    push!(objs, obj)
    return chngd
end

# Add control-flow. For any basic block with an evaluated statement inside it,
# check to see if the block has any successors, and if so mark that block's exit statement.
# Likewise, any preceding blocks should have *their* exit statement marked.
function add_control_flow!(isrequired, cfg, norequire)
    changed = false
    blocks = cfg.blocks
    nblocks = length(blocks)
    for (ibb, bb) in enumerate(blocks)
        r = rng(bb)
        if any(view(isrequired, r))
            if ibb != nblocks
                idxlast = r[end]
                idxlast ∈ norequire && continue
                changed |= !isrequired[idxlast]
                isrequired[idxlast] = true
            end
            for ibbp in bb.preds
                ibbp > 0 || continue # see Core.Compiler.compute_basic_blocks, near comment re :enter
                rpred = rng(blocks[ibbp])
                idxlast = rpred[end]
                idxlast ∈ norequire && continue
                changed |= !isrequired[idxlast]
                isrequired[idxlast] = true
            end
            for ibbs in bb.succs
                ibbs == nblocks && continue
                rpred = rng(blocks[ibbs])
                idxlast = rpred[end]
                idxlast ∈ norequire && continue
                changed |= !isrequired[idxlast]
                isrequired[idxlast] = true
            end
        end
    end
    return changed
end

# Do a traveral of "numbered" predecessors and find statement ranges and names of type definitions
function find_typedefs(src::CodeInfo)
    typedef_blocks, typedef_names = UnitRange{Int}[], Symbol[]
    i = 1
    nstmts = length(src.code)
    while i <= nstmts
        stmt = rhs(src.code[i])
        if istypedef(stmt) && !isanonymous_typedef(stmt::Expr)
            stmt = stmt::Expr
            r = typedef_range(src, i)
            push!(typedef_blocks, r)
            name = stmt.head === :call ? stmt.args[3] : stmt.args[1]
            if isa(name, QuoteNode)
                name = name.value
            end
            isa(name, Symbol) || @show src i r stmt
            push!(typedef_names, name::Symbol)
            i = last(r)+1
        else
            i += 1
        end
    end
    return typedef_blocks, typedef_names
end

# New struct definitions, including their constructors, get spread out over many
# statements. If we're evaluating any of them, it's important to evaluate *all* of them.
function add_typedefs!(isrequired, src::CodeInfo, edges::CodeEdges, (typedef_blocks, typedef_names), norequire)
    changed = false
    stmts = src.code
    idx = 1
    while idx < length(stmts)
        stmt = stmts[idx]
        isrequired[idx] || (idx += 1; continue)
        for (typedefr, typedefn) in zip(typedef_blocks, typedef_names)
            if idx ∈ typedefr
                ireq = view(isrequired, typedefr)
                if !all(ireq)
                    changed = true
                    ireq .= true
                    # Also mark any by-type constructor(s) associated with this typedef
                    var = get(edges.byname, typedefn, nothing)
                    if var !== nothing
                        for s in var.succs
                            s ∈ norequire && continue
                            stmt2 = stmts[s]
                            if isexpr(stmt2, :method) && (fname = (stmt2::Expr).args[1]; fname === false || fname === nothing)
                                isrequired[s] = true
                            end
                        end
                    end
                end
                idx = last(typedefr) + 1
                continue
            end
        end
        # Anonymous functions may not yet include the method definition
        if isanonymous_typedef(stmt)
            i = idx + 1
            while i <= length(stmts) && !ismethod3(stmts[i])
                i += 1
            end
            if i <= length(stmts) && (stmts[i]::Expr).args[1] == false
                tpreds = terminal_preds(i, edges)
                if minimum(tpreds) == idx && i ∉ norequire
                    changed |= !isrequired[i]
                    isrequired[i] = true
                end
            end
        end
        idx += 1
    end
    return changed
end

"""
    selective_eval!([recurse], frame::Frame, isrequired::AbstractVector{Bool}, istoplevel=false)

Execute the code in `frame` in the manner of `JuliaInterpreter.finish_and_return!`,
but skipping all statements that are marked `false` in `isrequired`.
See [`lines_required`](@ref). Upon entry, if needed the caller must ensure that `frame.pc` is
set to the correct statement, typically `findfirst(isrequired)`.
See [`selective_eval_fromstart!`](@ref) to have that performed automatically.

The default value for `recurse` is `JuliaInterpreter.finish_and_return!`.
`isrequired` pertains only to `frame` itself, not any of its callees.

This will return either a `BreakpointRef`, the value obtained from the last executed statement
(if stored to `frame.framedata.ssavlues`), or `nothing`.
Typically, assignment to a variable binding does not result in an ssa store by JuliaInterpreter.
"""
function selective_eval!(@nospecialize(recurse), frame::Frame, isrequired::AbstractVector{Bool}, istoplevel::Bool=false)
    pc = pcexec = pclast = frame.pc
    while isa(pc, Int)
        frame.pc = pc
        te = isrequired[pc]
        pclast = pcexec::Int
        if te
            pcexec = pc = step_expr!(recurse, frame, istoplevel)
        else
            pc = next_or_nothing!(frame)
        end
    end
    isa(pc, BreakpointRef) && return pc
    pcexec = (pcexec === nothing ? pclast : pcexec)::Int
    frame.pc = pcexec
    node = pc_expr(frame)
    is_return(node) && return lookup_return(frame, node)
    isassigned(frame.framedata.ssavalues, pcexec) && return frame.framedata.ssavalues[pcexec]
    return nothing
end
function selective_eval!(frame::Frame, isrequired::AbstractVector{Bool}, istoplevel::Bool=false)
    selective_eval!(finish_and_return!, frame, isrequired, istoplevel)
end

"""
    selective_eval_fromstart!([recurse], frame, isrequired, istoplevel=false)

Like [`selective_eval!`](@ref), except it sets `frame.pc` to the first `true` statement in `isrequired`.
"""
function selective_eval_fromstart!(@nospecialize(recurse), frame, isrequired, istoplevel::Bool=false)
    pc = findfirst(isrequired)
    pc === nothing && return nothing
    frame.pc = pc
    return selective_eval!(recurse, frame, isrequired, istoplevel)
end
function selective_eval_fromstart!(frame::Frame, isrequired::AbstractVector{Bool}, istoplevel::Bool=false)
    selective_eval_fromstart!(finish_and_return!, frame, isrequired, istoplevel)
end

"""
    print_with_code(io, src::CodeInfo, isrequired::AbstractVector{Bool})

Mark each line of code with its requirement status.

!!! compat Julia 1.6
    This function produces dummy output if suitable support is missing in your version of Julia.
"""
function print_with_code(io::IO, src::CodeInfo, isrequired::AbstractVector{Bool})
    nd = ndigits(length(isrequired))
    preprint(::IO) = nothing
    preprint(io::IO, idx::Int) = (c = isrequired[idx]; printstyled(io, lpad(idx, nd), ' ', c ? "t " : "f "; color = c ? :cyan : :plain))
    postprint(::IO) = nothing
    postprint(io::IO, idx::Int, bbchanged::Bool) = nothing

    print_with_code(preprint, postprint, io, src)
end

function print_with_code(io::IO, frame::Frame, obj)
    src = frame.framecode.src
    if isdefined(JuliaInterpreter, :reverse_lookup_globalref!)
        src = copy(src)
        JuliaInterpreter.reverse_lookup_globalref!(src.code)
    end
    print_with_code(io, src, obj)
end
