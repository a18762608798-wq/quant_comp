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

# Chapter 4
## Backend qasm_simulator


```python jupyter={"is_executing": false}
from qiskit import QuantumRegister, ClassicalRegister, QuantumCircuit, transpile
from qiskit_aer import Aer
from qiskit.visualization import plot_histogram
```

### Case1: H gate


* definite the circ.

```python
# definite bits.
qreg = QuantumRegister(1) # the group of qreg, which will update the logo of this reg(this logo is owing to the first bit)).
creg = ClassicalRegister(1)
circ = QuantumCircuit(qreg, creg)
# definite logic gate.
circ.h(qreg[0]) # 此处重复运行不刷新缓存区，也就是会接着加bit门。
circ.measure(qreg, creg)
circ.draw('mpl')
```

```python
# or a easy formal.
circ = QuantumCircuit(1, 1)
circ.h([0])
circ.measure([0], [0])
display(circ.draw('mpl'))
```

* run the circ.

```python
backend = Aer.get_backend('qasm_simulator') # get the back end.
transpiled_circ = transpile(circ, backend) # transpile the circ with certain backend.
job = backend.run(transpiled_circ, shots=1000, memory=True) # run the circ.
# get the result.
result = job.result() 
memory = result.get_memory()  # get memory
counts = result.get_counts()  # count the result.

print(counts)
print(memory)
plot_histogram(counts)
```

### Case2: HX gate

```python
from qiskit import QuantumRegister, ClassicalRegister, QuantumCircuit, transpile
from qiskit_aer import Aer
from qiskit.visualization import plot_histogram

qreg = QuantumRegister(1) 
print(qreg)
creg = ClassicalRegister(1)
circ = QuantumCircuit(qreg, creg)
circ.x(qreg[0]) # add this X-gate.
circ.h(qreg[0]) 
circ.measure(qreg, creg)
circ.draw('mpl')
backend = Aer.get_backend('qasm_simulator') 
transpiled_circ = transpile(circ, backend) 
job = backend.run(transpiled_circ, shots=1000, memory=True) 
result = job.result() 
counts = result.get_counts()
plot_histogram(counts)
```

### Case3 initialize

```python
from qiskit import QuantumRegister, ClassicalRegister, QuantumCircuit, transpile
from qiskit_aer import Aer
from qiskit.visualization import plot_histogram
import numpy as np
qreg = QuantumRegister(2) 
creg = ClassicalRegister(2)
circ = QuantumCircuit(qreg, creg)
# ----------
initial_vector = [0, 0, 1, 0] # initialize the circ, 这里需要直积空间的量子态而不是单个的。
circ.initialize(initial_vector, [0, 1], normalize=True) 
# ----------
circ.h(qreg[0]) 
circ.measure(qreg, creg)
circ.draw('mpl')
backend = Aer.get_backend('qasm_simulator') 
transpiled_circ = transpile(circ, backend) 
job = backend.run(transpiled_circ, shots=1000, memory=True) 
result = job.result() 
memory = result.get_memory() 
counts = result.get_counts()

display(circ.draw('mpl'))
plot_histogram(counts)
```

### Case4 HH gate

```python
from qiskit import QuantumCircuit, transpile
from qiskit_aer import Aer
from qiskit.visualization import plot_histogram

circ = QuantumCircuit(2, 2)
circ.h([0, 1])
circ.measure([0, 1], [0, 1]) # qreq0 \rightarrow creq0, qreq1 \rightarrow creq1.
display(circ.draw('mpl'))
backend = Aer.get_backend('qasm_simulator') 
transpiled_circ = transpile(circ, backend) 
job = backend.run(transpiled_circ, shots=1000, memory=True) 
result = job.result() 
memory = result.get_memory() 
counts = result.get_counts()
plot_histogram(counts)
```

### Case5: Bell state

```python
from qiskit import QuantumCircuit, transpile
from qiskit_aer import Aer
from qiskit.visualization import plot_histogram

circ = QuantumCircuit(2, 2)
circ.h([0])
circ.cx(0, 1) # C-NOT gate.
circ.measure([0, 1], [0, 1])
display(circ.draw('mpl'))
backend = Aer.get_backend('qasm_simulator') 
transpiled_circ = transpile(circ, backend) 
job = backend.run(transpiled_circ, shots=1000, memory=True) 
result = job.result() 
memory = result.get_memory() 
counts = result.get_counts()
plot_histogram(counts)
```

