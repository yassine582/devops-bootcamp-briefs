#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/logger.sh"

check_service() {
  local sname="$1"
  if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet "$sname"; then
      log_info "Service $sname is active"
      return 0
    else
      log_warn "Service $sname is not active"
      return 1
    fi
  else
    log_warn "systemctl not available; cannot check service $sname"
    return 2
  fi
}

restart_service() {
  local sname="$1"; shift
  local dry_run=${1:-false}
  if $dry_run; then
    log_info "[dry-run] Would restart service $sname"
    return 0
  fi
  if command -v systemctl >/dev/null 2>&1; then
    systemctl restart "$sname" && log_info "Restarted $sname" || log_error "Failed restart for $sname"
  else
    log_warn "systemctl not available; cannot restart $sname"
  fi
}

check_services_all() {
  local dry_run=${1:-false}
  if [[ -z "${SETTINGS_SERVICES-}" ]]; then
    log_info "No services configured to monitor"
    return 0
  fi
  IFS=',' read -ra svcs <<< "$SETTINGS_SERVICES"
  for s in "${svcs[@]}"; do
    strim=$(echo "$s" | xargs)
    if ! check_service "$strim"; then
      restart_service "$strim" "$dry_run"
    fi
  done
}
