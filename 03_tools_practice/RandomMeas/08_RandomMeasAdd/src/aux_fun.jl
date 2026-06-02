# ------------------------------------------------------------------------
# ----------Import the data from npz accroding to permuted order----------
# ------------------------------------------------------------------------

# This method has the function to reduce.
function import_permuted_group(filepath::String, site_indices, permuted_order)
    permuted_indices = site_indices[permuted_order]
    group_data = npzread(filepath)
    meas_res = 2 .- Int64.(group_data["measurement_results"])
    settings = ComplexF64.(group_data["measurement_settings"])
    permuted_meas_res = meas_res[:, :, permuted_order]
    permuted_settings = settings[:, permuted_order, :, :]
    permuted_group = MeasurementGroup(permuted_meas_res, permuted_settings, permuted_indices)
    return permuted_group, permuted_indices
end


# ---------------------------------------------- 
# ----------transform shadows to a mpo---------- 
# ---------------------------------------------- 

function get_factorized_shadow_mpo(
    shadow::FactorizedShadow
)
    return MPO(shadow.shadow_data)
end

function get_factorized_shadow_mpo(
    shadows::Matrix{FactorizedShadow}
)
    settings_num, shots = size(shadows)    
    mpo_shadows = Matrix{MPO}(undef, settings_num, shots)
    for settings = 1:settings_num
        for shot = 1:shots
            shadow = shadows[settings, shot]
            mpo_shadow = get_factorized_shadow_mpo(shadow)
            mpo_shadows[settings, shot] = mpo_shadow
        end
    end
    return mpo_shadows
end

function get_factorized_shadow_mpo(
    shadows::Vector{FactorizedShadow}
)
    return get_factorized_shadow_mpo(
        reshape(shadows, length(shadows), 1)
    )
end


# --------------------------------------------
# ---------- calculate the jackvals ----------
# --------------------------------------------

# calculate jackvals perms avg
function calculate_jackvals_perms_avg(
    shadows::Array{<:AbstractShadow,2},
    k::Int;
    O::Union{Nothing,MPO} = nothing,
    show_progress = true,
)
    @assert 0 ≤ k ≤ 2 "k must be in [0, 2]."

    # pre-enumerate permutations and m–cartesian product
    n_ru, n_m = size(shadows)
    perms   = collect(combinations(1:n_ru, k))
    cprod   = collect(CartesianIndices(ntuple(_ -> 1:n_m, k)))
    perms_num  = length(perms)

    # average over measurements for each permutation
    perms_avg = zeros(Float64, perms_num)
    @showprogress desc="Permutations Processing..." enabled=show_progress @threads for pidx in eachindex(perms)
        r = perms[pidx]
        ssum = 0.0
        for m in cprod
            ssum += real(get_trace_product(
                (shadows[r[i], m[i]] for i in 1:k)...; O
            ))
        end
        perms_avg[pidx] = ssum / length(cprod)
    end

    return perms_avg
end

# 2 moment
function calculate_jackvals_2_moment(
    shadows::Array{<:AbstractShadow,2};
    O::Union{Nothing,MPO} = nothing,
    compute_renyi::Bool        = false,
    show_progress::Bool = true,
)
    n_ru, n_m = size(shadows)
    # pre-enumerate permutations
    perms   = collect(combinations(1:n_ru, 2))

    # average over measurements for each permutation
    perm_avg = calculate_jackvals_perms_avg(
        shadows,
        2;
        O = O,
        show_progress = show_progress,
    )

    # define the averaging functional
    avgfun(x) = compute_renyi ?
        (1/ (1 - 2)) * log2(mean(x)) :
        mean(x)

    θ  = avgfun(perm_avg)

    # jackknife groups: permutations not containing unitary i
    jackvals = zeros(Float64, n_ru)
    @threads for i in 1:n_ru
        s = 0.0
        count = 0
        for (idx, r) in enumerate(perms) 
            if i ∉ r
                s += perm_avg[idx]
                count += 1
            end
        end
        μ = s / count
        jackvals[i] = compute_renyi ? (1 / (1 - 2)) * log2(μ) : μ
    end

    return θ, jackvals
end

function calculate_jackvals_2_moment(
    shadows::Vector{<:AbstractShadow};
    kwargs...,
)
    return calculate_jackvals_2_moment(
        reshape(shadows, length(shadows), 1);
        kwargs...,
    )
