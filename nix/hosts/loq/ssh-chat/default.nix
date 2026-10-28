{ ... }:

{
	imports = [ ../../../modules/system/ssh-chat ];

	dotfiles.ssh-chat = {
		port = 14159;
		admins = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN39JLlSkaHxZ6EjJmxU5NFNGFnDOJnCkQd3ouIWLkwB vladyslav@loq"
		];
	};
}
