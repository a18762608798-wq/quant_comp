OPENQASM 2.0;
include "qelib1.inc";
qreg q[1];
creg c[1];
u3(0.8203918658747584,2.632992020483295,-2.086260830466622) q[0];
measure q[0] -> c[0];
