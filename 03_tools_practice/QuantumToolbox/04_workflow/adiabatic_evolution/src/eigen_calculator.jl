include("op_creator.jl")
using NPZ

function get_eigen(H, p, tlist, O; energy_num=10)
    # get the info
    room_dim = size(H.data, 1)
    t_num = length(tlist)
    # storge the res
    # eigen info
    Ets = Matrix{ComplexF64}(undef, energy_num, t_num)
    eigen_states_t = Array{ComplexF64}(undef, room_dim, energy_num, t_num)
    ground_states = Vector{Qobj}(undef, t_num)
    for t_idx in eachindex(tlist)
        t = tlist[t_idx]
        E, qobj_states, U = eigenstates(H(p, t)); 
        Ets[:, t_idx] .= E[1:energy_num]
        eigen_states_t[:, :, t_idx] .= U[:, 1:energy_num]
        ground_states[t_idx] = qobj_states[1]
    end
    # O info
    Ot_vals = Vector{Float64}(undef, t_num)
    for t_idx in eachindex(tlist)
        t = tlist[t_idx]
        ψ0 = ground_states[t_idx]
        Ot_vals[t_idx] = expect(O, ψ0)
    end
    return real.(Ets), eigen_states_t, real.(Ot_vals)
end

function save_eigen(file_path, H, p, tlist, O; kwargs...)
    Ets, eigen_states_t, Ot_vals = get_eigen(
        H, p, tlist, O;
        kwargs...
    )
    npzwrite(
        file_path,
        Dict(
            "tlist" => tlist,
            "Ets" => Ets,
            "eigen_states_t" => eigen_states_t,
            "Ot_vals" => Ot_vals,
        ),
    )
end

if abspath(PROGRAM_FILE) == @__FILE__
    # H
    qubit_num = 8
    p = (T = 10,)
    H = create_ssh_H(qubit_num, p);
    # Mz
    Mz = create_magnet_quantity(qubit_num);
    # spectrum
    dt = 0.01
    tlist = range(0, p.T; step = dt)
    file_path = joinpath(@__DIR__, "../data/eigen.npz")
    save_eigen(file_path, H, p, tlist, Mz; energy_num=20);
end
