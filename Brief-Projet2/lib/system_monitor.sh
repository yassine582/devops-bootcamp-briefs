#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/logger.sh"

check_cpu() {
  local warn=${THRESHOLD_CPU_WARN:-75}
  # Use 1-minute load average as a lightweight proxy
  local load
  load=$(awk '{print $1}' /proc/loadavg)
  # normalize by cores
  local cores
  cores=$(nproc || echo 1)
  local load_pct
  load_pct=$(awk -v l="$load" -v c="$cores" 'BEGIN{printf "%d", (l/c)*100}')
  if (( load_pct >= warn )); then
    log_warn "High CPU: ${load_pct}% (threshold ${warn}%)"
    return 1
  else
    log_info "CPU OK: ${load_pct}%"
    return 0
  fi
}

check_memory() {
  local warn=${THRESHOLD_MEM_WARN:-80}
  local used_pct
  if command -v free >/dev/null 2>&1; then
    used_pct=$(free | awk '/Mem:/ {printf "%d", $3/$2*100}')
  elif [[ -r /proc/meminfo ]]; then
    # Fallback: calculate from /proc/meminfo
    local mem_total mem_free mem_available mem_used
    mem_total=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
    mem_available=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo || echo 0)
    if [[ "$mem_available" -gt 0 ]]; then
      mem_used=$((mem_total - mem_available))
      used_pct=$(( mem_used * 100 / mem_total ))
    else
      # If MemAvailable not present, try MemFree+Buffers+Cached
      local memfree buffers cached
      memfree=$(awk '/MemFree:/ {print $2}' /proc/meminfo)
      buffers=$(awk '/Buffers:/ {print $2}' /proc/meminfo)
      cached=$(awk '/^Cached:/ {print $2}' /proc/meminfo)
      mem_used=$(( mem_total - (memfree + buffers + cached) ))
      used_pct=$(( mem_used * 100 / mem_total ))
    fi
  else
    log_warn "Unable to determine memory usage (no free and /proc/meminfo missing)"
    return 2
  fi
  if (( used_pct >= warn )); then
    log_warn "High memory usage: ${used_pct}% (threshold ${warn}%)"
    return 1
  else
    log_info "Memory OK: ${used_pct}%"
    return 0
  fi
}

check_disk() {
  local warn=${THRESHOLD_DISK_WARN:-85}
  local failures=0
  while read -r pct mount; do
    pct=${pct%%%}
    if (( pct >= warn )); then
      log_warn "Disk ${mount} usage high: ${pct}% (threshold ${warn}%)"
      failures=$((failures+1))
    else
      log_info "Disk ${mount} OK: ${pct}%"
    fi
  done < <(df -h --output=pcent,target | tail -n +2)
  if (( failures > 0 )); then
    return 1
  fi
  return 0
}

check_system_all() {
  local dry_run=${1:-false}
  check_cpu || true
  check_memory || true
  check_disk || true
}
