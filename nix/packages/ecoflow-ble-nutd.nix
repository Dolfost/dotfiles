# Ecoflow-BLE-NUTd: talks to an EcoFlow power station over Bluetooth LE
# (BlueZ via D-Bus) and serves it as a read-only UPS over the NUT protocol.
# For the Delta 3 Max Plus from tissot, where USB is taken by the hub and
# aorus already holds the USB link anyway. Not in nixpkgs.
#
# Built from my fork until the branch below is merged: it adds the AC side,
# battery details and one outlet per port as NUT variables (PR to upstream
# from github.com/Dolfost/Ecoflow-BLE-NUTd, branch nut-vars-delta3). Back to
# upstream's tag once released: owner/rev/hash, then let the build tell you
# the vendorHash if go.mod moved.
{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
	pname = "ecoflow-ble-nutd";
	version = "0.2.3-unstable-2026-11-11";

	src = fetchFromGitHub {
		owner = "Dolfost";
		repo = "Ecoflow-BLE-NUTd";
		rev = "5edf66bfe7c488442bf536c0872621c5a10c9640";
		hash = "sha256-hnX4n8xzqxmVb72K5gV9gUbJEx0tFMFJpHtm2FaIvJE=";
	};

	vendorHash = "sha256-2B+VYR7cS+HdKmQ/7WsJ3DtW1yuAt0J9bzePRNFDu2o=";

	subPackages = [ "cmd/ecoflow-ble-nutd" ];
	ldflags = [ "-s" "-w" ];

	meta = {
		description = "EcoFlow power stations over BLE as NUT UPS devices";
		homepage = "https://github.com/xKhronoz/Ecoflow-BLE-NUTd";
		license = lib.licenses.gpl3Only;
		mainProgram = "ecoflow-ble-nutd";
	};
}
