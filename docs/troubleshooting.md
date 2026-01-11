# Troubleshooting

This guide lists known issues and how to resolve them.

## Server Startup Errors

### `Address already in use` for port 3000

Stop the process using port 3000 or start on a different port:

```bash
PORT=4000 ./scripts/run.sh
```

### `No such file or directory - db/data.json`

The server creates the data store automatically. Ensure the `db/` directory is writable.

## API Errors

### `validation_error`

Ensure the request includes:

- `name` (string)
- `value` (number)
- `source` (string)

### `not_found`

Ensure the ID exists in the data store. You can list all records with:

```bash
curl -s http://127.0.0.1:3000/data
```

## Smoke Test Failures

If `./scripts/smoke_test.sh` fails:

1. Check `tmp/smoke.log` for server boot errors.
2. Confirm port 4567 is available.
3. Ensure the data store is writable in `tmp/`.

## GitHub Actions

If CI fails, compare your local `./scripts/verify.sh` output with the workflow logs.
The workflow runs the same script, so failures should be reproducible locally.

