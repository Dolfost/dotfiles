# stickpile client: the `stickpile` CLI and the stickpile-desktop quick-search
# popup (github.com/Dolfost/stickpile; the server is
# hosts/aorus/services/stickpile.nix). Wraps the flake's own home-manager
# module, which writes ~/.config/stickpile/config.toml (checked with
# `stickpile config check` at build time) and runs the popup as a hidden,
# resident user unit: on Wayland the app that copied serves the clipboard, so
# it has to outlive the popup.
#
# The token is not managed here. `stickpile login` writes it once per machine
# to ~/.local/state/stickpile/token. On a tailnet device it needs no password
# (the serve proxy says who you are); a tagged node such as aorus is never
# identified by tailscale, so it logs in with a password instead.
{ config, lib, inputs, ... }:

let
	facts = import ../../../facts.nix;
in
{
	imports = [ inputs.stickpile.homeManagerModules.default ];

	options.dotfiles.stickpile.enable =
		lib.mkEnableOption "the stickpile client (CLI and quick-search popup)";

	config = lib.mkIf config.dotfiles.stickpile.enable {
		programs.stickpile = {
			enable = true;
			desktop.enable = true;
			settings.server_url = lib.mkDefault "https://stickpile.${facts.ts_network}";
		};

		# SUPER + ; toggles the popup: a second stickpile-desktop hands its
		# command to the resident instance over D-Bus and exits. It reads the
		# focused window before the popup appears, so it knows the chat app it
		# copies for. Bound here rather than in hypr/input.lua so hosts without
		# the client get no dead key.
		dotfiles.hyprland.localConfig = ''
			hl.bind('SUPER + semicolon', hl.dsp.exec_cmd('stickpile-desktop'))
			hl.window_rule {
				name = 'stickpile-popup',
				match = { class = '^io\\.github\\.dolfost\\.Stickpile$' },
				float = true,
				center = true,
			}
		'';
	};
}
