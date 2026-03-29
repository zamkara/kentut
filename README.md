# kentut

Small systemd timer/service to drop Linux page cache when RAM usage crosses a configurable threshold.

## What it does

- Checks `MemTotal` and `MemAvailable` from `/proc/meminfo`
- Computes used RAM percentage
- Runs `sync` and `echo 3 > /proc/sys/vm/drop_caches` when the threshold is reached
- Applies a cooldown to avoid running too often

This is useful if you want to keep a repeatable copy of the setup outside `/etc` and `/usr/local/bin`, so you can reinstall it after a fresh OS install.

## Files

- `bin/kentut`: main command
- `systemd/kentut.service`: oneshot service
- `systemd/kentut.timer`: periodic timer
- `systemd/kentut.env`: editable configuration
- `install.sh`: install files into system locations
- `uninstall.sh`: remove installed files

## Default behavior

- Threshold: `70%`
- Cooldown: `900` seconds
- First run: `2` minutes after boot
- Interval: every `1` minute

## Install

```bash
cd ~/Downloads/kentut
sudo ./install.sh
```

After install, you can run:

```bash
kentut
kentut -t 5m
kentut -t 5s
kentut -t 5h -m 50%
kentut -m 50
kentut --status
kentut --watch 30s --dry-run
sudo kentut --set-threshold 55
sudo kentut --enable
sudo kentut --disable
sudo kentut --force
```

## Configure

Edit:

```bash
sudo nano /etc/default/kentut
```

Available variables:

- `THRESHOLD_PCT=70`
- `COOLDOWN_SECONDS=900`
- `STATE_FILE=/run/kentut.last`

## command

- `kentut`: run immediately using current threshold
- `kentut -t 5m`: wait 5 minutes, then run the check
- `kentut -t 5s`: wait 5 seconds, then run the check
- `kentut -t 5h`: wait 5 hours, then run the check
- `kentut -m 50` or `kentut -m 50%`: use `50%` as the threshold for that run
- `kentut --force`: drop cache without checking threshold
- `kentut --dry-run`: simulate the action without writing to `drop_caches`
- `kentut --status`: print current RAM usage, threshold, cooldown, and last run
- `kentut --watch 30s`: run in a loop every 30 seconds
- `kentut --set-threshold 55`: persist threshold to `/etc/default/kentut`
- `kentut --enable`: enable and start `kentut.timer`
- `kentut --disable`: disable and stop `kentut.timer`
- `kentut --start`: start `kentut.timer`
- `kentut --stop`: stop `kentut.timer`
- `kentut --restart`: restart `kentut.timer`
- `kentut --json`: return status or update output as JSON
- `kentut --notify`: send a desktop notification when `notify-send` is available
- `kentut -h` or `kentut --help`: show English help

Notes:

- `-m` only overrides the threshold for the current command.
- The persistent threshold for the systemd service still comes from `/etc/default/kentut`.
- Dropping page cache still requires root because it writes to `/proc/sys/vm/drop_caches`.
- Running `kentut` without root can do the countdown and memory check, but if the threshold is hit it will stop and tell you to use `sudo` or the system service.
- `--set-threshold` also requires root because it edits `/etc/default/kentut`.
- `--enable`, `--disable`, `--start`, `--stop`, and `--restart` also require root because they call `systemctl` on the system timer.

Then reload and restart the timer:

```bash
sudo systemctl daemon-reload
sudo systemctl restart kentut.timer
```

## Verify

```bash
systemctl status kentut.timer
systemctl status kentut.service
journalctl -u kentut.service --no-pager
```

## Uninstall

```bash
cd ~/Downloads/kentut
sudo ./uninstall.sh
```
