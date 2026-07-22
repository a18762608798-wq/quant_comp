using QMeasPost
using Test

@testset "integration" begin
    @testset "aer-independence — $ensemble" for ensemble in ["pauli", "haar", "derandom"]
        test_json = joinpath(@__DIR__, "aer-independence_$(ensemble).json")
        @assert isfile(test_json) "test data not found: $test_json"
        result = load_randmeas_result(test_json)
        @test result.runner == "aer"
        @test result.ensemble == ensemble
        @test length(result.meas_indices) == 4
        @test result.meas_indices == [[1], [2], [3], [4]]
        @test length(result.setting_runs) == 5
        @test length(result.params) == 5
        @test length(result.count_group) == 5
        @test isnothing(result.trivial_params)
        @test isnothing(result.trivial_count_group)
    end
end
