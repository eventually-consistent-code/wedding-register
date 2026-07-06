# How to Build a Real Project with Cairn

> A walkthrough using **wedding-register** — a 3-tier AWS web app — as the worked
> example. By the end you'll know what Cairn is, the one command interface, and
> the exact sequence that takes a blank folder to a planned, tracked,
> GitHub-linked build.

## What is Cairn?

A cairn is a stack of stones that marks a trail *and remembers the path you
took*. The plugin does the same for a project — it stacks **plan → work →
memory** into one marker so a solo build stays on-trail.

Cairn is **thin glue** between three tools, behind one `/cairn:` namespace:

| Tool | Role | "What is the…" |
|---|---|---|
| **GSD** (`/gsd:*`) | planning | …*plan*: roadmap → phases → PLAN.md |
| **beads** (`bd`) | issue tracking | …*work*: every requirement is a tracked ticket |
| **context-mode** (`ctx_*`) | memory | …*memory*: compressed recall, scoped to the task |

Install Cairn and it pulls GSD + context-mode in automatically (declared
dependencies) and offers to install the `bd` binary on first run. One `/cairn:init`
wires a project; the `/cairn:` verbs drive the combined lifecycle.

## What you'll build

`wedding-register` — guests submit their **name, address, phone**; the couple
gets a list. Deliberately small so the *workflow* is the star, not the app.

```
            ┌──────────┐     ┌──────────────┐     ┌──────────────┐
  guests ─▶ │ WAF +ALB │ ─▶  │ EC2 ASG       │ ─▶  │ RDS MySQL     │
            │ (web)    │     │ node/express  │     │ (data)        │
            └──────────┘     └──────────────┘     └──────────────┘
```

- **Frontend** React (Vite) · **Backend** Node/Express · **DB** MySQL
- **Infra** OpenTofu modules + Terragrunt (code-only here — validated, not deployed)

## Prerequisites

```text
/plugin marketplace add eventually-consistent-code/claude-plugins
/plugin marketplace add mksglu/context-mode      # cairn depends on it cross-marketplace
/plugin install cairn@eventually-consistent-code                  # GSD + context-mode auto-install
/reload-plugins
```

You also need the `bd` binary (Cairn offers to install it on first session) and,
for the GitHub linking, the `gh` CLI authenticated (`gh auth status`).

## The one interface

You never have to remember whether something is a `bd` command or a `/gsd:*`
command. `/cairn:help` prints the whole map:

```text
SETUP   /cairn:init   /cairn:new
LOOP    /cairn:plan N   /cairn:work N   /cairn:verify N   /cairn:ship
VIEW    /cairn:status   /cairn:progress   /cairn:issues [N]
MEMORY  /cairn:remember [what]   /cairn:recall <query>
RAW     /cairn:bd <args>   /cairn:gsd <cmd>   /cairn:ctx <op>
```

---

## Step 0 — Bootstrap: `/cairn:init`

From the empty project folder:

```text
/cairn:init
```

It does the soup-to-nuts wiring: confirms GSD is present, offers to install `bd`
if missing, runs `git init` + `bd init`, then hands off to the planning step.
After this you have a git repo and a beads database (`.beads/`).

> `bd init` also installs **beads' own** Claude integration (a `bd prime`
> SessionStart hook + a `CLAUDE.md` block). Cairn notices this and stays quiet
> about bd basics so you don't get double reminders.

## Step 1 — Plan the project: `/cairn:new`

```text
/cairn:new
```

This runs `/gsd:new-project` (an interview that produces `.planning/` + a
ROADMAP), then applies the Cairn convention: **one `bd` issue per requirement**,
each labelled `phase-N`, with dependencies wired from the roadmap. For
wedding-register that produced **10 tickets across 3 phases**:

| Phase | Tickets | bd id → GitHub |
|---|---|---|
| **1 — Infra** | VPC + subnets · Security groups + WAF · RDS MySQL · ALB + EC2 ASG | `szc`→#1, `hvq`→#8, `7rq`→#4, `9h5`→#5 |
| **2 — Backend** | guests schema · REST API + health · DB pool + config | `kol`→#9, `6oy`→#3, `dx2`→#7 |
| **3 — Frontend** | registry form · guest list · local dev stack | `dh9`→#6, `545`→#2, `mhh`→#10 |

