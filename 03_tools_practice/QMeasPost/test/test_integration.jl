using QMeasPost
using Test

@testset "integration" begin
    test_json = joinpath(@__DIR__, "quark-correction-pair.json")
    @assert isfile(test_json) "test data not found: $test_json"
    result = load_randmeas_result(test_json)
    @test result.runner == "quark"
    @test length(result.meas_indices) == 2
    @test result.meas_indices == [[2, 5], [3, 4]]
    @test length(result.setting_runs) == 2
    @test length(result.params) == 2
    @test length(result.count_group) == 2
    @test !isnothing(result.trivial_params)
    @test !isnothing(result.trivial_count_group)
end
