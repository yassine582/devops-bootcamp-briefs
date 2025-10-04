#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../logs")/sysmonitor.log}"

timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

log() {
  local level="$1"; shift
  local msg="$*"
  echo "$(timestamp) [$level] $msg" | tee -a "$LOG_FILE"
}

log_info()  { log "INFO" "$*"; }
log_warn()  { log "WARN" "$*"; }
log_error() { log "ERROR" "$*"; }
