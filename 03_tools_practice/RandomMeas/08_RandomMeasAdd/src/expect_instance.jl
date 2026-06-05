# --------------------------------------
# ----------room reflect (Z_r)----------
# --------------------------------------

"""
get_reflect_expect_shadow(filepath, site_indices, permuted_order; shadows_type="factorized",
                          G=fill(1.0, length(site_indices)), compute_sem=false, show_progress=true)

Compute the expectation value of the reflection operator Z_r using classical shadows.

Arguments
- filepath::String
    Path to the stored shadow/group data.
- site_indices
    Indices of sites (qubits) in the original system.
- permuted_order
    Permutation order applied to site_indices before computing shadows.

Keyword arguments
- shadows_type::String = "factorized" | "dense"
    Selects shadow representation. Default is "factorized".
- G::Vector{Float64}
    Weight vector per site (default: ones). It is permuted according to permuted_order.
- compute_sem::Bool
    If true, also compute and return the standard error of the mean (SEM).
- show_progress::Bool
    If true, display progress information when performing calculations.

Returns
- If compute_sem == false: returns real(expectation)::Float64.
- If compute_sem == true: returns (real(expectation)::Float64, sem::Float64).

Notes
This function loads a permuted group from filepath, constructs factorized or dense
shadows for the permuted system, builds the adjacent-swap operator for reflection,
and delegates the expectation/SEM estimation to modified_get_expect_shadow.
"""
function get_reflect_expect_shadow(
    filepath::String,
    site_indices,
    permuted_order;
    shadows_type="factorized",
    G=fill(1.0, length(site_indices))::Vector{Float64},
    compute_sem=false,
    show_progress=true,
)
    permuted_G = G[permuted_order]
    permuted_group, permuted_indices = import_permuted_group(
        filepath, site_indices, permuted_order
    )

    if shadows_type == "factorized"
        permuted_shadows = get_factorized_shadows(permuted_group; G=permuted_G)
    elseif shadows_type == "dense"
        permuted_shadows = get_dense_shadows(permuted_group; G=permuted_G)
    else
        error("wrong shadows type: $shadows_type")
    end

    adjacent_swap_op = create_adjacent_swap_op(permuted_indices)

    if compute_sem == false
        reflect_expect = modified_get_expect_shadow(
            adjacent_swap_op,
            permuted_shadows;
            compute_sem=compute_sem,
            show_progress=show_progress,
        )
        return real(reflect_expect)
    elseif compute_sem == true
        reflect_expect, sem = modified_get_expect_shadow(
            adjacent_swap_op,
            permuted_shadows;
            compute_sem=compute_sem,
            show_progress=show_progress,
        )
        return real(reflect_expect), sem
    else
        error("The values of compute_sem must be true of false")
    end
end

"""
get_z_r_shadow(filepath, site_indices, permuted_order; shadows_type="dense",
               G=fill(1.0, length(site_indices)), compute_sem=false, show_progress=true)

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
- shadows_type::String = "factorized" | "dense"
    Selects shadow representation. Default is "dense".
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
- constructs factorized or dense shadows for full and sub-systems,
- builds the adjacent-swap operator, and
- computes jackknife values via calculate_z_r_jackvals to obtain an estimate and (optionally) SEM.
"""
function get_z_r_shadow(
    filepath::String,
    site_indices,
    permuted_order;
    shadows_type="dense",
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
    if shadows_type == "factorized"
        shadows = get_factorized_shadows(permuted_group; G=permuted_G)
        odd_shadows = get_factorized_shadows(odd_group; G=odd_G)
        even_shadows = get_factorized_shadows(even_group; G=even_G)
    elseif shadows_type == "dense"
        shadows = get_dense_shadows(permuted_group; G=permuted_G)
        odd_shadows = get_dense_shadows(odd_group; G=odd_G)
        even_shadows = get_dense_shadows(even_group; G=even_G)
    else
        error("wrong shadows type: $shadows_type")
    end
    # product the op
    adjacent_swap_op = create_adjacent_swap_op(permuted_indices)

    # calculate the expectation and sem
    # get the jackvals info
    n_ru = size(shadows, 1)
    z_r_val, z_r_jackvals = calculate_z_r_jackvals(
        shadows, odd_shadows, even_shadows, adjacent_swap_op, show_progress
    )
    # calculate the sem
    if compute_sem
        variance = (n_ru - 1)^2 / n_ru * var(z_r_jackvals)
        sem = sqrt(variance)
        z_r_jack = n_ru * z_r_val - (n_ru - 1) * mean(z_r_jackvals)
        return z_r_val, z_r_val - z_r_jack, sem
    else
        return z_r_val
    end
end

# ---------------------------------------
# ----------time reversal (Z_T)----------
# ---------------------------------------

#   function get_reversal_expect_shadow(
#
#   )
#
#
#   end
