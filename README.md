# Ruby Data Processor

Ruby Data Processor is a pure-Ruby HTTP service for ingesting, transforming, and summarizing numeric data records.
It exposes a REST API backed by a JSON file store, making it runnable without external dependencies.

## Features

- Real-time data ingestion (single record or bulk)
- Filterable record listing
- Summary statistics (count, min, max, average)
- Transformation pipeline utilities
- Health endpoint for monitoring
- Deterministic verification via `./scripts/verify.sh`

## Requirements

- Ruby 3.2.3

## Quickstart

```bash
git clone https://github.com/your-username/Ruby-Data-Processor.git
cd Ruby-Data-Processor

./scripts/run.sh
```

The server starts on `http://127.0.0.1:3000` by default.

## Usage

### API Endpoints

- `GET /health`: Health check
- `GET /data`: Retrieve data records (supports filters)
- `POST /data`: Ingest a new data record
- `GET /data/:id`: Retrieve a specific data record
- `PUT /data/:id`: Update a data record (full update)
- `DELETE /data/:id`: Delete a data record
- `POST /data/bulk`: Ingest multiple data records
- `GET /data/summary`: Summary statistics for filtered records

### Example Requests

Create a record:

```bash
curl -s -X POST http://127.0.0.1:3000/data \
  -H 'Content-Type: application/json' \
  -d '{
    "data_record": {
      "name": "Temperature",
      "value": 22.5,
      "source": "sensor",
      "metadata": {"unit": "celsius"}
    }
  }'
```

Fetch records:

```bash
curl -s http://127.0.0.1:3000/data
```

Fetch summary statistics:

```bash
curl -s http://127.0.0.1:3000/data/summary
```

## Scripts

- `./scripts/run.sh`: Run the server with sane defaults.
- `./scripts/verify.sh`: Run unit tests and a smoke test.

## Verified Quickstart

The following commands were executed successfully in the repository to validate the setup:

```bash
./scripts/run.sh
```

## Verified Verification

The canonical verification command is:

```bash
./scripts/verify.sh
```

This command runs Minitest unit tests and executes the smoke test that exercises the HTTP API.

## Documentation

- `docs/api_reference.md`: Detailed API reference with examples.
- `docs/architecture.md`: System architecture and data flow.
- `docs/development.md`: Local development workflow.
- `docs/testing.md`: Testing strategy and verification.
- `docs/troubleshooting.md`: Common issues and fixes.
- `docs/data_workflows.md`: Data processing workflows.
- `docs/operations.md`: Production and operations notes.
- `docs/configuration_reference.md`: Configuration options and defaults.
- `docs/data_store_format.md`: JSON store structure and migration notes.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
