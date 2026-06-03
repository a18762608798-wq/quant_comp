using RandomMeas
using NPZ

function import_permuted_group(filepath::String, site_indices, permuted_order)
    permuted_indices = site_indices[permuted_order]
    group_data = npzread(filepath)
    meas_res = 2 .- group_data["measurement_results"]
    settings = group_data["measurement_settings"]
    permuted_meas_res = meas_res[:, :, permuted_order]
    permuted_settings = settings[:, permuted_order, :, :]
    permuted_group = MeasurementGroup(
        permuted_meas_res, permuted_settings, permuted_indices
    )
    return permuted_group, permuted_indices
end

if abspath(PROGRAM_FILE) == @__FILE__
    N = 16
    siteindices = siteinds("Qubit", N);
    permuted_order = [x for pair in 1:(N ÷ 2) for x in (pair, N - pair + 1)];
    permuted_group, permuted_indices = import_permuted_group(
        "./03_tools_practice/RandomMeas/04_workflow/b_data_acquisition/group.npz",
        siteindices,
        permuted_order,
    )
end
