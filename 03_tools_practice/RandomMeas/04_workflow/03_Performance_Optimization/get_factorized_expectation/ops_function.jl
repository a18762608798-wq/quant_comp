using RandomMeas

# create local swap op
function create_local_swap_op(bitsnum::Int64, localsites::Vector{Int64}, siteindices::Vector{Index{Int64}})
    ops = Vector{MPO}(undef, 4)
    site1 = localsites[1]
    site2 = localsites[2]
    opstrbases = ["I", "X", "Y", "Z"]
    for basesindex = 1:4
        opstrbase = opstrbases[basesindex]
        opstrs = ["I" for _ in 1:bitsnum]
        opstrs[site1], opstrs[site2] = opstrbase, opstrbase
        op = MPO(ComplexF64, siteindices, opstrs)
        ops[basesindex] = op
    end
    return local_swap_op = sum(ops) / 2
end

# reflect op 
function create_reflect_op(bitsnum::Int64, siteindices::Vector{Index{Int64}})
    @assert iseven(bitsnum) "bitsnum must be even" # constrain
    pairsnum = bitsnum ÷ 2
    opstrs = ["I" for _ in 1:bitsnum]
    op = MPO(ComplexF64, siteindices, opstrs)
    for pairsite = 1:pairsnum
        site1 = pairsite
        site2 = bitsnum - site1 + 1
        sites = [site1, site2]
        local_swap_op = create_local_swap_op(bitsnum, sites, siteindices)
        op = apply(local_swap_op, op)
    end
    return op
end

# overall swap op but adjacent 
function create_adjacent_swap_op(bitsnum::Int64, siteindices::Vector{Index{Int64}})
    @assert iseven(bitsnum) "bitsnum must be even" # constrain
    pairsnum = bitsnum ÷ 2
    opstrs = ["I" for _ in 1:bitsnum]
    op = MPO(ComplexF64, siteindices, opstrs)
    for pairsite = 1:pairsnum
        site1 = 2 * pairsite - 1
        site2 = 2 * pairsite
        sites = [site1, site2]
        local_swap_op = create_local_swap_op(bitsnum, sites, siteindices)
        op = apply(local_swap_op, op)
    end
    return op 
end

if abspath(PROGRAM_FILE) == @__FILE__
    using RandomMeas
    # settings 
    N = 8
    site_indices = siteinds("Qubit",N)
    # local swap op
    local_swap_op = create_local_swap_op(N, [1, N], site_indices)
    @show linkdims(local_swap_op)
    # reflect op
    reflect_op = create_reflect_op(N, site_indices); 
    @show linkdims(reflect_op)
    # swap op but adjacent
    adjacent_swap_op = create_adjacent_swap_op(N, site_indices); 
    @show linkdims(adjacent_swap_op)
end
