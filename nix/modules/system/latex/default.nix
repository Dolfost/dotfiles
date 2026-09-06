{ pkgs, ... }: {
	environment.systemPackages = with pkgs; [
		texliveFull
		pandoc
		haskellPackages.pandoc-crossref
		haskellPackages.pandoc-plot
		(python3.withPackages (ps: [ ps.matplotlib ]))
		pandoc-include
		librsvg
	];
}
