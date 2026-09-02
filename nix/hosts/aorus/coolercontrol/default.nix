# deliberately a copy of
{ config, lib, ... }:

{
	programs.coolercontrol.enable = true;

	boot.kernelParams = [ "amdgpu.ppfeaturemask=0xFFF7FFFF" ];

	# The motherboard: the IT8622E behind this Gigabyte board's
	# fan headers (AIO
	boot.extraModulePackages = [ config.boot.kernelPackages.it87 ];
	boot.kernelModules = [ "it87" ];
	boot.extraModprobeConfig = ''
		options it87 ignore_resource_conflict=1 force_id=0x8622
	'';

	environment.etc = lib.genAttrs [
		"coolercontrol/config.toml"
		"coolercontrol/config-ui.json"
		"coolercontrol/alerts.json"
		"coolercontrol/calibrations.json"
		"coolercontrol/modes.json"
	] (name: {
		source = "${config.users.users.${config.dotfiles.user}.home}/dotfiles/nix/hosts/aorus/${name}";
	});
}
