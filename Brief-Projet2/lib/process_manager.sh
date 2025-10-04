#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/logger.sh"

check_process() {
  local pname="$1"
  if pgrep -f "$pname" >/dev/null 2>&1; then
    log_info "Process '$pname' is running"
    return 0
  else
    log_warn "Process '$pname' is NOT running"
    return 1
  fi
}

restart_process() {
  local pname="$1"; shift
  local dry_run=${1:-false}
  if $dry_run; then
    log_info "[dry-run] Would attempt to restart process: $pname"
    return 0
  fi
  # This is intentionally generic: real projects should supply restart commands
  if command -v systemctl >/dev/null 2>&1; then
    log_info "Restarting service via systemctl: $pname"
    systemctl restart "$pname" || log_error "systemctl restart failed for $pname"
  else
    log_warn "No systemctl available; can't restart $pname automatically"
    return 2
  fi
}

check_processes_all() {
  local dry_run=${1:-false}
  # read process list from SETTINGS_PROCESSES if set
  if [[ -z "${SETTINGS_PROCESSES-}" ]]; then
    log_info "No processes configured to monitor"
    return 0
  fi
  IFS=',' read -ra procs <<< "$SETTINGS_PROCESSES"
  for p in "${procs[@]}"; do
    ptrim=$(echo "$p" | xargs)
    if ! check_process "$ptrim"; then
      log_warn "Process $ptrim failure detected"
      restart_process "$ptrim" "$dry_run"
    fi
  done
}
