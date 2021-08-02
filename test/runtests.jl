using HERE
using Test
using Revise
using DataFrames
include("keys.jl")

#=
# Traffic API
testBox = "39.8485715,-86.0969867;39.8358934,-86.0757964"
flow(apikey=key, bbox=testBox)
=#

# Weather API


@testset "HERE.jl" begin
    df = flow(apikey=key, bbox="39.8485715,-86.0969867;39.8358934,-86.0757964")
    @test !isempty(df)

    df = weather(;apikey=key, info="weather observation", loc=(name = "Jaipur",))
    @test !isempty(df)

    df = weather(;apikey=key, info="weather forecast", loc=(name = "Jaipur",))
    @test !isempty(df)

    df = weather(;apikey=key, info="astronomy forecast", loc=(name = "Jaipur",))
    @test !isempty(df)
end
