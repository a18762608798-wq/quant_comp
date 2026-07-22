function get_purity(
    groups::Vector{RandomGroup{N}};
    compute_sem=false,
) where N
    n = length(groups)
    purity = Vector{Float32}(undef, n)
    sem = Vector{Union{Nothing,Float32}}(undef, n)
    for idx in eachindex(groups)
        purity[idx], sem[idx] = get_purity(groups[idx]; compute_sem=compute_sem)
    end
    return purity, sem
end

function get_purity(
    group::RandomGroup{N};
    compute_sem=false,
) where N
    data = unroll_data(group)
    is_derandom = (group.ensemble == "derandom")
    purity = 0.0f0
    if !compute_sem
        for idx in eachindex(data)
            purity += get_purity(data[idx])
        end
        purity /= group.M
        purity *= 2^N
        return purity, nothing
    else
        purity_vals = Vector{Float32}(undef, group.M)
        for idx in eachindex(data)
            est = get_purity(data[idx])
            est /= group.M
            est *= 2^N
            purity_vals[idx] = est
        end
        purity = mean(purity_vals)
        sem = std(purity_vals; corrected=true) / sqrt(group.M)
        # TODO: derandom sem calculation
        if is_derandom
            sem = nothing
        end
        return purity, sem
    end
end

function get_purity(
    data::RandomData{N};
) where N
    is_single = all(g -> length(g) == 1, data.meas_indices)
    return _get_purity(data.K, data.counts, Val(is_single))
end

function _get_purity(
    K::Int,
    counts::Array{Int,N},
    ::Val{true};
) where {N}
    @assert all(==(2), size(counts))
    est = 0.0f0
    for idx1 in 2:length(counts)
        for idx2 in 1:(idx1-1)
            ham_dis = count_ones((idx1 - 1) ⊻ (idx2 - 1))
            est += counts[idx1] * counts[idx2] * (-2.0f0)^(-ham_dis)
        end
    end
    for idx in 1:length(counts)
        est += 0.5f0 * counts[idx] * (counts[idx] - 1)
    end
    est *= 2
    est /= (K * (K - 1))
    return est
end

function _get_purity(
    ::Int,
    ::Array{Int,N},
    ::Val{false},
) where N
    error("get_purity requires all groups to have exactly 1 qubit")
end




