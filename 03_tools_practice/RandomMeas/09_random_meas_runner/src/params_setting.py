import numpy as np
from numpy.random import uniform, choice
from itertools import product

PAULI_ROTATIONS = np.array([[np.pi / 2, 0], [np.pi / 2, np.pi / 2], [0, 0]])


def get_random_params(params, meas_indices, setting_num, ensemble="haar"):
    meas_num = len(meas_indices)
    theta, llambda = params
    if ensemble == "haar":
        parameter_binds = [
            {
                **{
                    theta[i]: vals
                    for i in range(meas_num)
                    for vals in [[np.acos(uniform(-1, 1)) for _ in range(setting_num)]]
                },
                **{
                    llambda[i]: vals
                    for i in range(meas_num)
                    for vals in [[uniform(0, 2 * np.pi) for _ in range(setting_num)]]
                },
            }
        ]
    elif ensemble == "pauli":
        theta_choice_groups = np.zeros((meas_num, setting_num))
        llambda_choice_groups = np.zeros((meas_num, setting_num))
        for i in range(meas_num):
            pauli_choice_indices = choice(3, size=setting_num, replace=True)
            theta_choice_groups[i] = PAULI_ROTATIONS[pauli_choice_indices, 0]
            llambda_choice_groups[i] = PAULI_ROTATIONS[pauli_choice_indices, 1]
        parameter_binds = [
            {
                **{
                    theta[i]: vals
                    for i in range(meas_num)
                    for vals in [theta_choice_groups[i]]
                },
                **{
                    llambda[i]: vals
                    for i in range(meas_num)
                    for vals in [llambda_choice_groups[i]]
                },
            }
        ]
    elif ensemble == "derandom":
        setting_upper = 3**meas_num
        # Get choice groups
        theta_choice_groups = np.zeros((meas_num, setting_num))
        llambda_choice_groups = np.zeros((meas_num, setting_num))
        if setting_num == setting_upper:
            for setting_idx, combo in enumerate(product([0, 1, 2], repeat=meas_num)):
                theta_choice_groups[:, setting_idx] = PAULI_ROTATIONS[combo, 0]
                llambda_choice_groups[:, setting_idx] = PAULI_ROTATIONS[combo, 1]
        elif setting_num < setting_upper:
            # Sampling without replacement.
            complete_bases = list(product([0, 1, 2], repeat=meas_num))
            choice_indices = choice(setting_upper, size=setting_num, replace=False)
            for setting_idx in range(setting_num):
                base = np.array(complete_bases[choice_indices[setting_idx]])
                theta_choice_groups[:, setting_idx] = PAULI_ROTATIONS[base, 0]
                llambda_choice_groups[:, setting_idx] = PAULI_ROTATIONS[base, 1]
        else:
            assert setting_num <= setting_upper, (
                "何意味, setting_num 不应超过 3^n (n为测量比特的数目）."
            )
        # Save to binds
        parameter_binds = [
            {
                **{
                    theta[i]: vals
                    for i in range(meas_num)
                    for vals in [theta_choice_groups[i]]
                },
                **{
                    llambda[i]: vals
                    for i in range(meas_num)
                    for vals in [llambda_choice_groups[i]]
                },
            }
        ]
    else:
        assert False, "目前只有haar, pauli, derandom(pauli)."

    return parameter_binds


def get_condition_params(params, meas_indices, setting_num, ensemble="haar"):
    meas_num = len(meas_indices)
    assert meas_num % 2 == 0, "meas_num must be even for condition (paired) parameters."
    pair_num = meas_num // 2
    theta, llambda = params
    if ensemble == "haar":
        parameter_binds = [
            {
                **{
                    theta[k]: vals
                    for i in range(pair_num)
                    for vals in [[np.acos(uniform(-1, 1)) for _ in range(setting_num)]]
                    for k in (2 * i, 2 * i + 1)
                },
                **{
                    llambda[k]: vals
                    for i in range(pair_num)
                    for vals in [[uniform(0, 2 * np.pi) for _ in range(setting_num)]]
                    for k in (2 * i, 2 * i + 1)
                },
            }
        ]
    elif ensemble == "pauli":
        theta_choice_groups = np.zeros((pair_num, setting_num))
        llambda_choice_groups = np.zeros((pair_num, setting_num))
        for i in range(pair_num):
            pauli_choice_indices = choice(3, size=setting_num, replace=True)
            theta_choice_groups[i] = PAULI_ROTATIONS[pauli_choice_indices, 0]
            llambda_choice_groups[i] = PAULI_ROTATIONS[pauli_choice_indices, 1]
        parameter_binds = [
            {
                **{
                    theta[k]: vals
                    for i in range(pair_num)
                    for vals in [theta_choice_groups[i]]
                    for k in (2 * i, 2 * i + 1)
                },
                **{
                    llambda[k]: vals
                    for i in range(pair_num)
                    for vals in [llambda_choice_groups[i]]
                    for k in (2 * i, 2 * i + 1)
                },
            }
        ]
    elif ensemble == "derandom":
        setting_upper = 3**pair_num
        theta_choice_groups = np.zeros((pair_num, setting_num))
        llambda_choice_groups = np.zeros((pair_num, setting_num))
        if setting_num == setting_upper:
            for setting_idx, combo in enumerate(product([0, 1, 2], repeat=pair_num)):
                theta_choice_groups[:, setting_idx] = PAULI_ROTATIONS[combo, 0]
                llambda_choice_groups[:, setting_idx] = PAULI_ROTATIONS[combo, 1]
        elif setting_num < setting_upper:
            complete_bases = list(product([0, 1, 2], repeat=pair_num))
            choice_indices = choice(setting_upper, size=setting_num, replace=False)
            for setting_idx in range(setting_num):
                base = np.array(complete_bases[choice_indices[setting_idx]])
                theta_choice_groups[:, setting_idx] = PAULI_ROTATIONS[base, 0]
                llambda_choice_groups[:, setting_idx] = PAULI_ROTATIONS[base, 1]
        else:
            assert setting_num <= setting_upper, (
                "何意味, setting_num 不应超过 3^N (N为pair数目)."
            )
        parameter_binds = [
            {
                **{
                    theta[k]: vals
                    for i in range(pair_num)
                    for vals in [theta_choice_groups[i]]
                    for k in (2 * i, 2 * i + 1)
                },
                **{
                    llambda[k]: vals
                    for i in range(pair_num)
                    for vals in [llambda_choice_groups[i]]
                    for k in (2 * i, 2 * i + 1)
                },
            }
        ]
    else:
        assert False, "目前只有haar, pauli, derandom(pauli)."

    return parameter_binds
