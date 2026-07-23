function hist_to_prob(hist::AbstractDict{String,Int})::Dict{String,Float32}
    total = sum(values(hist))
    Dict(bits => val / total for (bits, val) in hist)
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
    hist_to_prob(accum)
end

function u3_state(theta::Real, phi::Real, bit::Int)::Vector{ComplexF32}
    T32 = Float32(theta)
    P32 = Float32(phi)
    ct = cos(T32 / 2)
    st = sin(T32 / 2)
    if bit == 0
        return ComplexF32[ct, st]
    else
        return ComplexF32[-exp(im * P32) * st, exp(im * P32) * ct]
    end
end

function single_qubit_shadow(theta::Real, phi::Real, bit::Int)::Matrix{ComplexF32}
    psi = u3_state(theta, phi, bit)
    Π = psi * psi'
    return 3 * Π - I
end





