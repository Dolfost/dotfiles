# CoolerControl config

Version-controlled copy of `/etc/coolercontrol/` (fan curves, profiles, modes,
UI layout). CoolerControl is **not** containerized — it's a root daemon that
writes hardware sysfs (`/sys/class/hwmon/*/pwm*`), which doesn't belong in a
container. The portable artifact is this config, not the daemon.

## What's here (non-secret, world-readable, copied without sudo)

- `config.toml` — devices, fan curves / speed profiles (the important one)
- `config-ui.json` — web UI layout
- `alerts.json`, `calibrations.json`, `modes.json`

## Deliberately excluded (host-specific secrets, see `.gitignore`)

- `.passwd` — admin password hash
- `coolercontrol.key` / `coolercontrol.crt` — TLS pair

CoolerControl regenerates the TLS pair and prompts for a new password on a fresh
machine, so these don't need to travel.

## Refresh this copy after changing settings

```sh
cp /etc/coolercontrol/{config.toml,config-ui.json,alerts.json,calibrations.json,modes.json} \
   ~/dotfiles/etc/coolercontrol/
```

## Restore on a new machine (e.g. NixOS)

Install CoolerControl (NixOS: `programs.coolercontrol.enable = true`), stop the
daemon, drop these files into `/etc/coolercontrol/`, then start it. Fan curves
reference devices by name/hwmon path — if hardware differs, re-check the
profiles in the UI.
