using EzXML

function Base.iterate(node::EzXML.Node) 
    v = [node]
    t = EzXML.Node[]
    while !isempty(v)
        parentnode = pop!(v)
        for childnode in eachelement(parentnode)
            push!(v, childnode)
            push!(t, childnode)
        end
    end
    return t
end
