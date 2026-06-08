# --------------------
# transform shadows to a mpo
# --------------------

"""
Convert a FactorizedShadow into an MPO representation.

Arguments
- shadow::FactorizedShadow: a single factorized shadow instance.

Returns
- MPO representation constructed from shadow.shadow_data.
"""
function get_factorized_shadow_mpo(shadow::FactorizedShadow)
    return MPO(shadow.shadow_data)
end

"""
Convert a matrix of FactorizedShadow objects into a matrix of MPOs.

Arguments
- shadows::Matrix{FactorizedShadow}: a 2D array with dimensions (settings, shots).

Returns
- Matrix{MPO} with the same dimensions where each entry is the MPO form of
  the corresponding FactorizedShadow.
"""
function get_factorized_shadow_mpo(shadows::Matrix{FactorizedShadow})
    settings_num, shots = size(shadows)
    mpo_shadows = Matrix{MPO}(undef, settings_num, shots)
    for settings in 1:settings_num
        for shot in 1:shots
            shadow = shadows[settings, shot]
            mpo_shadow = get_factorized_shadow_mpo(shadow)
            mpo_shadows[settings, shot] = mpo_shadow
        end
    end
    return mpo_shadows
end

"""
Convert a vector of FactorizedShadow objects into a column matrix of MPOs.

This is a convenience overload that reshapes the vector to a (N,1) matrix and
calls the Matrix{FactorizedShadow} method.
"""
function get_factorized_shadow_mpo(shadows::Vector{FactorizedShadow})
    return get_factorized_shadow_mpo(reshape(shadows, length(shadows), 1))
end

