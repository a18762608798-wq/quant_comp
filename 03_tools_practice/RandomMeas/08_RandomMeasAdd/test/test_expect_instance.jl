include("../src/RandomMeasAdd.jl")
using .RandomMeasAdd
using RandomMeas

# get sub shadows
N = 8
site_indices = siteinds("Qubit", N)
group_path = "./04_workflow/b_data_acquisition/random_group.npz"
reduced_N = 4
permuted_order = [x for pair in 3:(3 + reduced_N ÷ 2 - 1) for x in (pair, N - pair + 1)];

test_index = 3

if test_index == 1
    @show get_reflect_shadow(
        group_path, site_indices, permuted_order; compute_sem=true,
    )
elseif test_index == 2
    group_path = "./04_workflow/b_data_acquisition/conditional_random_group.npz"
    @show get_reflect_hamming(
        group_path, site_indices, permuted_order; compute_sem=true,
    )
elseif test_index == 3
    pauli_path = "./04_workflow/b_data_acquisition/reflect_pauli_group.npz"
    permuted_order = [3, 6, 4, 5];
    res, bases = import_permuted_pauli(
        pauli_path, permuted_order
    );
    @show get_reflect_pauli(res[:, 3, :], bases)
elseif test_index == 4
    @show get_purity_shadow(
        group_path, site_indices, permuted_order; compute_sem=true,
    )
elseif test_index == 5
    @show get_purity_hamming(
        group_path, site_indices, permuted_order; compute_sem=true,
    )
elseif test_index == 6
    @show get_z_r_shadow(
        group_path, site_indices, permuted_order; compute_sem=true,
    )
end
