# ---------------------
# Import the data from npz accroding to permuted order.
# ---------------------

"""
Import a measurement group saved in an npz file and reorder its entries
according to a provided permutation.

Arguments
- filepath::String: path to the .npz file produced by the measurement routines.
- site_indices: array of site indices corresponding to the group saved in the file.
- permuted_order: permutation vector indicating the new ordering of sites.

Returns
- permuted_group::MeasurementGroup: MeasurementGroup with measurement results
  and settings reordered to match permuted_order.
- permuted_indices: site_indices reordered by permuted_order.

Notes
- The function converts measurement_results and measurement_settings fields
  to the expected types and applies the permutation consistently across
  measurements and settings.
"""
function import_permuted_group(filepath::String, site_indices, permuted_order)
    permuted_indices = site_indices[permuted_order]
    group_data = npzread(filepath)
    meas_res = 2 .- Int64.(group_data["measurement_results"])
    settings = ComplexF64.(group_data["measurement_settings"])
    permuted_meas_res = meas_res[:, :, permuted_order]
    permuted_settings = settings[:, permuted_order, :, :]
    permuted_group = MeasurementGroup(
        permuted_meas_res, permuted_settings, permuted_indices
    )
    return permuted_group, permuted_indices
end

