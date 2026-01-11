# Development Guide

This guide covers local development workflows for Ruby Data Processor.

## Prerequisites

- Ruby 3.2.3

## Setup

No external dependencies are required. The app runs with the Ruby standard library.

## Running the Server

Use the provided run script to ensure consistent defaults:

```bash
./scripts/run.sh
```

The server listens on `http://127.0.0.1:3000` by default. Override the port:

```bash
PORT=4000 ./scripts/run.sh
```

## Configuration

Environment variables supported:

| Variable | Default | Description |
| --- | --- | --- |
| `HOST` | `127.0.0.1` | Server host binding. |
| `PORT` | `3000` | Server port. |
| `DATA_STORE_PATH` | `db/data.json` | JSON store path. |

A sample `.env.example` file is included for convenience.

## Development Workflows

### Adding a New Endpoint

1. Add a route in `lib/ruby_data_processor/app.rb`.
2. Implement a handler method in `lib/ruby_data_processor/handlers`.
3. Add tests in `test/`.
4. Update `docs/api_reference.md`.

### Extending the Data Pipeline

To add a transformation step:

1. Create a new step in `lib/data_processor/transformation_pipeline.rb`.
2. Add the step to `DataTransformationService`.
3. Add unit tests under `test/data_processor`.

## Scripts

The following scripts are canonical entry points:

- `./scripts/run.sh` for running the server
- `./scripts/verify.sh` for running tests and smoke checks
- `./scripts/smoke_test.sh` for the standalone smoke check

## Data Store

The data store is a JSON file created automatically on first run. To reset it:

```bash
rm -f db/data.json
```

## Roadmap Suggestions

Potential improvements you can contribute:

- Add CSV import/export helpers
- Add authentication (API keys or JWT)
- Add streaming ingestion for large payloads
- Add pagination metadata in list responses
- Add metrics endpoint for monitoring

