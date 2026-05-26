include("../src/RandomMeasAdd.jl")
using .RandomMeasAdd
using RandomMeas

N = 6
site_indices = siteinds("Qubit", N)
group_path = joinpath(@__DIR__, "../../04_workflow/b_data_acquisition/group.npz")

test_index = 2

if test_index == 1 
    reduced_N = 4
    permuted_order = [x for pair = 1:reduced_N ÷ 2 for x in (pair, N - pair + 1)];
    @show get_reflect_expect_shadow(
        group_path,
        site_indices, 
        permuted_order;
        shadows_type="factorized"
    )
elseif test_index == 2
    reduced_N = 4
    permuted_order = [x for pair = 1:reduced_N ÷ 2 for x in (pair, N - pair + 1)];
    @show get_normalized_reflect_expect_shadow(
        group_path,
        site_indices, 
        permuted_order;
        shadows_type="dense",
    )
end
