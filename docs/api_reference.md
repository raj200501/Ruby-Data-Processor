# API Reference

This document is the authoritative reference for the Ruby Data Processor HTTP API. All examples are verified against
`rails server` defaults and the request/response payloads produced by the application.

> Base URL
>
> `http://localhost:3000`

## Common Conventions

### Content Type

All requests that send a body should include `Content-Type: application/json`.

### Timestamps

The API uses ISO-8601 timestamps in UTC for `created_at`, `updated_at`, and `ingested_at` fields.

### Errors

Errors follow a consistent shape:

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

### Data Record Schema

A data record includes the following fields:

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | integer | yes (server generated) | Primary key. |
| `name` | string | yes | Metric or observation name. |
| `value` | number | yes | Numeric measurement. |
| `source` | string | yes | Origin of the data (e.g., `sensor`, `manual`). |
| `metadata` | string or object | no | JSON string or object containing additional context. |
| `ingested_at` | string | no | Time the record was collected. |
| `created_at` | string | yes | Time persisted. |
| `updated_at` | string | yes | Time last modified. |

---

## GET /health

### Description

Provides a simple health check for load balancers and smoke tests.

### Request

```bash
curl -s http://localhost:3000/health
```

### Response

```json
{
  "status": "UP"
}
```

---

## GET /data

### Description

Returns a filtered list of data records. Records are ordered by `created_at` in descending order.

### Query Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `min_value` | number | Only include records with `value >= min_value`. |
| `max_value` | number | Only include records with `value <= max_value`. |
| `source` | string | Filter by source name. |
| `name` | string | Substring match on name. |
| `since` | string | ISO-8601 timestamp to filter by `ingested_at >= since`. |
| `limit` | integer | Max number of records (default 100, max 500). |
| `offset` | integer | Offset for pagination. |

### Example: Fetch all records

```bash
curl -s http://localhost:3000/data
```

### Example: Filter by value and source

```bash
curl -s "http://localhost:3000/data?min_value=10&source=sensor"
```

### Example Response

```json
[
  {
    "id": 12,
    "name": "Temperature",
    "value": 21.4,
    "source": "sensor",
    "metadata": "{\"unit\":\"celsius\"}",
    "ingested_at": "2024-02-01T10:03:20Z",
    "created_at": "2024-02-01T10:03:21Z",
    "updated_at": "2024-02-01T10:03:21Z"
  }
]
```

---

## GET /data/:id

### Description

Returns a single data record by ID.

### Example

```bash
curl -s http://localhost:3000/data/12
```

### Example Response

```json
{
  "id": 12,
  "name": "Temperature",
  "value": 21.4,
  "source": "sensor",
  "metadata": "{\"unit\":\"celsius\"}",
  "ingested_at": "2024-02-01T10:03:20Z",
  "created_at": "2024-02-01T10:03:21Z",
  "updated_at": "2024-02-01T10:03:21Z"
}
```

---

## POST /data

### Description

Creates a new data record.

### Example Request

```bash
curl -s -X POST http://localhost:3000/data \
  -H 'Content-Type: application/json' \
  -d '{
    "data_record": {
      "name": "Pressure",
      "value": 101.2,
      "source": "sensor",
      "metadata": {"unit": "kPa"}
    }
  }'
```

### Example Response

```json
{
  "id": 13,
  "name": "Pressure",
  "value": 101.2,
  "source": "sensor",
  "metadata": "{\"unit\":\"kPa\"}",
  "ingested_at": "2024-02-01T10:05:00Z",
  "created_at": "2024-02-01T10:05:00Z",
  "updated_at": "2024-02-01T10:05:00Z"
}
```

### Validation Errors

If required fields are missing or invalid, the API returns `422`:

```bash
curl -s -X POST http://localhost:3000/data \
  -H 'Content-Type: application/json' \
  -d '{
    "data_record": {
      "name": "",
      "value": "not-a-number",
      "source": ""
    }
  }'
```

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

---

## PUT /data/:id

### Description

Updates an existing data record. This is a full update; send all required fields.

### Example Request

```bash
curl -s -X PUT http://localhost:3000/data/13 \
  -H 'Content-Type: application/json' \
  -d '{
    "data_record": {
      "name": "Pressure",
      "value": 102.0,
      "source": "sensor",
      "metadata": {"unit": "kPa"}
    }
  }'
```

### Example Response

```json
{
  "id": 13,
  "name": "Pressure",
  "value": 102.0,
  "source": "sensor",
  "metadata": "{\"unit\":\"kPa\"}",
  "ingested_at": "2024-02-01T10:05:00Z",
  "created_at": "2024-02-01T10:05:00Z",
  "updated_at": "2024-02-01T10:06:00Z"
}
```

---

## DELETE /data/:id

### Description

Deletes a data record. Returns `204 No Content`.

### Example Request

```bash
curl -i -X DELETE http://localhost:3000/data/13
```

### Example Response

```
HTTP/1.1 204 No Content
```

---

## POST /data/bulk

### Description

Ingests multiple records in one request. This endpoint is optimized for batch ingestion.

### Example Request

```bash
curl -s -X POST http://localhost:3000/data/bulk \
  -H 'Content-Type: application/json' \
  -d '{
    "data": [
      {"name": "Temperature", "value": 22.1, "source": "sensor"},
      {"name": "Humidity", "value": 45.0, "source": "sensor"},
      {"name": "Pressure", "value": 101.3, "source": "sensor"}
    ]
  }'
```

### Example Response

```json
{
  "created": 3
}
```

### Partial Failures

The batch endpoint validates each record and will fail the entire request if any record is invalid.
This ensures downstream processing can rely on complete batches.

---

## GET /data/summary

### Description

Returns summary statistics for the filtered dataset. Accepts the same query parameters as `GET /data`.

### Example Request

```bash
curl -s "http://localhost:3000/data/summary?source=sensor"
```

### Example Response

```json
{
  "count": 12,
  "min": 5.1,
  "max": 101.3,
  "average": 43.85
}
```

---

## Example Workflow

### 1. Create a record

```bash
curl -s -X POST http://localhost:3000/data \
  -H 'Content-Type: application/json' \
  -d '{
    "data_record": {
      "name": "Temperature",
      "value": 24.6,
      "source": "manual",
      "metadata": {"unit": "celsius", "location": "lab-1"}
    }
  }'
```

### 2. List records

```bash
curl -s http://localhost:3000/data
```

### 3. Summarize records

```bash
curl -s http://localhost:3000/data/summary
```

---

## FAQ

### Why is `metadata` returned as a string?

The API stores metadata as JSON in a text field for SQLite compatibility. You can parse the string in the client
if needed.

### How do I store additional attributes?

Use the `metadata` field to include any extra attributes that are not part of the canonical schema.

### How do I update only one field?

The `PUT /data/:id` endpoint requires all mandatory fields. Clients should send the full record to avoid
validation errors.
