# AMD GPU control: lact's daemon drives clocks, power caps, and fan
# curves; the GUI talks to it. Per-host tuning is nix/hosts/<host>/lact.
{ ... }:

{
	services.lact.enable = true;
	boot.kernelParams = [ "amdgpu.ppfeaturemask=0xFFF7FFFF" ];
}
