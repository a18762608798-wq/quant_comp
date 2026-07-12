from collections.abc import (
    Callable,
)  # `Callable` 是“可调用对象”（函数/lambda/方法）的类型，只用于类型注解，表示“这里要塞一个函数”
from dataclasses import (
    dataclass,
)  # 装饰器，自动帮类生成 `__init__`、`__repr__`、`__eq__`，不用手写
from itertools import product

import numpy as np
from qiskit.circuit import ParameterVector

# 这些没有运行时作用，纯粹给类型/可读性用，`X = 某类型` 就是给类型起个短名字：
ParameterBinds = list[dict]
ParameterGroups = list[tuple[int, ...]]

GroupBuilder = Callable[
    [int], ParameterGroups
]  # `Callable[[参数类型...], 返回类型]` 就是“函数的类型签名”。
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
# Group builders: how measured qubits share parameters(分组函数, 测量位如何共享参数)
# ------------------------------------------------------------------


def _independent_groups(meas_num: int) -> ParameterGroups:
    return [(i,) for i in range(meas_num)]


def _paired_groups(meas_num: int) -> ParameterGroups:
    if meas_num % 2 != 0:
        raise ValueError("pair mode requires an even number of measured qubits")

    return [(i, i + 1) for i in range(0, meas_num, 2)]


GROUP_BUILDERS: dict[str, GroupBuilder] = {
    "independence": _independent_groups,
    "pair": _paired_groups,
}


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

    if setting_num == setting_upper:
        selected = all_bases
    else:
        selected_indices = rng.choice(
            setting_upper,
            size=setting_num,
            replace=False,
        )
        selected = all_bases[selected_indices]

    # selected shape: (setting_num, group_num) -> (group_num, setting_num)
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
    group_builder: GroupBuilder
    angle_sampler: AngleSampler
    rng: np.random.Generator

    # 工厂决定“用哪种策略，`generate` 执行“这种策略”.
    def generate(
        self,
        params: list[ParameterVector],
        meas_indices: list[int],
        setting_num: int,
    ) -> ParameterBinds:
        meas_num = len(meas_indices)

        groups = self.group_builder(meas_num)

        group_theta, group_lambda = self.angle_sampler(
            len(groups),
            setting_num,
            self.rng,
        )

        theta_values, lambda_values = _expand_group_values(
            groups=groups,
            group_theta=group_theta,
            group_lambda=group_lambda,
            meas_num=meas_num,
            setting_num=setting_num,
        )

        return _to_parameter_binds(
            params=params,
            theta_values=theta_values,
            lambda_values=lambda_values,
        )


def _expand_group_values(
    groups: ParameterGroups,
    group_theta: np.ndarray,
    group_lambda: np.ndarray,
    meas_num: int,
    setting_num: int,
) -> tuple[np.ndarray, np.ndarray]:
    theta_values = np.empty((meas_num, setting_num), dtype=float)
    lambda_values = np.empty((meas_num, setting_num), dtype=float)

    for group_idx, members in enumerate(groups):
        for meas_idx in members:
            theta_values[meas_idx] = group_theta[group_idx]
            lambda_values[meas_idx] = group_lambda[group_idx]

    return theta_values, lambda_values


def _to_parameter_binds(
    params: list[ParameterVector],
    theta_values: np.ndarray,
    lambda_values: np.ndarray,
) -> ParameterBinds:
    theta, llambda = params
    meas_num = len(theta)

    binds = {theta[i]: theta_values[i].tolist() for i in range(meas_num)}

    binds.update({llambda[i]: lambda_values[i].tolist() for i in range(meas_num)})

    return [binds]


def create_parameter_generator(
    meas_mode: str,
    ensemble: str,
    *,  # `*` 表示它**后面的参数只能按关键字传**（keyword-only）。不需要我们给一个默认vals.
    seed: int | None = None,
) -> ParameterGenerator:
    try:
        group_builder = GROUP_BUILDERS[meas_mode]
    except KeyError:
        raise ValueError(
            f"Unknown meas_mode: {meas_mode!r}. Available: {list(GROUP_BUILDERS)}"
        ) from None

    try:
        angle_sampler = ANGLE_SAMPLERS[ensemble]
    except KeyError:
        raise ValueError(
            f"Unknown ensemble: {ensemble!r}. Available: {list(ANGLE_SAMPLERS)}"
        ) from None

    return ParameterGenerator(
        group_builder=group_builder,
        angle_sampler=angle_sampler,
        rng=np.random.default_rng(seed),
    )
