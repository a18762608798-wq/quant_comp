import numpy as np
from random import uniform

def get_shadow_params(params, meas_indices, setting_num):
    meas_num = len(meas_indices)
    theta, llambda = params
    parameter_binds = [
        {
            **{
                theta[i]: vals
                for i in range(meas_num)
                for vals in [[np.acos(uniform(-1, 1)) for j in range(setting_num)]]
            },

            **{
                llambda[i]: vals
                for vals in [[uniform(0, 2 * np.pi) for j in range(setting_num)]] 
                for i in range(meas_num)
            },
        }
    ]
    return parameter_binds


def get_hamming_params(params, meas_indices, setting_num):
    meas_num = len(meas_indices)
    pair_num = meas_num // 2
    theta, llambda = params

    parameter_binds = [
        {
            **{
                theta[k]: vals
                for i in range(pair_num)
                for vals in [[np.acos(uniform(-1, 1)) for j in range(setting_num)]]
                for k in (2 * i, 2 * i + 1)
            },

            **{
                llambda[k]: vals
                for i in range(pair_num)
                for vals in [[uniform(0, 2 * np.pi) for j in range(setting_num)]]
                for k in (2 * i, 2 * i + 1)
            },
        }
    ]
    return parameter_binds
