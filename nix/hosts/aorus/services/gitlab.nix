# GitLab: the git forge (web 8929, ssh 2224; tailnet serves ssh on plain 22).
# State lives on the NVMe (/storage/data) since 2026-11-09: on the 2.5" HDD
# every start took 8 minutes and the disk could never spin down. The
# single-user tuning (puma single mode, sidekiq 10 threads, prometheus and
# kas off) lives in gitlab.rb inside that state dir, not here.
# The omnibus override points
# external_url at the tailscale hostname so clone/redirect URLs come out right
# - including ssh port 22, matching the tailnet forward rather than the
# host-side 2224 publish; nginx inside the container still listens plain http
# on 8929 for the serve proxy.
{ config, ... }:

let
	facts = import ../../../facts.nix;
in
{
	dotfiles.serve.gitlab = { port = 8929; ssh = 2224; };

	home-manager.users.${config.dotfiles.user}.xdg.configFile
		."systemd/user/gitlab.service.d/env.conf".text = ''
[Service]
Environment=GITLAB_DIR=/storage/data/gitlab
Environment="GITLAB_OMNIBUS_CONFIG=external_url 'https://gitlab.${facts.ts_network}'; nginx['listen_port'] = 8929; nginx['listen_https'] = false; gitlab_rails['gitlab_shell_ssh_port'] = 22"
'';
}
