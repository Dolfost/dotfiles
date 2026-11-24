# AI coding agents: herdr (the multiplexer that tracks them), Claude Code,
# Pi, and Hermes talking to DeepSeek on DeepInfra. Always on, like the shell.
#
# The DeepInfra key lives in sops (deepinfra_api_key) and reaches Hermes
# through the hermes.env template rendered on the host side
# (modules/system/agents). Standalone homes have no sops, so there the
# key goes into ~/.hermes/.env by hand.
{ osConfig ? { }, config, lib, pkgs, inputs, ... }:

let
	link = config.lib.dotfiles.link;
	system = pkgs.stdenv.hostPlatform.system;
	unstable = import inputs.nixpkgs-unstable {
		inherit system;
		config.allowUnfree = true;
	};
	hermesEnv = osConfig.sops.templates."hermes.env".path or null;
	# Hosts with the Android tooling (modules/system/android: adb, a phone or
	# an emulator to drive). Maestro brings a JDK, so not the others.
	android = osConfig ? dotfiles && osConfig.dotfiles ? android;
in
{
	imports = [ inputs.hermes-agent.homeManagerModules.default ];

	home.packages = [
		inputs.herdr.packages.${system}.default
		inputs.pi.packages.${system}.default
	] ++ lib.optionals android [
		pkgs.maestro # by hand too: `maestro test`, `maestro studio`
	];

	# Claude Code, through the module only for what it wraps around the
	# package: its MCP servers go in as a plugin (`--plugin-dir`), since the
	# user-scope ones live in ~/.claude.json, which is state. Nothing else of
	# the module is set, so ~/.claude/settings.json stays a file of ours.
	#
	# maestro (docs.maestro.dev/get-started/maestro-mcp): the Android app on
	# whatever `adb devices` lists, for a session to look at and drive (the
	# screen, its view hierarchy, flows). `/mcp` in a session shows it.
	programs.claude-code = {
		enable = true;
		package = unstable.claude-code;
		mcpServers = lib.optionalAttrs android {
			maestro = { type = "stdio"; command = "${pkgs.maestro}/bin/maestro"; args = [ "mcp" ]; };
		};
	};

	# Only the file: ~/.config/herdr also holds sockets, logs and session
	# state that don't belong in the repo.
	xdg.configFile."herdr/config.toml" = link "herdr/config.toml";

	# Claude Code's personal skills, one link per skill: ~/.claude/skills
	# also holds what claude.ai syncs down (synced/), which is not ours.
	# notify tells every session how to reach the phone (`ntfy-cmd claude`,
	# modules/system/ntfy).
	home.file.".claude/skills/notify" = link "claude/skills/notify";
	# music takes an album from Soulseek into the library on aorus, with the
	# commands of modules/user/music.
	home.file.".claude/skills/music" = link "claude/skills/music";

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
