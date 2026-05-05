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

# Chapter 8


## 8.1 test T1 and T2 
* T1 多给ID门，此门数量无限制。
* T2 同理。

T2也就是相对相位一般先出问题。

此为定性比较，具体数字待定。

```python
import os
import time
import matplotlib.pyplot as plt 
from qiskit import QuantumCircuit, qasm2
from quark import Task

def quark_comp(qiskit_circ, repeat_count=1, my_job='my_job', chip='Yudu', target_qubits=[]):
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
# test T1
circ = QuantumCircuit(1, 1)
circ.x(0)
for i in range(10024): 
    circ.id(0)
    circ.barrier()
circ.measure(0, 0)

quark_comp(circ)
```

```python
# test T2
circ = QuantumCircuit(1, 1)
circ.x(0)
circ.h(0)
for i in range(1024):
    circ.id(0)
    circ.barrier()
circ.h(0)
circ.measure(0, 0)
quark_comp(circ)
```

## 8.2 纠错

1. 两种错误：
* 比特翻转纠错: 用3个比特保证第一个比特不变。
* 相位翻转纠错：用3个比特保证第一个相位不变。

2. 同时纠错**shor 码**，9个，心累。

在真实的量子计算机上可以看出来显然是越纠越错。

```python
# bit filp
from qiskit_aer import Aer
from qiskit import transpile
from qiskit.visualization import plot_histogram
circ = QuantumCircuit(3, 3)
circ.h(0)
circ.cx([0, 0], [1, 2])
circ.barrier()
circ.x(0)
circ.barrier()
circ.cx([0, 0], [1, 2])
circ.ccx(1, 2, 0)
circ.measure([0, 1, 2], [0, 1, 2])
display(circ.draw('mpl'))

backend = Aer.get_backend('statevector_simulator') # different simulator
transpiled_circ = transpile(circ, backend) 
job = backend.run(transpiled_circ, shots=10000) 
result = job.result() 
counts = result.get_counts()
plot_histogram(counts) 

```

```python
quark_comp(circ, chip='Baihua')
```

```python
# phase error
circ = QuantumCircuit(3, 3)
circ.h(0)
circ.cx([0, 0], [1, 2])
circ.h([0, 1, 2])
circ.barrier([0, 1, 2])
circ.z(0)
circ.barrier([0, 1, 2])
circ.h([0, 1, 2])
circ.cx([0, 0], [1, 2])
circ.ccx(1, 2, 0)
circ.measure([0, 1, 2], [0, 1, 2])
display(circ.draw('mpl'))

backend = Aer.get_backend('statevector_simulator') # different simulator
transpiled_circ = transpile(circ, backend) 
job = backend.run(transpiled_circ, shots=10000) 
result = job.result() 
counts = result.get_counts()
plot_histogram(counts) 
```

```python
quark_comp(circ, chip='Baihua')
```

```python
# shor 码
circ = QuantumCircuit(9, 1)
circ.h(0)
circ.cx([0, 0], [3, 6])
circ.h([0, 3, 6])
circ.cx([0, 0, 3, 3, 6, 6], [1, 2, 4, 5, 7, 8])
circ.barrier([i for i in range(9)])
circ.x(0)
circ.z(0)
circ.barrier([i for i in range(9)])
circ.cx([0, 0, 3, 3, 6, 6], [1, 2, 4, 5, 7, 8])
for i in [3 * j for j in range(3)]:
    circ.ccx(i + 2, i + 1, i)
circ.h([0, 3, 6])
circ.cx([0, 0], [3, 6])
circ.ccx(3, 6, 0)
circ.measure(0, 0)
display(circ.draw('mpl'))
```

```python
backend = Aer.get_backend('statevector_simulator') # different simulator
transpiled_circ = transpile(circ, backend) 
job = backend.run(transpiled_circ, shots=10000) 
result = job.result() 
counts = result.get_counts()
plot_histogram(counts) 
```

```python
quark_comp(circ, chip='Baihua')
```

```python
# shor 码
circ = QuantumCircuit(1, 1)
circ.h(0)
circ.measure(0, 0)
display(circ.draw('mpl'))
quark_comp(circ, chip='Baihua')
```
