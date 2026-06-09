# --------------------------------------
# ----------room reflect (Z_r)----------
# --------------------------------------

"""
get_z_r_shadow(filepath, site_indices, permuted_order; G, compute_sem, show_progress)

Estimate the Z_r quantity (reflection-related observable) using classical shadows,
where the system is partitioned into adjacent pairs and Z_r is computed from those pairs.

Arguments
- filepath::String
    Path to the stored shadow/group data.
- site_indices
    Indices of sites (qubits) in the original system.
- permuted_order
    Permutation order applied to site_indices before computing shadows.

Keyword arguments
- G::Vector{Float64}
    Weight vector per site (default: ones). It is permuted according to permuted_order.
- compute_sem::Bool
    If true, compute and return the jackknife-based bias estimate and SEM.
- show_progress::Bool
    If true, display progress information when performing calculations.

Returns
- If compute_sem == false: returns z_r_val::Float64 (estimated expectation).
- If compute_sem == true: returns a tuple (z_r_val::Float64, bias_estimate::Float64, sem::Float64),
  where bias_estimate is (z_r_val - z_r_jack) computed from jackknife values and sem is the standard error.

Notes
This function:
- loads the permuted group,
- splits qubits into adjacent pairs (odd/even subsystems),
- constructs dense shadows for full and sub-systems,
- builds the adjacent-swap operator, and
- computes jackknife values via get_z_r_loos_shadow to obtain an estimate and (optionally) SEM.
"""
function get_z_r_shadow(
    filepath::String,
    site_indices,
    permuted_order;
    G=fill(1.0, length(site_indices))::Vector{Float64},
    compute_sem=false,
    show_progress=true,
)
    # get the info of three systems
    # get the groups
    permuted_group, permuted_indices = import_permuted_group(
        filepath, site_indices, permuted_order
    )
    qubits_num = length(permuted_order)
    pairs_num = qubits_num ÷ 2
    odd_order = [2i - 1 for i in 1:pairs_num]
    even_order = [2i for i in 1:pairs_num]
    odd_group = reduce_to_subsystem(permuted_group, odd_order)
    even_group = reduce_to_subsystem(permuted_group, even_order)
    # get G for every system
    permuted_G = G[permuted_order]
    odd_G = permuted_G[odd_order]
    even_G = permuted_G[even_order]
    # product the shadows
    shadows = get_dense_shadows(permuted_group; G=permuted_G)
    odd_shadows = get_dense_shadows(odd_group; G=odd_G)
    even_shadows = get_dense_shadows(even_group; G=even_G)
    # product the op
    adjacent_swap_op = create_adjacent_swap_op(permuted_indices)

    # get the expectation and sem
    # get the jackvals info
    n_ru = size(shadows, 1)
    z_r_est, z_r_loos = get_z_r_loos_shadow(
        shadows, odd_shadows, even_shadows, adjacent_swap_op, show_progress
    )
    # get the sem
    if compute_sem
        variance = (n_ru - 1)^2 / n_ru * var(z_r_loos)
        sem = sqrt(variance)
        z_r_jack = n_ru * z_r_est - (n_ru - 1) * mean(z_r_loos)
        return z_r_est, z_r_est - z_r_jack, sem
    else
        return z_r_est
    end
end