### Case6: Ry gate

```python
from qiskit import QuantumCircuit, transpile
from qiskit_aer import Aer
from qiskit.visualization import plot_histogram
import numpy as np

circ = QuantumCircuit(1, 1)
circ.h([0])
circ.ry(np.pi/2, 0) # Ry gate. 直接作用到1态上，作弊要彻底。
circ.measure([0], [0])
display(circ.draw('mpl'))
backend = Aer.get_backend('qasm_simulator') 
transpiled_circ = transpile(circ, backend) 
job = backend.run(transpiled_circ, shots=1000, memory=True) 
result = job.result() 
memory = result.get_memory() 
counts = result.get_counts()
plot_histogram(counts)
```

### Case7 GHZ state

```python
from qiskit import QuantumCircuit, transpile
from qiskit.visualization import plot_histogram
from qiskit_aer import Aer
import numpy as np

circ = QuantumCircuit(3, 6) # 多次测量备用。
circ.h([0, 1, 2])
circ.measure([0, 1, 2], [0, 1, 2])
display(circ.draw('mpl'))
backend = Aer.get_backend('qasm_simulator') 
transpiled_circ = transpile(circ, backend) 
job = backend.run(transpiled_circ, shots=1000) 
result = job.result() 
counts = result.get_counts()
plot_histogram(counts) # 后三位为0, 因为没有信号。
```

* reset and continue to arrange

```python
circ.barrier([0, 1, 2]) # barrier and reset. reset is not supported now.
circ.reset([0, 1, 2])
circ.h([0])
circ.cx(0, 1)
circ.cx(0, 2)
circ.measure([0, 1, 2], [3, 4, 5])
display(circ.draw('mpl'))
transpiled_circ = transpile(circ, backend) 
job = backend.run(transpiled_circ, shots=1000) 
result = job.result() 
counts = result.get_counts()
plot_histogram(counts) 
```

## Backend statevector_simulator

different backend. `statevector_simulator`

```python
from qiskit import QuantumCircuit
from qiskit_aer import Aer
from qiskit.visualization import plot_bloch_multivector
import numpy as np

circ = QuantumCircuit(1, 1)
circ.h([0])
circ.ry(-np.pi/3, 0) 
display(circ.draw('mpl'))
backend = Aer.get_backend('statevector_simulator') # different simulator
result = backend.run(circ).result()
psi = result.get_statevector()
print(psi)
plot_bloch_multivector(psi)
```

## quark run

目前思路是用qiskit转化为quam，然后用quark提交到quafu。太抽象了。

```python
from quark import Task
import os
token = os.getenv('QUARK_API_TOKEN')
token = "pHCY3u..ukZUs5Smk9QZRkb`WmR3[xGGdWSoOX[e.fO/Rg2FUO3NkN35jOydkN5VUP3dUN7JDd5WnJtJjOypUO1pEOyBTPz1jNy1TOzBkNjpkJ1GXbjxDN7JDcm[Y[tKDMj13ck6TdyCVN4hkOzh{OyRkNjpkJzW3d2Kzf"
tmgr = Task(token) # task manager
display(tmgr.status())
```

```python
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
display(circ.draw('mpl'))
backend = Aer.get_backend('statevector_simulator') # different simulator
transpiled_circ = transpile(circ, backend) 
job = backend.run(transpiled_circ, shots=10000) 
result = job.result() 
counts = result.get_counts()
plot_histogram(counts) 
```

```python
qasm_circ = qasm2.dumps(circ)

task = {
  'chip': 'Dongling',  # chip name
  'name': 'MyJob',  # task name
  'circuit':qasm_circ, # circuit written in OpenQASM2.0
  'compile': True, # transpile to native gate sets if True
  'options':{
    'correct': False, # readout error correction 
    'target_qubits': [] # [0, 1], effective only when compile is True
  }
}
```

```python
tid = tmgr.run(task, repeat=10) # shots = repeat*1024
```

```python
# 时间到了才有输出。
res = tmgr.result(tid)
display(res)
```

```python
import matplotlib.pyplot as plt
data = res['count']
bases = sorted(data)
count = [data[base] for base in bases]

plt.bar(bases, count)
plt.xticks(rotation=45)
```
