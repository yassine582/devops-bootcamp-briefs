# SysMonitor-Pro

Lightweight Bash system monitor that checks CPU, memory, disk, services, processes and network. Designed as a simple project scaffold for learning Bash and system monitoring.

Quick start:

1. Make sure you run on Linux or WSL (uses /proc, systemctl, ping).
2. Run a one-shot check:

```bash
./main.sh --once
```

Configuration:
- `config/settings.conf` - contains process/service lists and interval
- `config/thresholds.conf` - CPU/memory/disk warning thresholds

Logs are written to `./logs/sysmonitor.log` by default.
