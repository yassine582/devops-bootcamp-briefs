#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/logger.sh"

check_ping() {
  local host="$1"
  if ping -c 2 -W 2 "$host" >/dev/null 2>&1; then
    log_info "Ping to $host OK"
    return 0
  else
    log_warn "Ping to $host FAILED"
    return 1
  fi
}

check_dns() {
  local host="$1"
  if getent hosts "$host" >/dev/null 2>&1; then
    log_info "DNS resolution for $host OK"
    return 0
  else
    log_warn "DNS resolution for $host FAILED"
    return 1
  fi
}

check_network_all() {
  local dry_run=${1:-false}
  if [[ -z "${SETTINGS_NETWORK_HOSTS-}" ]]; then
    log_info "No network hosts configured to monitor"
    return 0
  fi
  IFS=',' read -ra hosts <<< "$SETTINGS_NETWORK_HOSTS"
  for h in "${hosts[@]}"; do
    htrim=$(echo "$h" | xargs)
    check_dns "$htrim" || check_ping "$htrim" || log_warn "Network issue detected for $htrim"
  done
}
