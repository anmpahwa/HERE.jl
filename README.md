# HERE

[![Build Status](https://travis-ci.com/anmol1104/HERE.jl.svg?branch=master)](https://travis-ci.com/anmol1104/HERE.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/anmol1104/HERE.jl?svg=true)](https://ci.appveyor.com/project/anmol1104/HERE-jl)
[![Coverage](https://codecov.io/gh/anmol1104/HERE.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/anmol1104/HERE.jl)
[![Coverage](https://coveralls.io/repos/github/anmol1104/HERE.jl/badge.svg?branch=master)](https://coveralls.io/github/anmol1104/HERE.jl?branch=master)

HERE Technologies is a crowd-based navigation, mapping, and location content platform.
- Traffic API: 
- Weather API: Weather information for any given place

## Traffic API

```julia
flow(;apikey, bbox, s=1.0, m=1/60)
```

Returns real-time vehicle speed in every s seconds for m minutes in a bounding box using HERE Traffic API. 

### Arguments
- `apikey::String`   : API key to access HERE
- `bbox::String`     : Bounding box defined as `"lat₁,long₁;lat₂,long₂"`
- `s::Float64=1.0`   : gap between every API call
- `m::Float64=1/60`  : time-period of analysis
