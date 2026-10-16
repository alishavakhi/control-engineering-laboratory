# File selection — what was published, what was not, and why

The intake contained **1 895 files (339 MB)**. This repository publishes **138**
of them (9.2 MB). This document records every decision.

The guiding rule: publish the author's own implementations, the files they need to
run, and genuine results. Exclude everything else.

## Summary

| Class | Files | Action |
|---|---|---|
| Simulink desktop-real-time target builds (`*_sldrt_win64/`) | 804 | Excluded — generated |
| Simulink build trees (`slprj/`, `codegen/`, `html/`, `tmwinternal/`) | 338 | Excluded — generated |
| Simulink generated code and build artefacts (`.dep .o .slxc .h .xml .c .mk .rsp .rxw64 .slxp .dmr .tmw .bat .elf .hex .eep .mexw64 …`) | ~330 | Excluded — generated |
| **Another student's material** (folders named for them) | 92 | **Excluded — not the author's** |
| Raw `.mat` logs | 72 | Replaced by CSV signal extracts |
| Provided library blocks and superseded model copies | 24 | Excluded |
| Subset duplicate of the Lab 3 motor set | 23 | Excluded — duplicate |
| Superseded Lab 3 working set (`Lab 3 (2)/`) | 21 | Excluded — duplicate |
| Duplicate archive of Lab 2 (`LAB2_ALI_VAHID/…/Part 2-…Z-001/`) | 21 | Excluded — duplicate |
| Superseded drafts and duplicate scripts | 13 | Excluded |
| Course documents (briefs, method handouts, guides) | 14 | Excluded — not redistributable here |
| Scratch folder duplicates (`Untitled folder/`) | 11 | Excluded — duplicate |
| Duplicate Lab 4 test models (`For Tests/`) | 7 | Excluded — duplicate |
| macOS archive junk (`__MACOSX/`, `.DS_Store`) | 7 | Excluded |
| Model files prepared for another student (`*_ForHisham.slx`) | 6 | **Excluded — not the author's** |
| Duplicate/superseded captures | 1 | Excluded |
| Other one-off build files (`.prj`, `.asv`) | 2 | Excluded |

## Published per lab

| Lab | Files published |
|---|---|
| `lab-0-modelling-and-identification` | 6 |
| `lab-1-state-space-tracking` | 55 |
| `lab-2-digital-control` | 36 |
| `lab-3-resonant-load-lqr` | 30 |
| `lab-4-balancing-robot` | 11 |

## Decisions that needed judgement

### Which version of each lab to keep

Several labs existed in more than one form in the archive. In each case the
**final** submission set was kept, and the earlier or partial set dropped.

- **Lab 1** — the archive held three generations: loose scripts at the Lab 1 root,
  an `Actual_tests/` set, and `LAB1_done_0404/Actual_tests/`. The last is a strict
  superset (it adds `AccProfileFF`, `Feedforward` and `Robust_AntiWindup`) and is
  what was published. The earlier two are drafts: the root-level `Lab1_Tracking.m`
  is a scratch file with most of its body commented out.
- **Lab 2** — `LAB 2/` holds the full model set. `Untitled folder/` is a scratch
  copy of part of it, but it also contains two models that exist nowhere else
  (`Lab_2_2_2_observer_design.slx`, `final_2_2_4.slx`), so those two were kept and
  the rest of the folder dropped. `Lab_Results/LAB2_ALI_VAHID/` is a zipped copy
  of `Actual Test - Part 2/` — the working copy was kept, the archive dropped.
- **Lab 3** — `Lab3_16_05_Done/` is the complete final set. `Lab 3/Simulations/`
  duplicates 23 of its files, and `Lab 3 (2)/` is an earlier working set with
  slightly different scripts. Both dropped. **`Lab 3/SS and LQR/` was kept even
  though it overlaps them in topic**, because its six design scripts
  (`position_SS_2_3_*`, `position_SS_2_4_*`) implement a distinct part of the lab —
  the state-space/LQR design sequence — that appears nowhere in the final folder.
- **Lab 4** — `Lab4_done/` kept; `For Tests/` dropped (its
  `Balancing_Robot_Robust.slx` is byte-identical to the `Lab4_done` copy). The
  root-level `Balancing_Robot*.slx` models were kept because they are all
  different sizes and cover the nominal, robust and hardware variants.

### Byte-identical files

Every file was hashed. Where the same content appeared more than once, one copy
was kept and the others dropped — for example `BalRob_Params.m` (3 identical
copies), `Nominal_Tracking.m` (3), `Parameters.m` in Lab 2 (3),
`Rob_Tracking_Resonant_Load.m` (2), `SRV02IL_NIDAQ_block.slx` (4 copies at two
different versions).

### Another student's material — excluded

The archive contains material belonging to other students:

- `LAB1-lilit/` and `LAB 2/Lab_Results/CELab_2_Lilit/` — folders named for a third
  student, containing their Lab 1 and Lab 2 sets (92 files).
- `DCServomotor_Lab1*_ForHisham.slx` and related — six models prepared for, or
  received from, another student.

**None of it is published.** Some of the Lab 2 files kept here are byte-identical
to files in the other student's folder, which is expected for group coursework
(the course briefs state the challenge submissions are one per group) — but the
copies published are the ones from the author's own folders, and the peer's
folders themselves are excluded.

### Raw `.mat` logs — replaced, not dropped

The logs were 25 MB — the majority of the repository's weight — and are binary
MATLAB workspaces that a reader cannot use without MATLAB. What matters in them is
the recorded signals, so:

- every logged channel used in a figure was extracted to a readable **CSV** and
  published alongside the figure that plots it;
- the `.mat` files themselves were not published.

The extracts are exact; nothing was resampled, rescaled or smoothed. Signals that
are not plotted were not extracted.

One consequence: the logged signals in Lab 2 come from runs of different lengths
(3 s, 7 s, 20 s) and in one case different scaling. They are published **as
logged**, not adjusted to match each other, and the Lab 2 README says so.

### Provided library blocks — excluded, and documented

Lab 0 of the intake contained a Simulink library of the plant elements (`DAC.slx`,
`DCMotorGearbox.slx`, `DCServomotor.slx`, `Encoder.slx`, `PIDController.slx`,
`VoltageDriver.slx`) following the course handout. These are course-provided
reference models, so they are not republished.

The hardware interface blocks (`SRV02IL_NIDAQ_block.slx`, `SRV02RL_NIDAQ_block.slx`,
`balrob3d_block.slx`) are third-party Quanser components. Their redistribution terms
are not established, so they are not republished either — the repository README
names them as a required dependency instead.

### Course documents — excluded

Twelve top-level workshop documents plus two more in subfolders (assignment briefs,
method handouts, introductory guides) were read for background and are **not**
republished. Each lab's objective is restated in this repository's own words in
that lab's README.

## Reproducibility of this selection

The full copy manifest — repository path, original intake path, SHA-256 and size
for every published file — is in [`../manifests/selection.json`](../manifests/selection.json).
The intake was hashed before any work began and re-verified afterwards; see
`docs/TEST_PLAN.md`.
