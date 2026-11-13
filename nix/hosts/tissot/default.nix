# The Mi A1 (tissot), as a NixOS container. The phone itself runs
# postmarketOS (see ../../../pmos: no mobile-nixos port exists for its SoC);
# this system is a systemd-nspawn guest on it, sharing the host's network
# namespace, and owns the services: ntfy, Pi-hole, Syncthing, Tailscale and
# the Bluetooth NUT server for the EcoFlow. The host side keeps what needs
# the kernel: USB host mode, NetworkManager, BlueZ, its own sshd on :22.
#
# Rebuild from any machine with this checkout: pmos/bin/tissot-rebuild
# (rsyncs the tree into the guest and runs nixos-rebuild there, so the
# aarch64 closure comes from the cache natively). First install:
#   nix build .#nixosConfigurations.tissot.config.system.build.tarball
#   machinectl import-tar <tarball> nixos && machinectl start nixos
{ pkgs, modulesPath, ... }:

{
	imports = [
		# What this machine is.
		"${modulesPath}/virtualisation/lxc-container.nix"
		./ssh
		./services
		./tailscale
		./power
		./syncthing
		./storage

		# The shared baseline, minus everything that assumes a real machine.
		../../modules/system/dotfiles
		../../modules/system/user
		../../modules/system/locale
		../../modules/system/nix
		../../modules/system/ntfy
	];

	nixpkgs.hostPlatform = "aarch64-linux";
	# Builds happen in here (pmos/bin/tissot-rebuild); an nspawn guest cannot
	# create the namespaces Nix's build sandbox wants.
	nix.settings.sandbox = false;
	# Unsandboxed, logrotate's build-time check stats the guest's real log
	# files and fails on the ones it can't read (Pi-hole's 0700 /var/log/pihole).
	services.logrotate.checkConfig = false;

	# Host network namespace (Private=no in the .nspawn unit): no veth, no
	# DHCP, the host's interfaces are ours. DNS is the Pi-hole (services/),
	# which the host uses too (its own resolver is off, pmos/etc).
	networking.useDHCP = false;
	networking.useHostResolvConf = false;
	networking.nameservers = [ "127.0.0.1" ];
	networking.firewall.enable = false;
	# The host keeps the clock; a guest without CAP_SYS_TIME only logs errors.
	services.timesyncd.enable = false;

	# Secrets: the guest has its own sops file and its own age key (no ssh host
	# key to derive one from); see .sops.yaml. The entries are declared where
	# they are used (power/).
	sops.defaultSopsFile = ../../secrets-tissot.yaml;
	sops.age.keyFile = "/var/lib/sops-nix/key.txt";
	sops.age.sshKeyPaths = [ ];

	environment.systemPackages = with pkgs; [
		git # the checkout under /home/vladyslav/dotfiles is a flake
	];

	# `ntfy-cmd TOPIC MESSAGE` from here too (modules/system/ntfy).
	dotfiles.ntfy.enable = true;

	system.stateVersion = "26.05";
}
