# NVIDIA GPU: proprietary driver (modesetting on, open kernel modules - right
# for Turing and newer) plus an NVML-enabled btop, hiPrio shadowing the
# baseline btop like amd-gpu's btop-rocm. PRIME offload bus IDs are per-host
# tuning once the host is installed.
{ lib, pkgs, ... }:

{
	services.xserver.videoDrivers = [ "nvidia" ];
	hardware.nvidia = {
		modesetting.enable = true;
		open = true;
	};

	environment.systemPackages = [ (lib.hiPrio pkgs.btop-cuda) ];
}
