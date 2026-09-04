# The one human account these machines are built around.
#
# Exists so nothing else has to name it: modules and hosts read
# config.dotfiles.user instead of hardcoding a login name.
{ config, lib, pkgs, ... }:

let
	user = config.dotfiles.user;
in
{
	options.dotfiles.user = lib.mkOption {
		type = lib.types.str;
		default = "vladyslav";
		description = "Login name of the primary account.";
	};

	config = {
		# uid and PRIMARY gid are pinned to match the Arch install on this
		# machine. NixOS would otherwise put a normal user in `users`
		# (gid 100), and that breaks rootless containers on shared storage.
		users.groups.${user}.gid = 1000;
		users.users.${user} = {
			isNormalUser = true;
			uid = 1000;
			group = user;
			# `users` is kept so files already written under gid 100 stay reachable.
			# NixOS patches iwd's D-Bus policy to allow `wheel` (not the upstream
			# `netdev`), so impala works without root via wheel membership.
			extraGroups = [ "users" "wheel" "networkmanager" ];
			shell = pkgs.zsh;
		};
		programs.zsh.enable = true;
	};
}
