function get_purity(
    meas_indices::Vector{Vector{Int}},
    counts::Array{Int, N};
    compute_sem=false,
) where N
    is_single = all(g -> length(g) == 1, meas_indices)
    _get_purity(counts, Val(is_single), Val(compute_sem))
end

function _get_purity(
    counts::Array{Int, N},
    ::Val{true},
    ::Val{false},
) where {N}
    @assert all(==(2), size(counts))
    est = 0.0f0
    for idx1 in 2:length(counts)
        for idx2 in 1:(idx1 - 1)
            ham_dis = count_ones((idx1 - 1) ⊻ (idx2 - 1)) # hamming distance
            est += counts[idx1] * counts[idx2] * (-2.0f0)^(-ham_dis)
        end
    end
    est *= 2.0f0 # get the est excluding diag.
    # 后续计算

    return est
end

function _get_purity(
    counts::Array{Int, N},
    ::Val{false},
    ::Union{Val{true}, Val{false}},
) where N
    error("get_purity requires all groups to have exactly 1 qubit, " *
          "got groups of sizes: $(join(string.(length.(meas_indices)), ", "))")
end

