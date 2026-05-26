if abspath(PROGRAM_FILE) == @__FILE__
    include("../src/RandomMeasAdd.jl")
    using .RandomMeasAdd
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
