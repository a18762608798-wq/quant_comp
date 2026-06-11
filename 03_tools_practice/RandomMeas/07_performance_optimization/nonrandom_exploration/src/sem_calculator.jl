using RandomMeas
using NPZ
using ProgressMeter

include("../../../08_RandomMeasAdd/src/RandomMeasAdd.jl")
using .RandomMeasAdd

# ----------
# reflect
# ----------
function save_reflect_sems_shadow(
    group_dir, 
    site_indices, 
    permuted_order, 
)
    # find the group data files
    group_files = filter(file -> occursin(r"^random_group\d+\.npz$", file), readdir(group_dir))
    group_num = length(group_files)
    sort!(group_files; by = file -> parse(Int, match(r"random_group(\d+)\.npz", file)[1]))
    # calculate the sems
    ests = Vector{Float64}(undef, group_num)
    sems = Vector{Float64}(undef, group_num)
    @showprogress desc="reflect_sems_shadow_calculating..." for (i, fname) in enumerate(group_files)
        group_path = joinpath(group_dir, fname)
        ests[i], sems[i] = get_reflect_shadow(
            group_path, site_indices, permuted_order; compute_sem=true, show_progress=false,
        )
    end

    npzwrite(
        joinpath(group_dir, "reflect_sems_shadow.npz"),
        Dict(
            "ests" => ests,
            "sems" => sems,
        ),
    )
end

function save_reflect_sems_hamming(
    group_dir, 
    site_indices, 
    permuted_order, 
)
    # find the group data files
    group_files = filter(file -> occursin(r"^conditional_group\d+\.npz$", file), readdir(group_dir))
    group_num = length(group_files)
    sort!(group_files; by = file -> parse(Int, match(r"conditional_group(\d+)\.npz", file)[1]))
    # calculate the sems
    ests = Vector{Float64}(undef, group_num)
    sems = Vector{Float64}(undef, group_num)
    @showprogress desc="reflect_sems_hamming_calculating..." for (i, fname) in enumerate(group_files)
        group_path = joinpath(group_dir, fname)
        ests[i], sems[i] = get_reflect_hamming(
            group_path, site_indices, permuted_order; compute_sem=true, show_progress=false,
        )
    end

    npzwrite(
        joinpath(group_dir, "reflect_sems_hamming.npz"),
        Dict(
            "ests" => ests,
            "sems" => sems,
        ),
    )
end

function save_reflect_sems_pauli(
    group_dir, 
    permuted_order, 
)
    # find the group data files
    group_files = filter(file -> occursin(r"^reflect_pauli_group\d+\.npz$", file), readdir(group_dir))
    group_num = length(group_files)
    sort!(group_files; by = file -> parse(Int, match(r"reflect_pauli_group(\d+)\.npz", file)[1]))
    # calculate the sems
    ests = Vector{Float64}(undef, group_num)
    sems = Vector{Float64}(undef, group_num)
    @showprogress desc="reflect_sems_pauli_calculating..." for (i, fname) in enumerate(group_files)
        group_path = joinpath(group_dir, fname)
        ests[i], sems[i] = get_reflect_pauli(
            group_path, permuted_order; compute_sem=true,
        )
    end

    npzwrite(
        joinpath(group_dir, "reflect_sems_pauli.npz"),
        Dict(
            "ests" => ests,
            "sems" => sems,
        ),
    )
end

# ----------
# purity
# ----------
function save_purity_sems_shadow(
    group_dir, 
    site_indices, 
    permuted_order, 
)
    # find the group data files
    group_files = filter(file -> occursin(r"^random_group\d+\.npz$", file), readdir(group_dir))
    group_num = length(group_files)
    sort!(group_files; by = file -> parse(Int, match(r"random_group(\d+)\.npz", file)[1]))
    # calculate the sems
    ests = Vector{Float64}(undef, group_num)
    sems = Vector{Float64}(undef, group_num)
    @showprogress desc="purity_sems_shadow_calculating..." for (i, fname) in enumerate(group_files)
        group_path = joinpath(group_dir, fname)
        ests[i], sems[i] = get_purity_shadow(
            group_path, site_indices, permuted_order; compute_sem=true, show_progress=false,
        )
    end

    npzwrite(
        joinpath(group_dir, "purity_sems_shadow.npz"),
        Dict(
            "ests" => ests,
            "sems" => sems,
        ),
    )
end

function save_purity_sems_hamming(
    group_dir, 
    site_indices, 
    permuted_order, 
)
    # find the group data files
    group_files = filter(file -> occursin(r"^random_group\d+\.npz$", file), readdir(group_dir))
    group_num = length(group_files)
    sort!(group_files; by = file -> parse(Int, match(r"random_group(\d+)\.npz", file)[1]))
    # calculate the sems
    ests = Vector{Float64}(undef, group_num)
    sems = Vector{Float64}(undef, group_num)
    @showprogress desc="purity_sems_hamming_calculating..." for (i, fname) in enumerate(group_files)
        group_path = joinpath(group_dir, fname)
        ests[i], sems[i] = get_purity_hamming(
            group_path, site_indices, permuted_order; compute_sem=true, show_progress=false,
        )
    end

    npzwrite(
        joinpath(group_dir, "purity_sems_hamming.npz"),
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
    # save reflect shadows sems
    group_dir = joinpath(@__DIR__, "../data/")
    save_reflect_sems_shadow(group_dir, site_indices, permuted_order)
    # save reflect hamming sems
    group_dir = joinpath(@__DIR__, "../data/")
    save_reflect_sems_hamming(group_dir, site_indices, permuted_order)
    # save reflect pauli sems
    group_dir = joinpath(@__DIR__, "../data/")
    save_reflect_sems_pauli(group_dir, permuted_order)
    # save purity shadows sems
    group_dir = joinpath(@__DIR__, "../data/")
    save_purity_sems_shadow(group_dir, site_indices, permuted_order)
    # save purity hamming sems
    group_dir = joinpath(@__DIR__, "../data/")
    save_purity_sems_hamming(group_dir, site_indices, permuted_order)
end
