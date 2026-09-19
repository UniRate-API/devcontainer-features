#!/bin/bash
#
# Default test: the feature is installed with no options, so 'version' falls
# back to 'latest'. Verifies the binary is on PATH and runs.
set -e

source dev-container-features-test-lib

check "unirate is on PATH" bash -c "command -v unirate"
check "unirate version runs" bash -c "unirate version | grep -E '^unirate '"
check "unirate help runs" bash -c "unirate --help | grep -iq usage"

reportResults
