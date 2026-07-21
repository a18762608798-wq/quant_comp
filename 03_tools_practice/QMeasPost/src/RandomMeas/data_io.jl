# RandomMeasResult IO

struct RandomMeasResult
    runner::String
    ensemble::String
    setting_runs::Vector{Tuple{Int,Int}}
    qc_num_qubits::Int
    qc_num_clbits::Int
    meas_indices::Vector{Vector{Int}}
    params::Union{Nothing,Vector{Dict{String,Matrix{Float32}}}}
    count_group::Vector{Vector{Dict{String,Int}}}
    trivial_params::Union{Nothing,Vector{Dict{String,Matrix{Float32}}}}
    trivial_count_group::Union{Nothing,Vector{Vector{Dict{String,Int}}}}
end

function load_randmeas_result(filepath::AbstractString)::RandomMeasResult
    raw = JSON.parsefile(filepath)
    RandomMeasResult(
        raw["runner"],
        get(raw, "ensemble", "none"),
        [(sr[1], sr[2]) for sr in raw["setting_runs"]],
        raw["qc_num_qubits"],
        raw["qc_num_clbits"],
        raw["meas_indices"],
        _opt_parse_params(raw, "params"),
        raw["count_group"],
        _opt_parse_params(raw, "trivial_params"),
        _opt_parse_counts(raw, "trivial_count_group"),
    )
end

function _parse_param_block(p::AbstractDict)::Dict{String,Matrix{Float32}}
    Dict(
        "theta" => Float32.(hcat(p["theta"]...)' ),
        "lambda" => Float32.(hcat(p["lambda"]...)' ),
    )
end

function _opt_parse_params(raw, key)
    if haskey(raw, key) && !isnothing(raw[key])
        return [_parse_param_block(p) for p in raw[key]]
    end
    return nothing
end

function _opt_parse_counts(raw, key)
    if haskey(raw, key) && !isnothing(raw[key])
        return raw[key]
    end
    return nothing
end

# RandomGroup

struct RandomGroup{N}
    ensemble::String
    M::Int
    K::Int
    meas_indices::Vector{Vector{Int}}
    params::Union{Nothing, Dict{String, Matrix{Float32}}}
    count_group::Vector{Array{Int, N}}
    trivial_params::Union{Nothing, Dict{String, Matrix{Float32}}}
    trivial_count_group::Union{Nothing, Vector{Array{Int, N}}}
end

function _counts_to_tensor(counts::Dict{String, Int})::Array{Int}
    N = length(first(keys(counts)))
    tensor = zeros(Int, ntuple(_ -> 2, N))
    for (bits, c) in counts
        idx = ntuple(i -> parse(Int, bits[i]) + 1, N)
        tensor[idx...] = c
    end
    return tensor
end

function split_groups(result::RandomMeasResult)
    n_runs = length(result.setting_runs)
    N_dim = sum(length, result.meas_indices)
    return [RandomGroup{N_dim}(
        result.ensemble,
        result.setting_runs[i][1],
        result.setting_runs[i][2],
        result.meas_indices,
        isnothing(result.params) ? nothing : result.params[i],
        [_counts_to_tensor(d) for d in result.count_group[i]],
        isnothing(result.trivial_params) ? nothing : result.trivial_params[i],
        isnothing(result.trivial_count_group) ? nothing :
            [_counts_to_tensor(d) for d in result.trivial_count_group[i]],
    ) for i in 1:n_runs]
end

