# Host half of the agents setup: the DeepInfra key out of sops, rendered into
# the env file Hermes reads (home side: modules/user/agents).
#
#   sops nix/secrets.yaml   ->   deepinfra_api_key: <key>
{ config, ... }:

let
	user = config.dotfiles.user;
in
{
	sops.secrets.deepinfra_api_key = { owner = user; };
	sops.templates."hermes.env" = {
		owner = user;
		# Plain string: '' would keep the tab indentation (it only strips
		# spaces) and the env line would start with tabs.
		content = "DEEPINFRA_API_KEY=${config.sops.placeholder.deepinfra_api_key}\n";
	};
}
