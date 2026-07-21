function count_to_prob(counts::AbstractDict{String,Int})::Dict{String,Float32}
    total = sum(values(counts))
    Dict(bits => val / total for (bits, val) in counts)
end

function hist_of_bits(
    count_group::Vector{Vector{Dict{String,Int}}},
    setting_idx::Int,
)::Dict{String,Float32}
    accum = Dict{String,Int}()
    for run_counts in count_group[setting_idx]
        for (bits, c) in run_counts
            accum[bits] = get(accum, bits, 0) + c
        end
    end
    count_to_prob(accum)
end

function u3_state(theta::Real, lambda::Real, bit::Int)::Vector{ComplexF32}
    T32 = Float32(theta)
    L32 = Float32(lambda)
    ct = cos(T32 / 2)
    st = sin(T32 / 2)
    if bit == 0
        return ComplexF32[ct, -exp(-im * L32) * st]
    else
        return ComplexF32[st, exp(-im * L32) * ct]
    end
end

function single_qubit_shadow(theta::Real, lambda::Real, bit::Int)::Matrix{ComplexF32}
    psi = u3_state(theta, lambda, bit)
    Π = psi * psi'
    return 3 * Π - I
end





