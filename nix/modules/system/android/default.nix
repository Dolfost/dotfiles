# Android tooling: adb/fastboot and scrcpy screen mirroring. Device access is
# handled by systemd's uaccess rules, no adbusers group needed.
#
# phone-cam streams the phone's camera into the "Phone Camera" loopback device
# (../media creates it at /dev/video11). On demand only: a plugged-in phone is
# usually just charging, so nothing starts on plug. scrcpy exits when the phone
# goes away, so an idle or absent phone costs nothing.
#
#   systemctl --user start phone-cam            the configured defaults
#   systemctl --user start phone-cam@portrait   same, other orientation
#   phone-cam [portrait|landscape|...] [usb|wifi] [scrcpy args]
{ config, lib, pkgs, ... }:

let
	cfg = config.dotfiles.android.phoneCam;

	# scrcpy rotates the sensor's landscape frame clockwise by this much.
	rotation = {
		landscape = 0;
		portrait = 90;
		landscape-flipped = 180;
		portrait-flipped = 270;
	};

	phone-cam = pkgs.writeShellScriptBin "phone-cam" ''
		export ADB=${pkgs.android-tools}/bin/adb
		orientation=${cfg.orientation}
		address=${if cfg.address == null then "" else cfg.address}
		# Leading keywords override the configured defaults; the rest goes to scrcpy.
		while [ $# -gt 0 ]; do
			case "$1" in
				landscape|portrait|landscape-flipped|portrait-flipped) orientation=$1 ;;
				usb) address= ;;
				wifi) address=${if cfg.address == null then "" else cfg.address} ;;
				*) break ;;
			esac
			shift
		done
		case "$orientation" in
			landscape) rotation=0 ;;
			portrait) rotation=90 ;;
			landscape-flipped) rotation=180 ;;
			portrait-flipped) rotation=270 ;;
		esac
		exec ${pkgs.scrcpy}/bin/scrcpy \
			''${address:+--tcpip=$address} \
			--video-source=camera \
			--camera-facing=${cfg.facing} \
			--camera-size=${cfg.size} \
			--camera-fps=${toString cfg.fps} \
			--video-codec=${cfg.codec} ${lib.optionalString (cfg.bitRate != null) "--video-bit-rate=${cfg.bitRate}"} \
			--capture-orientation=$rotation \
			--no-audio --no-window \
			--v4l2-sink=${cfg.device} \
			"$@"
	'';

	unit = args: {
		description = "Phone camera into ${cfg.device} via scrcpy";
		serviceConfig = {
			ExecStart = "${phone-cam}/bin/phone-cam ${args}";
			# scrcpy exiting with the phone is the normal stop, not a failure.
			Restart = "no";
		};
	};
in
{
	options.dotfiles.android.phoneCam = {
		address = lib.mkOption {
			type = lib.types.nullOr lib.types.str;
			default = null;
			description = ''
				The phone's Wi-Fi address for adb over TCP; null means USB. The
				phone must have had `adb tcpip 5555` run once over USB since it
				last booted.
			'';
		};
		facing = lib.mkOption {
			type = lib.types.enum [ "back" "front" "external" ];
			default = "back";
			description = "Which camera.";
		};
		size = lib.mkOption {
			type = lib.types.str;
			default = "1920x1080";
			description = "Capture size, as the camera lists it (always landscape; `scrcpy --list-camera-sizes`).";
		};
		fps = lib.mkOption {
			type = lib.types.int;
			default = 30;
			description = "Capture frame rate.";
		};
		orientation = lib.mkOption {
			type = lib.types.enum (builtins.attrNames rotation);
			default = "landscape";
			description = "Default orientation of the output; overridable per start (phone-cam@portrait).";
		};
		codec = lib.mkOption {
			type = lib.types.enum [ "h264" "h265" "av1" ];
			default = "h264";
			description = "Codec the phone encodes with on the way over. The loopback device always carries raw frames.";
		};
		bitRate = lib.mkOption {
			type = lib.types.nullOr lib.types.str;
			default = "20M";
			description = "Encoder bit rate; null falls back to scrcpy's 8M.";
		};
		device = lib.mkOption {
			type = lib.types.str;
			default = "/dev/video11";
			description = "The v4l2loopback device to write to (../media creates it).";
		};
	};

	config = {
		environment.systemPackages = with pkgs; [
			android-tools # adb + fastboot
			scrcpy
			phone-cam
		];

		systemd.user.services = {
			phone-cam = unit "";
			"phone-cam@" = unit "%i";
		};
	};
}
