include("../src/RandomMeasAdd.jl")
using .RandomMeasAdd
using RandomMeas

# settings 
N = 6
site_indices = siteinds("Qubit", N)
test_index = 3

if test_index == 1
    # reflect op
    reflect_op = create_reflect_op(site_indices)
    @show linkdims(reflect_op)
elseif test_index == 2
    # swap op but adjacent
    adjacent_swap_op = create_adjacent_swap_op(site_indices)
    @show linkdims(adjacent_swap_op)
elseif test_index == 3
    part1 = [1, 2, 3, 4]
    unitary_part_reversal_op = create_unitary_part_reversal_op(
        part1,
        site_indices;
        op_type = "ITensor",
    )
    unitary_part_reversal_op = create_unitary_part_reversal_op(
        part1,
        site_indices;
        op_type = "MPO",
    )
    @show linkdims(unitary_part_reversal_op)
end
