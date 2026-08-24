# Services aorus hosts: rootless podman quadlets, and the tailscale serve
# proxies that expose them on the tailnet.
{ config, lib, ... }:

let
	inherit (lib) mapAttrs' nameValuePair;

	facts = import ./facts.nix;

	tailscaleServices = {
		jellyfin = 8096;
		nicotine = 8085;
		paperless = 8000;
		navidrome = 4533;
		immich = 2283;
	};

	# Immich is three units sharing one state dir, so the same drop-in is
	# generated for each rather than written out three times.
	immichDir = "/storage/2.5/media/immich";
	mkImmichDropIn = unit:
		nameValuePair "systemd/user/${unit}.service.d/env.conf" {
			text = ''
[Service]
Environment=IMMICH_DIR=${immichDir}
'';
		};
	immichDropIns = lib.listToAttrs (map mkImmichDropIn [
		"immich-server" "immich-postgres" "immich-ml"
	]);

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
			# NICOTINE_DOWNLOADS is /storage/data, which Arch reaches through a
			# ~/data symlink — same directory on the same disk either way.
			"systemd/user/nicotine.service.d/env.conf".text = ''
[Service]
Environment=NICOTINE_DIR=/storage/2.5/nicotine
Environment=NICOTINE_DOWNLOADS=/storage/data/soulseek
Environment=NICOTINE_BIND_IP=${facts.tsIp4}
Environment=NICOTINE_SHARE_BOOKS=/storage/2.5/media/books
Environment=NICOTINE_SHARE_MOVIES=/storage/2.5/media/movies
Environment=NICOTINE_SHARE_MUSIC=/storage/2.5/media/music
Environment=NICOTINE_SHARE_OLD_MUSIC=/storage/2.5/media/old_music
Environment=NICOTINE_SHARE_SHOWS=/storage/2.5/media/shows
Environment=NICOTINE_SHARE_SHOWS_HDD=/storage/3.5/media/shows
'';
			"systemd/user/navidrome.service.d/env.conf".text = ''
[Service]
Environment=NAVIDROME_DIR=/storage/2.5/media/navidrome
Environment=NAVIDROME_MUSIC=/storage/2.5/media/music
Environment=NAVIDROME_OLD_MUSIC=/storage/2.5/media/old_music
'';
			"systemd/user/paperless.service.d/env.conf".text = ''
[Service]
Environment=PAPERLESS_DIR=/storage/2.5/media/paperless
'';
		} // immichDropIns;
	};
}
