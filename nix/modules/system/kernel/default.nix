{ lib, pkgs, ... }: {
	boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;
	boot.kernelParams = [ "consoleblank=120" ];
}
