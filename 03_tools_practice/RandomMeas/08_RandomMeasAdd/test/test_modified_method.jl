include("../src/RandomMeasAdd.jl")
using .RandomMeasAdd
using RandomMeas

# get shadows
N = 4
site_indices = siteinds("Qubit", N)
group_path = joinpath(@__DIR__, "../../04_workflow/b_data_acquisition/group.npz")
group = import_MeasurementGroup(group_path, site_indices=site_indices);
shadows = get_factorized_shadows(group);

test_index = 2

if test_index == 1 
    # get expect shadows
    reflect_op = create_reflect_op(site_indices)
    @show linkdims(reflect_op)
    @show modified_get_expect_shadow(reflect_op, shadows, compute_sem=true)
elseif test_index == 2
    # get trace moment
    @show modified_get_trace_moment(shadows, 2)
end
