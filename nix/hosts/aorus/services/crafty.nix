# Crafty: minecraft server panel. The panel serves self-signed TLS, and
# the game port is a raw TCP forward.
{ config, ... }:

{
	dotfiles.serve = {
		crafty = { port = 8443; scheme = "https+insecure"; };
		mc = { port = 25565; tcp = 25565; };
	};

	home-manager.users.${config.dotfiles.user}.xdg.configFile
		."systemd/user/crafty.service.d/env.conf".text = ''
[Service]
Environment=CRAFTY_DIR=/storage/data/crafty
'';
}
