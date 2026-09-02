# Paperless: document archive.
{ config, ... }:

{
	dotfiles.serve.paperless.port = 8000;

	home-manager.users.${config.dotfiles.user}.xdg.configFile
		."systemd/user/paperless.service.d/env.conf".text = ''
[Service]
Environment=PAPERLESS_DIR=/storage/2.5/media/paperless
'';
}
