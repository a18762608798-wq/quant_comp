using QMeasPost
using Test

@testset "data_io" begin
    @testset "_counts_to_tensor" begin
        counts_3q = Dict("000" => 1, "111" => 2)
        tensor3 = QMeasPost._counts_to_tensor(counts_3q)
        @test ndims(tensor3) == 3
        @test size(tensor3) == (2, 2, 2)
        @test tensor3[1, 1, 1] == 1
        @test tensor3[2, 2, 2] == 2
    end

    @testset "split_groups" begin
        test_json = joinpath(@__DIR__, "quark-correction-pair.json")
        @assert isfile(test_json) "test data not found: $test_json"
        result = load_randmeas_result(test_json)
        groups = split_groups(result)

        @test length(groups) == 2
        @test groups isa Vector{<:RandomGroup}

        g1, g2 = groups[1], groups[2]
        print(g2)

        @test g2.ensemble == "derandom"
        @test g2.M == 5
        @test g2.K == 2048
        @test g2.meas_indices == [[2, 5], [3, 4]]
        @test length(g2.count_group) == 5
        @test ndims(g2.count_group[1]) == 4
        @test size(g2.params["theta"]) == (5, 2)
        @test size(g2.params["lambda"]) == (5, 2)
        @test !isnothing(g2.trivial_params)
        @test !isnothing(g2.trivial_count_group)

        sum_g11 = sum(g1.count_group[1])
        @test sum_g11 == 1024
    end
end
