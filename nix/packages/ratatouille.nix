# Neural amp modeler with a UI: loads *.nam and *.aidax models, two slots with
# blending, built-in IR loader. Vendored verbatim from nixpkgs master
# (pkgs/by-name/ra/ratatouille-lv2); 
{
  cairo,
  fetchFromGitHub,
  lib,
  libx11,
  libjack2,
  libsndfile,
  lv2,
  pkg-config,
  stdenv,
  which,
  xorgproto,
  xxd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ratatouille-lv2";
	# Unreleased master: v0.9.11 (May 2025) ships a NAM core that only
	# reads legacy A1 models; SlimmableContainer (A2, e.g. TONE3000
	# exports) support landed in PR #52 (2026-05-08) after the last tagged
	# release.
  version = "0.9.11-unstable-2026-05-08";

  src = fetchFromGitHub {
    owner = "brummer10";
    repo = "Ratatouille.lv2";
    rev = "30aa06683fcd5dd5985910b40530a334e662a433";
    hash = "sha256-H5NB6B9yOE7icZ0njuNCFbFko/T4Pmb3IRbOmMq3PzY=";
    fetchSubmodules = true;
  };

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    which
    xxd
  ];

  buildInputs = [
    libx11
    xorgproto
    cairo
    lv2
    libsndfile
    libjack2
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "INSTALL_DIR=$(out)/lib/lv2"
    "EXE_INSTALL_DIR=$(out)/bin"
    "CLAP_INSTAL_DIR=$(out)/lib/clap"
    "VST2_INSTAL_DIR=$(out)/lib/vst"
    "user=root"
    "STRIP=:"
    "PKGCONFIG=$(PKG_CONFIG)"
  ];

  postPatch = ''
    substituteInPlace Ratatouille/makefile \
      --replace-fail "-flto=auto" "" \
      --replace-fail "pkg-config" '$(PKGCONFIG)'
  '';

  meta = {
    homepage = "https://github.com/brummer10/Ratatouille.lv2";
    description = "Neural Amp Modeler LV2 plugin";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ eymeric ];
    platforms = lib.platforms.linux;
    mainProgram = "Ratatouille";
  };
})
