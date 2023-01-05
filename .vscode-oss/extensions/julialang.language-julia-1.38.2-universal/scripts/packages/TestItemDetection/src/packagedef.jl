include("vendored_code.jl")

function find_test_items_detail!(node, testitems, errors)
    node isa EXPR || return

    if node.head == :macrocall && length(node.args)>0 && CSTParser.valof(node.args[1]) == "@testitem"
        pos = 1 + get_file_loc(node)[2]
        range = pos:pos+node.span-1

        # filter out line nodes
        child_nodes = filter(i->!(isa(i, EXPR) && i.head==:NOTHING && i.args===nothing), node.args)

        # Check for various syntax errors
        if length(child_nodes)==1
            push!(errors, (error="Your @testitem is missing a name and code block.", range=range))
            return
        elseif length(child_nodes)>1 && !(child_nodes[2] isa EXPR && child_nodes[2].head==:STRING)
            push!(errors, (error="Your @testitem must have a first argument that is of type String for the name.", range=range))
            return
        elseif length(child_nodes)==2
            push!(errors, (error="Your @testitem is missing a code block argument.", range=range))
            return
        elseif !(child_nodes[end] isa EXPR && child_nodes[end].head==:block)
            push!(errors, (error="The final argument of a @testitem must be a begin end block.", range=range))
            return
        else
            option_tags = nothing
            option_default_imports = nothing

            # Now check our keyword args
            for i in child_nodes[3:end-1]
                if !(i isa EXPR && i.head isa EXPR && i.head.head==:OPERATOR && CSTParser.valof(i.head)=="=")
                    push!(errors, (error="The arguments to a @testitem must be in keyword format.", range=range))
                    return
                elseif !(length(i.args)==2)
                    error("This code path should not be possible.")
                elseif CSTParser.valof(i.args[1])=="tags"
                    if option_tags!==nothing
                        push!(errors, (error="The keyword argument tags cannot be specified more than once.", range=range))
                        return
                    end

                    if !(i.args[2].head == :vect)
                        push!(errors, (error="The keyword argument tags only accepts a vector of symbols.", range=range))
                        return
                    end

                    option_tags = Symbol[]

                    for j in i.args[2].args
                        if !(j isa EXPR && j.head==:quotenode && length(j.args)==1 && j.args[1] isa EXPR && j.args[1].head==:IDENTIFIER)
                            push!(errors, (error="The keyword argument tags only accepts a vector of symbols.", range=range))
                            return
                        end

                        push!(option_tags, Symbol(CSTParser.valof(j.args[1])))
                    end
                elseif CSTParser.valof(i.args[1])=="default_imports"
                    if option_default_imports!==nothing
                        push!(errors, (error="The keyword argument default_imports cannot be specified more than once.", range=range))
                        return
                    end

                    if !(CSTParser.valof(i.args[2]) in ("true", "false"))
                        push!(errors, (error="The keyword argument default_imports only accepts bool values.", range=range))
                        return
                    end

                    option_default_imports = parse(Bool, CSTParser.valof(i.args[2]))
                else
                    push!(errors, (error="Unknown keyword argument.", range=range))
                    return
                end
            end

            if option_tags===nothing
                option_tags = Symbol[]
            end

            if option_default_imports===nothing
                option_default_imports = true
            end

            # TODO + 1 here is from the space before the begin end block. We might have to detect that,
            # not sure whether that is always assigned to the begin end block EXPR
            code_pos = get_file_loc(child_nodes[end])[2] + 1 + length("begin")

            code_range = code_pos:code_pos+child_nodes[end].span - 1 - length("begin") - length("end")

            push!(testitems, (name=CSTParser.valof(node.args[3]), range=range, code_range=code_range, option_default_imports=option_default_imports, option_tags=option_tags))
        end
    elseif node.head == :module && length(node.args)>=3 && node.args[3] isa EXPR && node.args[3].head==:block
        for i in node.args[3].args
            find_test_items_detail!(i, testitems, errors)
        end
    end
end
