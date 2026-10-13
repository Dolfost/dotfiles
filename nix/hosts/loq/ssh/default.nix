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
		};
		"jet1" = {
			HostName = "192.168.144.231";
			User = "jetson";
		};
		"jet2" = {
			HostName = "192.168.144.30";
			User = "jetson";
		};
		"jet_default" = {
			HostName = "192.168.144.222";
			User = "jetson";
		};
		"rpi1" = {
			HostName = "192.168.144.70";
			User = "pi";
		};
		"rpi2" = {
			HostName = "192.168.144.31";
			User = "pi";
		};
		"192.168.144.*" = {
			IdentityFile = "~/.ssh/lab35-ml";
		};
	};
}
