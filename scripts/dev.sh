#!/usr/bin/env bash

########################
# Script by John Reed  #
# wedding-register dev #
########################

# Brings the whole stack up locally for the demo / recording:
#   1. MySQL + Adminer via docker compose
#   2. backend API (node)        -> http://localhost:4000
#   3. frontend (vite)           -> http://localhost:5173
# Ctrl-C stops the node processes; `docker compose down` stops the DB.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "starting mysql + adminer..."
docker compose up -d
echo "waiting for mysql to be healthy..."
until [ "$(docker inspect -f '{{.State.Health.Status}}' "$(docker compose ps -q db)" 2>/dev/null)" = "healthy" ]; do
  sleep 2; printf "."
done
echo " ready."

echo "installing deps (first run only)..."
[ -d backend/node_modules ] || ( cd backend && npm install )
[ -d frontend/node_modules ] || ( cd frontend && npm install )

echo "starting api + web... (Ctrl-C to stop)"
( cd backend && npm start ) &
API_PID=$!
( cd frontend && npm run dev ) &
WEB_PID=$!
trap 'kill $API_PID $WEB_PID 2>/dev/null' INT TERM
echo
echo "***************************************************"
echo "* web:     http://localhost:5173                  *"
echo "* api:     http://localhost:4000/api/guests       *"
echo "* adminer: http://localhost:8080  (db: wedding)   *"
echo "***************************************************"
wait
