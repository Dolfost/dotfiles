# Sleep and battery for a laptop. The rule: on the charger it never sleeps by
# itself - lid closed or idle changes nothing - and only the power key puts it
# to sleep. On battery it sleeps on lid close and after half an hour idle (the
# listener in hypr/hypridle.conf, which checks the AC state itself). Sleep is
# suspend-then-hibernate: RAM first, and after HibernateDelaySec it writes to
# the swap partition and powers off, so a forgotten lid does not drain the
# battery. Resume needs boot.resumeDevice, taken from the first swap device.
#
# NVIDIA: the driver's suspend/resume units save video memory across sleep;
# without them hybrid laptops come back to a black screen. Fine-grained runtime
# power management (dGPU off when idle) is left out - it needs PRIME offload
# bus ids, per-host tuning not done yet.
#
# Battery: Lenovo's conservation mode caps the charge around 60% for a machine
# that lives on the charger; `conserve off` before a trip, `conserve on` after.
{ config, lib, pkgs, ... }:

let
swap = lib.findFirst (sd: sd ? device) null config.swapDevices;
ideapad = "/sys/bus/platform/devices/VPC2004:00/conservation_mode";
in
{
	assertions = [{
		assertion = swap != null;
		message = "modules/system/laptop: suspend-then-hibernate needs a swap partition in swapDevices.";
	}];

	boot.resumeDevice = lib.mkDefault swap.device;
	systemd.sleep.settings.Sleep.HibernateDelaySec = "2h";

	services.logind.settings.Login = {
		HandleLidSwitch = "suspend-then-hibernate";
		HandleLidSwitchExternalPower = "ignore";
		HandleLidSwitchDocked = "ignore";
		HandlePowerKey = "suspend-then-hibernate";
		HandlePowerKeyLongPress = "poweroff";
	};

	hardware.nvidia.powerManagement.enable =
		lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers) true;

# The attribute appears when ideapad_acpi binds, hence bind as well as add.
	services.udev.extraRules = ''
		ACTION=="add|bind", SUBSYSTEM=="platform", KERNEL=="VPC2004:00", ATTR{conservation_mode}="1"
		'';
	environment.systemPackages = [
		(pkgs.writeShellScriptBin "conserve" ''
		 case "''${1:-status}" in
		 on)  echo 1 | sudo tee ${ideapad} >/dev/null ;;
	off) echo 0 | sudo tee ${ideapad} >/dev/null ;;
	status) ;;
	*) echo "usage: conserve [on|off|status]" >&2; exit 2 ;;
	esac
		 case "$(cat ${ideapad})" in
		1) echo "conservation mode on: charge capped" ;;
		0) echo "conservation mode off: full charge" ;;
		esac
			'')
	];
}
