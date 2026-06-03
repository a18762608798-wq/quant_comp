# --------------------------------------
# ----------room reflect (Z_r)----------
# --------------------------------------

# reflect expect (Z_r)
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
