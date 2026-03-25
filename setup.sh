#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures.
set -euo pipefail

case $(uname -s) in
  Darwin)
    ./setup_mac.sh
    ;;
  Linux)
    ./setup_linux.sh
    ;;
  *)
    echo "Unsupported OS."
    exit 1
    ;;
esac
