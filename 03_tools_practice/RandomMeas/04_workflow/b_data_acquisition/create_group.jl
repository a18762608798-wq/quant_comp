using RandomMeas

if abspath(PROGRAM_FILE) == @__FILE__
    siteindices = siteinds("Qubit", 4);
    measurement_group = import_MeasurementGroup(
        "./03_tools_practice/RandomMeas/04_workflow/b_data_acquisition/group.npz";
        site_indices=siteindices,
    )
    classical_measurement_group = import_MeasurementGroup(
        "./03_tools_practice/RandomMeas/04_workflow/b_data_acquisition/classical_group.npz";
        site_indices=siteindices,
    )
    @show measurement_group.N
    @show measurement_group.NU
    @show measurement_group.NM
    @show classical_measurement_group.N
    @show classical_measurement_group.NU
    @show classical_measurement_group.NM
end
