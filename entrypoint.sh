#!/bin/bash
set -e
set -o pipefail

function encrypt {
  if [ -z "${S3_GPG_ENCRYPTION_PASSPHRASE}" ]
  then
    cat
  else
    gpg --symmetric --batch --passphrase "${S3_GPG_ENCRYPTION_PASSPHRASE}"
  fi
}

function decrypt {
  if [ -z "${S3_GPG_ENCRYPTION_PASSPHRASE}" ]
  then
    cat
  else
    gpg --decrypty --batch --passphrase "${S3_GPG_ENCRYPTION_PASSPHRASE}"
  fi
}

if [ "$1" == "backup" ]; then
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
    "${DATABASE}" | gzip | encrypt | mc pipe "backup/${S3_DIRECTORY}/${FOLDER}/${FILE}"

  if [ -z "${S3_CLEAN_OLDER_THAN}" ]
  then
    echo "Skipping cleanup of old backups."
  else
    mc rm -r --force --older-than "${S3_CLEAN_OLDER_THAN}" "backup/${S3_DIRECTORY}"
  fi
elif [ "$1" == "restore" ]; then
  echo "Not yet implemented!"
  exit 1
else
  echo "Mode must be backup or restore!"
  exit 1
fi
