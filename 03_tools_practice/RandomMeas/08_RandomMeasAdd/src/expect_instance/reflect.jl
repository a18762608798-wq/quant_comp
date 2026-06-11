# -------------
# reflect operator 
# -------------

"""
get_reflect_shadow(filepath, site_indices, permuted_order; G, compute_sem, show_progress)

Compute the expectation value of the reflection operator Z_r using classical shadows.

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
    If true, also compute and return the standard error of the mean (SEM).
- show_progress::Bool
    If true, display progress information when performing calculations.

Returns
- If compute_sem == false: returns real(expectation)::Float64.
- If compute_sem == true: returns (real(expectation)::Float64, sem::Float64).

Notes
This function loads a permuted group from filepath, constructs dense
shadows for the permuted system, builds the adjacent-swap operator for reflection,
and delegates the expectation/SEM estimation to modified_get_expect_shadow.
"""
function get_reflect_shadow(
    filepath::String,
    site_indices,
    permuted_order;
    G=fill(1.0, length(site_indices))::Vector{Float64},
    compute_sem=false,
    show_progress=true,
)
    permuted_G = G[permuted_order]
    permuted_group, permuted_indices = import_permuted_group(
        filepath, site_indices, permuted_order
    )
    permuted_shadows = get_dense_shadows(permuted_group; G=permuted_G)
    adjacent_swap_op = create_adjacent_swap_op(permuted_indices)

    if compute_sem
        reflect_expect, sem = modified_get_expect_shadow(
            adjacent_swap_op,
            permuted_shadows;
            compute_sem=compute_sem,
            show_progress=show_progress,
        )
        return real(reflect_expect), sem
    else
        reflect_expect = modified_get_expect_shadow(
            adjacent_swap_op,
            permuted_shadows;
            compute_sem=compute_sem,
            show_progress=show_progress,
        )
        return real(reflect_expect)
    end
end

"""
get_reflect_hamming(data::MeasurementData)

Compute the reflection expectation value using the Hamming distance method
for a single MeasurementData object.

Arguments
- data::MeasurementData: a single measurement dataset.

Returns
- reflect_est::Float64: estimated reflection expectation value.

Notes
The estimator uses the formula: R = (1/NM) * Σ_m 2^pairs * (-2)^(-hamming_dist(m)),
where the system is split into adjacent odd/even site pairs.
"""
function get_reflect_hamming(
    data::MeasurementData,
)
    # get data
    qubits_num = data.N
    m_num = data.NM
    results = data.measurement_results
    pairs_num = qubits_num ÷ 2
    odd_order = [2i - 1 for i in 1:pairs_num]
    even_order = [2i for i in 1:pairs_num]

    # get reflect_est
    ssum = 0
    for m_idx = 1:m_num
        result = results[m_idx, :]
        odd_result = @view result[odd_order]
        even_result = @view result[even_order]
        hamming_dist = sum(odd_result .!= even_result)
        ssum += (-2.0)^(-hamming_dist)
    end
    ssum *= 2.0^pairs_num

    reflect_est = ssum / m_num

    return reflect_est
end

"""
get_reflect_hamming(filepath, site_indices, permuted_order; compute_sem, show_progress)

Compute the reflection expectation value using the Hamming distance method
from saved measurement data, averaging over random unitary settings.

Arguments
- filepath::String: path to the .npz file produced by the measurement routines.
- site_indices: array of site indices corresponding to the group saved in the file.
- permuted_order: permutation vector indicating the new ordering of sites.

Keyword arguments
- compute_sem::Bool: if true, compute and return the standard error of the mean (SEM)
  across different random-unitary settings.
- show_progress::Bool: if true, display progress information.

Returns
- If compute_sem == false: returns reflect_est::Float64.
- If compute_sem == true: returns (reflect_est::Float64, sem::Float64).

Notes
This function loads a permuted group, then for each random-unitary setting computes
the Hamming-distance reflection estimator via get_reflect_hamming(::MeasurementData),
and averages the results across settings.
"""
function get_reflect_hamming(
    filepath::String,
    site_indices,
    permuted_order;
    compute_sem=false,
    show_progress=true,
)
    # get data
    group, _ = import_permuted_group(
        filepath, site_indices, permuted_order
    )
    u_num = group.NU
    datas = group.measurements
    reflect_ests = Vector{Float64}(undef, u_num)

    # get reflect_est
    ssum = 0
    @showprogress desc="hamming_est..." enabled=show_progress @threads  for u_idx = 1:u_num
        data = datas[u_idx]
        reflect_ests[u_idx] = get_reflect_hamming(data)
    end
    
    reflect_est = mean(reflect_ests)

    if compute_sem
        sem = std(reflect_ests) / sqrt(u_num)
        return reflect_est, sem
    else
        reflect_est = mean(reflect_ests)
        return reflect_est
    end

