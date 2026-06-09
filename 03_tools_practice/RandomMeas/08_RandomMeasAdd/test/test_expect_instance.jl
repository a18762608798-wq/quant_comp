include("../src/RandomMeasAdd.jl")
using .RandomMeasAdd
using RandomMeas

# get sub shadows
N = 8
site_indices = siteinds("Qubit", N)
group_path = "./04_workflow/b_data_acquisition/random_group.npz"

test_index = 2

if test_index == 1
    reduced_N = 4
    permuted_order = [x for pair in 3:(3 + reduced_N ÷ 2 - 1) for x in (pair, N - pair + 1)];
    @show get_reflect_expect_shadow(
        group_path, site_indices, permuted_order; compute_sem=true,
    )
elseif test_index == 2
    group_path = "./04_workflow/b_data_acquisition/conditional_random_group.npz"
    reduced_N = 4
    permuted_order = [x for pair in 3:(3 + reduced_N ÷ 2 - 1) for x in (pair, N - pair + 1)];
    @show get_reflect_expect(
        group_path, site_indices, permuted_order; compute_sem=true,
    )
elseif test_index == 3
    reduced_N = 4
    permuted_order = [x for pair in 3:(3 + reduced_N ÷ 2 - 1) for x in (pair, N - pair + 1)];
    @show get_purity_expect_shadow(
        group_path, site_indices, permuted_order; compute_sem=true,
    )
elseif test_index == 4
    reduced_N = 4
    permuted_order = [x for pair in 3:(3 + reduced_N ÷ 2 - 1) for x in (pair, N - pair + 1)];
    @show get_z_r_shadow(
        group_path, site_indices, permuted_order; compute_sem=true,
    )
end
