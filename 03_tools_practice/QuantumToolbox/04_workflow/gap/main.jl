include("./src/gap_calculator.jl")

function main()
    # setting
    p = (T = 10,)
    t = p.T / 2
    qubit_nums = [2i for i = 2:11]
    file_path = joinpath(@__DIR__, "./data/gap.npz")
    save_gap(file_path, p, t, qubit_nums)
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
