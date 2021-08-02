using HERE
using Test
#using Revise

function loadkey()
    if "key" in keys(ENV)
        return ENV[key]
    else
        open("test\\keys") do f
            return strip(readline(f))
        end
    end
end

testkey = loadkey()
@testset "dummy test" begin
    @test typeof(testkey) == String
end
#=@testset "Traffic API" begin
    df = flow(apikey=testkey, bbox="39.8485715,-86.0969867;39.8358934,-86.0757964")
    @test !isempty(df)
end

@testset "Weather API" begin
    df = weather(;apikey=testkey, info="weather observation", loc=(name = "Jaipur",))
    @test !isempty(df)

    df = weather(;apikey=testkey, info="weather forecast", loc=(name = "Jaipur",))
    @test !isempty(df)

    df = weather(;apikey=testkey, info="astronomy forecast", loc=(name = "Jaipur",))
    @test !isempty(df)
end=#
