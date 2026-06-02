include("../src/RandomMeasAdd.jl")
using .RandomMeasAdd
using RandomMeas

# get sub shadows
N = 8
site_indices = siteinds("Qubit", N)
group_path = "./04_workflow/b_data_acquisition/group.npz"

test_index = 2

if test_index == 1 
    reduced_N = 4
    permuted_order = [x for pair = 3:3 + reduced_N ÷ 2 - 1 for x in (pair, N - pair + 1)];
    @show get_reflect_expect_shadow(
        group_path,
        site_indices, 
        permuted_order;
        shadows_type="dense",
        compute_sem = true,
    )
elseif test_index == 2
    reduced_N = 4
    permuted_order = [x for pair = 3:3 + reduced_N ÷ 2 - 1 for x in (pair, N - pair + 1)];
    @show get_z_r_shadow(
        group_path,
        site_indices, 
        permuted_order;
        shadows_type="dense",
        compute_sem = true,
    )
end
