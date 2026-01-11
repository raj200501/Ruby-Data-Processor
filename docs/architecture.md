# Architecture

This document describes the internal architecture of Ruby Data Processor. It provides an overview of the
major components, how data flows through the system, and the rationale behind design decisions.

## High-Level Overview

The service is a pure-Ruby HTTP server that accepts data records over HTTP, persists them in a JSON
store, and provides aggregation and visualization helpers. The core flow is:

1. **HTTP request** arrives at the server.
2. **Request parser** extracts method, path, query params, and JSON body.
3. **Router** selects a handler based on method and path.
4. **Handler** validates input, interacts with the data store, and returns JSON.
5. **Response** is serialized back to the client.

## Directory Layout

| Path | Purpose |
| --- | --- |
| `lib/ruby_data_processor/` | Core HTTP server, router, and handlers. |
| `lib/` | Data store and data processing utilities. |
| `scripts/` | Run and verification entrypoints. |
| `test/` | Automated tests (unit and integration). |
| `docs/` | Additional documentation. |

## Core Components

### Server

`RubyDataProcessor::Server` is a lightweight HTTP server built on `TCPServer`. It accepts
connections sequentially, parses requests, and returns responses. It is intentionally small
and dependency-free.

### Request Parsing

`RubyDataProcessor::Request` handles:

- HTTP method parsing
- Query parameter extraction
- JSON body parsing (when `Content-Type` is `application/json`)

### Routing

`RubyDataProcessor::Router` matches routes using simple path patterns (e.g. `/data/:id`).
Handlers are invoked with the parsed request and any path parameters.

### Handlers

Handlers live in `lib/ruby_data_processor/handlers` and are responsible for
processing requests and returning JSON responses.

* `HealthHandler` serves the `/health` endpoint.
* `DataHandler` handles CRUD operations, batch ingestion, and summaries.

### Data Store

`DataStore` is a file-backed JSON store. It provides:

- `all` records
- `find` by ID
- `create` new records
- `update` existing records
- `delete` records
- `query` with filters

File locking is used to prevent concurrent writes. The store is created automatically
at `db/data.json` (configurable via `DATA_STORE_PATH`).

### Data Processing Utilities

Utilities in `lib/data_processor` are framework-agnostic:

- `Normalizer` standardizes input values
- `Validator` enforces schema rules
- `Summary` computes aggregate statistics
- `Visualization` outputs chart-friendly JSON
- `TransformationPipeline` composes transformation steps

## Error Handling

Handlers return structured errors:

- `400` for invalid JSON or missing payloads
- `404` for missing records or routes
- `422` for validation errors
- `500` for unexpected errors

## Extensibility Guidelines

When adding new features:

1. Add a route in `RubyDataProcessor::App`.
2. Implement a handler method in `lib/ruby_data_processor/handlers`.
3. Add tests in `test/`.
4. Update the API reference in `docs/api_reference.md`.

## Scaling Notes

The server is intentionally lightweight for local use. For higher throughput:

- Run multiple processes behind a load balancer.
- Replace the JSON store with a database-backed implementation.
- Add concurrency (threads or workers) to the server loop.

