include("./create_ops.jl")
include("./aux_fun.jl")

### reflect op
# permute the order of group and create permuted_shadows
N = 16
siteindices = siteinds("Qubit", N);
permuted_order = [x for pair = 1:N÷2 for x in (pair, N - pair + 1)];
group_data_path = joinpath(@__DIR__, "group.npz")
permuted_group, permuted_indices = import_permuted_group(group_data_path, siteindices, permuted_order);
permuted_shadows = get_factorized_shadows(permuted_group);
# calculate op 
adjacent_swap_op = create_adjacent_swap_op(permuted_indices);
@show linkdims(adjacent_swap_op)
@time @show get_expect_shadow(adjacent_swap_op, permuted_shadows; compute_sem=true)
