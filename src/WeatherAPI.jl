using HTTP
using DataFrames

"""
    weather(; apikey, info, loc, units=:metric)

Returns weather information for the place identifed with loc keyword.

# Arguments
apikey::String  : API key to access HERE
loc::NamedTuple : a named tuple with lat and long, zipcode, or name of the place
info::String    : takes weather observation, weather forecast, or astronomy forecast as string

For more information visit: https://developer.here.com/documentation/destination-weather/dev_guide/topics/user-guide.html

Example request: https://developer.here.com/documentation/destination-weather/dev_guide/topics/examples.html
"""
function weather(;apikey, info, loc, units=:metric)
    # Request
    baseurl = "https://weather.cc.api.here.com"
    path = "weather/1.0"
    resource = "report.xml"
    if info == "weather observation" product = "observation"
    elseif info == "weather forecast" product = "forecast_7days_simple"
    elseif info == "astronomy forecast" product = "forecast_astronomy"
    else product = ""
    end
    if :latitude ∈ keys(loc) && :longitude ∈ keys(loc) place = "latitude=$(loc[:lat])&longitude=$(loc[:long])"
    elseif :zipcode ∈ keys(loc) place = "zipcode=$(loc[:zipcode])"
    elseif :name ∈ keys(loc) place = "name=$(loc[:name])"
    else place = ""
    end
    url = "$baseurl/$path/$resource?apiKey=$apikey&product=$product&$place&metric=$(units==:metric)"
    r = HTTP.request(:GET, url)
    f = parsexml(String(r.body))
    rootnode = root(f)
    
    if info == "weather observation"
        # TODO: Add funciton arguments and date of observation as metadata
        # Create a blank dataframe
        df = DataFrame(sid = Int64[], latitude = Float64[], longitude = Float64[], distance = Float64[])
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
                push!(df[!, :distance], parse(Float64, node["distance"]))
            end
            if nodename(node) == "observation"
                for childnode in iterate(node) push!(df[!, nodename(childnode)], nodecontent(childnode)) end
            end
        end
    elseif info == "weather forecast"
        # TODO: Add function argument and station information as metadata
        # Create a blank dataframe
        df = DataFrame(id = Int64[], datetime = String[], day = String[])
        for node in iterate(rootnode)
            if nodename(node) == "forecast"
                for childnode in iterate(node) df[!, nodename(childnode)] = [] end
                break
            end
        end
        # Fill the dataframe
        for node in iterate(rootnode)
            if nodename(node) == "forecast"
                push!(df[!, :id], length(df[!, :id]) + 1)
                push!(df[!, :datetime], node["utcTime"])
                push!(df[!, :day], node["weekday"])
                for childnode in iterate(node) push!(df[!, nodename(childnode)], nodecontent(childnode)) end
            end
        end
    else df = DataFrame() 
    end    

    return df
end