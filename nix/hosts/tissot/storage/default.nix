# The 64 GB SD card as ~/storage: one GPT partition named "storage", btrfs,
# its root owned by vladyslav. The host lets the guest at it
# (pmos/etc/systemd/system/systemd-nspawn@nixos.service.d/storage.conf), but
# a container gets no udev and no /dev node, so storage-node makes one from
# what sysfs says about the partition. The node isn't bound in from the host
# because nspawn refuses to start over a missing bind source; this way a
# missing card only fails the mount.
{ ... }:

{
	# A mount unit, not fileSystems: with /sys read-only the fstab generator
	# takes itself to be in a container and drops every /dev/ entry.
	systemd.mounts = [{
		description = "SD card";
		what = "/dev/storage";
		where = "/home/vladyslav/storage";
		type = "btrfs";
		# zstd:1 is cheap on the A53s and spares the card writes; btrfs skips
		# what doesn't compress. nofail keeps it off local-fs.target.
		options = "nofail,noatime,compress=zstd:1";
		requires = [ "storage-node.service" ];
		after = [ "storage-node.service" ];
		wantedBy = [ "multi-user.target" ];
	}];

	systemd.services.storage-node = {
		description = "Device node for the SD card";
		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = true;
		};
		script = ''
			for part in /sys/class/block/*; do
				if grep -qx PARTNAME=storage "$part/uevent"; then
					IFS=: read -r major minor < "$part/dev"
					rm -f /dev/storage
					mknod -m 0600 /dev/storage b "$major" "$minor"
					exit 0
				fi
			done
			echo "no partition named storage" >&2
			exit 1
		'';
	};
}
