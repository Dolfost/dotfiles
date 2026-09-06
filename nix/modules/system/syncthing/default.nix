# Syncthing, wired up from the fleet facts (../../../facts.nix). The folder
# topology lives here once; a host imports this module and maps the folders it
# carries to local paths via dotfiles.syncthing.folders. Devices are every
# machine in facts with a syncthing_id, dialed directly over the tailnet when
# the address is known (phones and the mac fall back to discovery).
#
# overrideDevices/overrideFolders are on: devices and folders added through the
# web GUI are wiped on the next rebuild - this file is the source of truth.
#
# Adding a new machine (pre-generate the identity, no chicken-and-egg):
#
#   nix run nixpkgs#syncthing -- generate --home=/tmp/newpc
#
# creates cert.pem + key.pem and prints the device id right there. Then:
#
#   1. Record the id in facts.nix as the machine's syncthing_id (plus its
#      ts_ipv4 once it joins the tailnet).
#   2. Add the machine's name to the members lists in the topology below for
#      whichever folders it should carry.
#   3. Create nix/hosts/<name>/syncthing/default.nix mapping those folders to
#      local paths, importing this module - same shape as loq's.
#   4. Store its secrets in nix/secrets.yaml: the two pem files as
#      syncthing/<name>/cert + key, and a gui hash (mkpasswd -m bcrypt)
#      as syncthing/<name>/gui_hash.
#   5. Rebuild everywhere. Existing hosts pick the new device up from facts
#      automatically; nothing manual in any GUI. (After the machine's first
#      boot, also enroll it in sops: ssh-to-age its host key into .sops.yaml
#      and run `sops updatekeys nix/secrets.yaml`.)
{ config, lib, pkgs, ... }:

let
	facts = import ../../../facts.nix;
	me = config.networking.hostName;
	user = config.dotfiles.user;

	topology = {
		books    = { id = "n9zmf-v33nw"; members = [ "aorus" "loq" "rodin" "mac" ]; };
		obsidian = { id = "qqank-em9du"; members = [ "aorus" "loq" "rodin" ]; };
		shared   = { id = "hwkjf-gy4hu"; members = [ "aorus" "rodin" ]; };
		avatars  = { id = "fuck1-fuck1"; members = [ "aorus" "rodin" "mac" "loq" ]; };
	};

	peers = lib.filterAttrs
		(name: machine: name != me && machine ? syncthing_id)
		facts.hosts;

	paths = config.dotfiles.syncthing.folders;
in
{
	options.dotfiles.syncthing.folders = lib.mkOption {
		type = lib.types.attrsOf lib.types.str;
		default = { };
		description = "Folder name (a key of the topology above) -> local path on this host.";
	};

	config = {
		assertions = [{
			assertion = lib.all
				(name: topology ? ${name} && lib.elem me topology.${name}.members)
				(lib.attrNames paths);
			message = "dotfiles.syncthing.folders on ${me} names a folder this host is not a member of (see the topology in modules/system/syncthing).";
		}];

		services.syncthing = {
			enable = true;
			inherit user;
			group = "users";
			dataDir = "/home/${user}";
			configDir = "/home/${user}/.local/state/syncthing";
			# The identity behind syncthing_id in facts.nix, installed from sops
			# on every start - a machine rebuilt from this repo keeps its id.
			cert = config.sops.secrets.syncthing_cert.path;
			key = config.sops.secrets.syncthing_key.path;
			openDefaultPorts = true;
			overrideDevices = true;
			overrideFolders = true;

			settings = {
				devices = lib.mapAttrs (name: machine: {
					id = machine.syncthing_id;
					addresses =
						lib.optional (machine ? ts_ipv4) "tcp://${machine.ts_ipv4}:22000"
						++ [ "dynamic" ];
				}) peers;

				folders = lib.mapAttrs (name: path: {
					inherit (topology.${name}) id;
					inherit path;
					label = name;
					devices = lib.filter (member: peers ? ${member}) topology.${name}.members;
				}) paths;

				# The tailnet already authenticates and encrypts the transport;
				# the password (pushed by syncthing-gui-auth below) is just a
				# second fence.
				gui.address = "0.0.0.0:8384";
				gui.insecureSkipHostcheck = true;
				gui.user = user;
				options.urAccepted = -1;
			};
		};

		# The password hash can't go through services.syncthing.settings - that
		# ends up world-readable in the nix store - so it comes from sops and is
		# pushed into the running instance over the local REST api instead.
		sops.secrets = {
			syncthing_cert = { key = "syncthing/${me}/cert"; owner = user; };
			syncthing_key = { key = "syncthing/${me}/key"; owner = user; };
			syncthing_gui_hash = { key = "syncthing/${me}/gui_hash"; owner = user; };
		};
		systemd.services.syncthing-gui-auth = {
			description = "Syncthing GUI password from sops";
			after = [ "syncthing.service" ];
			requires = [ "syncthing.service" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "oneshot";
				User = user;
			};
			script = ''
				st() { ${pkgs.syncthing}/bin/syncthing cli --home ${config.services.syncthing.configDir} "$@"; }
				for _ in $(seq 30); do
					st show system >/dev/null 2>&1 && break
					sleep 2
				done
				st config gui password set -- "$(cat ${config.sops.secrets.syncthing_gui_hash.path})"
			'';
		};

		# GUI reachable from the tailnet only (aorus has no firewall at all, there
		# this is a no-op).
		networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8384 ];
	};
}
