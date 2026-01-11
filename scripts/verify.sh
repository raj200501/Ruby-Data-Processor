#!/usr/bin/env bash
set -euo pipefail

ruby -Itest test/run_tests.rb

./scripts/smoke_test.sh
