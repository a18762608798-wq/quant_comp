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

test_index = 4

if test_index == 1 
    # get expect shadows
    reflect_op = create_reflect_op(sub_indices)
    @show linkdims(reflect_op)
    @show modified_get_expect_shadow(
        reflect_op, sub_shadows;
        compute_sem=true
    )
elseif test_index == 2
    reflect_op = create_reflect_op(sub_indices)
    # NOTICE: Which should be equal.
    @show modified_get_expect_shadow(
        reflect_op, 
        sub_shadows, 
        compute_sem=true
    )
    @show modified_get_trace_moment(
        sub_shadows, 1; 
        O = reflect_op, 
        compute_sem = true
    )
elseif test_index == 3
    @show modified_get_trace_moment(sub_shadows, 2)
elseif test_index == 4
    @show modified_get_trace_moment(
        sub_shadows, 2;
        compute_sem = true,
    )
    @show modified_get_trace_2_moments(
        sub_shadows;
        compute_sem = true,
    )
end
