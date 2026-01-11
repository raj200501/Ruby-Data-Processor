# Testing Guide

This guide explains how automated verification is structured and how to run tests locally.

## Test Suite Overview

The project uses Minitest, which is part of the Ruby standard library.

| Test Type | Location | Purpose |
| --- | --- | --- |
| Unit tests | `test/unit` | Validate data processing utilities. |
| Integration tests | `test/integration` | Validate HTTP endpoints. |
| Store tests | `test/store` | Validate JSON persistence. |

## Running All Tests

```bash
ruby -Itest test/run_tests.rb
```

## Smoke Test

The smoke test is a separate script that starts the server and performs real HTTP requests.
It validates the end-to-end behavior described in the README.

```bash
./scripts/smoke_test.sh
```

## Canonical Verification

`./scripts/verify.sh` is the canonical entrypoint for CI. It performs:

1. `ruby -Itest test/run_tests.rb`
2. `./scripts/smoke_test.sh`

## Determinism

The test suite avoids randomness when verifying counts and data values. When sample data is
required, tests assert deterministic expectations (counts and known values).

## Debugging Failing Tests

- Review `tmp/smoke.log` after running the smoke test.
- Confirm the data store is reset between tests.

