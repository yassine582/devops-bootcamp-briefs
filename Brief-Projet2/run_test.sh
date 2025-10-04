#!/usr/bin/env bash
set -euo pipefail

echo "Running SysMonitor-Pro one-shot test"
./main.sh --once --dry-run
echo "--- log tail ---"
tail -n 100 logs/sysmonitor.log || true
