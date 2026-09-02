# Immich: photo library. Three units share one state dir, so the same
# drop-in is generated for each rather than written out three times.
{ config, lib, ... }:

let
	immichDir = "/storage/2.5/media/immich";
	mkDropIn = unit:
		lib.nameValuePair "systemd/user/${unit}.service.d/env.conf" {
			text = ''
[Service]
Environment=IMMICH_DIR=${immichDir}
'';
		};
in
{
	dotfiles.serve.immich.port = 2283;

	home-manager.users.${config.dotfiles.user}.xdg.configFile =
		lib.listToAttrs (map mkDropIn [
			"immich-server" "immich-postgres" "immich-ml"
		]);
}
