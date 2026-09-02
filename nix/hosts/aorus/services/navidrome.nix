# Navidrome: music streaming.
{ config, ... }:

{
	dotfiles.serve.navidrome.port = 4533;

	home-manager.users.${config.dotfiles.user}.xdg.configFile
		."systemd/user/navidrome.service.d/env.conf".text = ''
[Service]
Environment=NAVIDROME_DIR=/storage/2.5/media/navidrome
Environment=NAVIDROME_MUSIC=/storage/2.5/media/music
Environment=NAVIDROME_OLD_MUSIC=/storage/2.5/media/old_music
'';
}
