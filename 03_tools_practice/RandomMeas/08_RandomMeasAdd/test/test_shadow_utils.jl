include("../src/RandomMeasAdd.jl")
using .RandomMeasAdd
using RandomMeas

N = 8
site_indices = siteinds("Qubit", N);
group_path = joinpath(@__DIR__, "../../04_workflow/b_data_acquisition/group.npz")

test_index = 1

if test_index == 1
    group = import_MeasurementGroup(group_path; site_indices=site_indices);
    shadows = get_factorized_shadows(group);
    shadows_mpo = get_factorized_shadow_mpo(shadows);
    @show size(shadows_mpo)
end

