# GitLab: the heavyweight git forge (web 8929, ssh 2224 - clear of gitea's
# 3000/2222; tailnet serves ssh on plain 22). The omnibus override points
# external_url at the tailscale hostname so clone/redirect URLs come out right
# - including ssh port 22, matching the tailnet forward rather than the
# host-side 2224 publish; nginx inside the container still listens plain http
# on 8929 for the serve proxy.
{ config, ... }:

let
	facts = import ../facts.nix;
in
{
	dotfiles.serve.gitlab = { port = 8929; ssh = 2224; };

	home-manager.users.${config.dotfiles.user}.xdg.configFile
		."systemd/user/gitlab.service.d/env.conf".text = ''
[Service]
Environment=GITLAB_DIR=/storage/2.5/gitlab
Environment="GITLAB_OMNIBUS_CONFIG=external_url 'https://gitlab.${facts.ts_network}'; nginx['listen_port'] = 8929; nginx['listen_https'] = false; gitlab_rails['gitlab_shell_ssh_port'] = 22"
'';
}
