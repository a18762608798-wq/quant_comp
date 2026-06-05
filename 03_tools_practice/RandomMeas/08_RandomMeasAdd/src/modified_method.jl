# --------------------
# get expect shadow
# --------------------

"""
modified_get_expect_shadow(O, shadows; compute_sem=false, show_progress=true)

Estimate the expectation value of operator O using an array of classical shadows.

Arguments
- O::MPO
    The operator (as an MPO) whose expectation value is to be estimated.
- shadows::AbstractArray{<:AbstractShadow, 2}
    A 2D array of shadows with dimensions (settings_num, shots). Each element is an
    AbstractShadow representing the classical shadow for a given random unitary and shot.

Keyword arguments
- compute_sem::Bool=false
    If true, return (mean, sem) where sem is the standard error of the mean across
    different random-unitary settings.
- show_progress::Bool=true
    If true, display progress bars for inner loops.

Returns
- If compute_sem == false: returns mean_value::ComplexF64 (mean expectation).
- If compute_sem == true: returns (mean_value::ComplexF64, sem_value::Float64).

Notes
This function computes expectation values for each (setting, shot) pair by calling
get_expect_shadow, averages over shots and settings, and optionally computes the
standard error (SEM) across settings. A dispatch overload accepts a 1D vector of
shadows and reshapes it to the expected 2D form.
"""
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

"""
modified_get_expect_shadow(O, shadows::AbstractShadow[]; kwargs...)

Overload for a 1D vector of shadows. Internally reshapes the vector into a
single-column 2D array and calls the 2D implementation.
"""
function modified_get_expect_shadow(
    O::MPO, shadows::AbstractArray{<:AbstractShadow, 1}; kwargs...
)
    return modified_get_expect_shadow(O, reshape(shadows, length(shadows), 1); kwargs...)
end

# --------------------
# get trace moment
# --------------------

"""
modified_get_trace_moment(shadows, kth_moment; O=nothing, compute_sem=false, compute_renyi=false, show_progress=true)

Estimate the k-th trace moment (e.g. Tr(ρ^k) when O==nothing or generalized trace products when O provided)
using classical shadows.

Arguments
- shadows::Array{<:AbstractShadow, 2}
    A 2D array of shadows with dimensions (n_ru, n_m), where n_ru is the number of
    random-unitary settings and n_m the number of measurement shots per setting.
- kth_moment::Int
    The moment k to estimate.

Keyword arguments
- O::Union{Nothing, MPO}=nothing
    Optional operator inserted into the trace product. When O==nothing the routine
    estimates pure trace moments of the state.
- compute_sem::Bool=false
    If true, compute and return jackknife-based bias and standard error.
- compute_renyi::Bool=false
    If true, transform estimates to Rényi entropy form (uses (1/(1-k)) * log2(mean)).
- show_progress::Bool=true
    Toggle progress display.

Returns
- If compute_sem == false: returns scalar moment estimate::Float64.
- If compute_sem == true: returns (estimate::Float64, bias::Float64, sem::Float64).

Notes
This function delegates to modified_get_trace_moments which supports vectorized k
inputs and covariance estimation. A 1D shadows overload reshapes input to the
expected 2D form.
"""
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

"""
modified_get_trace_moment(shadows::AbstractShadow[]..., kth_moment; kwargs...)

Overload for 1D shadow vectors. Reshapes shadows to a 2D single-column array and
calls the main implementation.
"""
function modified_get_trace_moment(
    shadows::Array{<:AbstractShadow, 1}, kth_moment::Int; kwargs...
)
    return modified_get_trace_moment(
        reshape(shadows, length(shadows), 1), kth_moment; kwargs...
    )
end

"""
modified_get_trace_moments(shadows, k_vec; O=nothing, compute_cov=false, compute_renyi=false, show_progress=true)

Estimate multiple trace moments specified by k_vec. Returns a vector of estimates
and optionally jackknife-based bias and covariance matrix.

Algorithm
- Enumerates all permutations of k distinct random-unitary settings and the
  Cartesian product over shots for those settings.
- Computes per-permutation averages of trace products (via get_trace_product).
- Optionally applies a Rényi transform for compute_renyi.
- If compute_cov is true, computes jackknife values by leaving out each unitary
  and constructs a covariance matrix and bias-corrected estimates.

Arguments
- shadows::Array{<:AbstractShadow, 2}
    Shadows arranged as (n_ru, n_m).
- k_vec::Vector{Int}
    List of integer moments to compute.

Keyword arguments
- O::Union{Nothing, MPO}=nothing
- compute_cov::Bool=false
- compute_renyi::Bool=false
- show_progress::Bool=true

Returns
- If compute_cov == false: returns θ_est::Vector{Float64} of length nK.
- If compute_cov == true: returns (θ_est, bias_vec, Σ) where bias_vec = θ_est - θ_jack and Σ is the covariance matrix.
"""
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

"""
modified_get_trace_moment(shadows::Vector{<:AbstractShadow}, kth_moment::Int; kwargs...)

Overload for vector of shadows. Reshapes to 2D and calls modified_get_trace_moment.
"""
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
"""
modified_get_purity_shadow(shadows; compute_sem=false, compute_renyi=false, show_progress=true)

Estimate the purity Tr(ρ^2) of the underlying quantum state using classical shadows.

Arguments
- shadows::Array{<:AbstractShadow, 2}
    Shadows arranged as (n_ru, n_m).

Keyword arguments
- compute_sem::Bool=false
    If true, compute and return jackknife-based bias and standard error.
- compute_renyi::Bool=false
    If true, adapt the jackknife values for Rényi transform if applicable.
- show_progress::Bool=true

Returns
- If compute_sem == false: returns purity_estimate::Float64.
- If compute_sem == true: returns (purity_estimate::Float64, bias::Float64, sem::Float64).

Notes
This function relies on calculate_purity_jackvals to obtain jackknife values for
the purity estimator and then computes bias and SEM when requested.
"""
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

"""
modified_get_purity_shadow(shadows::Vector{<:AbstractShadow}; kwargs...)

Overload for vector-of-shadows input. Reshapes to 2D and delegates to the main function.
"""
function modified_get_purity_shadow(shadows::Vector{<:AbstractShadow}; kwargs...)
    return modified_get_purity_shadow(reshape(shadows, length(shadows), 1); kwargs...)
end
