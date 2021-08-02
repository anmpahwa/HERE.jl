using HTTP
using DataFrames

"""
    network(;apikey, bbox)

Returns shape for every street of the network within the bounding box.

# Arguments
apikey::String   : API key to access HERE
bbox::String     : Bounding box defined as `"lat₁,long₁;lat₂,long₂"`

For more information visit: https://developer.here.com/documentation/traffic/dev_guide/topics/guide.html

Example request: https://developer.here.com/documentation/traffic/dev_guide/topics_v6.1/example-flow-bounding-box.html
"""
function network(;apikey, bbox)
    # Request
    baseurl = "https://traffic.ls.hereapi.com"
    path = "traffic/6.2"
    resource = "flow.xml"
    url = "$baseurl/$path/$resource?apiKey=$apikey&bbox=$bbox&responseattributes=shape"
    r = HTTP.request(:GET, url)
    f = parsexml(String(r.body))
    rootNode = root(f)
    
    # Build network
    df = DataFrame(lid = Int64[], name = String[], length = Float64[], ffs = Float64[], shape = String[])
    for node in iterate(rootNode)
        if nodename(node) == "FI"
            shape = ""
            for childnode in eachelement(node)
                # Fetch name and length
                if childnode == firstelement(node)
                    push!(df[!, :lid], length(df[!, :lid]) + 1)
                    push!(df[!, :name], childnode["DE"])
                    push!(df[!, :length], parse(Float64, childnode["LE"]))
                # Fetch free flow speed 
                elseif childnode == lastelement(node)
                    push!(df[!, :ffs], parse(Float64, childnode["FF"]))
                # Fetch link shape (Note: Link shape is of the same format as the bbox)
                else
                    shape *= replace(nodecontent(childnode), " " => ";")
                end
            end
            push!(df[!, :shape], shape)
        end
    end

    return df
end