# Import the data from npz accroding to permuted order; 
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

# transform shadows to a mpo
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


# -------------------------------------------
# --- calculate the jackvals ----------------
# -------------------------------------------

# 2 moment
function calculate_jackvals_2_moment(
    shadows::Array{<:AbstractShadow,2};
    O::Union{Nothing,MPO} = nothing,
    compute_renyi::Bool        = false,
    show_progress::Bool = true,
)
    n_ru, n_m = size(shadows)
    # pre-enumerate permutations and m–cartesian product
    perms   = collect(combinations(1:n_ru, 2))
    cprod   = collect(CartesianIndices(ntuple(_ -> 1:n_m, 2)))
    n_perm  = length(perms)

    # average over measurements for each permutation
    perm_avg = zeros(Float64, n_perm)
    @showprogress desc="Permutations Processing..." enabled=show_progress @threads for pidx in eachindex(perms)
        r = perms[pidx]

        ssum = 0.0
        for m in cprod
            ssum += real(get_trace_product(
                (shadows[r[i], m[i]] for i in 1:2)...; O
            ))
        end

        perm_avg[pidx] = ssum / length(cprod)
    end

    # define the averaging functional
    avgfun(x) = compute_renyi ?
        (1/ (1 - 2)) * log2(mean(x)) :
        mean(x)

    θ  = avgfun(perm_avg)

    # jackknife groups: permutations not containing unitary i
    groups = Vector{Vector{Int}}(undef, n_ru)
    for i in 1:n_ru
        groups[i] = [idx for (idx,r) in enumerate(perms) if i ∉ r]
    end

    jackvals = zeros(Float64, n_ru)
    for i in 1:n_ru
        jackvals[i] = avgfun(perm_avg[groups[i]])
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
    n_ru, n_m = size(shadows)
    # pre-enumerate permutations and m–cartesian product
    perms   = collect(combinations(1:n_ru, 1))
    cprod   = collect(CartesianIndices(ntuple(_ -> 1:n_m, 1)))
    n_perm  = length(perms)

    # average over measurements for each permutation
    perm_avg = zeros(Float64, n_perm)
    @showprogress desc="Permutations Processing..." enabled=show_progress @threads for pidx in eachindex(perms)
        r = perms[pidx]

        ssum = 0.0
        for m in cprod
            ssum += real(get_trace_product(
                (shadows[r[i], m[i]] for i in 1:1)...; O
            ))
        end

        perm_avg[pidx] = ssum / length(cprod)
    end

    θ  = mean(perm_avg)

    # jackknife groups: permutations not containing unitary i
    groups = Vector{Vector{Int}}(undef, n_ru)
    for i in 1:n_ru
        groups[i] = [idx for (idx,r) in enumerate(perms) if i ∉ r]
    end

    jackvals = zeros(Float64, n_ru)
    for i in 1:n_ru
        jackvals[i] = mean(perm_avg[groups[i]])
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
    even_shadows::Array{<:AbstractShadow,2};
)
    Z_R(R_I_val, P_I1, P_I2) = R_I_val / (sqrt((P_I1 + P_I2) / 2)) # Z_R function


end
