#!/usr/bin/env bash
# Throwaway Postgres + pgvector with no network, for running a PR's SQL on synthetic data.
#   sandbox_pg.sh up [migration.sql ...]   start (or reuse) and apply each file twice (idempotency check)
#   sandbox_pg.sh sql                      read SQL on stdin, print rows (-qAt)
#   sandbox_pg.sh down                     remove the container
# Never point this at a real database: it has no port and no network on purpose.
set -euo pipefail
NAME=${SANDBOX_PG:-mechanism-sim}
psql_() { docker exec -i "$NAME" psql -U postgres -qAt -v ON_ERROR_STOP=1 "$@"; }
case "${1:-}" in
  up)
    shift
    if ! docker inspect "$NAME" >/dev/null 2>&1; then
      docker run -d --name "$NAME" --network none -e POSTGRES_PASSWORD=sim pgvector/pgvector:pg16 >/dev/null
      for _ in $(seq 1 30); do docker exec "$NAME" pg_isready -U postgres -q && break; sleep 1; done
      # Supabase roles and schema that migrations grant to or reference.
      psql_ <<'SQL'
create role anon nologin; create role authenticated nologin; create role service_role nologin bypassrls;
create schema if not exists extensions;
SQL
    fi
    for f in "$@"; do
      psql_ < "$f" >/dev/null 2>&1 || { echo "FAILED (1st run): $f" >&2; psql_ < "$f"; exit 1; }
      psql_ < "$f" >/dev/null 2>&1 && echo "applied twice: $f" || { echo "FAILED (2nd run, not idempotent): $f" >&2; exit 1; }
    done ;;
  sql) psql_ ;;
  down) docker rm -f "$NAME" >/dev/null && echo "removed $NAME" ;;
  *) echo "usage: $0 up [file.sql ...] | sql | down" >&2; exit 2 ;;
esac
