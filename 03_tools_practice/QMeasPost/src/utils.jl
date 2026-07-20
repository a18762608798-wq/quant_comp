# QMeasPost util types and I/O — included as bare file (no submodule wrapper)

struct RandomMeasResult
    runner::String
    meas_mode::String
    ensemble::String
    setting_runs::Vector{Tuple{Int,Int}}
    qc_num_qubits::Int
    qc_num_clbits::Int
    meas_indices::Vector{Int}
    params::Vector{Dict{String,Matrix{Float64}}}
    count_group::Vector{Vector{Dict{String,Int}}}
    trivial_params::Union{Nothing,Vector{Dict{String,Matrix{Float64}}}}
    trivial_count_group::Union{Nothing,Vector{Vector{Dict{String,Int}}}}
end

function load_randmeas_result(filepath::AbstractString)::RandomMeasResult
    raw = JSON.parsefile(filepath)
    RandomMeasResult(
        raw["runner"],
        raw["meas_mode"],
        get(raw, "ensemble", "none"),
        [(sr[1], sr[2]) for sr in raw["setting_runs"]],
        raw["qc_num_qubits"],
        raw["qc_num_clbits"],
        raw["meas_indices"],
        [_parse_param_block(p) for p in raw["params"]],
        raw["count_group"],
        _opt_parse_params(raw, "trivial_params"),
        _opt_parse_counts(raw, "trivial_count_group"),
    )
end

function _parse_param_block(p::AbstractDict)::Dict{String,Matrix{Float64}}
    Dict(
        "theta" => Float64.(hcat(p["theta"]...)' ),
        "lambda" => Float64.(hcat(p["lambda"]...)' ),
    )
end

function _opt_parse_params(raw, key)
    if haskey(raw, key) && !isnothing(raw[key])
        return [_parse_param_block(p) for p in raw[key]]
    end
    nothing
end

function _opt_parse_counts(raw, key)
    if haskey(raw, key) && !isnothing(raw[key])
        return raw[key]
    end
    nothing
end

function count_to_prob(counts::AbstractDict{String,Int})::Dict{String,Float64}
    total = sum(values(counts))
    Dict(bits => val / total for (bits, val) in counts)
end

function hist_of_bits(
    count_group::Vector{Vector{Dict{String,Int}}},
    setting_idx::Int,
)::Dict{String,Float64}
    accum = Dict{String,Int}()
    for run_counts in count_group[setting_idx]
        for (bits, c) in run_counts
            accum[bits] = get(accum, bits, 0) + c
        end
    end
    count_to_prob(accum)
end

function u3_state(theta::Real, lambda::Real, bit::Int)::Vector{ComplexF64}
    ct = cos(theta / 2)
    st = sin(theta / 2)
    if bit == 0
        return [ct, -exp(-im * lambda) * st]
    else
        return [st, exp(-im * lambda) * ct]
    end
end

function single_qubit_shadow(theta::Real, lambda::Real, bit::Int)::Matrix{ComplexF64}
    psi = u3_state(theta, lambda, bit)
    Π = psi * psi'
    return 3 * Π - I
end



