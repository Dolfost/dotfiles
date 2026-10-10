# Android tooling: adb/fastboot and scrcpy screen mirroring. Device access is
# handled by systemd's uaccess rules, no adbusers group needed.
#
# phone-cam (./phone-cam.sh) streams the phone's camera into a "Phone Camera"
# virtual webcam. On demand only: a plugged-in phone is usually just charging,
# so nothing starts on plug. scrcpy exits when the phone goes away, so an idle
# or absent phone costs nothing.
#
#   systemctl --user start phone-cam            the configured defaults
#   systemctl --user start phone-cam@portrait   same, other orientation
#   phone-cam portrait usb                      in a terminal, any keywords
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

	phone-cam = pkgs.replaceVarsWith {
		name = "phone-cam";
		src = ./phone-cam.sh;
		dir = "bin";
		isExecutable = true;
		replacements = {
			bash = pkgs.runtimeShell;
			adb = "${pkgs.android-tools}/bin/adb";
			scrcpy = "${pkgs.scrcpy}/bin/scrcpy";
			address = if cfg.address == null then "" else cfg.address;
			rotation = toString rotation.${cfg.orientation};
			inherit (cfg) facing size codec;
			fps = toString cfg.fps;
			bitRate = if cfg.bitRate == null then "" else "--video-bit-rate=${cfg.bitRate}";
			device = "/dev/video${toString cfg.videoNr}";
		};
	};

	unit = args: {
		description = "Phone camera into /dev/video${toString cfg.videoNr} via scrcpy";
		serviceConfig = {
			ExecStart = "${phone-cam}/bin/phone-cam ${args}";
			# scrcpy exiting with the phone is the normal stop, not a failure.
			Restart = "no";
		};
	};
in
{
	imports = [ ../v4l2loopback ];

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
		videoNr = lib.mkOption {
			type = lib.types.int;
			default = 11;
			description = "N in the /dev/videoN the camera appears as.";
		};
	};

	config = {
		dotfiles.v4l2loopback.devices.phone = { nr = cfg.videoNr; label = "Phone Camera"; };

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
