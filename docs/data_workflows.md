# Data Workflows

This document walks through common data workflows and how they map to the internal services.

## Workflow: Single Record Ingestion

1. Client sends `POST /data` with a JSON payload.
2. `DataHandler#create` extracts `data_record` parameters.
3. `DataRecordBuilder` normalizes and validates the payload.
4. `DataStore` persists the record to `db/data.json`.
5. Response returns the persisted record.

### Example Payload

```json
{
  "data_record": {
    "name": "Temperature",
    "value": 23.5,
    "source": "sensor",
    "metadata": {"unit": "celsius"}
  }
}
```

### Resulting Record

```json
{
  "id": 1,
  "name": "Temperature",
  "value": 23.5,
  "source": "sensor",
  "metadata": "{\"unit\":\"celsius\"}",
  "ingested_at": "2024-02-01T10:00:00Z",
  "created_at": "2024-02-01T10:00:00Z",
  "updated_at": "2024-02-01T10:00:00Z"
}
```

## Workflow: Bulk Ingestion

1. Client sends `POST /data/bulk` with an array of records.
2. `DataIngestionService` normalizes and validates each record.
3. Each record is created in the data store.
4. The response returns a count of created records.

### Example Payload

```json
{
  "data": [
    {"name": "Temperature", "value": 22.1, "source": "sensor"},
    {"name": "Humidity", "value": 45.0, "source": "sensor"}
  ]
}
```

### Example Response

```json
{
  "created": 2
}
```

## Workflow: Transformation

The transformation service applies a pipeline to every record in the dataset. The pipeline supports:

- Scaling values (e.g., multiply by 2)
- Offsetting values (e.g., add 5)
- Clamping values (e.g., min/max)

This can be used to normalize data before export or analysis.

## Workflow: Summaries

`GET /data/summary` computes statistics on filtered records. It uses:

1. `DataQueryService` to apply filters.
2. `DataProcessor::Summary` to compute statistics.

The response always includes count, min, max, and average.

## Workflow: Querying with Filters

Examples:

- `GET /data?min_value=10&max_value=30`
- `GET /data?source=sensor`
- `GET /data?name=Temp`
- `GET /data?since=2024-01-01T00:00:00Z`

All filters can be combined. Pagination is supported via `limit` and `offset`.

## Workflow: Error Handling

Validation errors return `422` and include details on which fields failed. Missing records return `404`.

Example error response:

```json
{
  "error": "validation_error",
  "message": "Record validation failed",
  "details": {
    "name": "is required",
    "value": "must be numeric",
    "source": "is required"
  }
}
```

## Workflow: Health Checks

The `/health` endpoint always returns `{ "status": "UP" }` when the app is running.
It is used in smoke tests and can be used by external monitoring.

