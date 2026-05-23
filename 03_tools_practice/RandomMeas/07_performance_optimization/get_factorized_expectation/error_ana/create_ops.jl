using RandomMeas

# reflect op 
function create_reflect_op(siteindices::Vector{Index{Int64}})
    bitsnum = length(siteindices)
    @assert iseven(bitsnum) "bitsnum must be even" # constrain
    pairsnum = bitsnum ÷ 2
    identity_op = MPO(siteindices, "Id")
    gates = [
        op("SWAP", siteindices[i], siteindices[bitsnum - i + 1]) for i = 1:pairsnum
    ]
    reflect_op = apply(gates, identity_op; cutoff=1e-12)
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
    adjacent_swap_op = apply(gates, identity_op; cutoff=1e-12)
    return adjacent_swap_op
end

if abspath(PROGRAM_FILE) == @__FILE__
    using RandomMeas
    # settings 
    N = 8
    site_indices = siteinds("Qubit", N)
    # reflect op
    reflect_op = create_reflect_op(site_indices)
    @show linkdims(reflect_op)
    # swap op but adjacent
    adjacent_swap_op = create_adjacent_swap_op(site_indices)
    @show linkdims(adjacent_swap_op)
end
