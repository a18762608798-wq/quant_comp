include("./src/eigen_calculator.jl")
include("./src/evolution_calculater.jl")

function main()
    # setting
    qubit_num = 12 # the const setting
    dt = 0.05
    p = (T = 2,)
    tlist = range(0, p.T; step = dt)
    H = create_ssh_H(qubit_num, p); # the ops setting
    Mz = create_magnet_quantity(qubit_num);

    # eigen calculate
    file_path = joinpath(@__DIR__, "./data/eigen.npz")
    save_eigen(file_path, H, p, tlist, Mz; energy_num=16);

    # evolution calculate
    #___, states, ___ = eigenstates(H(p, 0)); # set ground state be the initial state.
    #ψ0 = states[1]
    #file_path = joinpath(@__DIR__, "./data/evolution.npz")
    #save_evolution(file_path, H, p, ψ0, tlist, Mz);
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
