using QMeasPost
using Test

@testset "data_io" begin
    @testset "_hist_to_tensor" begin
        hist_3q = Dict("000" => 1, "111" => 2)
        tensor3 = QMeasPost._hist_to_tensor(hist_3q)
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

        @test groups isa Vector{<:RandomGroup}

        g = groups[1]

        @test g.ensemble == "pauli"
        @test g.M == 56
        @test g.K == 1024
        @test g.meas_indices == [[1], [2], [3], [4]]
        @test size(g.params["theta"]) == (56, 4)
        @test size(g.params["phi"]) == (56, 4)
        @test isnothing(g.trivial_params)
        @test isnothing(g.trivial_count_group)

        @test sum(g.count_group[1]) == 1024
    end

    @testset "RandomData" begin
        test_json = joinpath(@__DIR__, "aer-independence_pauli.json")
        result = load_randmeas_result(test_json)
        groups = split_groups(result)
        g = groups[4]

        data = unroll_data(g)
        @test length(data) == 81
        @test data isa Vector{<:RandomData}
        @test all(d -> d isa RandomData{4}, data)

        d1 = data[1]
        @test d1.ensemble == "pauli"
        @test d1.K == 1024
        @test d1.meas_indices == [[1], [2], [3], [4]]
        @test d1.params == g.params
        @test d1.hist == g.count_group[1]
        @test isnothing(d1.trivial_params)
        @test isnothing(d1.trivial_hist)

        @info d1.hist
        @info resample(d1.hist, d1.K)
    end
end


