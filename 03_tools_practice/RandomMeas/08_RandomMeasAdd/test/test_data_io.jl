include("../src/RandomMeasAdd.jl")
using .RandomMeasAdd
using RandomMeas

N = 8
site_indices = siteinds("Qubit", N);

test_index = 2

if test_index == 1
    group_path = "./04_workflow/b_data_acquisition/random_group.npz"
    permuted_order = [3, 6, 4, 5];
    permuted_group, permuted_indices = import_permuted_group(
        group_path, site_indices, permuted_order
    )
elseif test_index == 2
    pauli_path = "./04_workflow/b_data_acquisition/reflect_pauli_group.npz"
    permuted_order = [3, 6, 4, 5];
    res, bases = import_permuted_pauli(
        pauli_path, permuted_order
    );
end
