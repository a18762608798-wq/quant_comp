include("./src/eigen_calculator.jl")
include("./src/evolution_calculater.jl")
include("./src/op_operator.jl")

function get_spectrum(H, p, tlist, Mz; energy_num=4)
    # eigen calculate
    file_path = joinpath(@__DIR__, "./data/eigen.npz")
    save_eigen(file_path, H, p, tlist, Mz; energy_num=energy_num);
end

function get_evolution(H, ψ0, p, tlist, Mz)
    # evolution calculate
    file_path = joinpath(@__DIR__, "./data/evolution.npz")
    save_evolution(file_path, H, p, ψ0, tlist, Mz);
end


if abspath(PROGRAM_FILE) == @__FILE__

    test_indices = (4,)

    if 1 in test_indices
        # %5 evolution
        # the const setting, which must be same for spectrum and evolution.
        qubit_num = 8
        energy_num = 4
        p = (T=50,)
        dt = 5e-4 * p.T
        tlist = range(5e-4 * p.T, 5e-2 * p.T; step=dt)
        H = create_ssh_H(qubit_num);
        ___, states, ___ = eigenstates(H(p, tlist[1]));
        ψ0 = states[1]
        Mz = create_magnet_quantity(qubit_num);
        get_spectrum(H, p, tlist, Mz; energy_num=energy_num) # spectrum
        get_evolution(H, ψ0, p, tlist, Mz) # evolution
    end

    if 2 in test_indices
        # evolution with a states nearby t0. 
        # the const setting, which must be same for spectrum and evolution.
        qubit_num = 8
        energy_num = 4
        p = (T=50,)
        dt = 1e-2 * p.T
        tlist = range(0, p.T; step=dt)
        H = create_ssh_H(qubit_num);
        ___, states, ___ = eigenstates(H(p, 1e-2 * p.T)); # near H(t0)
        ψ0 = states[1]
        Mz = create_magnet_quantity(qubit_num);
        get_spectrum(H, p, tlist, Mz; energy_num=energy_num) # spectrum
        get_evolution(H, ψ0, p, tlist, Mz) # calculate
    end

    if 3 in test_indices
        # calculate the symmetry of base
        qubit_num = 8
        energy_num = 4
        p = (T=50,)
        H = create_ssh_H(qubit_num);
        sym_op = create_sym_op(qubit_num)
        ___, states, ___ = eigenstates(H(p, 0.6 * p.T));
        # NOTE: 中间两个态没有不简并的时候.
        @show expect(sym_op, states[1]) # 3
        @show expect(sym_op, states[2])
        @show expect(sym_op, states[3])
        @show expect(sym_op, states[4]) # 1
    end

    if 4 in test_indices
        # Strictly calculate to initial state with sym of $P=3$
        qubit_num = 8
        energy_num = 4
        p = (T=50,)
        H = create_ssh_H(qubit_num);
        sym_op = create_sym_op(qubit_num)
        ___, states, ___ = eigenstates(H(p, 0)); # initial degenerate states
        subspace_sym_op = get_subspace_op(sym_op, states[1:4])
        sym_vals, sym_params, ___ = eigenstates(subspace_sym_op); # symmetry marked states
        # Get the params to construct the symmetry marked states(sym_val=3)
        @show sym_vals[4]
        @show sym_params[4]
        ψ0 = normalize(sum(sym_params[4][i] * states[i] for i in 1:4))
        @show ρ_23 = ptrace(ψ0, (2, 3))
        @show ρ_45 = ptrace(ψ0, (4, 5))
        @show ρ_67 = ptrace(ψ0, (4, 5))
        @show ρ_bound = ptrace(ψ0, (1, qubit_num))
        # Evolution
        dt = 1e-2 * p.T
        tlist = range(0, p.T; step=dt)
        Mz = create_magnet_quantity(qubit_num);
        get_spectrum(H, p, tlist, Mz; energy_num=energy_num) # spectrum
        get_evolution(H, ψ0, p, tlist, Mz) # evolution
    end

end
