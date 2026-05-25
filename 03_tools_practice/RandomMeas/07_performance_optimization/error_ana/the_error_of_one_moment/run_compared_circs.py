from run_circs import savez_reflect_data


def run_diff_size(N_ls, settings_num, shots):
    for N in N_ls:
        print("N = ", N)
        group_name = "./data/group_diff_size(N = {})".format(str(N))
        savez_reflect_data(group_name, N, settings_num, shots)


def run_diff_settings(N, settings_num_ls, shots_ls):
    for settings_num in settings_num_ls:
        print("\nSettings_num = ", settings_num)
        for shots in shots_ls:
            group_name = (
                "./data/group_diff_settings(settings_num = {}, shots = {})".format(
                    str(settings_num), str(shots)
                )
            )
            savez_reflect_data(group_name, N, settings_num, shots)


if __name__ == "__main__":
    # run diff size
    N_ls = [2 * i for i in range(2, 10)]
    settings_num = 2**7
    shots = 2**7
    run_diff_size(N_ls, settings_num, shots)
    # run diff settings
    N = 4
    settings_num_ls = [2**i for i in range(6, 11)]
    shots_ls = [2**i for i in range(6, 11)]
    run_diff_settings(N, settings_num_ls, shots_ls)
