# Hosts only this machine cares about. Merges into the fleet-wide config from
# modules/user/ssh.
{ config, ... }:

{
	home-manager.users.${config.dotfiles.user}.programs.ssh.settings = {
		# job bitbucket, reached over its tailnet address
		"100.88.230.160" = {
			User = "git";
			Port = 7999;
			IdentityFile = "~/.ssh/lab35-bitbucket";
		};
	};
}
