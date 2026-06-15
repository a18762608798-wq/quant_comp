# ----------
# purity
# ----------
"""
get_purity_shadow(filepath, site_indices, permuted_order; G, compute_sem, show_progress)

Estimate the purity Tr(ρ²) using classical shadows from saved measurement data.

Arguments
- filepath::String: path to the .npz file produced by the measurement routines.
- site_indices: array of site indices corresponding to the group saved in the file.
- permuted_order: permutation vector indicating the new ordering of sites.

Keyword arguments
- G::Vector{Float64}: weight vector per site (default: ones). It is permuted according to permuted_order.
- compute_sem::Bool: if true, also compute and return the standard error of the mean (SEM).
- show_progress::Bool: if true, display progress information.

Returns
- If compute_sem == false: returns purity::Float64.
- If compute_sem == true: returns (purity::Float64, sem::Float64).

Notes
This function loads a permuted group from filepath, constructs dense shadows,
and delegates purity estimation to modified_get_purity_shadow.
"""
function get_purity_shadow(
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
    shadows = get_dense_shadows(permuted_group; G=permuted_G)

    if compute_sem
        purity, _, sem = modified_get_purity_shadow(
            shadows;
            compute_sem=compute_sem,
            show_progress=show_progress,
        )
        return purity, sem

    else
        purity = modified_get_purity_shadow(
            shadows;
            compute_sem=compute_sem,
            show_progress=show_progress,
        )
        return purity

    end
end

"""
get_purity_hamming(filepath, site_indices, permuted_order; compute_sem, show_progress)

Estimate the purity Tr(ρ²) using the overlap-based method ("hamming" variant)
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
- If compute_sem == false: returns purity_est::Float64.
- If compute_sem == true: returns (purity_est::Float64, sem::Float64).

Notes
This function loads a permuted group, then for each random-unitary setting computes
the purity via get_overlap(data, data; apply_bias_correction=true),
and averages the results across settings.
"""
function get_purity_hamming(
    filepath::String,
    site_indices,
    permuted_order;
    compute_sem=false,
    show_progress=true,
)
    group, _ = import_permuted_group(
        filepath, site_indices, permuted_order
    )

    u_num = group.NU
    datas = group.measurements
    purity_ests = Vector{Float64}(undef, u_num)

    @showprogress desc="hamming_est..." enabled=show_progress @threads  for u_idx = 1:u_num
        data = datas[u_idx]
        purity_ests[u_idx] = get_overlap(data, data, apply_bias_correction=true)
    end

    purity_est = mean(purity_ests)

    if compute_sem
        sem = std(purity_ests) / sqrt(u_num)
        return purity_est, sem

    else
        purity_est = mean(purity_ests)
        return purity_est

    end
end

# ------------
# get pauli purity
# ------------
function get_purity_pauli(
    pauli_path::String,
    permuted_order::Vector;
    compute_sem=false,
    show_progress=true,
)
    res, bases = import_permuted_pauli(
        pauli_path, permuted_order
    );
    shot_num = size(res, 2)
    base_ests = clean_pauli_data(res, bases)
    purity_est, loos = get_purity_loos_pauli(
        base_ests;
        show_progress=show_progress,
    )

    if compute_sem
        variance = (shot_num - 1)^2 / shot_num * var(loos)
        sem = sqrt(variance)
        return purity_est, sem
    else
        return purity_est
    end
end

