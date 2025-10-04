#!/usr/bin/env bash
set -euo pipefail
# main entrypoint for SysMonitor-Pro

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
CONFIG_DIR="$SCRIPT_DIR/config"

source "$LIB_DIR/logger.sh"
source "$LIB_DIR/network_utils.sh"
source "$LIB_DIR/process_manager.sh"
source "$LIB_DIR/service_checker.sh"
source "$LIB_DIR/system_monitor.sh"

source "$CONFIG_DIR/settings.conf" || true
source "$CONFIG_DIR/thresholds.conf" || true

usage() {
	cat <<EOF
Usage: $0 [--once] [--dry-run] [--interval N]

--once     Run one iteration and exit
--dry-run  Don't perform restarts or alerts, only log checks
--interval N  Override check interval (seconds)
EOF
}

ONCE=false
DRY_RUN=false
while [[ ${1:-} != "" ]]; do
	case "$1" in
		--once) ONCE=true; shift ;;
		--dry-run) DRY_RUN=true; shift ;;
		--interval) INTERVAL_OVERRIDE="$2"; shift 2 ;;
		-h|--help) usage; exit 0 ;;
		*) echo "Unknown arg: $1"; usage; exit 2 ;;
	esac
done

INTERVAL=${INTERVAL_OVERRIDE:-${CHECK_INTERVAL:-60}}

mkdir -p "$(dirname "$LOG_FILE")"

log_info "Starting SysMonitor-Pro (interval=${INTERVAL}s)"

main_loop() {
	log_info "Running health checks"
	check_system_all "$DRY_RUN"
	check_services_all "$DRY_RUN"
	check_network_all "$DRY_RUN"
	check_processes_all "$DRY_RUN"
}

if $ONCE; then
	main_loop
	log_info "Finished one-shot run"
	exit 0
fi

while true; do
	main_loop
	sleep "$INTERVAL"
done
