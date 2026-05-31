include("../src/RandomMeasAdd.jl")
using .RandomMeasAdd
using RandomMeas

# get sub shadows
N = 8
site_indices = siteinds("Qubit", N)
group_path = "./04_workflow/b_data_acquisition/group.npz"
sub_range = [3, 4, 5, 6];
sub_group, sub_indices = import_permuted_group(group_path, site_indices, sub_range);
sub_shadows = get_dense_shadows(sub_group);

test_index = 1

if test_index == 1 
    # get expect shadows
    reflect_op = create_reflect_op(sub_indices)
    @show linkdims(reflect_op)
    @show modified_get_expect_shadow(reflect_op, sub_shadows, compute_sem=true)
elseif test_index == 2
    # get trace moment
    @show modified_get_trace_moment(sub_shadows, 2)
end
