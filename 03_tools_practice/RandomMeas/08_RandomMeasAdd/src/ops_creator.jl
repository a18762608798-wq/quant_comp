# --------------------
# local swap
# --------------------

"""
create_reflect_op(siteindices)

Create a reflection operator that swaps the i-th site with the (N - i + 1)-th site
for each i in 1:pairsnum. This implements a spatial reflection (swap of symmetric
positions) across the center of the 1D chain.

Arguments
- siteindices::Vector{Index{Int64}}: vector of site indices for the full system.

Returns
- reflect_op::MPO: matrix product operator representing the reflection.

Notes
- The number of sites (bitsnum) must be even.
- The operator is built by applying SWAP gates onto an identity MPO.
"""
function create_reflect_op(siteindices::Vector{Index{Int64}})
    bitsnum = length(siteindices)
    @assert iseven(bitsnum) "bitsnum must be even" # constraint
    pairsnum = bitsnum ÷ 2
    identity_op = MPO(siteindices, "Id")
    gates = [op("SWAP", siteindices[i], siteindices[bitsnum - i + 1]) for i in 1:pairsnum]
    reflect_op = apply(gates, identity_op)
    return reflect_op
end

# adjacent swap 
"""
create_adjacent_swap_op(siteindices)

Create an operator that swaps adjacent pairs of sites: (1, 2), (3, 4), ...,
(N-1, N). This is a local (nearest-neighbor) swap operator on the 1D chain.

Arguments
- siteindices::Vector{Index{Int64}}: vector of site indices for the full system.

Returns
- adjacent_swap_op::MPO: matrix product operator implementing adjacent swaps.

Notes
- The number of sites (bitsnum) must be even.
- The operator is built by applying SWAP gates onto an identity MPO.
"""
function create_adjacent_swap_op(siteindices::Vector{Index{Int64}})
    bitsnum = length(siteindices)
    @assert iseven(bitsnum) "bitsnum must be even" # constraint
    pairsnum = bitsnum ÷ 2
    identity_op = MPO(siteindices, "Id")
    gates = [op("SWAP", siteindices[2i - 1], siteindices[2i]) for i in 1:pairsnum]
    adjacent_swap_op = apply(gates, identity_op)
    return adjacent_swap_op
end

# Z
function create_z_op(siteindices::Vector{Index{Int64}})
    bitnum = length(siteindices)
    identity_op = MPO(siteindices, "Id")
    gates = [op("Z", siteindices[i]) for i in 1:bitnum]
    z_op = apply(gates, identity_op)
    return z_op
end

# ---------------------
# the time reversal operator
# ---------------------

"""
create_unitary_part_reversal_op(part1, site_indices; op_type="MPO")

Create the unitary part of the time-reversal operator by applying Pauli-Y gates
on the sites specified in `part1`. This implements the operator ⊗_{i∈part1} Y_i
acting on the chosen subsystem.

Arguments
- part1::Vector{Int64}: indices of the sites on which to apply the Pauli-Y gate.
- site_indices::Vector{Index{Int64}}: vector of site indices for the full system.

Keyword arguments
- op_type::String="MPO": output type. Supported values are "MPO" (returns an MPO)
  and "ITensor" (contracts the MPO into a single ITensor).

Returns
- If op_type == "MPO": returns unitary_part_reversal_op::MPO.
- If op_type == "ITensor": returns contracted ITensor.

Notes
- The Y gates are applied onto an identity MPO of the full system.
- An error is thrown if op_type is not "MPO" or "ITensor".
"""
function create_unitary_part_reversal_op(
    part1::Vector{Int64}, site_indices::Vector{Index{Int64}}; op_type="MPO"
)
    qubits_num = length(site_indices)
    identity_op = MPO(site_indices, "Id")
    gates = [op("Y", site_indices[i]) for i in part1]
    unitary_part_reversal_op = apply(gates, identity_op)
    if op_type == "MPO"
        return unitary_part_reversal_op
    elseif op_type == "ITensor"
        return contract(unitary_part_reversal_op)
    else
        error("wrong output type: $op_type")
    end
end
