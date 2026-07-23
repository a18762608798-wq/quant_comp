using QMeasPost
using Test

@testset "purity" begin
    @testset "get_purity — aer-independence" begin
        for ensemble in ["pauli", "haar", "derandom"]
            test_json = joinpath(@__DIR__, "aer-independence_$(ensemble).json")
            result = load_randmeas_result(test_json)
            groups = split_groups(result)
            purities, sems = get_purity(groups; compute_sem=true)
            @info "$ensemble purity = $(purities)"
            #@info "$ensemble sem = $(sems)"
        end
    end

    @testset "get_purity — not single" begin
        data = RandomData{2}("test", 2, [[1, 2]], nothing, zeros(Int, 2, 2), nothing, nothing)
        @test_throws ErrorException get_purity(data)
    end
end
