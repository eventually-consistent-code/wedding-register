#!/usr/bin/env python3

"""
Purpose: Generate an asciicast v2 recording of the deterministic terminal parts
         of the Cairn demo (bd / gh / tofu) — runs the REAL commands, captures
         their output, and emits a typed-animation .cast you can `asciinema play`
         or embed. No TTY needed (works headless), unlike `asciinema rec`.
Author(s): John Reed
"""

import json
import subprocess
import time as _time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs" / "cast" / "cairn-demo.cast"
PROMPT = "\x1b[38;5;168mwedding-register\x1b[0m $ "

# Each step: a command to show being typed, and how to get its output.
# `run` executes for real (cwd relative to repo root); `text` is a canned line.
STEPS = [
    ("banner", "#  Cairn demo — beads + GitHub, deterministic parts"),
    ("run", "bd ready", "."),
    ("run", "bd list -l phase-1", "."),
    ("run", "gh issue list --repo eventually-consistent-code/wedding-register -L 10", "."),
    ("comment", "#  every beads ticket mirrored to a GitHub issue (labels carry the phase)"),
    ("run", "cat .cairn/id-map.json", "."),
    ("comment", "#  infra is OpenTofu + Terragrunt — validates with no AWS account"),
    ("run", "tofu validate", "infra/modules/network"),
]

events = []
t = 0.0


def emit(s):
    global t
    events.append([round(t, 3), "o", s])


def advance(dt):
    global t
    t += dt


def type_cmd(cmd):
    emit(PROMPT)
    advance(0.25)
    for ch in cmd:
        emit(ch)
        advance(0.035)
    emit("\r\n")
    advance(0.25)


def run(cmd, cwd):
    p = subprocess.run(cmd, shell=True, cwd=str(ROOT / cwd), capture_output=True, text=True)
    out = (p.stdout or "") + (p.stderr or "")
    return out.replace("\n", "\r\n")


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    emit("\x1b[2J\x1b[H")  # clear
    advance(0.4)
    for step in STEPS:
        kind = step[0]
        if kind in ("banner", "comment"):
            emit("\x1b[38;5;245m" + step[1] + "\x1b[0m\r\n")
            advance(1.1)
        elif kind == "run":
            _, cmd, cwd = step
            type_cmd(cmd)
            emit(run(cmd, cwd))
            advance(1.6)
    emit("\r\n\x1b[38;5;168m✓ plan → work → memory, one trail. that's Cairn.\x1b[0m\r\n")
    advance(2.0)

    header = {
        "version": 2,
        "width": 96,
        "height": 30,
        "timestamp": 0,
        "title": "Building wedding-register with Cairn",
        "env": {"SHELL": "/bin/bash", "TERM": "xterm-256color"},
    }
    with OUT.open("w") as f:
        f.write(json.dumps(header) + "\n")
        for e in events:
            f.write(json.dumps(e) + "\n")
    print(f"wrote {OUT}  ({len(events)} events, {t:.1f}s)")


if __name__ == "__main__":
    main()
