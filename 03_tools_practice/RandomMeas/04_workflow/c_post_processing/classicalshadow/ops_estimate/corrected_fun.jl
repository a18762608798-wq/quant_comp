using Statistics
using RandomMeas

include("create_ops.jl")

function corrected_get_expect_shadow(
    O::MPO,
    shadows::AbstractArray{<:AbstractShadow};
    compute_sem::Bool = false
)
    # Ensure the array of shadows is not empty and is a matrix
    @assert !isempty(shadows) "Array of shadows is empty."
    if ndims(shadows) == 1
        shadows = reshape(shadows, length(shadows), 1)
    end

    # Compute all expectation values
    settings_num, shots = size(shadows)
    expect_values = Matrix{ComplexF64}(undef, settings_num, shots)
    for settings = 1:settings_num
        for shot = 1:shots
            shadow = shadows[settings, shot]
            expect_values[settings, shot] = get_expect_shadow(O, shadow)
        end
    end

    # Compute mean (of every settings num)
    mean_values = mean(expect_values, dims=2)
    mean_value = mean(mean_values)

    if compute_sem
        # Compute standard error of the mean (SEM)
        sem_value = std(mean_values) / sqrt(settings_num)
        return mean_value, sem_value
    else
        return mean_value
    end
end


if abspath(PROGRAM_FILE) == @__FILE__
    # settings
    N = 4
    site_indices = siteinds("Qubit", N)
    # reflect op
    reflect_op = create_reflect_op(site_indices)
    @show linkdims(reflect_op)
    group_path = joinpath(@__DIR__, "../../../b_data_acquisition/group.npz")
    group = import_MeasurementGroup(group_path, site_indices=site_indices);
    shadows = get_factorized_shadows(group);
    @show corrected_get_expect_shadow(reflect_op, shadows, compute_sem=true)
end
