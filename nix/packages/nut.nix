# NUT from its development branch at a fixed commit, for the EcoFlow on
# aorus. nixpkgs' 2.8.4 (and the 2.8.5 release) leak 128 bytes on every
# runtime poll in the EcoFlow subdriver, about 6 MB a day at pollinterval 2,
# and cannot read the EcoFlow's CDC port (ecoflow_cdc_port: live watts,
# voltage, frequency, temperatures). Both are planned for 2.8.6; drop this
# file once nixpkgs ships that.
#
# To move the pin: a new rev, its hash from
# `nix flake prefetch github:networkupstools/nut/<rev>`, and the version's
# last number from the commits since v2.8.5 (GitHub's compare view).
{ nut, fetchFromGitHub, perl, python3 }:

nut.overrideAttrs (old: {
	version = "2.8.5-unstable-2026-10-23";

	src = fetchFromGitHub {
		owner = "networkupstools";
		repo = "nut";
		rev = "1c4ab78c615a7b2b8231bdb023d553abd64b541d";
		hash = "sha256-rguVxJD9eYSoZGJlFV/1CrmEZVYthLCCnl1IqJsZ/Ck=";
	};

	# A git checkout lacks what a release tarball carries: autogen.sh writes
	# the USB device lists (and the udev rules made from them) with perl and
	# the Augeas lens with python, and the version usually comes from git.
	nativeBuildInputs = old.nativeBuildInputs ++ [ perl python3 ];
	env = (old.env or { }) // { NUT_VERSION_FORCED = "2.8.5.1711"; };
	# --with-all grew a UPower driver that needs GLib; nothing here uses it.
	# The new sysusers.d file defaults to systemd's own store path; the NixOS
	# module makes the users itself, so it only needs to land somewhere.
	# And the config dir now gets a /nut suffix, which would move the sample
	# files the NixOS module points at (upssched.conf.sample) out of etc/.
	configureFlags = old.configureFlags ++ [
		"--without-upower"
		"--with-systemdsysusersdir=$(out)/lib/sysusers.d"
		"--with-confdir=${placeholder "out"}/etc"
	];
	preAutoreconf = ''
		patchShebangs autogen.sh tools
		./autogen.sh
	'';
})
