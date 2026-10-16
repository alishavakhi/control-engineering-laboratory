# Lab 0 — Modelling a DC servomotor and identifying its parameters

## Objective

Build a simulation model of the laboratory DC gearmotor and use it to design a
position PID controller in the frequency domain, then estimate the parameters the
datasheet does not give — in particular the equivalent inertia and the friction
terms — from experimental step tests.

The identified values are not an end in themselves: Labs 1 and 3 use them for
friction and inertia feedforward compensation and for the model of the resonant
load.

## Plant

Quanser SRV-02 rotary servo:

| Element | Detail |
|---|---|
| Motor | Faulhaber 2338S006S brushed DC |
| Gearbox | Micromotor SA 23/1 planetary, 14:1 |
| Encoder | Hewlett-Packard HEDS-5540, 500 × 4 pulses/rev |
| Drive | op-amp voltage driver, ±12 V |

The model is assembled in the block-diagram form given in the course handout:
electrical dynamics → current-to-torque → mechanical rotor dynamics → gearbox
reduction → load dynamics, with the static-friction and viscous-friction terms
added on the load side, and `rad2deg` / `rads2rpm` conversion gains at the outputs
so the plots read in degrees and rpm.

## Method

**Frequency-domain PID design.** The loop gain is shaped on the Bode plot against
settling-time and overshoot specifications, giving Kp, Ki and Kd directly rather
than by trial and error. The design is carried out on the nominal (datasheet)
parameter set, so it is reproducible without any measurement.

**Parameter identification.** The datasheet gives the motor constants but not the
equivalent inertia or the friction coefficients. These are obtained by running the
motor through a staircase of constant speeds and recording the torque, the speed
and the acceleration. The friction torque is modelled as

```
Tf = Bv·ω + τsf·sign(ω)
Ti = Tm − Tf
```

and the equivalent inertia is then the slope of the torque-versus-acceleration
relation, evaluated between consecutive averaged operating points:

```
Jeq_hat = ΔTi / ΔA_m
```

Each operating point is formed by averaging a window of samples
(`Avg_Am.m`), which is what makes the estimate usable in the presence of a noisy
acceleration signal.

## Files

| File | Role |
|---|---|
| `matlab/Parameters.m` | Full nominal parameter set: motor, gearbox, mechanical load, voltage driver, sensors |
| `matlab/Avg_Am.m` | Windowed averaging and the `Jeq_hat = ΔTi/ΔA_m` estimate |
| `simulink/Lab0.slx` | Plant model with inertial load |
| `simulink/Lab0_actual.slx` | Model wired to the hardware interface for the experimental runs |
| `simulink/DCServomotor_Cpy.slx` | Working copy of the motor model as used in the runs |
| `data/identification_run.csv` | Logged speed and acceleration from the identification run |

## Results

![Lab 0 — logged speed staircase and acceleration](../docs/figures/lab0_identification_run.png)

The speed trace shows the staircase of constant-speed operating points; the
acceleration trace is the corresponding measured signal, visibly noisy, which is
why the operating points are averaged before the quotient is formed.

## Running it

```
cd lab-0-modelling-and-identification/matlab
matlab -batch "Parameters"          % loads the nominal parameter set
```

Then open `simulink/Lab0.slx` and run. `Lab0_actual.slx` additionally requires the
hardware interface block — see the repository README.

Requires MATLAB and Simulink with the Control System Toolbox. Not executed on this
host — see the repository `docs/TEST_PLAN.md`.
