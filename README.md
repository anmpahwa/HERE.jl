# HERE

[![Build Status](https://travis-ci.com/anmol1104/HERE.jl.svg?branch=master)](https://travis-ci.com/anmol1104/HERE.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/anmol1104/HERE.jl?svg=true)](https://ci.appveyor.com/project/anmol1104/HERE-jl)
[![Coverage](https://codecov.io/gh/anmol1104/HERE.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/anmol1104/HERE.jl)
[![Coverage](https://coveralls.io/repos/github/anmol1104/HERE.jl/badge.svg?branch=master)](https://coveralls.io/github/anmol1104/HERE.jl?branch=master)

HERE Technologies is a crowd-based navigation, mapping, and location content platform.

## TrafficAPI

```julia
flow(;apikey, bbox, s=1.0, m=1/60)
```

Returns real-time vehicle speed in every s seconds for m minutes in a bounding box using HERE Traffic API. 

### Arguments
- `apikey::String`   : API key to access HERE
- `bbox::String`     : Bounding box defined as `"lat₁,long₁;lat₂,long₂"`
- `s::Float64=1.0`   : gap between every API call
- `m::Float64=1/60`  : time-period of analysis

## WeatherAPI
```julia
weather(; apikey, info, loc, units=:metric)
```

Returns weather information for the place identifed with loc keyword.

### Arguments
- `apikey::String`  : API key to access HERE
- `loc::NamedTuple` : a named tuple with lat and long, zipcode, or name of the place
- `info::String`    : takes weather observation, weather forecast, or astronomy forecast as string

For more information visit: https://developer.here.com/documentation/destination-weather/dev_guide/topics/user-guide.html

Example request: https://developer.here.com/documentation/destination-weather/dev_guide/topics/examples.html
