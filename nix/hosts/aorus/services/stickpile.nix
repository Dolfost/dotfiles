# stickpile: sticker and meme library (github.com/Dolfost/stickpile), a
# rootless quadlet like the others; containers/systemd/stickpile.container is
# a copy of deploy/quadlet/stickpile.container from its repo. State is on the
# NVMe: SQLite plus sticker media is small and read often, and the 2.5" HDD
# should be left to spin down.
#
# Unlike the other services the tailnet proxy does not target a TCP port but
# the server's trusted unix socket, $STICKPILE_DIR/tailscale.sock: only there
# does stickpile trust the Tailscale-User-Login header and log tailnet users
# in without a password. A loopback port cannot be trusted that way with
# rootless podman, since every local user can reach it - hence the `unix`
# escape hatch in mkServe (default.nix).
#
# `tailscale serve --service=svc:...` does forward the identity headers
# (stickpile docs/plan.md, question 2; seen 2026-11-12: the first visit from
# the mac created that tailnet login's account). Requests from tagged nodes,
# aorus itself included, carry no identity.
{ config, ... }:

let
	stickpileDir = "/storage/data/stickpile";
in
{
	dotfiles.serve.stickpile.unix = "${stickpileDir}/tailscale.sock";

	# Bot token for publishing sets as Telegram sticker packs (config.toml
	# [telegram] bot_token_file = "/run/secrets/telegram-bot-token"). Owned by
	# you, which keep-id maps to the server's uid in the container. Restart
	# stickpile after changing it: the container keeps the file it mounted.
	sops.secrets."stickpile/telegram_bot_token".owner = config.dotfiles.user;

	home-manager.users.${config.dotfiles.user} = {
		# All state, config.toml and secrets/ live under $STICKPILE_DIR (layout in
		# the quadlet). Files there are owned by you (UserNS=keep-id). The
		# Telegram token is the exception, see above.
		xdg.configFile."systemd/user/stickpile.service.d/env.conf".text = ''
[Service]
Environment=STICKPILE_DIR=${stickpileDir}
Environment=STICKPILE_TELEGRAM_TOKEN=${config.sops.secrets."stickpile/telegram_bot_token".path}
'';

		# The client on the same box talks to the server over loopback: no
		# dependency on tailscaled, and the tailnet would not identify this
		# tagged node anyway, so it needs a token either way.
		dotfiles.stickpile.enable = true;
		programs.stickpile.settings.server_url = "http://127.0.0.1:8080";
	};
}
