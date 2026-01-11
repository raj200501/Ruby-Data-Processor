# Data Store Format

This document describes the JSON data store format used by Ruby Data Processor. The goal
is to make the storage format explicit so it can be inspected or migrated easily.

## File Structure

The store is a JSON object with two keys:

```json
{
  "records": [],
  "last_id": 0
}
```

### `records`

An array of record objects. Each record has the following keys:

| Field | Type | Description |
| --- | --- | --- |
| `id` | integer | Auto-incrementing identifier. |
| `name` | string | Data metric name. |
| `value` | number | Numeric measurement. |
| `source` | string | Origin of the data. |
| `metadata` | string | JSON string representing metadata. |
| `ingested_at` | string | ISO-8601 timestamp of ingestion. |
| `created_at` | string | ISO-8601 timestamp of creation. |
| `updated_at` | string | ISO-8601 timestamp of last update. |

### `last_id`

Tracks the most recently assigned ID to keep `id` generation deterministic across restarts.

## Example File

```json
{
  "records": [
    {
      "id": 1,
      "name": "Temperature",
      "value": 22.5,
      "source": "sensor",
      "metadata": "{\"unit\":\"celsius\"}",
      "ingested_at": "2024-02-01T10:00:00Z",
      "created_at": "2024-02-01T10:00:00Z",
      "updated_at": "2024-02-01T10:00:00Z"
    },
    {
      "id": 2,
      "name": "Humidity",
      "value": 45.0,
      "source": "sensor",
      "metadata": "{\"unit\":\"percent\"}",
      "ingested_at": "2024-02-01T10:05:00Z",
      "created_at": "2024-02-01T10:05:00Z",
      "updated_at": "2024-02-01T10:05:00Z"
    }
  ],
  "last_id": 2
}
```

## Metadata Field

`metadata` is stored as a JSON string for portability. Clients may parse it into a structured
object. Example:

```json
{"unit":"celsius","location":"lab-1"}
```

## Updates

When a record is updated:

- `updated_at` is refreshed.
- The `id` and `created_at` fields remain unchanged.

## Deletions

When a record is deleted:

- The entry is removed from `records`.
- `last_id` remains unchanged to keep IDs monotonic.

## Consistency Notes

The data store uses file locking to ensure writes are serialized. Concurrent reads may occur
between writes; in that case, the previous committed file state is returned.

## Migration Strategy

To migrate the JSON store to another system:

1. Stop the server to avoid writes.
2. Copy `db/data.json` to a safe location.
3. Parse the file and import records into the target system.
4. Preserve IDs if other systems rely on them.

## Recovery

If the store is corrupted:

1. Restore from a backup copy.
2. If no backup exists, inspect the file and remove invalid JSON sections.
3. Restart the server to reinitialize the store.

## Manual Editing

You can manually edit the file for testing. Ensure that:

- JSON is valid.
- `last_id` matches the highest `id` in the records list.
- Timestamps remain in ISO-8601 format.

## Notes on Scaling

The JSON store is intended for small to medium datasets. When the number of records grows
substantially, consider replacing it with a database-backed implementation to avoid large
in-memory loads and file size growth.

