# Nicotine: soulseek client, tailnet-only web UI (no serve proxy).
# NICOTINE_DOWNLOADS is /storage/data, which Arch reaches through a
# ~/data symlink - same directory on the same disk either way.
{ config, ... }:

let
	facts = import ../facts.nix;
in
{
	home-manager.users.${config.dotfiles.user} = { config, ... }: {
		xdg.configFile = {
			"containers/nicotine".source =
				config.lib.file.mkOutOfStoreSymlink
					"${config.dotfiles.dir}/containers/nicotine";
			"systemd/user/nicotine.service.d/env.conf".text = ''
[Service]
Environment=NICOTINE_DIR=/storage/2.5/nicotine
Environment=NICOTINE_DOWNLOADS=/storage/data/soulseek
Environment=NICOTINE_BIND_IP=${facts.ts_ipv4}
Environment=NICOTINE_SHARE_BOOKS=/storage/2.5/media/books
Environment=NICOTINE_SHARE_MOVIES=/storage/2.5/media/movies
Environment=NICOTINE_SHARE_MUSIC=/storage/2.5/media/music
Environment=NICOTINE_SHARE_OLD_MUSIC=/storage/2.5/media/old_music
Environment=NICOTINE_SHARE_SHOWS=/storage/2.5/media/shows
Environment=NICOTINE_SHARE_SHOWS_HDD=/storage/3.5/media/shows
'';
		};
	};
}
