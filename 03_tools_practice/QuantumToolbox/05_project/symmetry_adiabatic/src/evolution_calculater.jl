include("op_creator.jl")
using NPZ

function save_evolution(file_path, H, p, ψ0, tlist, O)
    sol = sesolve(H, ψ0, tlist; params=p, e_ops=[O], saveat=tlist,);
    evolution_states = sol.states
    Ot_vals = real.(sol.expect[1, :])
    # Convert QuantumObject states to plain arrays for NPZ serialization
    evolution_states_t = reduce(hcat, [s.data for s in evolution_states])

    npzwrite(
        file_path,
        Dict(
            "tlist" => tlist,
            "evolution_states_t" => evolution_states_t,
            "Ot_vals" => Ot_vals,
        ),
    )
end


if abspath(PROGRAM_FILE) == @__FILE__
    # H
    qubit_num = 8
    p = (T=10,)
    H = create_ssh_H(qubit_num);
    # Mz
    Mz = create_magnet_quantity(qubit_num);
    # evolution 
    ___, states, ___ = eigenstates(H(p, 0)); # get the initial state
    ψ0 = states[1] # ground state
    dt = 0.01
    tlist = range(0, p.T; step=dt)
    file_path = joinpath(@__DIR__, "../data/evolution.npz")
    save_evolution(file_path, H, p, ψ0, tlist, Mz);
end
