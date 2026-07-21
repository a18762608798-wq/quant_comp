using QMeasPost
using Test

@testset "integration" begin
    test_json = joinpath(@__DIR__, "aer-independence.json")
    @assert isfile(test_json) "test data not found: $test_json"
    result = load_randmeas_result(test_json)
    @test result.runner == "aer"
    @test result.meas_mode == "independence"
    @test length(result.meas_indices) == 4
    @test length(result.setting_runs) == 2
    @test length(result.params) == 2
    @test length(result.count_group) == 2

    pauli_expect = expect_shadow(result, "ZZZZ")
    @test -1.0 <= pauli_expect <= 1.0
end
