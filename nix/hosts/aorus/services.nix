# Services aorus hosts: rootless podman quadlets, and the tailscale serve
# proxies that expose them on the tailnet.
{ config, lib, ... }:

let
	inherit (lib) mapAttrs' nameValuePair;

	tailscaleServices = {
		jellyfin = 8096;
	};

	mkServe = name: port: nameValuePair "tailscale-serve-${name}" {
		description = "tailscale serve: svc:${name} -> localhost:${toString port}";
		after = [ "tailscaled.service" ];
		wants = [ "tailscaled.service" ];
		wantedBy = [ "multi-user.target" ];
		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = true;
			Restart = "on-failure";
			RestartSec = 15;
			ExecStart = "${config.services.tailscale.package}/bin/tailscale "
				+ "serve --yes --service=svc:${name} --https=443 ${toString port}";
		};
		unitConfig.StartLimitIntervalSec = 0;
	};
in {

	virtualisation.podman.enable = true;
	users.users.vladyslav.linger = true;

	systemd.services = mapAttrs' mkServe tailscaleServices;

	home-manager.users.vladyslav = { config, ... }:
	let
		link = path: {
			source = config.lib.file.mkOutOfStoreSymlink
				"${config.home.homeDirectory}/dotfiles/${path}";
		};
	in {
		xdg.configFile = {
			"containers/systemd" = link "containers/systemd";
			"containers/nicotine" = link "containers/nicotine";
			"systemd/user/jellyfin.service.d/env.conf".text = ''
[Service]
Environment=JELLYFIN_DIR=/storage/2.5/media/jellyfin
Environment=JELLYFIN_MOVIES=/storage/2.5/media/movies
Environment=JELLYFIN_SHOWS=/storage/2.5/media/shows
Environment=JELLYFIN_SHOWS_HDD=/storage/3.5/media/shows
Environment=JELLYFIN_MUSIC=/storage/2.5/media/music
Environment=JELLYFIN_BOOKS=/storage/2.5/media/books
'';
		};
	};
}
