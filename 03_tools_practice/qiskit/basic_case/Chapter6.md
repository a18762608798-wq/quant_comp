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
    display_name: Python 3
    language: python
    name: python3
---

# Chapter 6

<!-- #region vscode={"languageId": "plaintext"} -->
## 6.1 get physical info from circ
<!-- #endregion -->

* state vec

```python
from qiskit import QuantumCircuit
from qiskit.quantum_info import Statevector
import numpy as np

pirc = QuantumCircuit(1)

# initialize
initial_vector = [1/np.sqrt(2), 1j*np.sqrt(2)] 
circ.initialize(initial_vector, [0], normalize=True)

# 使用 Statevector 直接计算电路的状态向量
state = Statevector(circ)
print("\n状态向量：")
print(state.data)
```

* get operator matrix

```python
from qiskit import QuantumCircuit
from qiskit.quantum_info import Operator
import numpy as np

# initialize
circ = QuantumCircuit(1)
circ.rx(np.pi/2, 0)

# 使用 Operator 直接计算电路的幺正矩阵(不接受initialize函数, 此过程非幺正操作。)
unitary = Operator(circ)
print("幺正矩阵：")
print(unitary.data)
```

* visualization(看 Chapter7, 放弃旧版。)

**显然bloch_vec，unitary在测量前，Qsphere和histogram要在测量后（因为其结果是包括测量的）。**

## 6.2 real comp

![image.png](attachment:image.png)

以百度的超导电路平台为例。圆为单量子比特，菱形连接处为双量子比特（这个平台只有Cz）。
**转译受基础门影响，但不一定都是基础门。**

* T1: 纵向弛豫时间，反映量子态**自发**从激发态回到基态的平均时间。
* T2: 横向弛豫时间（相位相干时间）。
* qubit_frequency: 量子比特工作频率, 影响门操作速度和串扰。
* readout_frequency: 读出频率。
* single_qubit_gate_duration：单量子比特门持续时间
* single_qubit_gate_fidelity: 保真度。

```python
# try to specified certain quatum bits.

from quark import Task
import os
from qiskit import qasm2
import time
import matplotlib.pyplot as plt

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
    bases = sorted(data)
    count = [data[base] for base in bases]
    plt.bar(bases, count)
    plt.xticks(rotation=45)
```

```python
# case:
from qiskit import QuantumCircuit
from qiskit import qasm2
import numpy as np

circ = QuantumCircuit(3, 6) # 多次测量备用。
circ.h([0, 1, 2])
circ.barrier([0, 1, 2]) # barrier and reset.
circ.h([0])
circ.cx(0, 1)
circ.cx(0, 2)
circ.measure([0, 1, 2], [3, 4, 5])
circ.draw()
```

```python
quark_comp(circ, target_qubits=[70, 71, 72])
```
