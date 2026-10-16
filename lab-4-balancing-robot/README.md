# Lab 4 — Longitudinal control of a balancing robot

## Objective

Design and test a state-space controller for the two-wheeled balancing robot. The
controller must do two things at once:

- hold the body upright at its unstable equilibrium, and
- drive the base to a commanded longitudinal position.

Both are longitudinal-only: the motion is assumed to lie on a straight line, so the
lateral and heading dynamics are ignored and the model is planar.

## The problem in one line

The inverted pendulum is unstable in open loop, and the only control input is the
wheel torque. That single input must stabilise one fast unstable mode *and* satisfy
a slow position command, which is why the design is done on the linearised model
and the position requirement is met by augmenting the state with the position error.

## Plant

| Element | Detail |
|---|---|
| Motors | 2 × Pololu 30:1 brushed DC gearmotor, 12 V nominal |
| Battery | 11.1 V, mounted above the axle |
| States | `[γ, θ, γ̇, θ̇]` — base position, body angle, and their rates |
| Sampling | `Ts = 10 ms` |

`BalRob_Params.m` builds the full parameter set from measured geometry — motor
masses and moments of inertia, rotor and stator centre-of-mass offsets in the body
frame, gearbox ratio and friction, battery mass and position. The motor constants
(`Kt`, `Ke`, `R`) are derived from the datasheet's stall torque, stall current and
no-load speed rather than taken as given.

## Method

**Nonlinear model.** The equations of motion are written as

```
q̈ = M⁻¹(q)·(−C(q, q̇)·q̇ − Fv·q̇ − g(q) + τ)
```

and implemented in Simulink with the chain-of-integrators approach: `M(q)`, `C(q, q̇)`
and `g(q)` are built from Constant and Fcn blocks, combined with Mux and Matrix
Concatenate, and multiplied as a true matrix product. The wheel torque enters as
`(2·N·Kt/R)·[1, −1]ᵀ·ua`.

**Linearisation.** Around the upright equilibrium:

```
M_lin = [M11, M12_lin; M12_lin, M22]
A = [0, I; −M_lin⁻¹·G, −M_lin⁻¹·Fv]
B = (2·N·Kt/R)·[0; M_lin⁻¹]·[1; −1]
```

**Discretisation and LQR.** The continuous model is discretised with `c2d` at
`Ts = 10 ms` and the gain obtained from `dlqr`. The nominal design uses

```
Q = diag([ (18/π)², (360/π)², 0, 0 ])
```

— weights expressed as 1/(allowable deviation)² in degrees, so the entries carry a
physical meaning rather than being tuned by hand.

**Robust tracking.** The state is augmented with the integral of the base-position
error,

```
Phi_e = [1, H; 0, Phi]        Gamma_e = [0; Gamma]
```

and `dlqr` on the augmented pair gives the integral gain and the state gain
together. This is what lets the robot settle at a position setpoint despite the
model not being exact — the same structural idea as Lab 1, carried into discrete
time.

## Files

| File | Role |
|---|---|
| `matlab/BalRob_Params.m` | Full robot parameter set: motors, gearbox, battery, geometry, initial condition |
| `matlab/Nominal_Tracking.m` | Linearised model, discretisation, `dlqr`, feedforward gains |
| `matlab/Robust_Tracking.m` | Integral-action augmentation and the robust gain |
| `simulink/Balancing_Robot.slx` | Nonlinear model of the robot |
| `simulink/Balancing_Robot_Nom_Tracking.slx` | Nominal tracking controller |
| `simulink/Balancing_Robot_Rob_Tracking.slx` | Robust tracking controller |
| `simulink/Balancing_Robot_Nom_Tracking_Quanser.slx` | Nominal design on the hardware |
| `simulink/Balancing_Robot_Robust.slx` | Robust design |
| `simulink/Rob_Tracking_lab.slx` | Test harness |
| `simulink/testrun.slx` | Run used to capture the recorded data |
| `simulink/Balancing_Robot_Nominal.slx` | Nominal variant used for testing |

## Results

The recorded test data from the runs is in the original archive
(`test_data.fig`). No figure is reproduced here, because the data that would
back it was not published with the models — see the note under *Limitations* in
the repository README. The controller gains and design are fully implemented and
readable in `matlab/`.

The nominal and robust designs are both implemented; the robustness gain `Ki` in
the submitted script is assigned explicitly to a value chosen from the design
rather than used straight from `dlqr`, and both variants are present in the file.

## Running it

```
cd lab-4-balancing-robot/matlab
matlab -batch "Robust_Tracking"
```

`Robust_Tracking.m` calls `Nominal_Tracking.m`, which in turn calls
`BalRob_Params.m` — the three must be on the path together, and the order is
handled by the nested calls.

Requires MATLAB, Simulink and the Control System Toolbox (`c2d`, `dlqr`, `linsolve`).
Not executed on this host — see `docs/TEST_PLAN.md`.
