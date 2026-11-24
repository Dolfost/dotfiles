# The watchlist (modules/user/watchlist): what Claude looks for on its own
# and fetches from Soulseek when it comes out. `watchlist list` shows the
# state, `watchlist check NAME --dry-run` what a run would do.
{ config, ... }:

{
	home-manager.users.${config.dotfiles.user}.dotfiles.watchlist = {
		enable = true;

		items = {
			south-park = {
				kind = "show";
				name = "South Park";
				tvmaze = 112;
				path = "/storage/2.5/media/shows/South_Park";
				every = "daily";
			};

			# An artist looks like this (the id is the one in the address of
			# the artist's MusicBrainz page):
			# burial = {
			# 	kind = "artist";
			# 	name = "Burial";
			# 	mbid = "9ddce51c-2b75-4b3e-ac8c-1db09e7c89c6";
			# 	every = "weekly";
			# };
		};
	};
}
