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
        _opt_parse_hist(raw, "trivial_count_group"),
    )
end

function _parse_param_block(p::AbstractDict)::Dict{String,Matrix{Float32}}
    Dict(
        "theta" => Float32.(hcat(p["theta"]...)'),
        "phi" => Float32.(hcat(p["phi"]...)'),
    )
end

function _opt_parse_params(raw, key)
    if haskey(raw, key) && !isnothing(raw[key])
        return [_parse_param_block(p) for p in raw[key]]
    end
    return nothing
end

function _opt_parse_hist(raw, key)
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
    params::Union{Nothing,Dict{String,Matrix{Float32}}}
    count_group::Vector{Array{Int,N}}
    trivial_params::Union{Nothing,Dict{String,Matrix{Float32}}}
    trivial_count_group::Union{Nothing,Vector{Array{Int,N}}}
end

function _hist_to_tensor(hist::Dict{String,Int})::Array{Int}
    N = length(first(keys(hist)))
    tensor = zeros(Int, ntuple(_ -> 2, N))
    for (bits, c) in hist
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
        [_hist_to_tensor(d) for d in result.count_group[i]],
        isnothing(result.trivial_params) ? nothing : result.trivial_params[i],
        isnothing(result.trivial_count_group) ? nothing :
        [_hist_to_tensor(d) for d in result.trivial_count_group[i]],
    ) for i in 1:n_runs]
end

# RandomData — single setting slice of RandomGroup

struct RandomData{N}
    ensemble::String
    K::Int
    meas_indices::Vector{Vector{Int}}
    params::Union{Nothing,Dict{String,Matrix{Float32}}}
    hist::Array{Int,N}
    trivial_params::Union{Nothing,Dict{String,Matrix{Float32}}}
    trivial_hist::Union{Nothing,Array{Int,N}}
end

function unroll_data(group::RandomGroup{N}) where N
    [RandomData{N}(
        group.ensemble,
        group.K,
        group.meas_indices,
        group.params,
        hist,
        group.trivial_params,
        isnothing(group.trivial_count_group) ? nothing :
        group.trivial_count_group[s],
    ) for (s, hist) in enumerate(group.count_group)]
end

# resample
function resample(hist::Array{Int,N}, K::Int) where N
    @assert sum(hist) == K
    prob = Float32.(hist) ./ sum(hist)
    samples = sample(1:length(hist), Weights(vec(prob)), K; replace=true)
    new_hist = reshape(counts(samples, 1:length(hist)), size(hist)) # counts: count the frequency of ench idx of prob.
    return new_hist
end

function resample(group::RandomGroup{N}) where N
    new_count_group = [
        resample(group.count_group[idx], group.K) for idx = 1:group.M
    ]
    return RandomGroup{N}(
        group.ensemble,
        group.M,
        group.K,
        group.meas_indices,
        group.params,
        new_count_group,
        group.trivial_params,
        group.trivial_count_group,
    )
end

