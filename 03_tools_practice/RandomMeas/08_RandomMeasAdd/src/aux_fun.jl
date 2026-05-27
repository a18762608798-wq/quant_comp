# This method has the function to reduce.
function import_permuted_group(filepath::String, site_indices, permuted_order)
    permuted_indices = site_indices[permuted_order]
    group_data = npzread(filepath)
    meas_res = 2 .- Int64.(group_data["measurement_results"])
    settings = ComplexF64.(group_data["measurement_settings"])
    permuted_meas_res = meas_res[:, :, permuted_order]
    permuted_settings = settings[:, permuted_order, :, :]
    permuted_group = MeasurementGroup(permuted_meas_res, permuted_settings, permuted_indices)
    return permuted_group, permuted_indices
end


# transform shadows to a mpo
function get_factorized_shadow_mpo(
    shadow::FactorizedShadow
)
    return MPO(shadow.shadow_data)
end


function get_factorized_shadow_mpo(
    shadows::Matrix{FactorizedShadow}
)
    settings_num, shots = size(shadows)    
    mpo_shadows = Matrix{MPO}(undef, settings_num, shots)
    for settings = 1:settings_num
        for shot = 1:shots
            shadow = shadows[settings, shot]
            mpo_shadow = get_factorized_shadow_mpo(shadow)
            mpo_shadows[settings, shot] = mpo_shadow
        end
    end
    return mpo_shadows
end


function get_factorized_shadow_mpo(
    shadows::Vector{FactorizedShadow}
)
    return get_factorized_shadow_mpo(
        reshape(shadows, length(shadows), 1)
    )
end
