#!/bin/bash

# Make sure dartfmt is run on everything
# This assumes you have dart_style as a dev_dependency
echo "Checking dartfmt..."
NEEDS_DARTFMT="$(find lib test tool -name "*.dart" | xargs pub run dart_style:format -n)"
if [[ ${NEEDS_DARTFMT} != "" ]]
then
  echo "FAILED"
  echo "${NEEDS_DARTFMT}"
  exit 1
fi
echo "PASSED"

# Make sure we pass the analyzer
echo "Checking dartanalyzer..."
FAILS_ANALYZER="$(find lib test tool -name "*.dart" | xargs dartanalyzer --options .analysis_options)"
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
dart tool/echo/http.dart & export HTTP_ECHO_PID=$!
dart tool/echo/ws.dart & export SOCKET_ECHO_PID=$!

# Run all of our tests
# If anything fails, we kill the ECHO_PID, otherwise kill at the end.
echo "Running all tests..."
pub run test -p "content-shell,vm,chrome" || kill $HTTP_ECHO_PID $SOCKET_ECHO_PID
kill $HTTP_ECHO_PID $SOCKET_ECHO_PID

