if abspath(PROGRAM_FILE) == @__FILE__
    include("../src/RandomMeasAdd.jl")
    using .RandomMeasAdd
    using RandomMeas
    N = 4
    siteindices = siteinds("Qubit", N);
    permuted_order = [x for pair = 1:N÷2 for x in (pair, N - pair + 1)];
    group_path = joinpath(@__DIR__, "../../04_workflow/b_data_acquisition/group.npz")
    permuted_group, permuted_indices = import_permuted_group(group_path, siteindices, permuted_order)
end
