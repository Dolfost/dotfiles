# AMD GPU control: lact's daemon drives clocks, power caps, and fan curves; the
# GUI talks to it. Per-host tuning is nix/hosts/<host>/lact.
{ lib, pkgs, ... }:

{
	services.lact.enable = true;
	boot.kernelParams = [ "amdgpu.ppfeaturemask=0xFFF7FFFF" ];

	# btop only sees AMD GPUs when built against ROCm's SMI library. Shadow the
	# baseline btop with the rocm build (hiPrio wins the bin/btop collision) so
	# the GPU panel works on AMD hosts.
	environment.systemPackages = [ (lib.hiPrio pkgs.btop-rocm) ];
}
