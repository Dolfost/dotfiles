# Guest sshd beside the host's: :2222, keys only. Each machine's own
# ~/.ssh/home (`ssh tissot-nix` from the fleet ssh config; the host's own
# sshd stays on :22).
{ ... }:

{
	services.openssh = {
		enable = true;
		ports = [ 2222 ];
		startWhenNeeded = false;
		settings.PasswordAuthentication = false;
	};
	users.users.vladyslav.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxCmHMkYs/GMwP/uZ464oE5l9Y8PfNOT7BmAAPXgzA6 vladyslav@daorus"
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKqafb6cQTxh5pBB0PIMA5EV2DvA+PIZmo1ce4Nia72Z vladyslav@dmac.local"
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN39JLlSkaHxZ6EjJmxU5NFNGFnDOJnCkQd3ouIWLkwB vladyslav@loq"
	];
	# pmos/bin/tissot-rebuild and friends come in over ssh and sudo.
	security.sudo.wheelNeedsPassword = false;
}
