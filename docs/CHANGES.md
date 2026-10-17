# Changes made preparing this repository

## No laboratory code was modified

Every `.m` script and `.slx` model published here is **byte-identical** to the file
in the original archive. They were copied, renamed only in the sense of being moved
into a new directory tree, and nothing else. `tools/static_checks.py` verifies this
by re-hashing each published file against the original and reporting any mismatch.

This was a deliberate choice. The implementations are the work being presented, and
"tidying" a controller design changes what it does. Where a script has a quirk, the
quirk is documented rather than edited.

## What was done

### 1. Selected 138 files from 1 895

The full reasoning is in [`SELECTION.md`](SELECTION.md). In short: the final
submission set for each lab, the files needed to run it, genuine results, and
nothing else. Another student's material (98 files), course documents (14),
generated build output (~1 470) and byte-identical duplicates were excluded.

### 2. Reorganised into five lab directories with a consistent layout

Files were moved from the intake's per-session folder names into a uniform
structure per lab — `matlab/`, `simulink/`, `results/`, `data/`. Original file
names are preserved throughout, because the scripts and Simulink models reference
each other and the shared parameter files by name.

Nothing was renamed. `Lab_2_2_2.m` is still `Lab_2_2_2.m`.

### 3. Extracted logged signals from the `.mat` workspaces into CSV

25 MB of MATLAB workspace files were reduced to ~780 KB of readable CSV, one
extract per figure, containing exactly the channels plotted. Nothing was resampled,
rescaled or filtered. Raw `.mat` files are not published.

### 4. Regenerated documentation figures from the recorded data

Six figures were drawn directly from the logged signals:

| Figure | Source signal |
|---|---|
| `lab0_identification_run.png` | speed and acceleration staircase, `ResultsTwo_Speed.mat` |
| `lab2_tustin_tracking.png` | controller output and measured position, `Lab2_2_1_1_1_Tustin_T1.mat` |
| `lab3_tracking_nominal.png` | hub angle, `Nom_Motor_50_Result.mat` |
| `lab3_tracking_robust.png` | hub angle, `Rob_Tracking_Motor_50_Result.mat` |
| `lab3_resonant_mode.png` | beam angle (the resonant mode), `Nom_Motor_50_Result.mat` |
| `lab3_identification.png` | the free-response window the log-decrement fit uses |

No figure is synthesised, smoothed or illustrative. Two earlier drafts of these
figures were discarded during preparation and are described below.

### 5. Wrote the documentation

A README per lab covering objective, method, files, results and execution, plus
this repository's main README with the summary table. Every lab objective is
restated in this repository's own words; no course document is reproduced.

### 6. Added `tools/static_checks.py`

Twelve checks runnable without MATLAB — see the file for the list.

## Errors caught during preparation

Recorded because they are the kind of thing that would otherwise sit on a public
page unnoticed.

**A figure plotted data that did not exist.** The first version of the Lab 3
identification figure mirrored the fitted peak markers onto negative time to make
the plot look symmetric. The fitted peaks lie inside the response window and
nowhere else, so the negative-time markers were invented. Removed; the figure now
plots only the signal and the peaks that the fit actually uses.

**Two figures plotted signals that are not comparable.** The first Lab 3 tracking
figure labelled the beam angle `Theta_d` as the *reference*, which it is not — it is
the second mass. And the first Lab 2 figure overlaid four signals from runs of
different lengths, units and sampling rates on one axis, which produced a
2700-degree "position" curve. Both were redrawn: the beam angle has its own figure
labelled correctly, and the Lab 2 figure plots the pair of channels logged together
over the same 20-second run. The Lab 2 README states that the remaining logged
channels are from different runs and are published as logged.

Both were caught by looking at the rendered images before publishing, not by any
automated check.

## Quirks documented rather than changed

- **`Lab 1/Lab1_Tracking.m`** (not published — superseded) had most of its body
  commented out. It is a scratch file, which is why `LAB1_done_0404/` was selected
  instead.
- **`signSize` in Lab 3's estimation path** computes a squared negative quantity
  and is not a usable area; it is unused by the identification, which works from
  the peak list directly.
- **The signed PID gains** in the Lab 3 logs (negative `Kp`) follow the sign
  convention of the model in that lab and are published as logged.
- **Lab 4's `Robust_Tracking.m`** computes the integral gain from `dlqr` and then
  assigns an explicit value to `Ki`, keeping both in the file. Both lines are
  preserved as written.

---

## Licence scope moved out of the `LICENSE` file

**Files:** `LICENSE`, new `LICENSE-SCOPE.md`

The MIT licence text was correct, but a "Scope of this licence" section had been
appended to the same file. GitHub's licence detector matches a file against known
licence texts, so the extra section made it report **no licence** for this
repository instead of MIT — a worse result for anyone deciding whether they may
reuse the code.

The scope text is now in `LICENSE-SCOPE.md` and is referenced from the README's
*Licence* section. `LICENSE` holds the standard MIT text and nothing else. No
right or exclusion was changed in the move — the same words, in a file that
parsers and readers can both use.
