include("./src/eigen_calculator.jl")
include("./src/evolution_calculater.jl")

function get_spectrum(H, p, tlist, Mz; energy_num=4)
    # eigen calculate
    file_path = joinpath(@__DIR__, "./data/eigen.npz")
    save_eigen(file_path, H, p, tlist, Mz; energy_num=energy_num);
end

function get_evolution(H, p, tlist, Mz)
    # evolution calculate
    ___, states, ___ = eigenstates(H(p, tlist[1])); # ground state at the FIRST time point
    ψ0 = states[1]
    file_path = joinpath(@__DIR__, "./data/evolution.npz")
    save_evolution(file_path, H, p, ψ0, tlist, Mz);
end


if abspath(PROGRAM_FILE) == @__FILE__

    test_indices = (1, 2)

    # the const setting, which must be same for spectrum and evolution.
    qubit_num = 8 
    energy_num = 4
    p = (T = 50,)
    dt = 5e-6 * p.T
    tlist = range(5e-4 * p.T, 5e-2 * p.T; step = dt)
    H = create_ssh_H(qubit_num, p); # the ops setting
    Mz = create_magnet_quantity(qubit_num);

    if 1 in test_indices
        # spectrum
        get_spectrum(H, p, tlist, Mz; energy_num=energy_num)
    end
    if 2 in test_indices
        # evolution
        get_evolution(H, p, tlist, Mz)
    end
end
