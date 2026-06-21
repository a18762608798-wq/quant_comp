include("op_creator.jl")
using ProgressMeter
using NPZ

function get_gap(H, p, t) 
    # get the info
    room_dim = size(H.data, 1)
    # storge the res
    if room_dim <= 2^10
        E, qobj_states, U = eigenstates(H(p, t))
        return real.(E[2] - E[1])
    else
        # 找最低能量态：适合 Hermitian Hamiltonian
        E, qobj_states, U = eigenstates(H(p, t);
            sparse=true,
            eigvals=2,
            sortby=real,
            rev=false,
        )
        return real.(E[2] - E[1])
    end
end

function save_gap(file_path, p, t, qubit_nums)
    E_gaps = Vector{Float64}(undef, length(qubit_nums))
    @showprogress "Computing gaps" for qubit_idx in eachindex(qubit_nums)
        qubit_num = qubit_nums[qubit_idx]
        H = create_ssh_H(qubit_num, p); # the ops setting
        E_gaps[qubit_idx] = get_gap(H, p, t)
    end
    npzwrite(
        file_path,
        Dict(
            "L" => qubit_nums,
            "E_gap" => E_gaps,
        ),
    )
end
