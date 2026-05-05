---
jupyter:
  jupytext:
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.19.0
  kernelspec:
    display_name: .python
    language: python
    name: python3
---

# Chapter9 gover 搜索算法


## 9.1 量子相位反冲

手动制作，两个比特都是 $\pi$ 相位。

**图上颜色可以看出是正常的相对相位相位。** 这个破书的理解是 $|1\rangle$ 转 $\pi$ 相位所以 $|11\rangle$ 是 $2\pi$ 不变，也对。

```python
import numpy as np
from qiskit import QuantumCircuit
from qiskit_aer import Aer
from qiskit.visualization import plot_state_qsphere
# circ
circ = QuantumCircuit(2, 2)
circ.h([0, 1])
circ.rz([0, 1])
display(circ.draw('mpl'))
# qsphere plot
circ.save_statevector()
vec_backend = Aer.get_backend('aer_simulator_statevector')
vec_result = vec_backend.run(circ).result()
psi = vec_result.get_statevector()
print(psi)
display(plot_state_qsphere(psi))
```

相位为pi，作为受控受控位置，可以反控制。

```python
circ = QuantumCircuit(2, 2)
circ.h([0, 1])
circ.rz(np.pi, 1)
circ.cx(0, 1)
display(circ.draw('mpl'))

# qsphere plot
circ.save_statevector()
vec_backend = Aer.get_backend('aer_simulator_statevector')
vec_result = vec_backend.run(circ).result()
psi = vec_result.get_statevector()
print(psi)
display(plot_state_qsphere(psi))
```

## 9.2 双比特grover

我想不到有什么意义，可能需要绑定其他信息？

```python
import numpy as np
from qiskit import QuantumCircuit
from qiskit_aer import Aer
from qiskit.visualization import plot_state_qsphere

# 均匀初态
circ = QuantumCircuit(2, 2)
circ.h([0, 1])
circ.barrier([0, 1])
# |01\rangle 取反
circ.x(0)
circ.h(1)
circ.cx(0, 1)
circ.x(0)
circ.h(1)
circ.barrier([0, 1])
# 放大反位
circ.h([0, 1])
circ.x([0, 1])
circ.h(1)
circ.cx(0, 1)
circ.h(1)
circ.barrier([0, 1])
circ.x([0, 1])
circ.h([0, 1])
circ.measure([0, 1], [0, 1])
display(circ.draw('mpl'))

```

```python
import os
import time
import matplotlib.pyplot as plt 
from qiskit import QuantumCircuit, qasm2
from quark import Task

def quark_comp(qiskit_circ, repeat_count=1, my_job='my_job', chip='Baihua', target_qubits=[]):
    # circ trans
    qasm_circ = qasm2.dumps(qiskit_circ)
    # tmgr
    token = os.getenv('QUARK_API_TOKEN')
    tmgr = Task(token) # task manager
    task = {
    'chip': chip,  
    'name': my_job,  
    'circuit':qasm_circ, # circuit written in OpenQASM2.0
    'compile': True, # 可能用模拟机。(你要是自信自己写的全是基础门就用False.)
    'options':{
        'correct': False,
        'target_qubits': target_qubits # 具体bit而非范围。 
    }
    }

    tid = tmgr.run(task, repeat=repeat_count) # shots = repeat*1024
    res = tmgr.result(tid)
    while not res:
        time.sleep(1)
        res = tmgr.result(tid)
    display(res)

    data = res['count']
    bases = sorted(data) # 00, 01, 10, 11
    count = [data[base] for base in bases]
    plt.bar(bases, count)
    plt.xticks(rotation=45)
    return data
```

```python
quark_comp(circ)
```

## 9.3 多比特grover

也没说原理直接用包装好的。需要现构造oracle，根据其制备有初态的电路：

* 'x & y' - 逻辑与（AND）
* 'x | y' - 逻辑或（OR）
* '~x' - 逻辑非（NOT）

Q是"Quantum Oracle"的缩写，表示这是一个量子黑盒操作。oracle意味预言机。

太逆天了。

```python
from qiskit import QuantumCircuit
from qiskit.circuit.library import grover_operator, PhaseOracle

# 1. 创建预言机 (例如：搜索 |......> 状态)
oracle = PhaseOracle('~a & b & c & d & e')  # oracle 本身就是一个 QuantumCircuit 对象

# 初态
n_qubits = oracle.num_qubits
state_preparation = QuantumCircuit(n_qubits)
state_preparation.h(range(n_qubits))  # 创建均匀叠加态

# 3. 生成 Grover 算子电路
grover_op = grover_operator(
    oracle=oracle,
    state_preparation=state_preparation
)

# 4. 构建完整 Grover 电路 (1次迭代), 每次迭代都会使目标状态的概率振幅增加，非目标状态的振幅减少。
iterations = 100
grover_circuit = QuantumCircuit(n_qubits)
grover_circuit.compose(state_preparation, inplace=True)  # 初始叠加
grover_circuit.compose(grover_op.power(iterations), inplace=True)  # 应用 Grover 算子

# 5. 添加测量 (如果需要)
grover_circuit.measure_all()

```

```python
from qiskit_aer import Aer
from qiskit import transpile
from qiskit.visualization import plot_histogram

backend = Aer.get_backend('aer_simulator') 
transpiled_circ = transpile(grover_circuit, backend) 
job = backend.run(transpiled_circ, shots=1000) 
result = job.result() 
counts = result.get_counts()
plot_histogram(counts)
```

无法接受Q了。。。

```python
quark_comp(grover_circuit)
```