end

function get_reflect_pauli(
    nontrivial_meas_re::AbstractArray{<:Integer, 1}, 
    nontrivial_base::AbstractArray{<:Integer, 1},
)
    # get info
    qubit_num = length(nontrivial_meas_re)
    pair_num = qubit_num ÷ 2
    # storage result
    dims_vec = [4 for _ = 1:qubit_num]
    general_meas_re = fill(NaN, Tuple(dims_vec))

    # calculate pauli_est
    # nontrival
    general_meas_re[nontrivial_base...] = prod(nontrivial_meas_re)

    # include partial trivial and totally trivial
    for trivial_num = 1:pair_num
        for trivial_pair_index in combinations(1:pair_num, trivial_num)
            # find the trivial indices
            odd_trivial_indices = 2trivial_pair_index .- 1
            even_trivial_indices = 2trivial_pair_index
            # revise the trivial re
            meas_re = copy(nontrivial_meas_re)
            meas_re[odd_trivial_indices] .= 1
            meas_re[even_trivial_indices] .= 1
            pauli_est = prod(meas_re) 
            # revise the trivial bases
            general_base = copy(nontrivial_base)
            general_base[odd_trivial_indices] .= 1
            general_base[even_trivial_indices] .= 1
            # storage
            general_meas_re[general_base...] = pauli_est
        end
    end

    return general_meas_re
end


function get_reflect_pauli(
    nontrivial_meas_res::AbstractArray{<:Integer, 2}, 
    nontrivial_bases::AbstractArray{<:Integer, 2},
)
    # get info
    nontrivial_bases_num, qubit_num = size(nontrivial_bases)
    # storage
    dims_vec = [4 for _ = 1:qubit_num]
    base_sums = zeros(Tuple(dims_vec))
    base_count = zeros(Int, Tuple(dims_vec))
    # calculate the est of pauli bases
    # calculat the sum of pauli bases
    for base_idx = 1:nontrivial_bases_num
        nontrivial_meas_re = @view nontrivial_meas_res[base_idx, :]
        base = @view nontrivial_bases[base_idx, :]
        meas_re = get_reflect_pauli(
            nontrivial_meas_re,
            base,
        )

        hit_pos = .!isnan.(meas_re)
        base_count .+= hit_pos
        base_sums[hit_pos] .+= meas_re[hit_pos]
    end
    # calculate the est of pauli bases
    hit_pos = base_count .> 0
    base_ests = base_sums[hit_pos] ./ base_count[hit_pos]
    base_sum = 1 / sqrt(2)^qubit_num * sum(base_ests)

    return base_sum
end

function get_reflect_pauli(
    nontrivial_meas_res::AbstractArray{<:Integer, 3}, 
    nontrivial_bases::AbstractArray{<:Integer, 2};
    compute_sem=false,
)
    shot_num = size(nontrivial_meas_res, 2)
    base_ests = Vector{Float64}(undef, shot_num)
    for shot_idx = 1:shot_num
        nontrivial_meas_re = nontrivial_meas_res[:, shot_idx, :]
        base_ests[shot_idx] = get_reflect_pauli(
            nontrivial_meas_re,
            nontrivial_bases,
        )
    end
    est = mean(base_ests)
    if compute_sem
        sem = std(base_ests) / sqrt(shot_num)
        return est, sem
    else
        return est
    end

end

function get_reflect_pauli(
    filepath,
    permuted_order;
    kwargs...
)
    res, bases = import_permuted_pauli(filepath, permuted_order)
    return get_reflect_pauli(res, bases; kwargs...)

end
