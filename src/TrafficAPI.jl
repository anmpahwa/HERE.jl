using Dates
include("Network.jl")

"""
    flow(;apikey, bbox, s=1.0, m=1/60)

Returns real-time vehicle speed in every s seconds for m minutes in a bounding box using HERE Traffic API. 

# Arguments
apikey::String   : API key to access HERE
bbox::String     : Bounding box defined as `"lat₁,long₁;lat₂,long₂"`
s::Float64=1.0   : gap between every API call
m::Float64=1/60  : time-period of analysis

For more information visit: https://developer.here.com/documentation/traffic/dev_guide/topics/guide.html

Example request: https://developer.here.com/documentation/traffic/dev_guide/topics_v6.1/example-flow-bounding-box.html
"""
function flow(;apikey, bbox, s=1.0, m=1/60)
    # Create request url
    baseurl = "https://traffic.ls.hereapi.com"
    path = "traffic/6.2"
    resource = "flow.xml"
    url = "$baseurl/$path/$resource?apiKey=$apikey&bbox=$bbox&responseattributes=shape"

    # Fetch network
    df = network(apikey=apikey, bbox=bbox)

    # Fetch real-time speeds
    t = 1
    while t ≤ m * 60
        Tₒ = Dates.format(now(), "HH:MM:SS:sss")
        df[!, "rts @$Tₒ"] = zeros(nrow(df))
        r = HTTP.request(:GET, url)
        f = parsexml(String(r.body))
        rootnode = root(f)
        k = 1
        for node in iterate(rootnode)
            if nodename(node) == "FI"
                childnode = lastelement(node)
                v = parse(Float64, childnode["SU"])
                df[k, "rts @$Tₒ"] = v
                k += 1
            end
        end
        t += s
        sleep(s)
    end

    return df
end