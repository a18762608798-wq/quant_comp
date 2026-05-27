# reflect op 
function create_reflect_op(siteindices::Vector{Index{Int64}})
    bitsnum = length(siteindices)
    @assert iseven(bitsnum) "bitsnum must be even" # constrain
    pairsnum = bitsnum ÷ 2
    identity_op = MPO(siteindices, "Id")
    gates = [
        op("SWAP", siteindices[i], siteindices[bitsnum - i + 1]) for i = 1:pairsnum
    ]
    reflect_op = apply(gates, identity_op)
    return reflect_op
end

# adjacent swap 
function create_adjacent_swap_op(siteindices::Vector{Index{Int64}})
    bitsnum = length(siteindices)
    @assert iseven(bitsnum) "bitsnum must be even" # constrain
    pairsnum = bitsnum ÷ 2
    identity_op = MPO(siteindices, "Id")
    gates = [
        op("SWAP", siteindices[2i - 1], siteindices[2i]) for i = 1:pairsnum
    ]
    adjacent_swap_op = apply(gates, identity_op)
    return adjacent_swap_op
end

# unitary part of the time reversal operator
function create_unitary_part_reversal_op(
    part1::Vector{Int64},
    site_indices::Vector{Index{Int64}};
    op_type = "MPO"
)
    qubits_num = length(site_indices)
    identity_op = MPO(site_indices, "Id")
    gates = [
        op("Y", site_indices[i]) for i in part1
    ]
    unitary_part_reversal_op = apply(gates, identity_op)
    if op_type == "MPO"
        return unitary_part_reversal_op
    elseif op_type == "ITensor"
        return contract(unitary_part_reversal_op)
    else
        error("wrong output type: $op_type")
    end
end
