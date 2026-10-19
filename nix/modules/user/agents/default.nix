# AI coding agents: herdr (the multiplexer that tracks them), Claude Code,
# and Hermes talking to DeepSeek on DeepInfra. Always on, like the shell.
#
# The DeepInfra key lives in sops (deepinfra_api_key) and reaches Hermes
# through the hermes.env template rendered on the host side
# (modules/system/agents). Standalone homes have no sops, so there the
# key goes into ~/.hermes/.env by hand.
{ osConfig ? { }, config, pkgs, inputs, ... }:

let
	link = config.lib.dotfiles.link;
	system = pkgs.stdenv.hostPlatform.system;
	unstable = import inputs.nixpkgs-unstable {
		inherit system;
		config.allowUnfree = true;
	};
	hermesEnv = osConfig.sops.templates."hermes.env".path or null;
in
{
	imports = [ inputs.hermes-agent.homeManagerModules.default ];

	home.packages = [
		inputs.herdr.packages.${system}.default
		unstable.claude-code
	];

	# Only the file: ~/.config/herdr also holds sockets, logs and session
	# state that don't belong in the repo.
	xdg.configFile."herdr/config.toml" = link "herdr/config.toml";

	programs.hermes-agent.enable = true;
	services.hermes-agent = {
		enable = true;
		settings.model = {
			provider = "deepinfra";
			# Not the bare "DeepSeek-V4-Flash" alias: on DeepInfra it answers
			# Hermes's tools + system prompt with a bogus 429 "Model busy",
			# while every dated/other DeepSeek id takes the same request.
			default = "deepseek-ai/DeepSeek-V4.1-Flash";
		};
		environmentFiles = if hermesEnv != null then [ hermesEnv ] else [ ];
	};
}
