using RandomMeas
using NPZ
using ProgressMeter
using Statistics

include("../../../../08_RandomMeasAdd/src/RandomMeasAdd.jl")
using .RandomMeasAdd

# ----------
# z shadow 
# ----------
function save_z_sems_shadow(
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
    z_op = create_z_op(site_indices[permuted_order])
    @showprogress desc="z_sems_shadow_calculating..." for (i, fname) in enumerate(group_files)
        group_path = joinpath(group_dir, fname)
        sub_group, sub_indices = import_permuted_group(group_path, site_indices, permuted_order);
        sub_shadows = get_dense_shadows(sub_group);
        est, sem = modified_get_expect_shadow(z_op, sub_shadows, compute_sem=true, show_progress=false)
        ests[i] = real(est)
        sems[i] = real(sem)
    end

    npzwrite(
        joinpath(group_dir, "z_sems_shadow.npz"),
        Dict(
            "ests" => ests,
            "sems" => sems,
        ),
    )
end

# ----------
# z pauli
# ----------
function save_z_sems_pauli(
    group_dir, 
    site_indices, 
    permuted_order, 
)
    # find the group data files
    group_files = filter(file -> occursin(r"^pauli_z_group\d+\.npz$", file), readdir(group_dir))
    group_num = length(group_files)
    sort!(group_files; by = file -> parse(Int, match(r"pauli_z_group(\d+)\.npz", file)[1]))
    # calculate the sems
    estss = Vector{Float64}(undef, group_num)
    semss = Vector{Float64}(undef, group_num)
    @showprogress desc="z_sems_pauli_calculating..." for (i, fname) in enumerate(group_files)
        group_path = joinpath(group_dir, fname)
        permuted_meas_res, ___ = import_permuted_pauli(group_path, permuted_order)
        ests = vec(prod(permuted_meas_res, dims=3))
        est = mean(ests)
        sem = std(ests) / sqrt(length(ests))
        estss[i] = est
        semss[i] = sem
    end

    npzwrite(
        joinpath(group_dir, "z_sems_pauli.npz"),
        Dict(
            "ests" => estss,
            "sems" => semss,
        ),
    )
end

if abspath(PROGRAM_FILE) == @__FILE__
    N = 6 
    site_indices = siteinds("Qubit", N)
    permuted_order = [i for i = 1:6]
    #save z shadow sems
    group_dir = joinpath(@__DIR__, "../data/")
    save_z_sems_shadow(group_dir, site_indices, permuted_order)
    #save z pauli sems
    group_dir = joinpath(@__DIR__, "../data/")
    save_z_sems_pauli(group_dir, site_indices, permuted_order)
end
