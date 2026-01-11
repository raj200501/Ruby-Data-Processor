# Configuration Reference

This document enumerates configuration options, environment variables, and defaults used by the service.

## Environment Variables

### Core Runtime

| Variable | Default | Description |
| --- | --- | --- |
| `HOST` | `127.0.0.1` | Interface the server binds to. |
| `PORT` | `3000` | Port the HTTP server binds to. |
| `DATA_STORE_PATH` | `db/data.json` | Path to the JSON data store. |

## Data Store Defaults

The JSON store is created automatically if it does not exist. It contains:

```json
{
  "records": [],
  "last_id": 0
}
```

## Data Processing Defaults

The following defaults are applied in data processing services:

| Component | Default |
| --- | --- |
| Normalizer source | `manual` |
| Transformation multiplier | `2.0` |
| Transformation offset | `0.0` |
| Clamp min/max | `-inf`/`inf` |
| Data query limit | `100` (max `500`) |

## Configuring Transformation Behavior

`DataTransformationService` accepts keyword arguments:

```ruby
DataTransformationService.new(store, multiplier: 1.5, offset: 2.0, clamp_max: 100.0)
```

This allows you to tailor transformations to your domain without rewriting the service.

## Configuring Ingestion Behavior

`DataIngestionService` accepts `default_source`:

```ruby
DataIngestionService.new(store, records, default_source: 'sensor')
```

Each record can still override `source` explicitly.

## Sample `.env` File

```
HOST=127.0.0.1
PORT=3000
DATA_STORE_PATH=db/data.json
```

## Configuration Checklist

Before running in production:

- [ ] Set `DATA_STORE_PATH` to durable storage
- [ ] Bind `HOST=0.0.0.0` if needed
- [ ] Ensure backups of the JSON file

## Frequently Asked Questions

### Why use a JSON data store?

The JSON store keeps the application dependency-free and easy to run. It can be
replaced with a database-backed store if needed.

### Where do I configure logging format?

Logging is emitted to STDOUT. Customize the logger in `RubyDataProcessor::Server` if needed.

