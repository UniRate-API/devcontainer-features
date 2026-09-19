#!/bin/bash
#
# Scenario test: the feature installs correctly on Alpine (apk / musl / shasum
# fallback path), not just Debian/Ubuntu.
set -e

source dev-container-features-test-lib

check "unirate is on PATH" bash -c "command -v unirate"
check "unirate version runs" bash -c "unirate version | grep -E '^unirate '"

reportResults
