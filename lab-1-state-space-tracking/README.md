# Lab 1 — Continuous-time state-space tracking control

## Objective

Two things, in sequence:

1. improve the Lab 0 PID controller — suppress the overshoot caused by actuator
   saturation with an anti-windup scheme, and add friction/inertia feedforward;
2. design a continuous-time position controller with state-space methods, for both
   **nominal tracking** (feedforward) and **robust tracking** (integral action, or
   the internal model principle).

## Part 1 — PID improvements

**Anti-windup.** With a 360° step the controller output saturates, the integrator
keeps accumulating, and the response overshoots well beyond the design target. The
back-calculation anti-windup of the handout is added, with gain `Kw = 1/Tw` and
`Tw = ts,5%/5`. The comparison is run with the scheme enabled and disabled so the
effect is measured rather than asserted.

**Feedforward.** Using the equivalent inertia `Jeq`, viscous friction `Beq` and
static friction `τsf` identified in Lab 0, a feedforward term supplies the torque
the controller would otherwise have to generate from error. The result is a
smaller tracking error and a faster response, because the feedback loop no longer
has to discover the friction through error.

## Part 2 — State-space design

The plant is a second-order model in position and speed:

```
A = [0, 1; 0, −1/Tm]        B = [0; Km/(N·Tm)]        C = [1, 0]
```

`Tm` and `Km` are derived from the nominal electrical and mechanical parameters.

**Nominal tracking.** The steady-state feedforward gains come from solving

```
[A  B;  C  0] · [Nx; Nu] = [0; 0; 1]
```

so the output tracks a constant reference with zero steady-state error once the
state-feedback gain places the closed-loop poles at the specified damping and
natural frequency.

**Robust tracking with integral action.** Augmenting the plant with the integral of
the tracking error

```
A_e = [0  C; 0  A]        B_e = [0; B]
```

makes the closed loop reject constant disturbances and track constant setpoints
even when the plant parameters are wrong — which is the point, since the model is
only nominal. Pole placement on the augmented system yields the state gain and the
integral gain together.

**Robust tracking with the internal model principle.** For rejection of a
*time-varying* disturbance the controller must contain a model of the disturbance
generator. A resonant oscillator at the disturbance frequency is appended to the
plant,

```
A_z* = [0 1 0; 0 0 1; 0 −w0² 0]
```

and the error-space design places the closed-loop poles of the augmented system.
The reference period is swept over 0.15 / 0.25 / 0.5 / 1 s, which is what the
`Tr` vector in the script controls.

## Files

| File | Role |
|---|---|
| `matlab/Parameters.m` | Plant parameters |
| `matlab/Lab1_Nom_Tracking.m` | Feedforward gains and nominal pole placement |
| `matlab/Lab1_Robust_Tracking.m` | Augmented-system design with integral action |
| `matlab/Lab1_Robust_Tracking_Error_Space.m` | Internal-model error-space design |
| `simulink/Lab1_3_1_1_AntiWindup.slx` | Anti-windup validation |
| `simulink/Lab1_3_1_2_AccProfile.slx` | Acceleration-profile reference |
| `simulink/Lab1_3_1_2_Feedforward.slx` | Feedforward compensation |
| `simulink/Lab1_3_1_2_AccProfileFF.slx` | Acceleration profile with feedforward |
| `simulink/Lab1_3_2_1_Nominal.slx` | State-space nominal tracking |
| `simulink/Lab1_3_2_2_Robust.slx` | State-space robust tracking, integral action |
| `simulink/Lab1_3_2_2_Robust_AntiWindup.slx` | Robust tracking with anti-windup |
| `simulink/Lab1_3_2_3_RobustErrorSpc.slx` | Internal-model error-space design |
| `results/simulink/` | Step-response captures from the simulation runs |
| `results/physical-motor/` | Step-response captures from the **hardware** runs |

## Results

Each scheme was validated in simulation and then on the physical motor. The
captured responses are in `results/`, split by source:

- `results/simulink/` — nominal and robust tracking at 40, 70 and 120 rpm, the
  anti-windup comparison with and without feedforward, and the error-space design
  at 30/60/90;
- `results/physical-motor/` — the same set measured on the actual hardware,
  including the anti-windup pair (`Rob_*` against `Rob_*_AW`).

Keeping the two sets separate matters: agreement between them is the evidence that
the model is adequate, and they are only comparable because both were captured.

## Running it

```
cd lab-1-state-space-tracking/matlab
matlab -batch "Parameters; Lab1_Nom_Tracking"
```

The scripts are written to run from their own directory — `Parameters.m` defines
the workspace variables every other script and every Simulink model reads.

Requires MATLAB, Simulink and the Control System Toolbox (`place`, `acker`,
`linsolve`). Not executed on this host — see `docs/TEST_PLAN.md`.
