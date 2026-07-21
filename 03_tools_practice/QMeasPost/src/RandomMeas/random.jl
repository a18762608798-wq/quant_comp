# random.jl — Classical shadow post-processing for random measurements

const PAULI_MATRICES = Dict(
    "I" => Matrix{ComplexF32}([1 0; 0 1]),
    "X" => Matrix{ComplexF32}([0 1; 1 0]),
    "Y" => Matrix{ComplexF32}([0 -im; im 0]),
    "Z" => Matrix{ComplexF32}([1 0; 0 -1]),
)

function _pauli_expect(pauli_char::Char, psi::Vector{ComplexF32})::Float32
    P = PAULI_MATRICES[string(pauli_char)]
    real(psi' * P * psi)
end

function _shadow_prediction(
    theta::Vector{Float32},
    lambda::Vector{Float32},
    bits::AbstractString,
    pauli_str::AbstractString,
)::Float32
    k = count(c -> c != 'I', pauli_str)
    val = Float32(1.0)
    for (idx, pch) in enumerate(pauli_str)
        pch == 'I' && continue
        psi = u3_state(theta[idx], lambda[idx], parse(Int, bits[idx]))
        val *= 3 * _pauli_expect(pch, psi)
    end
    val
end

function _setting_expectation(
    theta::Vector{Float32},
    lambda::Vector{Float32},
    counts::AbstractDict{String,Int},
    pauli_str::AbstractString,
)::Float32
    total = sum(values(counts))
    sum_val = Float32(0.0)
    for (bits, c) in counts
        sum_val += c * _shadow_prediction(theta, lambda, bits, pauli_str)
    end
    sum_val / total
end

function expect_shadow(
    result::RandomMeasResult,
    pauli_str::AbstractString,
)::Float32
    n_qubits = length(result.meas_indices)
    @assert length(pauli_str) == n_qubits "pauli_str length must match meas_indices ($n_qubits)"

    setting_expects = Vector{Float32}[]

    for run_idx in 1:length(result.setting_runs)
        setting_num = result.setting_runs[run_idx][1]
        theta_mat = result.params[run_idx]["theta"]
        lambda_mat = result.params[run_idx]["lambda"]
        counts_list = result.count_group[run_idx]

        run_vals = Float32[]
        for s in 1:setting_num
            theta_s = theta_mat[s, :]
            lambda_s = lambda_mat[s, :]
            counts_s = counts_list[s]
            push!(run_vals, _setting_expectation(theta_s, lambda_s, counts_s, pauli_str))
        end
        push!(setting_expects, run_vals)
    end

    median_of_means(setting_expects)
end

function shadow_state(
    result::RandomMeasResult,
    run_idx::Int = 1,
)::Matrix{ComplexF32}
    n_qubits = length(result.meas_indices)
    dim = 1 << n_qubits
    rho = zeros(ComplexF32, dim, dim)

    setting_num = result.setting_runs[run_idx][1]
    theta_mat = result.params[run_idx]["theta"]
    lambda_mat = result.params[run_idx]["lambda"]
    counts_list = result.count_group[run_idx]

    for s in 1:setting_num
        theta_s = theta_mat[s, :]
        lambda_s = lambda_mat[s, :]
        counts_s = counts_list[s]
        total = sum(values(counts_s))
        for (bits, c) in counts_s
            w = c / total
            sigma = _full_shadow_snapshot(theta_s, lambda_s, bits)
            rho .+= (w / setting_num) .* sigma
        end
    end
    rho
end

function _full_shadow_snapshot(
    theta_s::Vector{Float32},
    lambda_s::Vector{Float32},
    bits::AbstractString,
)::Matrix{ComplexF32}
    n = length(bits)
    dim = 1 << n
    sigma = reduce(kron, (
        single_qubit_shadow(theta_s[i], lambda_s[i], parse(Int, bits[i]))
        for i in 1:n
    ); init = ones(ComplexF32, 1, 1))
    sigma
end

function classical_shadow_channel_inverse(A::Matrix{ComplexF32})::Matrix{ComplexF32}
    3 * A - I * tr(A)
end

function parallel_shadow_states(
    result::RandomMeasResult,
)::Vector{Vector{Matrix{ComplexF32}}}
    n_runs = length(result.setting_runs)
    run_states = Vector{Matrix{ComplexF32}}[]
    for run_idx in 1:n_runs
        push!(run_states, [shadow_state(result, run_idx)])
    end
    run_states
end

function median_of_means(data::Vector{Vector{Float32}})::Float32
    means = Float32[]
    for group in data
        push!(means, mean(group))
    end
    median(means)
end
