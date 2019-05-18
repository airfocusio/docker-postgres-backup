#!/bin/bash
set -e

mc config host add backup ${S3_HOST} ${S3_ACCESS_KEY_ID} ${S3_ACCESS_KEY_SECRET}
FOLDER="$(/bin/date +%Y)/$(/bin/date +%Y-%m)/$(/bin/date +%Y-%m-%d)"
FILE="$(/bin/date +%Y-%m-%d-%H%M%S)-${DATABASE}.sql.gz"
echo "${HOST}:${PORT:-5432}:${DATABASE}:${USERNAME}:${PASSWORD}" > ~/.pgpass
chmod 600 ~/.pgpass
pg_dump \
  --host="${HOST}" \
  --port="${PORT:-5432}" \
  --username="${USERNAME}" \
  --no-password \
  "${DATABASE}" | gzip | mc pipe "backup/${S3_DIRECTORY}/${FOLDER}/${FILE}"
