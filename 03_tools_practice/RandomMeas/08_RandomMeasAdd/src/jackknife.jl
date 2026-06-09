# ---------------------
# get the jackknife loos
# ---------------------

"""
Compute averaged trace-products for all k-element permutations of random
unitaries and over measurement indices.

Arguments
- shadows::Array{<:AbstractShadow, 2}: a (n_ru, n_m) array of shadow objects
  where n_ru is number of random unitaries and n_m is measurements per unitary.
- k::Int: permutation size (supported values 1 or 2).

Keyword Arguments
- O::Union{Nothing, MPO}=nothing: optional MPO operator passed to get_trace_product
  (only allowed for k == 1).
- show_progress::Bool=true: enable progress display.

Returns
- Array{Float64} of length choose(n_ru, k) with the mean trace-product for each
  k-permutation averaged over measurement Cartesian products.
"""
function get_comb_avgs_shadow(
    shadows::Array{<:AbstractShadow, 2},
    k::Int;
    O::Union{Nothing, MPO}=nothing,
    show_progress=true,
)
    @assert (k == 2 && isnothing(O)) || (k == 1) "O must be nothing for k=2, and k in the range of [1, 2]"

    # pre-enumerate permutations and m–cartesian product
    n_ru, n_m = size(shadows)
    combs = collect(combinations(1:n_ru, k))
    cprod = collect(CartesianIndices(ntuple(_ -> 1:n_m, k)))
    combs_num = length(combs)

    # average over measurements for each permutation
    comb_avgs = zeros(Float64, combs_num)
    @showprogress desc="Combinations Processing..." enabled=show_progress @threads for pidx in eachindex(combs)
        r = combs[pidx]
        ssum = 0.0
        for m in cprod
            ssum += real(get_trace_product((shadows[r[i], m[i]] for i in 1:k)...; O))
        end
        comb_avgs[pidx] = ssum / length(cprod)
    end

    return comb_avgs
end

function get_combs_loos_shadow(
    n_ru::Int64,
    combs::Vector{Vector{Int64}},
    avgs::Vector{Float64},
)
    k = length(first(combs))
    ssum = sum(avgs) # The sum of avg
    incident_threads = zeros(Float64, n_ru, Threads.maxthreadid()) # Sums of combinations that contain each random unitary.
    # get leave-one-out.
    @threads for idx in eachindex(combs)
        tid = threadid()
        incident_indices = combs[idx] # Record incidented items.
        incident_val = avgs[idx]
        for index in incident_indices 
            incident_threads[index, tid] += incident_val
        end
    end
    incidents = vec(sum(incident_threads; dims=2))
    denom = binomial(n_ru - 1, k)
    loos = (ssum .- incidents) ./ denom # Get loos

    return loos
end

# 2 moment
"""
Estimate the second moment (purity) from shadow data and compute jackknife
estimates over random unitaries.

Arguments
- shadows::Array{<:AbstractShadow, 2}: (n_ru, n_m) shadow data.

Keyword Arguments
- compute_renyi::Bool=false: if true, return the Rényi-2 entropy estimate
  (uses log2 of the averaged purity); otherwise returns purity.
- show_progress::Bool=true: show progress during permutation averaging.

Returns
- θ: scalar estimate (purity or Rényi-2 depending on compute_renyi).
- loos::Vector{Float64}: leave-one-out jackknife estimates for each random
  unitary.
"""
function get_purity_loos_shadow(
    shadows::Array{<:AbstractShadow, 2}; compute_renyi::Bool=false, show_progress::Bool=true
)
    n_ru, n_m = size(shadows)
    @assert n_ru ≥ 3 "At least 3 random unitaries are required for 2-moment estimation."
    # pre-enumerate permutations
    combs = collect(combinations(1:n_ru, 2))

    # average over measurements for each permutation
    comb_avgs = get_comb_avgs_shadow(shadows, 2; show_progress=show_progress)

    # define the averaging functional
    avgfun(x) = compute_renyi ? (1 / (1 - 2)) * log2(mean(x)) : mean(x)

    θ = avgfun(comb_avgs)

    # jackknife loo groups: permutations not containing unitary i
    loos = get_combs_loos_shadow(
        n_ru,
        combs,
        comb_avgs,
    )

    return θ, loos
end

function get_purity_loos_shadow(shadows::Vector{<:AbstractShadow}; kwargs...)
    return get_purity_loos_shadow(reshape(shadows, length(shadows), 1); kwargs...)
end

