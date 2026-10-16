#!/usr/bin/env python3
"""Static checks for this repository — no MATLAB, Simulink or network needed.

These establish the properties that matter for a curated coursework publication:
that the published code is unmodified, that nothing which should not be public has
been published, and that the documentation matches the files.

They do NOT claim the labs run. Nothing here executes MATLAB.

Usage:
    python tools/static_checks.py [--json]
"""

from __future__ import annotations

import argparse
import ast
import csv
import hashlib
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
MANIFEST = REPO / "manifests" / "selection.json"

PASSES: list[str] = []
FAILURES: list[str] = []

LABS = [
    "lab-0-modelling-and-identification",
    "lab-1-state-space-tracking",
    "lab-2-digital-control",
    "lab-3-resonant-load-lqr",
    "lab-4-balancing-robot",
]

#: Filenames that must never appear in the published tree.
FORBIDDEN_NAMES = {
    "SRV02IL_NIDAQ_block.slx", "SRV02RL_NIDAQ_block.slx", "balrob3d_block.slx",
}
FORBIDDEN_PATTERNS = [
    (r"^CELAB_(ASSIGNMENT|GUIDE|METHODS)_\d+\.pdf$", "a course document"),
    (r"(?i)lilit", "another student's folder"),
    (r"(?i)forhisham", "a model prepared for another student"),
    (r"(?i)ali_vahid", "the duplicate Lab 2 archive"),
]


def check(name: str, ok: bool, detail: str = "") -> None:
    (PASSES if ok else FAILURES).append(name if ok else f"{name}: {detail}")


def load_manifest() -> dict:
    return json.loads(MANIFEST.read_text()) if MANIFEST.is_file() else {}


def c1_layout() -> None:
    expected = (["README.md", "LICENSE", ".gitignore", "requirements.txt",
                 "docs/SELECTION.md", "docs/CHANGES.md", "docs/TEST_PLAN.md",
                 "tools/static_checks.py", "tools/verify_designs.py"]
                + [f"{lab}/README.md" for lab in LABS])
    missing = [p for p in expected if not (REPO / p).exists()]
    check("layout: every documented file exists", not missing, f"missing {missing}")
    absent_labs = [l for l in LABS if not (REPO / l).is_dir()]
    check("layout: all five labs present", not absent_labs, f"missing {absent_labs}")


def c2_code_unmodified() -> None:
    """Every published script and model is byte-identical to the intake original.

    This is the load-bearing check of this repository: the implementations are
    presented, not edited.
    """
    m = load_manifest()
    files = m.get("files", [])
    if not files:
        check("integrity: manifest present", False, "manifests/selection.json missing")
        return
    bad, missing = [], []
    for entry in files:
        p = REPO / entry["repo_path"]
        if not p.is_file():
            missing.append(entry["repo_path"])
            continue
        if p.suffix.lower() not in (".m", ".slx"):
            continue
        got = hashlib.sha256(p.read_bytes()).hexdigest()
        if got != entry["sha256"]:
            bad.append(entry["repo_path"])
    check(f"integrity: {sum(1 for e in files if e['repo_path'].endswith(('.m', '.slx')))}"
          " MATLAB scripts and models byte-identical to the originals",
          not bad, f"modified: {bad}")
    check("integrity: every manifest entry exists on disk", not missing,
          f"missing {missing[:5]}")


def c3_no_course_documents() -> None:
    hits = []
    for p in REPO.rglob("*"):
        if not p.is_file() or ".git" in p.parts:
            continue
        for pat, what in FORBIDDEN_PATTERNS:
            if re.search(pat, p.name) or re.search(pat, str(p.relative_to(REPO))):
                hits.append(f"{p.relative_to(REPO)} ({what})")
    check("exclusions: no course document or another student's material published",
          not hits, f"found {hits}")


def c4_no_third_party_blocks() -> None:
    hits = [str(p.relative_to(REPO)) for p in REPO.rglob("*.slx")
            if p.name in FORBIDDEN_NAMES]
    check("exclusions: no third-party Quanser block published", not hits, f"found {hits}")


def c5_no_build_artefacts() -> None:
    junk_ext = {".o", ".h", ".c", ".xml", ".dep", ".slxc", ".slxp", ".dmr",
                ".rxw64", ".tmw", ".bat", ".rsp", ".mexw64", ".elf", ".hex",
                ".eep", ".mk", ".asv", ".prj"}
    hits = []
    for p in REPO.rglob("*"):
        if not p.is_file() or ".git" in p.parts:
            continue
        if p.suffix.lower() in junk_ext:
            hits.append(str(p.relative_to(REPO)))
        if p.name in (".DS_Store", "Thumbs.db") or "__MACOSX" in p.parts:
            hits.append(str(p.relative_to(REPO)))
        if p.name.endswith("_sldrt_win64") or "_targ_data_map" in p.name:
            hits.append(str(p.relative_to(REPO)))
    check("cleanliness: no Simulink build output or OS junk", not hits,
          f"found {hits[:6]}")


