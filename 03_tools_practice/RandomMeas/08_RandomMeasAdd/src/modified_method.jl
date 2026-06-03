# --------------------
# get expect shadow
# --------------------

function modified_get_expect_shadow(
    O::MPO,
    shadows::AbstractArray{<:AbstractShadow, 2};
    compute_sem::Bool=false,
    show_progress::Bool=true,
)
    # Ensure the array of shadows is not empty and is a matrix
    @assert !isempty(shadows) "Array of shadows is empty."

    # Compute all expectation values
    settings_num, shots = size(shadows)
    expect_values = Matrix{ComplexF64}(undef, settings_num, shots)
    @showprogress desc="Expectation Processing..." enabled=show_progress @threads for settings in
                                                                                      1:settings_num

        for shot in 1:shots
            shadow = shadows[settings, shot]
            expect_values[settings, shot] = get_expect_shadow(O, shadow)
        end
    end

    # Compute mean (of every settings num)
    mean_values = mean(expect_values; dims=2)
    mean_value = mean(mean_values)

    if compute_sem
        # Compute standard error of the mean (SEM)
        sem_value = std(mean_values) / sqrt(settings_num)
        return mean_value, sem_value
    else
        return mean_value
    end
end

function modified_get_expect_shadow(
    O::MPO, shadows::AbstractArray{<:AbstractShadow, 1}; kwargs...
)
    return modified_get_expect_shadow(O, reshape(shadows, length(shadows), 1); kwargs...)
end

# --------------------
# get trace moment
# --------------------

function modified_get_trace_moment(
    shadows::Array{<:AbstractShadow, 2},
    kth_moment::Int;
    O::Union{Nothing, MPO}=nothing,
    compute_sem::Bool=false,
    compute_renyi::Bool=false,
    show_progress::Bool=true,
)
    if compute_sem
        s, bias, cov = modified_get_trace_moments(
            shadows,
            [kth_moment];
            O=O,
            compute_cov=compute_sem,
            compute_renyi=compute_renyi,
            show_progress=show_progress,
        )
        return s[1], bias[1], sqrt(cov[1, 1])
    else
        s = modified_get_trace_moments(
            shadows,
            [kth_moment];
            O=O,
            compute_cov=compute_sem,
            compute_renyi=compute_renyi,
            show_progress=show_progress,
        )
        return s[1]
    end
end

function modified_get_trace_moment(
    shadows::Array{<:AbstractShadow, 1}, kth_moment::Int; kwargs...
)
    return modified_get_trace_moment(
        reshape(shadows, length(shadows), 1), kth_moment; kwargs...
    )
end

function modified_get_trace_moments(
    shadows::Array{<:AbstractShadow, 2},
    k_vec::Vector{Int};
    O::Union{Nothing, MPO}=nothing,
    compute_cov::Bool=false,
    compute_renyi::Bool=false,
    show_progress::Bool=true,
)
    n_ru, n_m = size(shadows)
    k_vec_sorted = sort(unique(k_vec)) # work on distinct, ascending k
    nK = length(k_vec_sorted)

    # containers
    θ_est = zeros(Float64, nK)
    jackmat = compute_cov ? zeros(Float64, n_ru, nK) : nothing

    # --- helper: single-k estimator with optional jackknife ----------------
    function single_k(k::Int)
        @assert !(k == 1 && compute_renyi) "compute_renyi must be false when k == 1."
        # pre-enumerate permutations and m–cartesian product
        perms = collect(permutations(1:n_ru, k))
        cprod = collect(CartesianIndices(ntuple(_ -> 1:n_m, k)))
        n_perm = length(perms)

        # average over measurements for each permutation
        perm_avg = zeros(Float64, n_perm)
        @showprogress desc="Permutations Processing..." enabled=show_progress @threads for pidx in
                                                                                           eachindex(
            perms
        )
            r = perms[pidx]

            ssum = 0.0
            for m in cprod
                ssum += real(get_trace_product((shadows[r[i], m[i]] for i in 1:k)...; O))
            end

            perm_avg[pidx] = ssum / length(cprod)
        end

        # define the averaging functional
        avgfun(x) = compute_renyi ? (1/(1-k))*log2(mean(x)) : mean(x)

        θ = avgfun(perm_avg)

        if !compute_cov
            return θ, nothing
        end

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
            jackvals[i] = compute_renyi ? (1 / (1 - k)) * log2(μ) : μ
        end
        return θ, jackvals
    end
    # -----------------------------------------------------------------------

    # loop over desired moments
    for (idx, k) in enumerate(k_vec_sorted)
        θ_est[idx], jv = single_k(k)
        if compute_cov
            jackmat[:, idx] = jv
        end
    end

    # build covariance if requested
    if compute_cov
        Σ = zeros(Float64, nK, nK)
        for a in 1:nK, b in a:nK           # symmetric
            cov =
                (n_ru-1)^2/n_ru * dot(
                    jackmat[:, a] .- mean(jackmat[:, a]),
                    jackmat[:, b] .- mean(jackmat[:, b]),
                ) / (n_ru-1)
            Σ[a, b] = Σ[b, a] = cov
        end

        θ_jack = n_ru * θ_est .- (n_ru - 1) * vec(mean(jackmat; dims=1))

        return θ_est, θ_est - θ_jack, Σ
    else
        return θ_est
    end
end

function modified_get_trace_moment(
    shadows::Vector{<:AbstractShadow}, kth_moment::Int; kwargs...
)
    return modified_get_trace_moment(
        reshape(shadows, length(shadows), 1), kth_moment; kwargs...
    )
end

# --------------------
# get purity
# --------------------

# This function is only for O == nothing.
function modified_get_purity_shadow(
    shadows::Array{<:AbstractShadow, 2};
    compute_sem::Bool=false,
    compute_renyi::Bool=false,
    show_progress::Bool=true,
)
    n_ru, n_m = size(shadows)

    # loop over desired moments
    θ_est, jackmat = calculate_purity_jackvals(
        shadows; compute_renyi=compute_renyi, show_progress=show_progress
    )

    # build covariance if requested
    if compute_sem
        variance = (n_ru - 1)^2 / n_ru * var(jackmat)
        sem = sqrt(variance)
        θ_jack = n_ru * θ_est - (n_ru - 1) * mean(jackmat)
        return θ_est, θ_est - θ_jack, sem
    else
        return θ_est
    end
end

function modified_get_purity_shadow(shadows::Vector{<:AbstractShadow}; kwargs...)
    return modified_get_purity_shadow(reshape(shadows, length(shadows), 1); kwargs...)
end
