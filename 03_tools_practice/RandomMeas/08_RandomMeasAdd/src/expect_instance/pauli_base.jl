function clean_pauli_data(
    nontrivial_meas_re::AbstractArray{<:Integer, 1}, 
    nontrivial_base::AbstractArray{<:Integer, 1},
)
    # get info
    qubit_num = length(nontrivial_meas_re)
    # storage result
    dims_vec = [4 for _ = 1:qubit_num]
    general_meas_re = fill(NaN, Tuple(dims_vec))

    # calculate pauli_est
    # nontrival
    general_meas_re[nontrivial_base...] = prod(nontrivial_meas_re)

    # include partial trivial and totally trivial
    for trivial_num = 1:qubit_num
        for trivial_indices in combinations(1:qubit_num, trivial_num)
            # revise the trivial re
            meas_re = copy(nontrivial_meas_re)
            meas_re[trivial_indices] .= 1
            pauli_est = prod(meas_re) 
            # revise the trivial bases
            general_base = copy(nontrivial_base)
            general_base[trivial_indices] .= 1
            # storage
            general_meas_re[general_base...] = pauli_est
        end
    end

    return general_meas_re
end

function clean_pauli_data(
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
        meas_re = clean_pauli_data(
            nontrivial_meas_re,
            base,
        )

        hit_pos = .!isnan.(meas_re)
        base_count .+= hit_pos
        base_sums[hit_pos] .+= meas_re[hit_pos]
    end
    # calculate the est of pauli bases
    base_ests = similar(base_sums, Float64)      
    fill!(base_ests, NaN)                       
    hit_pos = base_count .> 0
    base_ests[hit_pos] .= 1 / sqrt(2)^qubit_num .* base_sums[hit_pos] ./ base_count[hit_pos]

    return base_ests
end

function clean_pauli_data(
    nontrivial_meas_res::AbstractArray{<:Integer, 3}, 
    nontrivial_bases::AbstractArray{<:Integer, 2};
)
    shot_num = size(nontrivial_meas_res, 2)
    base_ests = Vector{Array{Float64}}(undef, shot_num)
    @threads for shot_idx = 1:shot_num
        nontrivial_meas_re = nontrivial_meas_res[:, shot_idx, :]
        base_ests[shot_idx] = clean_pauli_data(
            nontrivial_meas_re,
            nontrivial_bases,
        )
    end

    return base_ests
end

