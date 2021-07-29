using HTTP
using DataFrames
using Dates
include("XMLiterate.jl")

"""
    fetch(s, m, bbox)
Fetch vehicle speed in every s seconds for m minutes in a bounding box - bbox, defined by latitudes and longitudes 
as "lat₁,long₁;lat₂,long₂" using the Traffic API - HERE and write it into a CSV.
\nFor more information visit: https://developer.here.com/documentation/traffic/dev_guide/topics/guide.html
\nExample request: https://developer.here.com/documentation/traffic/dev_guide/topics_v6.1/example-flow-bounding-box.html
"""
function flow(;apikey, bbox, s=1, m=1/60)
    baseurl = "https://traffic.ls.hereapi.com"
    path = "traffic/6.2"
    resource = "flow.xml"
    url = "$baseurl/$path/$resource?apiKey=$apikey&bbox=$bbox&responseattributes=shape"
    df = DataFrame(LID = Int64[], NAME = String[], LENGTH = Float64[], FFS = Float64[], SHAPE = String[])

    # Building network
    r = HTTP.request(:GET, url)
    f = parsexml(String(r.body))
    rootNode = root(f)
    for node in iterate(rootNode)
        if nodename(node) == "FI"
            shape = ""
            for child in eachelement(node)
                # Fetching name and length
                if child == firstelement(node)
                    push!(df[!, :LID], length(df[!, :LID]) + 1)
                    push!(df[!, :NAME], child["DE"])
                    push!(df[!, :LENGTH], parse(Float64, child["LE"]))
                # Fetching free flow speed 
                elseif child == lastelement(node)
                    push!(df[!, :FFS], parse(Float64, child["FF"]))
                # Fetching link shape (Note: Link shape is of the same format as the bbox)
                else
                    shape *= replace(nodecontent(child), " " => ";")
                end
            end
            push!(df[!, :SHAPE], shape)
        end
    end

    # Fetching real-time speeds
    t = 1
    while t ≤ m * 60
        Tₒ = Dates.format(now(), "HH:MM:SS:sss")
        df[!, "RTS @$Tₒ"] = zeros(nrow(df))
        r = HTTP.request(:GET, url)
        f = parsexml(String(r.body))
        rootNode = root(f)
        k = 1
        for node in iterate(rootNode)
            if nodename(node) == "FI"
                child = lastelement(node)
                v = parse(Float64, child["SU"])
                df[k, "RTS @$Tₒ"] = v
                k += 1
            end
        end
        t += s
        sleep(s)
    end
    return df
end
#SCAG = "35.809,-115.648;32.718,-119.442"


#= ────────────────────────────────────────────────────────────────────────────────
# Response XML file
-   RWS : A list of Roadway (RW) items
-   RW  : This is the composite item for flow across an entire roadway. A roadway item will be present for each roadway 
          with traffic flow information available.
-   FIS : A list of Flow Item (FI) elements
-   FI  : A single flow item
-   TMC : An ordered collection of TMC (Traffic Message Channel) locations
-   PC  : Point TMC Location Code
-   DE  : Text description of the road
-   QD  : Queuing direction. '+' or '-'. Note this is the opposite of the travel direction in the fully 
          qualified ID, For example for location 107+03021 the QD would be '-'".
-   LE  : Length of the stretch of road. The units are defined in the file header.
-   CF  : Current Flow. This element contains details about speed and Jam Factor information for the given flow item
-   CN  : Confidence, an indication of how the speed was determined. -1.0 road closed. 1.0=100% 0.7-100%. 
          Historical Usually a value between 0.7 and 1.0.
-   FF  : The free flow speed on this stretch of road
-   JF  : The number between 0.0 and 10.0 indicating the expected quality of travel. When there is a road closure, 
          the Jam Factor will be 10. As the number approaches 10.0 the quality of travel is getting worse. -1.0 indicates 
          that a Jam Factor could not be calculated.
-   SP  : Speed (based on UNITS) capped by speed limit
-   SU  : Speed (based on UNITS) not capped by speed limit
-   TY  : Type information for the given Location Referencing container. This may be freely defined string
──────────────────────────────────────────────────────────────────────────────── =#


#= ────────────────────────────────────────────────────────────────────────────────
# TODO: 
1. Add other bounding features.
2. Add metadata to the DataFrame
3. Add real time computation
4. Add progress bar
5. Only return data frame without link shape
──────────────────────────────────────────────────────────────────────────────── =#