"""
Estimate the first moment (expectation value) from shadow data and compute
jackknife estimates.

Arguments
- shadows::Array{<:AbstractShadow, 2}: (n_ru, n_m) shadow data.

Keyword Arguments
- O::Union{Nothing, MPO}=nothing: optional MPO operator used in the trace
  product evaluation (for expectation value estimation).
- show_progress::Bool=true: show progress during permutation averaging.

Returns
- θ: scalar estimate (mean expectation value).
- loos::Vector{Float64}: leave-one-out jackknife estimates for each random
  unitary.
"""
function get_momnet1_loos_shadow(
    shadows::Array{<:AbstractShadow, 2};
    O::Union{Nothing, MPO}=nothing,
    show_progress::Bool=true,
)
    n_ru, _ = size(shadows)
    @assert n_ru ≥ 2 "At least 2 random unitaries are required for 1-moment estimation."
    combs = collect(combinations(1:n_ru, 1))

    # average over measurements for each permutation
    comb_avgs = get_comb_avgs_shadow(shadows, 1; O=O, show_progress=show_progress)
    θ = mean(comb_avgs)

    # jackknife loo groups: permutations not containing unitary i
    loos = get_combs_loos_shadow(
        n_ru,
        combs,
        comb_avgs,
    )

    return θ, loos
end

function get_momnet1_loos_shadow(shadows::Vector{<:AbstractShadow}; kwargs...)
    return get_momnet1_loos_shadow(reshape(shadows, length(shadows), 1); kwargs...)
end

"""
Compute the z_r estimator and jackknife values combining reflect and purity
estimates.

Arguments
- shadows::Array{<:AbstractShadow, 2}: shadows used for the reflect operator
  evaluation (n_ru, n_m).
- odd_shadows::Array{<:AbstractShadow, 2}: shadows for one purity partition.
- even_shadows::Array{<:AbstractShadow, 2}: shadows for the complementary purity partition.
- reflect_op::MPO: operator used for the reflect expectation.

Keyword Arguments
- show_progress::Bool=true: show progress while averaging permutations.

Returns
- z_r_val::Float64: combined estimator value.
- z_r_loos::Vector{Float64}: jackknife leave-one-out estimates for z_r.

Notes
- z_r is computed as R / sqrt((P_odd + P_even)/2) where R is the reflect
  expectation and P_odd/P_even are the two purity estimates.
"""
function get_z_r_loos_shadow(
    shadows::Array{<:AbstractShadow, 2},
    odd_shadows::Array{<:AbstractShadow, 2},
    even_shadows::Array{<:AbstractShadow, 2},
    reflect_op::MPO,
    show_progress::Bool=true,
)
    # Pre-enumerate permutations (and m–cartesian product)
    n_ru, _ = size(shadows)
    @assert n_ru ≥ 3 "At least 3 random unitaries are required for z_r estimation."
    reflect_combs = collect(combinations(1:n_ru, 1))
    purity_combs = collect(combinations(1:n_ru, 2))

    # average over measurements for each permutation
    reflect_comb_avgs = get_comb_avgs_shadow(
        shadows, 1; O=reflect_op, show_progress=show_progress
    )
    reflect_expect = mean(reflect_comb_avgs)
    odd_comb_avgs = get_comb_avgs_shadow(
        odd_shadows, 2; show_progress=show_progress
    )
    odd_expect = mean(odd_comb_avgs)
    even_comb_avgs = get_comb_avgs_shadow(
        even_shadows, 2; show_progress=show_progress
    )
    even_expect = mean(even_comb_avgs)

    # Loo groups: leave-one-out.
    # get reflect leave-one-out.
    reflect_loos = get_combs_loos_shadow(
        n_ru,
        reflect_combs,
        reflect_comb_avgs,
    )
    # get purity leave-one-out.
    odd_loos = get_combs_loos_shadow(
        n_ru,
        purity_combs,
        odd_comb_avgs,
    )
    even_loos = get_combs_loos_shadow(
        n_ru,
        purity_combs,
        even_comb_avgs,
    )
    # get z_r_loos
    Z_R(R_I_val, P_I1, P_I2) = R_I_val / sqrt((P_I1 + P_I2) / 2)
    z_r_est = Z_R(reflect_expect, odd_expect, even_expect)
    z_r_loos = Z_R.(reflect_loos, odd_loos, even_loos)

    return z_r_est, z_r_loos
end

"""
Convenience overload accepting vectors for shadows; reshapes inputs to the
2D form and forwards to the main get_z_r_loos_shadow function.
"""
function get_z_r_loos_shadow(
    shadows::Array{<:AbstractShadow, 1},
    odd_shadows::Array{<:AbstractShadow, 1},
    even_shadows::Array{<:AbstractShadow, 1},
    reflect_op::MPO,
    show_progress::Bool=true,
)
    return get_z_r_loos_shadow(
        reshape(shadows, length(shadows), 1),
        reshape(odd_shadows, length(odd_shadows), 1),
        reshape(even_shadows, length(even_shadows), 1),
        reflect_op,
        show_progress,
    )
end

