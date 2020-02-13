# postgres-backup

```
docker run --rm \
  -e HOST=localhost \
  -e PORT=5432 \
  -e DATABASE=mydatabase \
  -e USERNAME=user \
  -e PASSWORD=pass \
  -e S3_HOST=https://fra1.digitaloceanspaces.com \
  -e S3_ACCESS_KEY_ID=id \
  -e S3_ACCESS_KEY_SECRET=secret \
  -e S3_DIRECTORY=myspace/mongo-backup \
  -e S3_CLEAN_OLDER_THAN=30d \
  -e S3_GPG_ENCRYPTION_PASSPHRASE=secret \
  airfocusio/postgres-backup:11.3 \
  backup
```
