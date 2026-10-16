# Lab 2 — Digital position control

## Objective

Replace the continuous-time controller with a digital one, using both routes:

- **design by emulation** — design in continuous time, then discretise;
- **direct digital design** — build a discrete-time model of the plant and design
  the controller entirely in the z-domain.

The comparison between the two, and the sensitivity to the sampling period, is the
substance of the lab.

## Design by emulation

The Lab 1 continuous controller is discretised with three different rules so the
choice of rule becomes a measured decision rather than an assumption:

| Rule | Character |
|---|---|
| Backward Euler (BE) | stable mapping, introduces phase lag |
| Forward Euler (FE) | can destabilise at long sampling periods |
| Tustin / bilinear | preserves stability, better phase behaviour |

Each discretised controller drives the same continuous plant, so any difference in
the response is attributable to the discretisation rule and not to the design.

A discrete feedforward filter is derived the same way (`FF_DT.m`), including the
Tustin step, so that Lab 1's feedforward compensation remains available in the
sampled-data controller.

## Direct digital design

The plant is sampled at `Ts`, `[Phi, Gamma, H, J] = ssdata(c2d(sys_c, Ts, 'zoh'))`,
and the controller is designed in the z-domain:

- the closed-loop poles are mapped from the continuous specification
  (`Mp`, `ts` → ζ, ωn) through `z = exp(s·Ts)`;
- state feedback `K` is obtained by pole placement on `(Phi, Gamma)`;
- a **reduced-order observer** estimates the unmeasured state. Because only the
  position is measured and the model is second order, the observer is first order,
  with gain `L = (Phi22 − z_o)/Phi12` — this is what the `A_22`, `A_12` lines in
  `Lab2_Nominal_Reduced_Order.m` are for;
- the reference gain comes from solving the augmented steady-state problem
  `[Phi − I, Gamma; H, 0]·[Nx; Nu] = [0; 0; 1]`;
- discrete integral action augments the state with the accumulated error, so
  constant disturbances are rejected in the sampled-data loop exactly as in Lab 1.

## Sampling period

The controller is re-run at several sampling periods and the responses compared.
The lab note is explicit that a sampled-data simulation must evaluate the plant
faster than the controller — the solver step is kept well below `Ts` so the
inter-sample behaviour is represented rather than assumed.

## Files

| File | Role |
|---|---|
| `matlab/Parameters.m` | Plant parameters |
| `matlab/Lab_2_2_2.m` | Direct digital design: discretisation, pole mapping, reduced-order observer, reference gain |
| `matlab/Lab_2_2_4.m` | Discrete integral-control augmentation |
| `matlab/FF_DT.m` | Discrete feedforward filter (Tustin) |
| `matlab/Lab2_Nominal_Reduced_Order.m` | Nominal design with reduced-order observer |
| `matlab/Lab2_Nominal_Reduced_Order_DT.m` | The same design, direct discrete |
| `matlab/Lab2_Robust_Reduced_Order.m` | Robust variant |
| `simulink/Lab2_2_1_1_1_{BE,FE,Tustin}.slx` | The three discretisation rules |
| `simulink/Lab2_2_1_1_3_BE_AntiWindup.slx` | Discrete anti-windup |
| `simulink/Lab2_2_1_1_4_BE_FF*.slx` | Discrete feedforward, with and without anti-windup |
| `simulink/Lab2_2_1_2_*.slx` | Reduced-order and DT designs, nominal and robust |
| `simulink/Lab_2_2_2_observer_design.slx` | Observer design model |
| `simulink/final_2_2_4.slx` | Final integral-control model |
| `results/simulation/` | Captured step responses across the sampling-period sweep |
| `data/tustin_tracking.csv` | Logged controller output and measured position, Tustin run |

## Results

![Lab 2 — Tustin controller output against measured position](../docs/figures/lab2_tustin_tracking.png)

Controller output and measured position for the Tustin-discretised controller over
the sampled-data run. The two traces track each other once the transient has
decayed, which is the expected behaviour for a well-damped discrete design.

The sampling-period study is captured in `results/simulation/`, where each figure
is named for the sampling period it was run at (`TS0.001`, `TS0.01`, `TS0.05`,
`TS0.1`) with separate step-response captures.

Note that the logged signals in `data/` come from different runs at different
lengths and units; they are published as logged rather than rescaled to match.

## Running it

```
cd lab-2-digital-control/matlab
matlab -batch "Parameters; Lab_2_2_2"
```

`Lab_2_2_2.m` prints the designed poles, gains, observer matrices and reference
gain to the console — that printout is the intended output of the script.

Requires MATLAB, Simulink and the Control System Toolbox (`c2d`, `place`,
`ssdata`). Not executed on this host — see `docs/TEST_PLAN.md`.
