#!/bin/sh
set -eu

/entrypoint.sh &
pgadmin_pid=$!

trap 'kill "$pgadmin_pid" 2>/dev/null || true; wait "$pgadmin_pid"' INT TERM

attempts=60
while [ "$attempts" -gt 0 ]; do
  if [ -f /var/lib/pgadmin/pgadmin4.db ]; then
    if PGADMIN_EMAIL="$PGADMIN_DEFAULT_EMAIL" /venv/bin/python - <<'PY'
import os
import sqlite3
import sys

conn = sqlite3.connect("/var/lib/pgadmin/pgadmin4.db")
cur = conn.cursor()

try:
    row = cur.execute(
        "select 1 from user where email = ? limit 1",
        (os.environ["PGADMIN_EMAIL"],),
    ).fetchone()
except Exception:
    row = None

sys.exit(0 if row else 1)
PY
    then
      break
    fi
  fi

  attempts=$((attempts - 1))
  sleep 1
done

if [ "$attempts" -eq 0 ]; then
  echo "pgAdmin user initialization not detected; skipping server import" >&2
  wait "$pgadmin_pid"
  exit $?
fi

/venv/bin/python /pgadmin4/setup.py load-servers /pgadmin4/servers.json \
  --user "$PGADMIN_DEFAULT_EMAIL" \
  --auth-source internal \
  --replace

wait "$pgadmin_pid"