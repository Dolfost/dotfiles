# TONE3000: NAM captures and IRs streamed straight from tone3000.com, as
# standalone, VST3, LV2 and CLAP. Not in nixpkgs. Upstream (MIT, JUCE) fetches
# JUCE at configure time and bakes a per-account publishable key into the
# binary, so this repackages the official Linux release instead of building
# from source.
{
	stdenv,
	lib,
	fetchurl,
	autoPatchelfHook,
	copyDesktopItems,
	makeDesktopItem,
	alsa-lib,
	curl,
	fontconfig,
	pipewire,
	libx11,
	libxcursor,
	libxext,
	libxi,
	libxinerama,
	libxrandr,
	libxscrnsaver,
}:

stdenv.mkDerivation (finalAttrs: {
	pname = "tone3000";
	version = "0.0.12";

	src = fetchurl {
		url = "https://github.com/tone-3000/tone3000-plugin/releases/download/v${finalAttrs.version}/TONE3000-v${finalAttrs.version}-linux-x64.tar.gz";
		hash = "sha256-xF6l1k5u75kbFPGIOkJJ7RqIMlPbGp2fBgXgVAq6X8c=";
	};

	nativeBuildInputs = [
		autoPatchelfHook
		copyDesktopItems
	];

	buildInputs = [
		stdenv.cc.cc.lib
		alsa-lib
		fontconfig
		libx11
	];

	# JUCE dlopens these by SONAME instead of linking them, so autoPatchelf can't
	# see them: libcurl for tone downloads, libjack/libpipewire for the
	# standalone's audio backend, the X extensions for the window. Not
	# runtimeDependencies: that only patches executables, and the plugin .so
	# files need libcurl just as much.
	appendRunpaths = map (p: "${lib.getLib p}/lib") [
		curl
		pipewire.jack
		pipewire
		libxcursor
		libxext
		libxi
		libxinerama
		libxrandr
		libxscrnsaver
	];

	dontConfigure = true;
	dontBuild = true;

	installPhase = ''
		runHook preInstall

		install -Dm755 TONE3000 $out/bin/TONE3000
		mkdir -p $out/lib/vst3 $out/lib/lv2 $out/lib/clap
		cp -r TONE3000.vst3 $out/lib/vst3/
		cp -r TONE3000.lv2 $out/lib/lv2/
		install -Dm644 TONE3000.clap $out/lib/clap/TONE3000.clap
		install -Dm644 tone3000.png $out/share/icons/hicolor/512x512/apps/tone3000.png

		# install.sh copies these to ~/.config/TONE3000/Presets/Factory; the
		# home module links them there.
		mkdir -p $out/share/tone3000
		cp -r factory-presets $out/share/tone3000/

		runHook postInstall
	'';

	desktopItems = [
		(makeDesktopItem {
			name = "tone3000";
			desktopName = "TONE3000";
			comment = "Play NAM captures and IRs straight from TONE3000";
			exec = "TONE3000";
			icon = "tone3000";
			categories = [ "AudioVideo" "Audio" "Music" ];
			startupWMClass = "TONE3000";
		})
	];

	meta = {
		homepage = "https://www.tone3000.com/plugin";
		description = "Neural Amp Modeler plugin with built-in TONE3000 tone browser";
		license = lib.licenses.mit;
		sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
		platforms = [ "x86_64-linux" ];
		mainProgram = "TONE3000";
	};
})
