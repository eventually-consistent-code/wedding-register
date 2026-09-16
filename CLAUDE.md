# wedding-register

Demo repo for the Cairn workflow (see `README.md`, `HOWTO-CAIRN.md`, `docs/recording-script.md`).
The *workflow* is the deliverable — the app is a deliberately tiny 3-tier registry
(React/Vite → Express → MySQL) plus OpenTofu/Terragrunt IaC that is **code-only, never applied**.
There is no test runner, linter, or CI in this repo — don't invent one as a gate; `node --check`
and `vite build` are the only sanity checks available.

## Run

```bash
./scripts/dev.sh                 # docker compose up (MySQL + Adminer), waits for healthcheck,
                                 # npm install on first run, then backend + frontend
# web http://localhost:5173  ·  api http://localhost:4000/api/guests  ·  adminer http://localhost:8080
cd backend  && npm start         # or `npm run dev` (node --watch)
cd frontend && npm run dev       # also `npm run build`, `npm run preview`
docker compose down              # stops DB; add `-v` to wipe data + reseed schema
```

## Infra (OpenTofu + Terragrunt)

```bash
cd infra/modules/network && tofu init -backend=false && tofu validate   # offline, any module
cd infra/live/dev && terragrunt run-all validate                        # needs AWS creds + state bucket
cd infra/live/dev && terragrunt run-all plan
```

NEVER `apply` — this demo stops at plan. Layout and the ALB-vs-NLB reasoning are in `infra/README.md`.

## Env

Backend reads `PORT`, `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` (`backend/src/server.js`);
defaults match `docker-compose.yml`, so no `.env` is needed locally (`backend/.env.example` if you want one).
Infra wants `TF_VAR_db_password` exported before `terragrunt` plan.

## Gotchas

- Vite proxies `/api` → `127.0.0.1:4000` (`frontend/vite.config.js`), so `frontend/src/api.js` has no
  base URL — same-origin on purpose, mirrors the ALB routing in AWS. Don't add one.
- `GET /health` exists only as the ALB target-group probe; nothing in the app calls it.
- One table, `guests`, in `db/schema.sql`. MySQL loads it via the docker-entrypoint volume on first
  boot only — schema edits need `docker compose down -v` to reseed.
- Beads' Dolt DB lives at `.beads/embeddeddolt/` (AGENTS.md says `.beads/dolt/`; it's wrong).

## Tracker

Beads (`bd`) for all task tracking — protocol in `AGENTS.md`; `bd prime` runs on SessionStart/PreCompact.
