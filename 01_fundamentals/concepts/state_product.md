# state product

## general state

Wait for learning.

## special state

### classical state

#### Bell base

We could explan the circuits via the transform of $\{ZI, IZ\}$ to $\{XX, ZZ\}$

Known bell base

$$
\begin{cases}
|\psi^-\rangle = \frac{1}{\sqrt 2} (|01\rangle \pm |10\rangle) \\
|\phi^-\rangle = \frac{1}{\sqrt 2} (|00\rangle \pm |11\rangle) \\
\end{cases}
$$

Bell state circuits are producted as follow

```text
|00⟩ + |11⟩
     ┌───┐     
q_0: ┤ H ├──■──
     └───┘┌─┴─┐
q_1: ─────┤ X ├
          └───┘
c: 2/══════════
               
Statevector([0.70710677+0.j, 0.        +0.j, 0.        +0.j,
             0.70710677+0.j],
            dims=(2, 2))

|00⟩ - |11⟩
     ┌───┐┌───┐     
q_0: ┤ X ├┤ H ├──■──
     └───┘└───┘┌─┴─┐
q_1: ──────────┤ X ├
               └───┘
c: 2/═══════════════
                    
Statevector([ 0.70710677+0.0000000e+00j,  0.        +0.0000000e+00j,
              0.        +0.0000000e+00j, -0.70710677-8.6595606e-17j],
            dims=(2, 2))

|01⟩ + |10⟩
     ┌───┐     
q_0: ┤ H ├──■──
     ├───┤┌─┴─┐
q_1: ┤ X ├┤ X ├
     └───┘└───┘
c: 2/══════════
               
Statevector([0.        +0.j, 0.70710677+0.j, 0.70710677+0.j,
             0.        +0.j],
            dims=(2, 2))


|01⟩ - |10⟩
     ┌───┐┌───┐     
q_0: ┤ X ├┤ H ├──■──
     ├───┤└───┘┌─┴─┐
q_1: ┤ X ├─────┤ X ├
     └───┘     └───┘
c: 2/═══════════════
                    
Statevector([ 0.        +0.0000000e+00j, -0.70710677-8.6595606e-17j,
              0.70710677+0.0000000e+00j,  0.        +0.0000000e+00j],
            dims=(2, 2))
```

