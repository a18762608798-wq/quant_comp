function get_purity(
    meas_indices::Vector{Vector{Int}},
    counts::Array{Int, N};
    compute_sem=false,
) where N
    is_single = all(g -> length(g) == 1, meas_indices)
    _get_purity(meas_indices, counts, Val(is_single), Val(compute_sem))
end

function _get_purity(
    meas_indices::Vector{Vector{Int}},
    counts::Array{Int, N},
    ::Val{true},
    ::Val(false),
) where N
    # TODO: pair-specific purity computation
    return nothing
end

function _get_purity(
    meas_indices::Vector{Vector{Int}},
    counts::Array{Int, N},
    ::Val{false},
    ::Union{true, false},
) where N
    error("get_purity requires all groups to have exactly 1 qubit, " *
          "got groups of sizes: $(join(string.(length.(meas_indices)), ", "))")
end

