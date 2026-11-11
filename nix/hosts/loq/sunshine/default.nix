# Sunshine host knowledge for the hybrid laptop. Enablement and apps come from
# modules/system/gaming, capture and the virtual display app from the desktop
# modules.
#
# Hyprland renders on the Intel iGPU (aquamarine picks it as primary), but
# Sunshine takes the first render node, which is the NVIDIA card here. Its
# screencopy dmabufs then live in NVIDIA memory; Hyprland draws into them with
# the wrong layout (garbage frames) and mesa aborts creating a fence for the
# foreign buffer, taking the compositor down. Pin Sunshine to the same GPU.
# by-path survives renderD128/129 swapping between boots.
{ pkgs, ... }:

{
	services.sunshine.settings.adapter_name = "/dev/dri/by-path/pci-0000:00:02.0-render";

	# H.264/HEVC encode on that iGPU: libva picks iHD for an i915/xe node on its
	# own, nothing else loads it. Without it Sunshine falls back to software x264.
	hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
}
