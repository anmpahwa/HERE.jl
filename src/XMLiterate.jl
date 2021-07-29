using EzXML

function Base.iterate(node::EzXML.Node) 
    v = [node]
    t = EzXML.Node[]
    while !isempty(v)
        parent = pop!(v)
        for child in eachelement(parent)
            push!(v, child)
            push!(t, child)
        end
    end
    return t
end
