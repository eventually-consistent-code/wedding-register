# Wedding Register

A tiny 3-tier wedding registry — guests add their **name, address, and phone**
so the couple can send thank-yous later.

> **This repo is a demo of [Cairn](https://github.com/eventually-consistent-code/claude-plugins/tree/main/cairn).**
> The point isn't the app — it's showing how Cairn drives a real build:
> planning → tracked tickets → execution → GitHub-linked issues, all from the
> `/cairn:` command surface. The full walkthrough is in
> **[HOWTO-CAIRN.md](./HOWTO-CAIRN.md)** (written against the cairn 1.x + beads
> flow; beads was retired 2026-09-17, cairn 2.0 tracks straight in GitHub).

## Architecture (3-tier, AWS)

```
            ┌─────────┐      ┌──────────────┐      ┌──────────────┐
  guests ─▶ │  WAF +   │ ─▶  │  App tier     │ ─▶  │  Data tier    │
            │  ALB     │      │  EC2 ASG      │      │  RDS MySQL    │
            │ (public) │      │  node/express │      │  (private)    │
            └─────────┘      └──────────────┘      └──────────────┘
              web tier         (private subnets)      (private subnets)
```

- **Web tier** — React (Vite) static build, fronted by an ALB with AWS WAF.
- **App tier** — Node/Express API on EC2 (Auto Scaling Group), private subnets.
- **Data tier** — RDS MySQL, private subnets, reachable only from the app tier.

IaC lives in [`infra/`](./infra) as **OpenTofu modules + Terragrunt** (code-only
in this demo — reviewed and `validate`d, not deployed).

## Run it locally

```bash
./scripts/dev.sh        # mysql+adminer (docker) + api + web
# web:     http://localhost:5173
# adminer: http://localhost:8080
```

Requires Docker, Node 18+.

## Layout

| Path | What |
|---|---|
| `frontend/` | React + Vite UI |
| `backend/`  | Node/Express API → MySQL |
| `db/schema.sql` | the `guests` table |
| `infra/`    | OpenTofu modules + Terragrunt live config |
| `HOWTO-CAIRN.md` | ⭐ how this was built with Cairn |
| `docs/recording-script.md` | the screen-recording shot list |
