# Jellyfin: media streaming.
{ config, ... }:

{
	dotfiles.serve.jellyfin.port = 8096;

	home-manager.users.${config.dotfiles.user}.xdg.configFile
		."systemd/user/jellyfin.service.d/env.conf".text = ''
[Service]
Environment=JELLYFIN_DIR=/storage/2.5/media/jellyfin
Environment=JELLYFIN_MOVIES=/storage/2.5/media/movies
Environment=JELLYFIN_SHOWS=/storage/2.5/media/shows
Environment=JELLYFIN_SHOWS_HDD=/storage/3.5/media/shows
Environment=JELLYFIN_MUSIC=/storage/2.5/media/music
Environment=JELLYFIN_BOOKS=/storage/2.5/media/books
'';
}
