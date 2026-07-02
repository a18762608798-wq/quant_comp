using QuantumToolbox

# 子空间对角化
function get_subspace_op(H, states)
    n = length(states)
    op = zeros(ComplexF64, n, n)

    for a in 1:n
        for b in 1:n
            op[a, b] = matrix_element(states[a], H, states[b])
        end
    end

    return Qobj(Hermitian((op + op') / 2))
end
