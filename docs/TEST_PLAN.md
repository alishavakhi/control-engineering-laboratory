# Test and verification plan

What was verified while preparing this repository, what was not, and what would
be needed to close each gap.

Three kinds of claim appear in this repository and they are kept strictly apart:

1. **results the laboratory sessions produced** — recorded at the time, published here;
2. **checks performed on this repository** — run during preparation, reproducible;
3. **tests not performed** — stated as such, with the reason.

---

## 1. What was verified here

### Design mathematics recomputed independently — `tools/verify_designs.py`

MATLAB is not available on the host used to prepare this repository, but the design
scripts are linear algebra, and every step has an exact equivalent in SciPy. The
model and the designs were therefore recomputed from the same inputs and compared
against the gains recorded in the runs' own MATLAB workspaces.

**20 checks, all passing.** The substantive ones:

| Check | Result |
|---|---|
| Lab 3 nominal pole-placement gain, recomputed from the two-mass model | **reproduces the recorded `K_nom` to 6 decimal places** (`[81.596559, 15.998324, 5.155919, 2.518709]`) |
| Lab 3 equivalent inertia `Jeq = mot.J + Jh/N²` | reproduces the recorded `3.87971972e-06` |
| Lab 3 identified parameters: `B̂b = Jb·2δ̂ω̂n`, `k̂ = Jb·ω̂n²`, `ω̂n = ω̂/√(1−δ̂²)` | all reproduce the recorded values |
| Lab 3 LQR, `Q = CᵀC, r = 1e-2` | closed loop stable |
| Lab 3 LQR with Bryson's rule | closed loop stable |
| Lab 2 sampled closed loop at Ts = 1 ms, 10 ms, 50 ms, 100 ms | stable at all four |
| Lab 4 linearised inverted pendulum | has a right-half-plane pole, as it must |
| Lab 0 derived constants `Kt`, `Ke`, driver DC gain | reproduce the scripted values |
| Lab 3 script's explicit `Ki_rob` vs the value the run recorded | both 100 |

The Ackermann implementation used was checked against a hand-computable case
(`acker([0 1; 0 0], [0;1], [-1,-2])` → `[2, 3]`) before being trusted.

**What this does not prove.** It verifies the arithmetic of the designs. It does not
run MATLAB, does not execute the Simulink models, and does not confirm that the
recorded behaviour follows from them.

The Lab 3 *robust* state gain is deliberately **not** claimed as reproduced: the
MATLAB workspaces accumulate variables across sessions, so the pole set behind the
recorded `K_rob` cannot be recovered from the logs. The check asserts the honest
thing — that the gain is finite, that it stabilises the augmented plant, and that it
does *not* accidentally match — rather than a pole set chosen to make it fit.

### Repository integrity — `tools/static_checks.py`

**12 checks, all passing:**

| Check | What it establishes |
|---|---|
| layout | all five labs and every documented file exist |
| integrity | **74 MATLAB scripts and models are byte-identical to the intake originals** |
| exclusions-course | no course document and no other student's material is published |
| exclusions-blocks | no third-party Quanser block is published |
| cleanliness-build | no Simulink build output, no OS junk |
| cleanliness-mat | no raw `.mat` workspace blobs |
| data-csv | every published CSV extract is well-formed and rectangular |
| readme-figures | 11 figures embedded as `![]()` images, every one present |
| docs-links | every relative link in every markdown file resolves |
| tools | the Python tooling parses |
| docs-files | every `.m`/`.slx` named in a lab README actually exists |
| size | no file exceeds 5 MB |

The byte-identity check is the load-bearing one: it is what justifies the claim
that the laboratory code was **presented, not edited**.

### Figure correctness — checked by inspection, not by a test

Both rendered figures were opened and looked at before publication, which caught
three defects that no automated check would have found:

- a figure that plotted **invented data** — the Lab 3 identification figure
  originally mirrored the fitted peak markers onto negative time for symmetry; the
  fitted peaks lie inside the response window and nowhere else. Removed;
- a figure that **mislabelled a signal** — the beam angle `Theta_d` was captioned as
  the reference. `Theta_d` is the second mass, not the reference. Re-captioned and
  given its own figure;
- a figure that **overlaid incomparable runs** — the first Lab 2 plot put four
  signals from different runs, lengths and units on one axis, producing a
  2700-degree "position" trace. Redrawn using only the channels logged together.

