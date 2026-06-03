include("../src/RandomMeasAdd.jl")
using .RandomMeasAdd
using RandomMeas

N = 6
site_indices = siteinds("Qubit", N);
group_path = joinpath(@__DIR__, "../../04_workflow/b_data_acquisition/group.npz")

test_index = 2

if test_index == 1
    permuted_order = [x for pair in 1:(N ÷ 2) for x in (pair, N - pair + 1)];
    permuted_group, permuted_indices = import_permuted_group(
        group_path, site_indices, permuted_order
    )
elseif test_index == 2
    group = import_MeasurementGroup(group_path; site_indices=site_indices);
    shadows = get_factorized_shadows(group);
    shadows_mpo = get_factorized_shadow_mpo(shadows);
    @show size(shadows_mpo)
end
