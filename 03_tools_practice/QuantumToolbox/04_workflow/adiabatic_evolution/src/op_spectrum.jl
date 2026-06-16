include("op_creator.jl")
using NPZ

function get_spectrum(H, p, tlist; energy_num=10)
    # get the info
    room_dim = size(H.data, 1)
    t_num = length(tlist)
    # storge the res
    Es = Matrix{ComplexF64}(undef, energy_num, t_num)
    eigen_states = Array{ComplexF64}(undef, room_dim, energy_num, t_num)
    for t_idx in eachindex(tlist)
        t = tlist[t_idx]
        E, ___, U = eigenstates(H(p, t)); 
        Es[:, t_idx] .= E[1:energy_num]
        eigen_states[:, :, t_idx] .= U[:, 1:energy_num]
    end
    return Es, eigen_states
end

function save_spectrum(file_path, H, p, tlist; kwargs...)
    Es, eigen_states = get_spectrum(
        H, p, tlist;
        kwargs...
    )
    npzwrite(
        file_path,
        Dict(
            "Es" => Es,
            "eigen_states" => eigen_states,
        ),
    )
end

if abspath(PROGRAM_FILE) == @__FILE__
    # H
    qubit_num = 8
    p = (T = 1,)
    H = create_ssh_H(qubit_num, p);
    # spectrum
    dt = 0.01
    tlist = range(0, p.T; step = dt)
    file_path = joinpath(@__DIR__, "../data/spectrum.npz")
    save_spectrum(file_path, H, p, tlist; energy_num=20);
end
