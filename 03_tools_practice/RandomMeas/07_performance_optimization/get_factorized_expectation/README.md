# README

This directory is used to give a efficient way to calculate the operators with the form of direct product and analysis standard error of the mean(SEM).

## expectation of ops

Because the restriction of `ITensors.jl` and `RandomMeas.jl`, the default order of tensor index contraction is generally not the most optimal, including MPO and ITensors. In `RandomMeas.jl`, the order of index contraction is totally own to the qubits sites, instead of common indices.

So we change the Hilbert space order, on the one hand, we product the permuted operators with lower link dimension between local range. On the one hand, we must change the order of measurement group(shadows) at the same time because the fixed contraction order in `RandomMeas.jl`.

The permuted operation of indices is not necessary but which reminds us the Hilbert space order has been permuted.

A case of reflect operator estimation ref to [reflect_op_estimate](./reflect_op_estimate.jl)

## error analysis

### the error of RandomMeas

Ref to [RandomMeas.AbstractShadow](https://github.com/bvermersch/RandomMeas.jl/blob/89c492bfb05508e5babe9c8c2c40697995be9e42/src/AbstractShadows.jl#L8-L35)

```julia
function get_expect_shadow(
    O::MPO,
    shadows::AbstractArray{<:AbstractShadow};
    compute_sem::Bool = false
)
    # Ensure the array of shadows is not empty
    @assert !isempty(shadows) "Array of shadows is empty."

    # Compute all expectation values
    expect_values = [get_expect_shadow(O, shadow) for shadow in shadows]

    # Compute mean
    mean_value = mean(expect_values)

    if compute_sem
        # Compute standard error of the mean (SEM)
        sem_value = std(expect_values) / sqrt(length(expect_values))
        return mean_value, sem_value
    else
        return mean_value
    end
end
```

Evidently, which calculate SEM but ignore the correlation between diff NU.

The subpart of `error_ana` as a case of reflect operator error analysis calculation ref to [compare_sems](./compare_sem.jl) and the visual display ref to [plot_sems](./plot_sems.py), to estimate the relationship of SEM and the growth of qubits, the exponential growth of NU and the exponential growth of NM.

The results show that the error is almost solely related to NU*NM. Which is absurdity when the expectation is 1 for Clifford measurement ref to [q-2023-06-29-1044.pdf](./../../08_reference/q-2023-06-29-1044.pdf).

总之对于统计误差，应该看最外层的独立样本的样本误差（不管是var还是sem), 内层的波动应该反映每个样本的具体测量数值上面, 本质上是因为“样本平均”“样本方差”这些概念都是建立在独立同分布上.
