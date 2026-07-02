using QuantumToolbox

function create_ssh_H(qubit_num::Int, p)
    pair_num = qubit_num ÷ 2

    # Definite the terms without t.
    X = sigmax()
    Y = sigmay()
    Z = sigmaz()
    qubit_dims = ntuple(_ -> 2, qubit_num)
    H1 = 0 * qeye(2^qubit_num; dims=qubit_dims)
    H2 = 0 * qeye(2^qubit_num; dims=qubit_dims)
    for pair_idx = 1:pair_num 
        odd_idx = 2pair_idx - 1
        even_idx = 2pair_idx
        for op in [X, Z]
            H1 += multisite_operator(
                Val(qubit_num),
                odd_idx => op, even_idx => op,
            )
        end
    end
    for pair_idx = 1:pair_num - 1 
        odd_idx = 2pair_idx + 1
        even_idx = 2pair_idx
        for op in [X, Z]
            H2 += multisite_operator(
                Val(qubit_num),
                odd_idx => op, even_idx => op,
            )
        end
    end

    # Definite the terms with t.
    s(p, t) = t / p.T
    H = QobjEvo((
        H2,
        (H1 - H2, s), 
    ))
    return H
end

function create_magnet_quantity(qubit_num)
    Z = sigmaz()
    qubit_dims = ntuple(_ -> 2, qubit_num)
    magnet_quantity = 0 * qeye(2^qubit_num; dims=qubit_dims)
    for qubit_idx = 1:qubit_num
        magnet_quantity += multisite_operator(
            Val(qubit_num),
            qubit_idx => Z,
        )
    end
    magnet_quantity = magnet_quantity / qubit_num
    return magnet_quantity
end

function create_sym_op(qubit_num)
    qubit_dims = ntuple(_ -> 2, qubit_num)
    X = sigmax()
    Z = sigmaz()
    ux = multisite_operator(
        Val(qubit_num), 
        (i => X for i in 1:qubit_num)...
    )
    uz = multisite_operator(
        Val(qubit_num), 
        (i => Z for i in 1:qubit_num)...
    )
    return ux + 2uz 
end