Dependencies are real — e.g. the ALB/ASG ticket is blocked by network, security,
*and* database. See it any time:

```text
/cairn:issues          # all tickets, grouped by status
/cairn:status          # ready-now + blocked + roadmap progress
```

`bd ready` shows only the unblocked roots — for this project, the three with no
blockers: **network**, **schema**, **local dev stack**.

## Step 2 — Build phase 1 (infra): `/cairn:plan 1` → `/cairn:work 1`

```text
/cairn:plan 1
```

Reads phase 1's `NN-BEADS-MAP.md`, runs `/gsd:plan-phase 1`, reconciles any
divergence (GSD's `CONTEXT.md` wins over stale ticket text), and stamps each
generated `PLAN.md` with the `beads:` ids it advances.

```text
/cairn:work 1
```

For each plan, Cairn **claims** its tickets (`bd update --claim --status
in_progress`), runs `/gsd:execute-phase 1`, and on success **closes** them
(`bd close --reason=…`). That's where the OpenTofu modules in
[`infra/`](./infra) come from — `network`, `security`, `database`, `compute`.
Validate them with no AWS account needed:

```bash
cd infra/modules/network && tofu init -backend=false && tofu validate
# Success! The configuration is valid.
```

## Step 3 — Build phases 2 & 3

Same loop, new phase numbers:

```text
/cairn:plan 2   &&   /cairn:work 2      # backend: schema, API, DB pool
/cairn:plan 3   &&   /cairn:work 3      # frontend: form, list, local stack
/cairn:verify 3                         # /gsd:verify-work cross-checked vs beads
```

Run the result locally (the website footage):

```bash
./scripts/dev.sh
# web:     http://localhost:5173
# adminer: http://localhost:8080   (watch rows land in MySQL)
```

## The payoff — beads ↔ GitHub linking

This is Cairn's sync feature: bd is the hub, every tool mirrors *to* bd. We
enabled the GitHub backend in [`.cairn/sync.json`](./.cairn/sync.json):

```json
{ "type": "github", "enabled": true,
  "config": { "repo": "eventually-consistent-code/wedding-register", "extra_labels": ["cairn"] } }
```

Each `bd` lifecycle event pushes to GitHub Issues (reusing your `gh` auth), so
every ticket has a linked issue carrying its `phase-N` label:

```bash
gh issue list --repo eventually-consistent-code/wedding-register
#  #1  [phase-1,cairn]  Provision VPC and 3-tier subnets
#  #3  [phase-2,cairn]  Guests REST API + health check
#  #6  [phase-3,cairn]  Registry form: name, address, phone
#  …10 issues, one per ticket
```

The bd↔GitHub map lives in `.cairn/id-map.json`. Pull external edits back into bd
on demand with `/cairn:sync-pull` (last-writer-wins by timestamp).

## Memory that knows the task — context-mode

While you work, Cairn ties context-mode's compressed memory to the **active
ticket + phase** so recall is scoped to the work, not the whole session:

```text
/cairn:remember the ALB needs the regional WAF, not CloudFront scope
/cairn:recall  how did we scope the WAF?
```

Indexed under a `gb/<bd_id>/<phase>` label; `/cairn:recall` searches just the
active ticket. No setup needed — context-mode ships as a dependency.

## Ship

```text
/cairn:ship
```

Gates on every completed phase's tickets being closed (`bd list -l phase-N
--status open` must be empty), then finalizes/pushes. Never ships with open work
on a "done" phase.

## Command cheat-sheet

| Goal | Command |
|---|---|
| Bootstrap a repo | `/cairn:init` |
| Start a project (plan + tickets) | `/cairn:new` |
| Plan / build / verify a phase | `/cairn:plan N` · `/cairn:work N` · `/cairn:verify N` |
| See state | `/cairn:status` · `/cairn:issues [N]` · `/cairn:progress` |
| Memory | `/cairn:remember …` · `/cairn:recall …` |
| Mirror to GitHub | (automatic on bd events) · reconcile: `/cairn:sync-pull` |
| Raw escape hatch | `/cairn:bd …` · `/cairn:gsd …` · `/cairn:ctx …` |
| Ship | `/cairn:ship` |

---

*The repository you're reading is the finished result of this workflow. The
[recording script](./docs/recording-script.md) walks the same path on camera.*
