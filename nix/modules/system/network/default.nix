{ config, lib, pkgs, ... }: {
	networking.networkmanager.enable = true;

	# A wake-<name> command for every fleet machine that records a mac in
	# facts.nix. WOL magic packets are a LAN broadcast, so they only work from a
	# machine that is already home - from outside, ssh through one that is.
	environment.systemPackages = lib.mapAttrsToList
		(name: machine: pkgs.writeShellScriptBin "wake-${name}" ''
			exec ${pkgs.wakeonlan}/bin/wakeonlan ${machine.mac}
		'')
		(lib.filterAttrs
			(name: machine: machine ? mac && name != config.networking.hostName)
			(import ../../../facts.nix).hosts);
	# iwd instead of wpa_supplicant: impala drives iwd over D-Bus.
	networking.networkmanager.wifi.backend = "iwd";
	networking.wireless.iwd.enable = true;

	# Wifi starts soft-blocked on every boot regardless of what the last session
	# left behind (there is no NixOS option for radio power state). `nmcli radio
	# wifi on` (or `rfkill unblock wlan`) turns it on; impala then connects as
	# usual. Runs before NetworkManager so the radio never comes up connected
	# first.
	systemd.services.wifi-off-at-boot = {
		description = "Soft-block wifi at boot";
		wantedBy = [ "multi-user.target" ];
		before = [ "NetworkManager.service" ];
		serviceConfig = {
			Type = "oneshot";
			ExecStart = "${pkgs.util-linux}/bin/rfkill block wlan";
		};
	};
	services.openssh = {
		enable = true;
		settings = {
			PasswordAuthentication = false;
			KbdInteractiveAuthentication = false;
		};
	};
	services.tailscale = {
		enable = true;
		openFirewall = true;
		useRoutingFeatures = lib.mkDefault "client";
	};
}
