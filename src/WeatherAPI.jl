using HTTP
using DataFrames

"""
    weather(; apikey, loc, units=:metric)

Returns weather observation for the place identifed with loc keyword.
This loc keyword can be a tuple with lat and long, zipcode, or name of the place.
"""
function weather(;apikey, loc, units=:metric)
    # Request
    baseurl = "https://weather.cc.api.here.com"
    path = "weather/1.0"
    resource = "report.xml"
    if :latitude ∈ keys(loc) && :longitude ∈ keys(loc) 
        place = "latitude=$(loc[:lat])&longitude=$(loc[:long])"
    elseif :zipcode ∈ keys(loc)
        place = "zipcode=$(loc[:zipcode])"
    elseif :name ∈ keys(loc)
        place = "name=$(loc[:name])"
    else
        place = ""
    end
    url = "$baseurl/$path/$resource?apiKey=$apikey&product=$product&$place&metric=$(units==:metric)"
    r = HTTP.request(:GET, url)
    f = parsexml(String(r.body))
    rootnode = root(f)
    
    # Create a blank dataframe
    df = DataFrame(sid = Int64[], latitude = Float64[], longitude = Float64[])
    for node in iterate(rootnode)
        if nodename(node) == "observation"
            for childnode in iterate(node) df[!, nodename(childnode)] = [] end
            break
        end
    end

    # Fill the dataframe
    for node in iterate(rootnode)
        if nodename(node) == "location"
            push!(df[!, :sid], length(df[!, :sid]) + 1)
            push!(df[!, :latitude], parse(Float64, node["latitude"]))
            push!(df[!, :longitude], parse(Float64, node["longitude"]))
        end
        if nodename(node) == "observation"
            for childnode in iterate(node) push!(df[!, nodename(childnode)], nodecontent(childnode)) end
        end
    end

    return df
end