These are recorded in `docs/CHANGES.md` as well, because a repository that reports
only its passing checks is not reporting honestly.

### Intake integrity

The intake was hashed before any work began (1 895 files) and re-verified at the
end. See §4.

---

## 2. Results the laboratory sessions produced

These come from the recorded runs and are **not** measurements taken while
preparing this repository.

| Evidence | Source |
|---|---|
| Lab 0 speed staircase and acceleration | `ResultsTwo_Speed.mat`, logged during the identification run |
| Lab 1 step responses, simulation **and hardware** | captured plots in `results/simulink/` and `results/physical-motor/` |
| Lab 2 sampling-period comparison | captured plots in `results/simulation/`, one per sampling period |
| Lab 2 Tustin controller tracking | `Lab2_2_1_1_1_Tustin_T1.mat` |
| Lab 3 nominal and robust tracking | `Nom_Motor_50_Result.mat`, `Rob_Tracking_Motor_50_Result.mat` |
| Lab 3 resonant beam response | `Nom_Motor_50_Result.mat` |
| Lab 3 joint identification | `estimation_raw.mat`, 16 peaks fitted by least squares |
| Lab 3 identified parameters | `δ̂ = 0.0468`, `ω̂n = 23.84 rad/s`, `B̂b = 0.003124`, `k̂ = 0.7955` |

The logged signals behind the regenerated figures are published as CSV extracts
alongside them, so the figures can be redrawn and checked.

---

## 3. What was NOT run

| Not run | Why | What it would take |
|---|---|---|
| Any MATLAB or Simulink execution | neither MATLAB nor Octave is installed on this host, and MATLAB cannot be installed on Linux without a licence | a MATLAB licence with Simulink + Control System Toolbox |
| `Lab0.slx`, `Lab0_actual.slx` and every other model | same | as above |
| The identification scripts producing `Estimated_Params.mat` | same | as above |
| The hardware models (`*_Quanser.slx`, `*_actual.slx`) | the Quanser DAQ blocks are not distributed here, **and** they need the physical SRV-02 setup | the blocks plus the hardware |
| Octave as a substitute | deliberately not attempted: Octave's Control package differs from MATLAB's in `acker`, `lqr`/`dlqr` and `evalfr` behaviour, so a passing Octave run would not have been evidence about MATLAB. Claiming otherwise would be worse than claiming nothing. | — |

**No statement in this repository should be read as "this was run here."** The
`*_Quanser.slx` and `*_actual.slx` models in particular will not open cleanly
without the DAQ blocks named in the main README.

---

## 4. Reproducing the verification

```bash
git clone https://github.com/alishavakhi/control-engineering-laboratory
cd control-engineering-laboratory
pip install -r requirements.txt

python tools/verify_designs.py     # 20 design checks, exit 0
python tools/static_checks.py      # 12 integrity checks, exit 0
```

Both are dependency-light: `verify_designs.py` needs NumPy and SciPy,
`static_checks.py` needs only the standard library.

To regenerate a figure from its published extract, load the CSV and plot the two
columns — each extract carries a comment line naming the run it came from.

---

## 5. Known limitations

1. **Nothing was executed.** Stated in the main README as well, because it is the
   single most important caveat here.
2. **The hardware models cannot run as published** — the Quanser DAQ blocks are
   required and are not redistributed (`docs/SELECTION.md`).
3. **Simulink models are binary `.slx`.** A reader without MATLAB cannot inspect
   their structure from this repository alone.
4. **Lab 4 has no result figure** — its test data was saved as a MATLAB `.fig`, not
   as a portable image, and the signals were not re-exported at the time.
5. **Lab 1 and Lab 2 results are captured images**, so they carry the axis ranges
   chosen at the time and cannot be re-derived from the published CSVs.
6. **The Lab 2 logged channels come from different runs** (3 s, 7 s, 20 s; one at a
   different scaling) and are published as logged, not normalised.
7. **The Lab 3 robust gain is not reproducible from the logs** — see §1.
8. **The scripts were edited between sessions.** The workspace recorded in a `.mat`
   file is the authority on what a given run used; where it disagrees with the
   current script (Lab 3's `ts`), the workspace was used and the difference noted.
