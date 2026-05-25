# README

This directory is used to give a efficient way to calculate the operators .

Because the restriction of `ITensors.jl` and `RandomMeas.jl`, the default order of tensor index contraction is generally not the most optimal, including MPO and ITensors. In `RandomMeas.jl`, the order of index contraction is totally own to the qubits sites, instead of common indices.

So we change the Hilbert space order, on the one hand, we product the permuted operators with lower link dimension between local range. On the one hand, we must change the order of measurement group(shadows) at the same time because the fixed contraction order in `RandomMeas.jl`.

The permuted operation of indices is not necessary but which reminds us the Hilbert space order has been permuted.

A case of reflect operator estimation ref to [reflect_op_estimate](./reflect_op_estimate.jl)
