#!/bin/bash

# Make sure dartfmt is run on everything
# This assumes you have dart_style as a dev_dependency
echo "Checking dartfmt..."
NEEDS_DARTFMT="$(find bin lib test -name "*.dart" | xargs pub run dart_style:format -n)"
if [[ ${NEEDS_DARTFMT} != "" ]]
then
  echo "FAILED"
  echo "${NEEDS_DARTFMT}"
  exit 1
fi
echo "PASSED"

# Make sure we pass the analyzer
echo "Checking dartanalyzer..."
FAILS_ANALYZER="$(find bin lib test -name "*.dart" | xargs dartanalyzer --options analysis_options.yaml)"
if [[ $FAILS_ANALYZER == *"[error]"* ]]
then
  echo "FAILED"
  echo "${FAILS_ANALYZER}"
  exit 1
fi
echo "PASSED"

# Fail on anything that fails going forward.
set -e

# Run a simple echo server, we use this to test most of our client code.
echo "Running echo servers..."
dart bin/http_echo.dart --port=9090 & export HTTP_ECHO_PID=$!
dart bin/socket_echo.dart --port=9095 & export SOCKET_ECHO_PID=$!

# Run all of our tests
# If anything fails, we kill the ECHO_PID, otherwise kill at the end.
echo "Running all tests..."
pub run test -p "dartium,vm" || kill $HTTP_ECHO_PID $SOCKET_ECHO_PID
kill $HTTP_ECHO_PID $SOCKET_ECHO_PID

