include("../../../08_RandomMeasAdd/src/RandomMeasAdd.jl")
using .RandomMeasAdd
using RandomMeas
using NPZ

function save_reflect_sems_shadow(
    group_dir, 
    site_indices, 
    permuted_order, 
)
    # find the group data files
    group_files = filter(file -> occursin(r"^group\d+\.npz$", file), readdir(group_dir))
    group_num = length(group_files)
    sort!(group_files; by = file -> parse(Int, match(r"group(\d+)\.npz", file)[1]))
    # calculate the sems
    ests = Vector{Float64}(undef, group_num)
    sems = Vector{Float64}(undef, group_num)
    for (i, fname) in enumerate(group_files)
        group_path = joinpath(group_dir, fname)
        ests[i], sems[i] = get_reflect_expect_shadow(
            group_path, site_indices, permuted_order, "dense", compute_sem=true
        )
    end

    npzwrite(
        joinpath(group_dir, "reflect_sems.npz"),
        Dict(
            "ests" => ests,
            "sems" => sems,
        ),
    )
end

function save_purity_sems_shadow(
    group_dir, 
    site_indices, 
    permuted_order, 
)
    # find the group data files
    group_files = filter(file -> occursin(r"^group\d+\.npz$", file), readdir(group_dir))
    group_num = length(group_files)
    sort!(group_files; by = file -> parse(Int, match(r"group(\d+)\.npz", file)[1]))
    # calculate the sems
    ests = Vector{Float64}(undef, group_num)
    sems = Vector{Float64}(undef, group_num)
    for (i, fname) in enumerate(group_files)
        group_path = joinpath(group_dir, fname)
        group, _ = import_permuted_group(group_path, site_indices, permuted_order)
        shadows = get_dense_shadows(group)
        ests[i], _, sems[i] = modified_get_purity_shadow(shadows; compute_sem=true)
    end

    npzwrite(
        joinpath(group_dir, "purity_sems.npz"),
        Dict(
            "ests" => ests,
            "sems" => sems,
        ),
    )
end

if abspath(PROGRAM_FILE) == @__FILE__
    N = 8
    site_indices = siteinds("Qubit", N)
    permuted_order = [2, 7, 3, 6, 4, 5]
    # save swap shadows sems
    group_dir = joinpath(@__DIR__, "../data/random/shadow/")
    #save_reflect_sems_shadow(group_dir, site_indices, permuted_order)
    # save purity shadows sems
    group_dir = joinpath(@__DIR__, "../data/random/shadow/")
    save_purity_sems_shadow(group_dir, site_indices, permuted_order)
end
