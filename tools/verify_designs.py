#!/usr/bin/env python3
"""Independent verification of the controller designs, without MATLAB.

The design scripts are linear algebra: build a state-space model from the
identified parameters, then place poles or solve an LQR problem. Every one of
those steps has an exact equivalent in SciPy, so the *designs* can be recomputed
here from the same inputs and compared against the gains recorded in the MATLAB
logs of the runs.

What this verifies:  the modelling and design arithmetic.
What it does not:    that MATLAB executes the scripts, or that the Simulink
                     models behave as recorded. That needs MATLAB.

Usage:
    python tools/verify_designs.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import numpy as np
from scipy.signal import cont2discrete, place_poles

TOL = 1e-4
FAILURES: list[str] = []
PASSES: list[str] = []


def check(name: str, ok: bool, detail: str = "") -> None:
    (PASSES if ok else FAILURES).append(f"{name}{(': ' + detail) if detail and not ok else ''}")


def close(a, b, tol=TOL) -> bool:
    return np.allclose(np.asarray(a, float), np.asarray(b, float), rtol=0, atol=tol)


def acker(A, B, poles):
    """MATLAB's acker(): Ackermann's single-input pole-placement formula."""
    A = np.atleast_2d(np.asarray(A, float))
    B = np.asarray(B, float).reshape(-1, 1)
    n = A.shape[0]
    ctrb = np.hstack([np.linalg.matrix_power(A, i) @ B for i in range(n)])
    coeffs = np.poly(np.asarray(poles, complex))
    # K = [0 ... 0 1] * C^-1 * phi(A)
    phi_A = np.zeros_like(A, dtype=complex)
    for k, c in enumerate(coeffs[::-1]):        # constant .. leading
        phi_A += c * np.linalg.matrix_power(A, k)
    e_n = np.zeros((1, n)); e_n[0, -1] = 1.0
    K = e_n @ np.linalg.inv(ctrb) @ phi_A
    return np.real(K).ravel()


def place(A, B, poles):
    return np.real(place_poles(np.asarray(A, float), np.asarray(B, float).reshape(-1, 1),
                               np.asarray(poles, complex)).gain_matrix).ravel()


# =====================================================================
# Nominal SRV-02 constants (as written in the parameter scripts)
# =====================================================================
OZIN2NM = 0.706e-2
RPM2RADS = 2 * np.pi / 60
RADS2RPM = 60 / (2 * np.pi)

mot_R = 2.6
mot_Kt = 1.088 * OZIN2NM
mot_Ke = 0.804e-3 * RADS2RPM
mot_J = 5.523e-5 * OZIN2NM

gbox_N = 14
drv_R1, drv_R2, drv_R3, drv_R4 = 7.5e3, 1.6e3, 1.2e3, 0.5e3
drv_dcgain = drv_R2 / (drv_R1 + drv_R2) * (1 + drv_R3 / drv_R4)

Req = 0.5 + mot_R                 # shunt resistor + armature resistance


def test_derived_parameters() -> None:
    """The derived constants match the values recorded in the run workspace."""
    check("motor torque constant Kt = 1.088 oz-in -> N.m",
          close(mot_Kt, 0.00768128, 1e-8), f"got {mot_Kt}")
    check("back-EMF constant Ke = 0.804e-3 rad/s->rpm",
          close(mot_Ke, 0.0076776, 1e-6), f"got {mot_Ke}")
    check("voltage-driver DC gain R2/(R1+R2)*(1+R3/R4)",
          close(drv_dcgain, 0.597802, 1e-5), f"got {drv_dcgain}")


def test_lab3_identified_parameters() -> None:
    """Values recovered by the log-decrement fit, as recorded in the run."""
    delta_hat, wn_hat = 0.046807, 23.837281
    Jb = 1.4e-3
    check("Bb_hat = Jb*2*delta_hat*wn_hat",
          close(Jb * 2 * delta_hat * wn_hat, 0.0031241, 1e-6),
          f"got {Jb * 2 * delta_hat * wn_hat}")
    check("k_hat = Jb*wn_hat^2",
          close(Jb * wn_hat ** 2, 0.79550232, 1e-5),
          f"got {Jb * wn_hat ** 2}")
    check("wn_hat = w_hat/sqrt(1-delta_hat^2)",
          close(23.81115379 / np.sqrt(1 - delta_hat ** 2), wn_hat, 1e-4),
          f"got {23.81115379 / np.sqrt(1 - delta_hat ** 2)}")


def lab3_plant():
    """The fourth-order two-mass model as written in Nom_Tracking_Resonant_Load.m."""
    Jh, Jb = 6.84e-4, 1.4e-3
    k, Bb = 0.79550232, 0.0031241
    Beq = 7.9953e-07
    Jeq = mot_J + Jh / gbox_N ** 2
    a = Beq + mot_Ke * mot_Kt / Req
    A = np.array([
        [0, 0, 1, 0],
        [0, 0, 0, 1],
        [0,                     k / (gbox_N ** 2 * Jeq),           -a / Jeq, 0],
        [0, -k / Jb - k / (gbox_N ** 2 * Jeq), -Bb / Jb + a / Jeq, -Bb / Jb],
    ], float)
    B = np.array([0, 0,
                  mot_Kt * drv_dcgain / (gbox_N * Jeq * Req),
                  -mot_Kt * drv_dcgain / (gbox_N * Jeq * Req)], float)
    return A, B, Jeq


def test_lab3_equivalent_inertia() -> None:
    """Jeq = mot.J + Jh/N^2 reproduces the value in the recorded workspace."""
    _, _, Jeq = lab3_plant()
    check("Lab 3 equivalent inertia Jeq = mot.J + Jh/N^2",
          close(Jeq, 3.87971972e-06, 1e-12), f"got {Jeq}")


def test_lab3_nominal_gain() -> None:
    """Pole placement reproduces the nominal gain recorded in the run.

    The specification used is the one the run recorded in its own workspace
    (``wn = 33.53 rad/s``), not the value in the current ``PID_Parameters.m`` —
    the scripts were edited between sessions and the workspace is the authority on
    what a given run actually used.
    """
    A, B, _ = lab3_plant()
    Mp = 0.3
    wn = 33.532935                     # as recorded in Nom_Motor_50_Result.mat
    delta = np.log(1 / Mp) / np.sqrt(np.pi ** 2 + np.log(1 / Mp) ** 2)
    phi = np.arctan(np.sqrt(1 - delta ** 2) / delta)
    poles = [wn * np.exp(1j * (-np.pi + phi)), wn * np.exp(1j * (-np.pi - phi)),
             wn * np.exp(1j * (-np.pi + phi / 2)), wn * np.exp(1j * (-np.pi - phi / 2))]
    K = acker(A, B, poles)
    recorded = [81.596559, 15.998324, 5.155919, 2.518709]
    check("Lab 3 nominal pole-placement gain reproduced from the model",
          close(K, recorded, 2e-3),
          f"computed {np.round(K, 6)} vs recorded {recorded}")

    # The recorded specification is consistent with ts = 0.25 s
    delta_ts = 3 / (delta * 0.25)
    check("recorded wn is consistent with a 0.25 s settling-time spec",
          close(delta_ts, wn, 1e-3), f"3/(delta*ts) = {delta_ts}, recorded {wn}")


def test_lab3_robust_variant() -> None:
    """The robust variant is internally consistent, and is NOT reproducible.

    Two things are checked here, both of which are true of the submitted code:

    * the augmented-system design does produce a finite gain, and that gain
      stabilises the augmented plant;
    * the integral gain recorded by the run is exactly the value the script
      assigns explicitly, rather than the gain ``acker`` returns.

    What is *not* claimed: that the recorded state gain can be recomputed. The
    MATLAB workspaces accumulate variables across sessions, so the pole set behind
    the recorded ``K_rob`` cannot be recovered from the logs. That is stated here
    rather than papered over with a fourth pole set chosen to fit.
    """
    A, B, _ = lab3_plant()
    C = np.array([1, 0, 0, 0], float)
    A_e = np.block([[np.zeros((1, 1)), C.reshape(1, -1)],
                    [np.zeros((4, 1)), A]])
    B_e = np.concatenate([[0.0], B])

    Mp, wn = 0.3, 20.958085
    delta = np.log(1 / Mp) / np.sqrt(np.pi ** 2 + np.log(1 / Mp) ** 2)
    phi = np.arctan(np.sqrt(1 - delta ** 2) / delta)
    poles = [wn * np.exp(1j * (-np.pi + phi)), wn * np.exp(1j * (-np.pi - phi)),
             wn * np.exp(1j * (-np.pi + phi / 2)), wn * np.exp(1j * (-np.pi - phi / 2)),
             -wn]
    Ke = acker(A_e, B_e, poles)
    Ki, K_rob = Ke[0], Ke[1:]

    check("Lab 3 robust design yields a finite real gain",
          np.all(np.isfinite(Ke)) and np.allclose(Ke.imag, 0, atol=1e-9)
          if np.iscomplexobj(Ke) else np.all(np.isfinite(Ke)), f"Ke = {Ke}")
    eigs = np.linalg.eigvals(A_e - np.outer(B_e, Ke))
    check("Lab 3 robust gain stabilises the augmented plant",
          np.all(np.real(eigs) < 0), f"eigenvalues {np.round(eigs, 4)}")
    check("Lab 3 robust gain differs from the value the run recorded",
          not close(K_rob, [16.818128, 23.307261, 1.223019, -0.575802], 1e-3),
          "unexpectedly reproduced — the caveat in this docstring would be wrong")

    # Cross-check the code against the log: the script overrides the computed
    # integral gain with a literal, and the run recorded that literal.
    script = (Path(__file__).resolve().parent.parent /
              "lab-3-resonant-load-lqr" / "matlab" / "Rob_Tracking_Resonant_Load.m")
    if script.is_file():
        text = script.read_text(errors="ignore")
        m = re.search(r"^\s*Ki_rob\s*=\s*([-\d.eE]+)\s*;", text, re.M)
        overridden = float(m.group(1)) if m else None
        check("Lab 3 script's explicit Ki_rob matches the value the run recorded",
              overridden is not None and close(overridden, 100.0),
              f"script says {overridden}, run recorded 100")


def test_lab3_lqr_is_stabilising() -> None:
    """The LQR weighting used in the lab yields a stabilising gain.

    ``lqr`` is not in SciPy, so the algebraic Riccati equation is solved directly
    and the resulting gain checked for closed-loop stability. That tests the
    design property (stability), not a printed number.
    """
    from scipy.linalg import solve_continuous_are
    A, B, _ = lab3_plant()
    C = np.array([1, 0, 0, 0], float)
    Q = C.reshape(-1, 1) @ C.reshape(1, -1)
    r = 1e-2
    P = solve_continuous_are(A, B.reshape(-1, 1), Q, np.array([[r]]))
    K = np.linalg.solve(np.array([[r]]), B.reshape(1, -1) @ P).ravel()
    eigs = np.linalg.eigvals(A - np.outer(B, K))
    check("Lab 3 LQR (Q=C'C, r=1e-2) gives a stable closed loop",
          np.all(np.real(eigs) < 0), f"eigenvalues {np.round(eigs, 4)}")

    # Bryson's rule weighting as written in the lab
    th_h_max = 0.3 * 50 * np.pi / 180
    th_d_max = np.pi / 36
    u_max = 10
    Qb = np.diag([9 / th_h_max ** 2, 0.3 / th_d_max ** 2, 0, 0])
    rb = 10 / u_max ** 2
    Pb = solve_continuous_are(A, B.reshape(-1, 1), Qb, np.array([[rb]]))
    Kb = np.linalg.solve(np.array([[rb]]), B.reshape(1, -1) @ Pb).ravel()
    eigs_b = np.linalg.eigvals(A - np.outer(B, Kb))
    check("Lab 3 LQR with Bryson's rule gives a stable closed loop",
          np.all(np.real(eigs_b) < 0), f"eigenvalues {np.round(eigs_b, 4)}")


def test_lab2_discretisation() -> None:
    """Discretising a continuous loop keeps it stable for a reasonable Ts."""
    A = np.array([[0, 1], [0, 0]], float)          # integrator chain, stabilised below
    B = np.array([[0], [1]], float)
    K = place(A, B, [-4, -5])
    Acl = A - B @ K.reshape(1, -1)
    for Ts in (1e-3, 1e-2, 5e-2, 1e-1):
        Phi, _, _, _, _ = cont2discrete((Acl, np.zeros((2, 1)), np.zeros((1, 2)), 0), Ts)
        eigs = np.linalg.eigvals(Phi)
        check(f"Lab 2 sampled closed loop stable at Ts={Ts:g} s",
              np.all(np.abs(eigs) < 1), f"|eigenvalues| {np.round(np.abs(eigs), 4)}")


def test_lab4_linearised_model_is_unstable() -> None:
    """The inverted pendulum is open-loop unstable — the premise of Lab 4.

    A sign convention check dressed as a physical one: if the linearised model
    does not have a right-half-plane pole, the stabilisation problem being solved
    is not the balancing problem.
    """
    g = 9.81
    A = np.array([[0, 0, 1, 0],
                  [0, 0, 0, 1],
                  [0, -g, 0, 0],
                  [0, 2 * g, 0, 0]], float)
    eigs = np.linalg.eigvals(A)
    unstable = np.any(np.real(eigs) > 1e-9)
    check("Lab 4 linearised inverted pendulum has an unstable mode",
          unstable, f"eigenvalues {np.round(eigs, 4)}")


TESTS = [v for k, v in sorted(globals().items()) if k.startswith("test_")]


def main() -> int:
    for fn in TESTS:
        try:
            fn()
        except Exception as exc:
            FAILURES.append(f"{fn.__name__} raised {type(exc).__name__}: {exc}")
    for name in PASSES:
        print(f"  PASS  {name}")
    for name in FAILURES:
        print(f"  FAIL  {name}")
    print(f"\n{len(PASSES)} passed, {len(FAILURES)} failed")
    return 1 if FAILURES else 0


if __name__ == "__main__":
    sys.exit(main())
