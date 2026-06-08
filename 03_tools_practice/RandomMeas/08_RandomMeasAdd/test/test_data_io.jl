include("../src/RandomMeasAdd.jl")
using .RandomMeasAdd
using RandomMeas

N = 8
site_indices = siteinds("Qubit", N);
group_path = joinpath(@__DIR__, "../../04_workflow/b_data_acquisition/group.npz")

test_index = 1

if test_index == 1
    permuted_order = [3, 6, 4, 5];
    permuted_group, permuted_indices = import_permuted_group(
        group_path, site_indices, permuted_order
    )
end