end

# 1 moment
function calculate_jackvals_1_moment(
    shadows::Array{<:AbstractShadow,2};
    O::Union{Nothing,MPO} = nothing,
    show_progress::Bool = true,
)
    n_ru, _ = size(shadows)
    perms = collect(combinations(1:n_ru, 1))

    # average over measurements for each permutation
    perm_avg = calculate_jackvals_perms_avg(
        shadows,
        1;
        O = O,
        show_progress = show_progress,
    )
    θ  = mean(perm_avg)

    # jackknife groups: permutations not containing unitary i
    jackvals = zeros(Float64, n_ru)
    @threads for i in 1:n_ru
        s = 0.0
        count = 0
        for (idx, r) in enumerate(perms) 
            if i ∉ r
                s += perm_avg[idx]
                count += 1
            end
        end
        μ = s / count
        jackvals[i] = μ
    end

    return θ, jackvals
end

function calculate_jackvals_1_moment(
    shadows::Vector{<:AbstractShadow};
    kwargs...,
)
    return calculate_jackvals_1_moment(
        reshape(shadows, length(shadows), 1);
        kwargs...,
    )
end

# calculate z_r jackvals
function calculate_z_r_jackvals(
    shadows::Array{<:AbstractShadow,2},
    odd_shadows::Array{<:AbstractShadow,2},
    even_shadows::Array{<:AbstractShadow,2},
    reflect_op::MPO,
    show_progress::Bool = true,
)
    # pre-enumerate permutations (and m–cartesian product)
    n_ru, _ = size(shadows)
    reflect_perms   = collect(combinations(1:n_ru, 1))
    purity_perms   = collect(combinations(1:n_ru, 2))

    # average over measurements for each permutation
    reflect_perms_avg = calculate_jackvals_perms_avg(
        shadows, 1; 
        O = reflect_op,
        show_progress = show_progress,
    )
    reflect_expect = mean(reflect_perms_avg)
    odd_perms_avg = calculate_jackvals_perms_avg(
        odd_shadows, 2;
        show_progress = show_progress,
    )
    odd_expect = mean(odd_perms_avg)
    even_perms_avg = calculate_jackvals_perms_avg(
        even_shadows, 2;
        show_progress = show_progress,
    )
    even_expect = mean(even_perms_avg)

    # jackknife groups: permutations not containing unitary i.
    reflect_jackvals = zeros(Float64, n_ru)
    odd_jackvals = zeros(Float64, n_ru)
    even_jackvals = zeros(Float64, n_ru)
    for i in 1:n_ru
        reflect_sum = 0.0
        reflect_count = 0
        odd_sum = 0.0
        odd_count = 0
        even_sum = 0.0
        even_count = 0

        for (idx, r) in enumerate(reflect_perms) 
            if i ∉ r
                reflect_sum += reflect_perms_avg[idx]
                reflect_count += 1
            end
        end
        μ = reflect_sum / reflect_count
        reflect_jackvals[i] = μ

        for (idx, r) in enumerate(purity_perms) 
            if i ∉ r
                odd_sum += odd_perms_avg[idx]
                odd_count += 1
                even_sum += even_perms_avg[idx]
                even_count += 1
            end
        end
        odd_μ = odd_sum / odd_count
        even_μ = even_sum / even_count
        odd_jackvals[i] = odd_μ
        even_jackvals[i] = even_μ
    end

    Z_R(R_I_val, P_I1, P_I2) = R_I_val / sqrt((P_I1 + P_I2) / 2)
    z_r_val = Z_R(reflect_expect, odd_expect, even_expect)
    z_r_jackvals = Z_R.(reflect_jackvals, odd_jackvals, even_jackvals)

    return z_r_val, z_r_jackvals
end

function calculate_z_r_jackvals(
    shadows::Array{<:AbstractShadow,1},
    odd_shadows::Array{<:AbstractShadow,1},
    even_shadows::Array{<:AbstractShadow,1},
    reflect_op::MPO,
    show_progress::Bool = true,
)
    return calculate_z_r_jackvals(
        reshape(shadows, length(shadows), 1),
        reshape(odd_shadows, length(odd_shadows), 1),
        reshape(even_shadows, length(even_shadows), 1),
        reflect_op,
        show_progress,
    )
end
