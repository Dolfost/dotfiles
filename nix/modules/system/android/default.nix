# Android tooling: adb/fastboot and scrcpy screen mirroring. Device access is
# handled by systemd's uaccess rules, no adbusers group needed.
{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		android-tools # adb + fastboot
		scrcpy
	];
}
