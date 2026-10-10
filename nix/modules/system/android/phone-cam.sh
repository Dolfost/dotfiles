#!@bash@
# The phone's camera into a v4l2loopback device via scrcpy. Rendered by
# ./default.nix, which fills the at-sign names from dotfiles.android.phoneCam.
#
#   phone-cam [landscape|portrait|landscape-flipped|portrait-flipped]
#   [usb|wifi] [scrcpy args]

export ADB=@adb@
rotation=@rotation@
address=@address@

# Leading keywords override the configured defaults; the rest goes to scrcpy.
while [ $# -gt 0 ]; do
	case "$1" in
		landscape) rotation=0 ;;
		portrait) rotation=90 ;;
		landscape-flipped) rotation=180 ;;
		portrait-flipped) rotation=270 ;;
		usb) address= ;;
		wifi) address=@address@ ;;
		*) break ;;
	esac
	shift
done

exec @scrcpy@ \
	${address:+--tcpip=$address} \
	--video-source=camera \
	--camera-facing=@facing@ \
	--camera-size=@size@ \
	--camera-fps=@fps@ \
	--video-codec=@codec@ @bitRate@ \
	--capture-orientation=$rotation \
	--no-audio --no-window \
	--v4l2-sink=@device@ \
	"$@"
