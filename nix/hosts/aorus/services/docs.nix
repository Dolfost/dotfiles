# Docs: the tailnet guide (docs/ at the repo root), rendered by mdBook at build
# time and served from the store - no container, content updates land on
# rebuild. Unlike the quadlet services this one is a plain NixOS service.
{ pkgs, ... }:

let
	site = pkgs.runCommand "tailnet-docs"
		{ nativeBuildInputs = [ pkgs.mdbook ]; } ''
		mdbook build --dest-dir $out ${../../../../docs}
	'';
in
{
	dotfiles.serve.docs.port = 8090;

	services.static-web-server = {
		enable = true;
		listen = "127.0.0.1:8090";
		root = site;
	};
}
