# Services aorus hosts: rootless podman quadlets, and the tailscale serve
# proxies that expose them on the tailnet. One file per service; this one
# is the plumbing they share.
{ config, lib, ... }:

let
	inherit (lib) mapAttrs' nameValuePair;

	mkServe = name: cfg:
	let
		mode = if cfg ? tcp
			then "--tcp=${toString cfg.tcp}"
			else "--https=443";
		port = if cfg ? scheme
			then "${cfg.scheme}://127.0.0.1:${toString cfg.port}"
			else toString cfg.port;
	in nameValuePair "tailscale-serve-${name}" {
		description = "tailscale serve: svc:${name} ${mode} -> ${port}";
		after = [ "tailscaled.service" ];
		wants = [ "tailscaled.service" ];
		wantedBy = [ "multi-user.target" ];
		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = true;
			Restart = "on-failure";
			RestartSec = 15;
			ExecStart = "${config.services.tailscale.package}/bin/tailscale "
				+ "serve --yes --service=svc:${name} ${mode} ${port}";
		};
		unitConfig.StartLimitIntervalSec = 0;
	};
in
{
	imports = [
		./jellyfin.nix
		./navidrome.nix
		./immich.nix
		./paperless.nix
		./gitea.nix
		./gitlab.nix
		./crafty.nix
		./nicotine.nix
		./pihole.nix
	];

	options.dotfiles.serve = lib.mkOption {
		type = lib.types.attrsOf lib.types.attrs;
		default = { };
		description = ''
			svc:<name> -> localhost:<port>. Default is an HTTPS proxy on 443
			to a plain HTTP backend. Two escape hatches:
			  tcp    = <port>   raw TCP forward instead of HTTPS (minecraft)
			  scheme = "..."    backend is not plain http (crafty serves
			                    self-signed TLS, so it needs https+insecure)
		'';
	};

	config = {
		virtualisation.podman.enable = true;
		users.users.${config.dotfiles.user}.linger = true;

		# Quadlets that declare After=network-online.target make podman
		# generate a podman-user-wait-network-online.service that polls until
		# that target is active. Nothing pulls the target in by default, so
		# it never activates and every container unit sits in the job queue
		# until the poller times out. Wanting it here pulls in
		# NetworkManager-wait-online, which activates it.
		systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

		systemd.services = mapAttrs' mkServe config.dotfiles.serve;

		home-manager.users.${config.dotfiles.user} = { config, ... }: {
			xdg.configFile."containers/systemd".source =
				config.lib.file.mkOutOfStoreSymlink
					"${config.dotfiles.dir}/containers/systemd";
		};
	};
}
