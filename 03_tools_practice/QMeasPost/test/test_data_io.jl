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
        test_json = joinpath(@__DIR__, "aer-independence_pauli.json")
        @assert isfile(test_json) "test data not found: $test_json"
        result = load_randmeas_result(test_json)
        groups = split_groups(result)

        @test length(groups) == 5
        @test groups isa Vector{<:RandomGroup}

        g = groups[5]

        @test g.ensemble == "pauli"
        @test g.M == 81
        @test g.K == 1024
        @test g.meas_indices == [[1], [2], [3], [4]]
        @test length(g.count_group) == 81
        @test ndims(g.count_group[1]) == 4
        @test size(g.params["theta"]) == (81, 4)
        @test size(g.params["phi"]) == (81, 4)
        @test isnothing(g.trivial_params)
        @test isnothing(g.trivial_count_group)

        @test sum(g.count_group[1]) == 1024
    end

    @testset "RandomData" begin
        test_json = joinpath(@__DIR__, "aer-independence_pauli.json")
        result = load_randmeas_result(test_json)
        groups = split_groups(result)
        g = groups[5]

        data = unroll_data(g)
        @test length(data) == 81
        @test data isa Vector{<:RandomData}
        @test all(d -> d isa RandomData{4}, data)

        d1 = data[1]
        @test d1.ensemble == "pauli"
        @test d1.K == 1024
        @test d1.meas_indices == [[1], [2], [3], [4]]
        @test d1.params == g.params
        @test d1.counts == g.count_group[1]
        @test isnothing(d1.trivial_params)
        @test isnothing(d1.trivial_counts)
    end
end


