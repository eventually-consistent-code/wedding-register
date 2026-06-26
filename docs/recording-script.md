# Recording Script — "Building wedding-register with Cairn"

A timed shot list for a screen recording you narrate afterward. Two surfaces:
**[T]** terminal, **[B]** browser. Each scene has what to do, what's on screen,
and a **🎙 voiceover cue** (record the v/o after, watching the footage).

> **Before you hit record**
> - Start Docker Desktop (the website scene needs it).
> - Big terminal font, clean prompt, `cd ~/repos/wedding-register`.
> - Log into GitHub in the browser (for the issues tab).
> - Optional: replay the prebuilt terminal cast instead of live-typing the
>   deterministic parts — `asciinema play docs/cast/cairn-demo.cast`.
> - Total target: ~5–6 minutes.

---

### Scene 1 — Cold open (~25s) · [T]
**Do:** clear screen; `type` (don't run) `/cairn:help`, then run it.
**Screen:** the `/cairn:` command map.
**🎙** "This is Cairn — one command interface over three tools: GSD for planning,
beads for issue tracking, context-mode for memory. Watch it take a blank folder
to a planned, tracked, GitHub-linked build."

### Scene 2 — Bootstrap (~30s) · [T]
**Do:** `/cairn:init`
**Screen:** git init ✓, bd init ✓, "next: /gsd:new-project".
**🎙** "`/cairn:init` is soup-to-nuts: it makes sure GSD and beads are here,
runs git init and bd init, and hands off to planning. One command."

### Scene 3 — Plan + tickets (~45s) · [T]
**Do:** `/cairn:new` (the GSD interview is quick — answer briefly), then
`/cairn:issues` and `bd ready`.
**Screen:** 10 tickets appear, grouped by phase; `bd ready` shows the 3 unblocked
roots.
**🎙** "`/cairn:new` plans the project and turns every requirement into a beads
ticket, labelled by phase, with real dependencies. `bd ready` shows only what's
unblocked — network, schema, local dev. The blocked ones are waiting on those."

### Scene 4 — The dependency graph (~25s) · [T]
**Do:** `/cairn:status` (or `bd dep tree wedding-register-9h5`).
**Screen:** the ALB/ASG ticket blocked by network + security + database.
**🎙** "The infra ticket for the load balancer is blocked by three others —
beads knows you can't stand up the ALB before the VPC, security groups, and
database exist."

### Scene 5 — GitHub linking (~40s) · [T] → [B]
**Do:** `[T]` `gh issue list --repo BigJiggity/wedding-register` →
`[B]` open `github.com/BigJiggity/wedding-register/issues`.
**Screen:** 10 issues, each with its `phase-N` + `cairn` label.
**🎙** "Here's Cairn's sync: every beads ticket is mirrored to a GitHub issue,
carrying its phase label. beads stays the source of truth; GitHub is the mirror.
The bd-to-issue map is in `.cairn/id-map.json`."

### Scene 6 — Build a phase (~50s) · [T]
**Do:** `/cairn:plan 1` then `/cairn:work 1` (or narrate over the prebuilt
result). Then prove the infra:
`cd infra/modules/network && tofu init -backend=false && tofu validate`.
**Screen:** ticket claimed → in_progress → closed; "Success! The configuration is
valid."
**🎙** "`/cairn:work` claims the phase's tickets, executes, and closes them on
success — the beads status moves as the code lands. The infrastructure is
OpenTofu and Terragrunt, and it validates clean."

### Scene 7 — The app, running (~45s) · [T] → [B]
**Do:** `[T]` `./scripts/dev.sh` → `[B]` open `http://localhost:5173`, add a
guest (name/address/phone) → open `http://localhost:8080` (Adminer) and show the
row in the `guests` table.
**Screen:** the registry form, the new guest in the list, the DB row.
**🎙** "And it's a real app — React front end, a node API, MySQL behind it. A
guest adds their details, and there's the row landing in the database."

### Scene 8 — Memory (~30s) · [T]
**Do:** `/cairn:remember WAF is regional on the ALB, not CloudFront scope` then
`/cairn:recall how did we scope the WAF?`
**Screen:** the scoped recall result.
**🎙** "While you work, Cairn ties context-mode's memory to the active ticket and
phase, so recall is about *this* task — not the whole session's noise."

### Scene 9 — Ship + close (~20s) · [T]
**Do:** `/cairn:ship` (or show `bd list -l phase-1 --status open` is empty).
**🎙** "`/cairn:ship` won't let you ship with open tickets on a finished phase.
Plan, work, memory — one trail, one marker. That's Cairn."

---

## Capture tips
- Record terminal and browser as separate sources if you can — easier to cut.
- For the slash-command scenes, the *prompt + output* is the story; pause ~1s on
  each result so the v/o has room.
- The deterministic terminal parts (git/bd/gh/tofu) are also in
  `docs/cast/cairn-demo.cast` — `asciinema play` it full-screen if you'd rather
  not live-type.