def c6_no_mat_blobs() -> None:
    hits = [str(p.relative_to(REPO)) for p in REPO.rglob("*.mat")]
    check("cleanliness: no raw .mat blobs (CSV extracts instead)", not hits,
          f"found {hits}")


def c7_csv_extracts_wellformed() -> None:
    """Each published CSV extract has two equal-length columns per signal and
    at least two data rows."""
    bad = []
    for p in sorted(REPO.rglob("*.csv")):
        with open(p, newline="") as fh:
            rows = [r for r in fh if not r.startswith("#")]
        if len(rows) < 3:
            bad.append(f"{p.name}: only {len(rows)} rows")
            continue
        header = rows[0].rstrip("\n").split(",")
        if len(header) % 2 != 0:
            bad.append(f"{p.name}: header has {len(header)} columns (want time/value pairs)")
        widths = {len(r.rstrip("\n").split(",")) for r in rows[1:]}
        if widths != {len(header)}:
            bad.append(f"{p.name}: ragged rows {widths} vs header {len(header)}")
    check("data: published CSV extracts are well-formed", not bad, "; ".join(bad))


def c8_readme_figures() -> None:
    """Figures referenced from the READMEs are embedded images and exist."""
    missing, embedded = [], 0
    for doc in list(REPO.glob("*.md")) + list(REPO.glob("*/README.md")) \
            + list(REPO.glob("docs/*.md")):
        text = doc.read_text(encoding="utf-8")
        for path in re.findall(r"!\[[^\]]*\]\(([^)\s]+)\)", text):
            embedded += 1
            if not (doc.parent / path).resolve().exists():
                missing.append(f"{doc.relative_to(REPO)} -> {path}")
    check(f"readme: {embedded} figures embedded as images, all present",
          embedded > 0 and not missing, f"missing {missing}")


def c9_internal_links() -> None:
    broken = []
    for doc in list(REPO.glob("*.md")) + list(REPO.glob("*/README.md")) \
            + list(REPO.glob("docs/*.md")):
        text = doc.read_text(encoding="utf-8")
        for link in re.findall(r"(?<!!)\[[^\]]*\]\(([^)#\s]+)\)", text):
            if link.startswith(("http://", "https://", "mailto:", "#")):
                continue
            if not (doc.parent / link).resolve().exists():
                broken.append(f"{doc.relative_to(REPO)} -> {link}")
    check("docs: every internal link resolves", not broken, "; ".join(broken))


def c10_tools_parse() -> None:
    bad = []
    for p in sorted((REPO / "tools").glob("*.py")):
        try:
            ast.parse(p.read_text(encoding="utf-8"), filename=str(p))
        except SyntaxError as e:
            bad.append(f"{p.name}:{e.lineno} {e.msg}")
    check("tools: python tooling parses", not bad, "; ".join(bad))


def c11_documented_files_exist() -> None:
    """Every `.m` or `.slx` named in a lab README is actually present."""
    missing = []
    for lab in LABS:
        readme = REPO / lab / "README.md"
        if not readme.is_file():
            continue
        text = readme.read_text(encoding="utf-8")
        for name in set(re.findall(r"`([A-Za-z0-9_\-]+\.(?:m|slx))`", text)):
            if "*" in name:
                continue
            hits = list((REPO / lab).rglob(name))
            if not hits:
                missing.append(f"{lab}/{name}")
    check("docs: every file named in a lab README exists", not missing,
          f"missing {missing}")


def c12_size() -> None:
    big = [f"{p.relative_to(REPO)} {p.stat().st_size/1048576:.1f} MB"
           for p in REPO.rglob("*")
           if p.is_file() and ".git" not in p.parts
           and p.stat().st_size > 5 * 1024 * 1024]
    check("size: no file over 5 MB", not big, "; ".join(big))


CHECKS = [
    ("layout", c1_layout),
    ("integrity", c2_code_unmodified),
    ("exclusions-course", c3_no_course_documents),
    ("exclusions-blocks", c4_no_third_party_blocks),
    ("cleanliness-build", c5_no_build_artefacts),
    ("cleanliness-mat", c6_no_mat_blobs),
    ("data-csv", c7_csv_extracts_wellformed),
    ("readme-figures", c8_readme_figures),
    ("docs-links", c9_internal_links),
    ("tools", c10_tools_parse),
    ("docs-files", c11_documented_files_exist),
    ("size", c12_size),
]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()
    for _, fn in CHECKS:
        try:
            fn()
        except Exception as exc:
            FAILURES.append(f"{fn.__name__} raised {type(exc).__name__}: {exc}")
    if args.json:
        print(json.dumps({"passed": PASSES, "failed": FAILURES}, indent=2))
    else:
        for n in PASSES:
            print(f"  PASS  {n}")
        for n in FAILURES:
            print(f"  FAIL  {n}")
        print(f"\n{len(PASSES)} passed, {len(FAILURES)} failed")
    return 1 if FAILURES else 0


if __name__ == "__main__":
    sys.exit(main())
