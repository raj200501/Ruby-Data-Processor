# Operations Guide

This guide describes how to operate Ruby Data Processor in a production-like environment.

## Environment Variables

| Variable | Required | Description |
| --- | --- | --- |
| `HOST` | yes | Interface to bind. |
| `PORT` | yes | Port to bind. |
| `DATA_STORE_PATH` | yes | Path to the JSON store. |

## Running in Production Mode

```bash
HOST=0.0.0.0 PORT=3000 DATA_STORE_PATH=/var/lib/data/data.json ./scripts/run.sh
```

## Logging

Logs are emitted to STDOUT. Redirect or capture them using your process manager.

Example:

```bash
./scripts/run.sh 2>&1 | tee logs/server.log
```

## Data Store

The default data store is a JSON file. For production workloads:

- Place the file on durable storage.
- Back it up regularly.
- Consider swapping the store implementation to a database if concurrency grows.

## Monitoring

The `/health` endpoint returns `status: UP` when the application is responsive. This
can be used for uptime checks.

## Zero-Downtime Deployments

For larger deployments, consider:

- Running multiple server processes behind a load balancer.
- Rotating data store backups during low-traffic windows.

## Security Recommendations

- Bind to `127.0.0.1` and expose via a reverse proxy if the service is public.
- Restrict access using firewall rules.
- Add authentication or API keys for public endpoints.


## Backup Strategy

### Manual Backup

```bash
cp db/data.json backups/data-$(date +%Y%m%d%H%M%S).json
```

### Automated Backup (cron)

Example cron entry:

```
0 * * * * /usr/bin/env bash -c 'cp /var/lib/data/data.json /var/lib/data/backups/data-$(date +\%Y\%m\%d\%H\%M\%S).json'
```

## Restore Procedure

1. Stop the server to prevent writes.
2. Copy the desired backup into place:

```bash
cp backups/data-20240201100000.json db/data.json
```

3. Restart the server.

## Log Rotation

When piping logs to a file, rotate them regularly. Example using `logrotate`:

```
/var/log/data-processor/server.log {
  daily
  rotate 7
  compress
  missingok
  notifempty
  copytruncate
}
```

## Process Supervision

Run the server under a supervisor such as `systemd`:

```
[Unit]
Description=Ruby Data Processor
After=network.target

[Service]
WorkingDirectory=/opt/ruby-data-processor
ExecStart=/opt/ruby-data-processor/scripts/run.sh
Restart=on-failure
Environment=HOST=0.0.0.0
Environment=PORT=3000
Environment=DATA_STORE_PATH=/var/lib/data/data.json

[Install]
WantedBy=multi-user.target
```

## Capacity Planning

Monitor the size of `db/data.json`. When the file grows beyond comfortable limits,
consider replacing the data store with a database-backed implementation.

