include("../../../08_RandomMeasAdd/src/RandomMeasAdd.jl")
using .RandomMeasAdd
using RandomMeas
using NPZ

function save_sems(
    group_dir, 
    get_est_fun, 
    site_indices, 
    permuted_order, 
    group_num
)
    ests = Vector{Float64}(undef, group_num)
    sems = Vector{Float64}(undef, group_num)
    for i = 1:group_num
        group_path = joinpath(group_dir, "group$i.npz")
        ests[i], sems[i] = get_est_fun(
            group_path, site_indices, permuted_order; shadows_type="dense", compute_sem=true
        )
    end
    npzwrite(
        joinpath(group_dir, "sems.npz"),
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
    get_est_fun = get_reflect_expect_shadow
    group_num = 8
    save_sems(group_dir, get_est_fun, site_indices, permuted_order, group_num)
end
