# Hosts only this machine cares about: the lab, reachable from the office LAN
# (10.10.200.x is wifi, 192.168.144.x the wired robot network). Merges into the
# fleet-wide config from modules/user/ssh.
{ config, ... }:

{
	home-manager.users.${config.dotfiles.user}.programs.ssh.settings = {
		"gitlab.priv.prod.app35.org.ua/ter/auf" = {
			HostName = "gitlab.priv.prod.app35.org.ua/ter/auf";
			User = "git";
			Port = 22;
			IdentityFile = "~/.ssh/lab35-bitbucket";
		};
		"mlpc" = {
			HostName = "10.10.200.48";
			User = "lab35";
			IdentityFile = "~/.ssh/lab35-ml";
		};
		"lloq" = {
			HostName = "10.10.200.56";
			IdentityFile = "~/.ssh/home";
		};
		"zbook" = {
			HostName = "10.10.200.72";
			User = "dolf";
			IdentityFile = "~/.ssh/lab35-ml";
		};
		"jet" = {
			HostName = "192.168.144.30";
			User = "jetson";
			IdentityFile = "~/.ssh/lab35-ml";
		};
		"jetw" = {
			HostName = "10.10.200.80";
			User = "jetson";
			IdentityFile = "~/.ssh/lab35-ml";
		};
		"jet2w" = {
			HostName = "10.10.200.61";
			User = "jetson";
			IdentityFile = "~/.ssh/lab35-ml";
		};
		"raspw" = {
			HostName = "10.10.200.95";
			User = "admin";
			IdentityFile = "~/.ssh/lab35-rasp";
		};
		"drone" = {
			HostName = "192.168.144.22";
			User = "admin";
			IdentityFile = "~/.ssh/lab35-rasp";
		};
	};
}
