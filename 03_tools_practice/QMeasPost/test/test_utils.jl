using QMeasPost
using Test
using LinearAlgebra

@testset "utils" begin
    @testset "u3_state" begin
        psi0 = u3_state(0.0f0, 0.0f0, 0)
        @test psi0 ≈ ComplexF32[1, 0]
        psi1 = u3_state(0.0f0, 0.0f0, 1)
        @test psi1 ≈ ComplexF32[0, 1]

        psi_pi = u3_state(Float32(π), 0.0f0, 0)
        @test psi_pi ≈ ComplexF32[0, 1]  atol=1e-7
    end

    @testset "single_qubit_shadow" begin
        σ = single_qubit_shadow(0.0f0, 0.0f0, 0)
        @test tr(σ) ≈ 1.0f0
        @test σ ≈ 3.0f0 * ComplexF32[1 0; 0 0] - I
    end

    @testset "count_to_prob" begin
        counts = Dict("00" => 500, "11" => 500)
        probs = count_to_prob(counts)
        @test probs["00"] ≈ 0.5
        @test probs["11"] ≈ 0.5
    end
end
