from collections.abc import (
    Callable,
)
from dataclasses import (
    dataclass,
)
from itertools import product

import numpy as np
from qiskit.circuit import ParameterVector

ParameterBinds = list[dict]

AngleSampler = Callable[
    [int, int, np.random.Generator],
    tuple[np.ndarray, np.ndarray],
]


PAULI_ROTATIONS = np.array(
    [
        [np.pi / 2, 0],
        [np.pi / 2, np.pi / 2],
        [0, 0],
    ],
    dtype=float,
)


# ------------------------------------------------------------------
# Angle samplers: how each logical group draws its values
# ------------------------------------------------------------------


def _sample_haar(
    group_num: int,
    setting_num: int,
    rng: np.random.Generator,
) -> tuple[np.ndarray, np.ndarray]:
    theta = np.arccos(
        rng.uniform(
            -1.0,
            1.0,
            size=(group_num, setting_num),
        )
    )

    llambda = rng.uniform(
        0.0,
        2.0 * np.pi,
        size=(group_num, setting_num),
    )

    return theta, llambda


def _sample_pauli(
    group_num: int,
    setting_num: int,
    rng: np.random.Generator,
) -> tuple[np.ndarray, np.ndarray]:
    indices = rng.choice(
        3,
        size=(group_num, setting_num),
        replace=True,
    )

    theta = PAULI_ROTATIONS[indices, 0]
    llambda = PAULI_ROTATIONS[indices, 1]

    return theta, llambda


def _sample_derandom(
    group_num: int,
    setting_num: int,
    rng: np.random.Generator,
) -> tuple[np.ndarray, np.ndarray]:
    setting_upper = 3**group_num

    if setting_num > setting_upper:
        raise ValueError(f"setting_num={setting_num} exceeds 3^{group_num}")

    all_bases = np.array(
        list(product(range(3), repeat=group_num)),
        dtype=int,
    )

    selected_indices = rng.choice(
        setting_upper,
        size=setting_num,
        replace=False,
    )
    selected = all_bases[selected_indices]

    selected = selected.T

    theta = PAULI_ROTATIONS[selected, 0]
    llambda = PAULI_ROTATIONS[selected, 1]

    return theta, llambda


ANGLE_SAMPLERS: dict[str, AngleSampler] = {
    "haar": _sample_haar,
    "pauli": _sample_pauli,
    "derandom": _sample_derandom,
}


# ------------------------------------------------------------------
# Generator
# ------------------------------------------------------------------


@dataclass
class ParameterGenerator:
    angle_sampler: AngleSampler
    rng: np.random.Generator

    def generate(
        self,
        params: list[ParameterVector],
        setting_num: int,
    ) -> ParameterBinds:
        group_num = len(params[0])

        group_theta, group_lambda = self.angle_sampler(
            group_num,
            setting_num,
            self.rng,
        )

        return _to_parameter_binds(
            params=params,
            theta_values=group_theta,
            lambda_values=group_lambda,
        )


def _to_parameter_binds(
    params: list[ParameterVector],
    theta_values: np.ndarray,
    lambda_values: np.ndarray,
) -> ParameterBinds:
    theta, llambda = params
    group_num = len(theta)

    binds = {theta[i]: theta_values[i].tolist() for i in range(group_num)}

    binds.update({llambda[i]: lambda_values[i].tolist() for i in range(group_num)})

    return [binds]


def create_parameter_generator(
    ensemble: str,
    *,
    seed: int | None = None,
) -> ParameterGenerator:
    try:
        angle_sampler = ANGLE_SAMPLERS[ensemble]
    except KeyError:
        raise ValueError(
            f"Unknown ensemble: {ensemble!r}. Available: {list(ANGLE_SAMPLERS)}"
        ) from None

    return ParameterGenerator(
        angle_sampler=angle_sampler,
        rng=np.random.default_rng(seed),
    )