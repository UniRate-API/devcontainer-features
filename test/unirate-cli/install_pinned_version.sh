#!/bin/bash
#
# Scenario test: the feature is installed with version "0.1.0" pinned, so the
# installed binary must report exactly that version.
set -e

source dev-container-features-test-lib

check "unirate is on PATH" bash -c "command -v unirate"
check "pinned version is 0.1.0" bash -c "unirate version | grep -Fx 'unirate 0.1.0'"

reportResults
