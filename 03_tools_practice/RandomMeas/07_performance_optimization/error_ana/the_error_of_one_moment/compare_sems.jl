include("./create_ops.jl")
include("./aux_fun.jl")
include("./corrected_fun.jl")

using Base.Threads

# calculate sems
function calculate_sems(group_name, N)
    siteindices = siteinds("Qubit", N);
    permuted_order = [x for pair = 1:N÷2 for x in (pair, N - pair + 1)];
    group_data_path = joinpath(@__DIR__, group_name)
    permuted_group, permuted_indices = import_permuted_group(group_data_path, siteindices, permuted_order);
    permuted_shadows = get_factorized_shadows(permuted_group);
    # calculate op 
    adjacent_swap_op = create_adjacent_swap_op(permuted_indices);
    expect_val, sem = corrected_get_expect_shadow(adjacent_swap_op, permuted_shadows; compute_sem=true);
    return expect_val, sem
end


# compare diff size 
function compare_diff_size(N_ls)
    N_num = length(N_ls)
    expect_val_vec = Vector{ComplexF64}(undef, N_num) 
    sem_vec = Vector{ComplexF64}(undef, N_num)
    @threads for N_index = 1:N_num
        N = N_ls[N_index]
        N_str = string(N)
        println("N = $N_str")
        group_name = "./data/group_diff_size(N = $N_str).npz"
        expect_val, sem = calculate_sems(group_name, N)
        expect_val_vec[N_index] = expect_val
        sem_vec[N_index] = sem
    end
    return expect_val_vec, sem_vec
end


# compare diff settings
function compare_diff_settings(N, settings_num_ls, shots_ls)
    settings_ls_length = length(settings_num_ls)
    shots_ls_length = length(shots_ls)
    expect_val_matrix = Matrix{ComplexF64}(undef, settings_ls_length, shots_ls_length) 
    sem_matrix = Matrix{ComplexF64}(undef, settings_ls_length, shots_ls_length)
    @threads for settings_index = 1:settings_ls_length
        settings_num = settings_num_ls[settings_index]
        settings_num_str = string(settings_num)
        println("settings_num = $(settings_num_str)")
        for shots_index = 1:shots_ls_length
            shots = shots_ls[shots_index]
            shots_str = string(shots)
            group_name = "./data/group_diff_settings(settings_num = $settings_num_str, shots = $shots_str).npz"
            expect_val, sem = calculate_sems(group_name, N)
            expect_val_matrix[settings_index, shots_index] = expect_val
            sem_matrix[settings_index, shots_index] = sem
        end
    end
    return expect_val_matrix, sem_matrix
end


if abspath(PROGRAM_FILE) == @__FILE__
    # compare diff size
    N_ls = [2 * i for i = 2:9]
    expect_val_vec, sem_vec = compare_diff_size(N_ls)
    diff_size_path = joinpath(@__DIR__, "./data/compare_diff_size.npz")
    npzwrite(
        diff_size_path,
        Dict(
            "N_ls" => N_ls,
            "expect_val_vec" => expect_val_vec,
            "sem_vec" => sem_vec,
        ),
    )
    # compare diff settings
    N = 4
    settings_num_ls = [2^i for i = 6:10]
    shots_ls = [2^i for i = 6:10]
    expect_val_matrix, sem_matrix = compare_diff_settings(N, settings_num_ls, shots_ls)
    diff_settings_path = joinpath(@__DIR__, "./data/compare_diff_settings.npz")
    npzwrite(
        diff_settings_path,
        Dict(
            "settings_num_ls" => settings_num_ls,
            "shots_ls" => shots_ls,
            "expect_val_matrix" => expect_val_matrix,
            "sem_matrix" => sem_matrix,
        ),
    )
end
