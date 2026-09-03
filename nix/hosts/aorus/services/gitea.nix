# Gitea: git hosting (web 3000, ssh 2222; tailnet serves ssh on plain 22).
{ config, ... }:

{
	dotfiles.serve.gitea = { port = 3000; ssh = 2222; };

	home-manager.users.${config.dotfiles.user}.xdg.configFile
		."systemd/user/gitea.service.d/env.conf".text = ''
[Service]
Environment=GITEA_DIR=/storage/2.5/gitea
'';
}
