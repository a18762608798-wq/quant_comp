using QMeasPost
using Test
using ITensors

@testset "data_io" begin
    @testset "_counts_to_tensor" begin
        counts_2q = Dict("00" => 10, "01" => 20, "10" => 30, "11" => 40)
        tensor = QMeasPost._counts_to_tensor(counts_2q)
        @test ndims(tensor) == 2
        @test size(tensor) == (2, 2)
        @test tensor[1, 1] == 10
        @test tensor[1, 2] == 20
        @test tensor[2, 1] == 30
        @test tensor[2, 2] == 40

        counts_partial = Dict("00" => 5, "11" => 7)
        tensor2 = QMeasPost._counts_to_tensor(counts_partial)
        @test tensor2[1, 2] == 0
        @test tensor2[2, 1] == 0
        @test tensor2[2, 2] == 7

        counts_3q = Dict("000" => 1, "111" => 2)
        tensor3 = QMeasPost._counts_to_tensor(counts_3q)
        @test ndims(tensor3) == 3
        @test size(tensor3) == (2, 2, 2)
        @test tensor3[1, 1, 1] == 1
        @test tensor3[2, 2, 2] == 2
    end

    @testset "split_groups" begin
        test_json = joinpath(@__DIR__, "aer-independence.json")
        @assert isfile(test_json) "test data not found: $test_json"
        result = load_randmeas_result(test_json)
        sites = [Index(2, "Qubit,$i") for i in 1:result.qc_num_qubits]
        groups = split_groups(result, sites)

        @test length(groups) == 2
        @test groups isa Vector{<:RandomGroup}

        g1, g2 = groups[1], groups[2]

        @test g1.ensemble == "derandom"
        @test g1.M == 2
        @test g1.K == 1024
        @test length(g1.meas_sites) == 4
        @test g1.meas_sites == sites[[2, 3, 4, 5]]
        @test length(g1.count_group) == 2
        @test ndims(g1.count_group[1]) == 4
        @test size(g1.count_group[1]) == (2, 2, 2, 2)
        @test size(g1.params["theta"]) == (2, 4)
        @test size(g1.params["lambda"]) == (2, 4)
        @test isnothing(g1.trivial_params)
        @test isnothing(g1.trivial_count_group)

        @test g2.ensemble == "derandom"
        @test g2.M == 5
        @test g2.K == 1024
        @test length(g2.meas_sites) == 4
        @test g2.meas_sites == sites[[2, 3, 4, 5]]
        @test length(g2.count_group) == 5
        @test ndims(g2.count_group[1]) == 4
        @test size(g2.params["theta"]) == (5, 4)
        @test size(g2.params["lambda"]) == (5, 4)
        @test isnothing(g2.trivial_params)
        @test isnothing(g2.trivial_count_group)

        sum_g11 = sum(g1.count_group[1])
        @test sum_g11 == 1024
        sum_g22 = sum(g2.count_group[2])
        @test sum_g22 == 1024
    end
end
