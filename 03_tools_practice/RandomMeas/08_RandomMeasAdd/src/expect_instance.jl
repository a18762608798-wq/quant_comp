# reflect expect (Z_r)
function get_reflect_expect_shadow(
    filepath::String,
    site_indices, 
    permuted_order;
    shadows_type="factorized",
    G = fill(1.0, length(site_indices))::Vector{Float64},
    compute_sem = false,
    show_progress = true,
)
    permuted_G = G[permuted_order]
    permuted_group, permuted_indices = import_permuted_group(
        filepath, 
        site_indices, 
        permuted_order
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
            compute_sem = compute_sem,
            show_progress = show_progress,
        )
        return real(reflect_expect)
    elseif compute_sem == true
        reflect_expect, sem = modified_get_expect_shadow(
            adjacent_swap_op, 
            permuted_shadows;
            compute_sem = compute_sem,
            show_progress = show_progress,
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
    G = fill(1.0, length(site_indices))::Vector{Float64},
    compute_sem = false,
    show_progress = true,
)
    println("Now we are calculating expectation of numerator:")
    numerator, _ = get_reflect_expect_shadow(
        filepath,
        site_indices, 
        permuted_order;
        shadows_type=shadows_type,
        G = G,
        compute_sem = true,
        show_progress = show_progress,
    )
    println("Now we are calculating the expectation of denominator")
    # get the subsystem group
    permuted_group, permuted_indices = import_permuted_group(
        filepath, 
        site_indices, 
        permuted_order
    )
    permuted_G = G[permuted_order]
    qubits_num = length(permuted_order)
    pairs_num = qubits_num ÷ 2
    odd_order = [2i - 1 for i = 1:pairs_num]
    even_order = [2i for i = 1:pairs_num]
    odd_group = reduce_to_subsystem(
        permuted_group,
        odd_order,
    )
    even_group = reduce_to_subsystem(
        permuted_group,
        even_order,
    )
    odd_G = permuted_G[odd_order]
    even_G = permuted_G[even_order]

    if shadows_type == "factorized"
        odd_shadows = get_factorized_shadows(odd_group; G=odd_G)
        even_shadows = get_factorized_shadows(even_group; G=even_G)
    elseif shadows_type == "dense" 
        odd_shadows = get_dense_shadows(odd_group; G=odd_G)
        even_shadows = get_dense_shadows(even_group; G=even_G)
    else
        error("wrong shadows type: $shadows_type")
    end

    println("Now we calculate the purity of subsystem 1:")
    odd_purity = real(modified_get_trace_moment(odd_shadows, 2))
    println("Now we calculate the purity of subsystem 2:")
    even_purity = real(modified_get_trace_moment(even_shadows, 2))
    normalized_param = 1 / (sqrt((odd_purity + even_purity) / 2))
    return numerator * normalized_param
end


# time reversal (Z_T)
#   function get_reversal_expect_shadow(
#
#   )
#
#
#   end
