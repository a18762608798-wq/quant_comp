# Groups
function get_purity(
    groups::Vector{RandomGroup{N}};
    compute_sem=false,
) where N
    n = length(groups)
    purity = Vector{Float32}(undef, n)
    sem = Vector{Union{Nothing,Float32}}(undef, n)
    Threads.@threads for idx in eachindex(groups)
        purity[idx], sem[idx] = get_purity(groups[idx]; compute_sem=compute_sem)
    end
    return purity, sem
end

# Group
function get_purity(
    group::RandomGroup{N};
    compute_sem=false,
) where N
    is_derandom = (group.ensemble == "derandom")
    return _get_purity(group, Val(compute_sem), Val(is_derandom))
end

function _get_purity(
    group::RandomGroup{N},
    ::Val{false}, # Compute_sem=false
    ::Union{Val{true},Val{false}}, # Derandom or not
) where N
    data = unroll_data(group)
    purity = 0.0f0
    for idx in eachindex(data)
        purity += get_purity(data[idx])
    end
    purity /= group.M
    return purity, nothing
end

function _get_purity(
    group::RandomGroup{N},
    ::Val{true}, # compute_sem=true
    ::Val{false}, # is_derandom=false
) where N
    data = unroll_data(group)
    purity_vals = Vector{Float32}(undef, group.M)
    for idx in eachindex(data)
        purity_vals[idx] = get_purity(data[idx])
    end
    purity = mean(purity_vals)
    sem = std(purity_vals; corrected=true) / sqrt(group.M)
    return purity, sem
end

function _get_purity(
    group::RandomGroup{N},
    ::Val{true}, # compute_sem=true
    ::Val{true}; # is_derandom=true
    ϵ=0.05f0,
) where N
    purity, _ = _get_purity(group, Val(false), Val(true))
    # NOTE: We could only calculate the part of shot noise; the number of samples is M.
    sample_num = ceil(Int, 1 + 1 / (2 * ϵ^2))
    sample_purity = zeros(Float32, sample_num)
    for idx = 1:sample_num
        sample_group = resample(group)
        sample_purity[idx], _ = _get_purity(sample_group, Val(false), Val(true))
    end
    sem = std(sample_purity)
    return purity, sem
end

# Data
function get_purity(
    data::RandomData{N};
) where N
    is_single = all(g -> length(g) == 1, data.meas_indices)
    return _get_purity(data.K, data.hist, Val(is_single))
end

function _get_purity(
    K::Int,
    hist::Array{Int,N},
    ::Val{true};
) where {N}
    @assert all(==(2), size(hist))
    est = 0.0f0
    for idx1 in 2:length(hist)
        for idx2 in 1:(idx1-1)
            ham_dis = count_ones((idx1 - 1) ⊻ (idx2 - 1))
            est += hist[idx1] * hist[idx2] * (-2.0f0)^(-ham_dis)
        end
    end
    for idx in 1:length(hist)
        est += 0.5f0 * hist[idx] * (hist[idx] - 1)
    end
    est *= 2
    est /= (K * (K - 1))
    est *= 2^N
    return est
end

function _get_purity(
    ::Int,
    ::Array{Int,N},
    ::Val{false},
) where N
    error("get_purity requires all groups to have exactly 1 qubit")
end




