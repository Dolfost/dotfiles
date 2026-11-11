# tissot (Xiaomi Mi A1) on postmarketOS

Always-on box on the EcoFlow: NUT server over Bluetooth, ntfy, Pi-hole,
Syncthing. Those run in a NixOS guest (`nix/hosts/tissot`, a systemd-nspawn
container from the flake); the phone itself is postmarketOS, because
mobile-nixos has no port for its SoC (msm8953). This directory is the
postmarketOS side: a few units and config files, nothing Nix.

- Image: generic `qcom-msm8953` port, v26.06, systemd, console UI, built
  with pmbootstrap (in a Lima VM on the mac: `limactl shell pmos`), flashed
  from stock or lk2nd fastboot: lk2nd to `boot_a` and `boot_b`, the rootfs
  to `userdata`. The Wi-Fi profile and the ssh key are baked into the
  image.
- Power: no battery. The 2x4 battery connector (rows are mirrors) is
  labelled GND, +, -, VBAT; the real positive is `+` (bulk caps behind it),
  `-` is the thermistor pull-up, `VBAT` is a sense line. Supply on `+` and
  GND (both rows), 10 kΩ from `-` to GND, VBAT open. Boots at 4.0 V with a
  4 A limit (3 A trips on the kernel's spike); runs from the EcoFlow's 5 V
  too, which the PMIC sees as 4.7 V with health "Good", though 4.x is the
  designed range. USB-C is data only: the charger input is suspended
  whenever the port is a host, and VBUS makes the kernel flip the role back
  to device, hence tissot-usb-host.service re-asserts host in a loop.
- USB: UGREEN CM473 hub on a hand-made USB-A female to Type-C male lead
  (VBUS wire not needed, the hub runs on its own 5 V input), Hoco RTL8153
  gigabit dongle behind it (`linux-firmware-rtl_nic` for its patch).
- Guest: `etc/systemd/nspawn/nixos.nspawn` (host network namespace, host
  D-Bus bound in for BlueZ). Guest sshd is on :2222, the host's on :22.
- Scripts: `bin/tissot-deploy` rsyncs `etc/` to the phone and enables the
  units in it; `bin/tissot-rebuild` rebuilds the NixOS guest from this
  checkout.
- Host extras installed by hand: bluez,
  linux-firmware-rtl_nic, rsync.
