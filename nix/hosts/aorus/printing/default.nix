# The Brother MFC-L2802DW on the LAN, driverless. It is AirPrint/Mopria
# certified, so CUPS builds the PPD from the printer's own IPP attributes
# (pwg-raster, A4 default, duplex) and no vendor driver is needed. The queue
# keeps the name CUPS gives the auto-discovered destination, so anything that
# already printed to it needs no re-pointing.
{ ... }:

{
	services.printing.enable = true;

	# The queue addresses the printer by its DNS-SD name, not its IP, so a new
	# DHCP lease from the router does not break it. Avahi does that resolving
	# (GNOME already turns it on, stated here because printing depends on it).
	# CUPS turns the DNS-SD name into the printer's .local hostname and then asks
	# the system resolver for it, so .local has to be in nsswitch too - without
	# nssmdns4 every job dies with "Name or service not known".
	services.avahi = {
		enable = true;
		nssmdns4 = true;
	};

	# cups-browsed would auto-create a queue for whatever it finds on the LAN,
	# duplicating the one declared here. One explicit queue is enough.
	services.printing.browsed.enable = false;

	hardware.printers = {
		ensurePrinters = [{
			name = "Brother_MFC_L2802DW";
			description = "Brother MFC-L2802DW";
			deviceUri = "dnssd://Brother%20MFC-L2802DW._ipp._tcp.local/?uuid=e3248000-80ce-11db-8000-94ddf84db51f";
			model = "everywhere";
		}];
		ensureDefaultPrinter = "Brother_MFC_L2802DW";
	};

	# `-m everywhere` asks the printer for its capabilities, so the queue can
	# only be created while it is reachable: wait for the network first. If the
	# printer is powered off at boot the unit fails harmlessly - a queue made on
	# an earlier boot stays. `systemctl restart ensure-printers` once it is on.
	systemd.services.ensure-printers = {
		wants = [ "network-online.target" ];
		after = [ "network-online.target" ];
	};
}
