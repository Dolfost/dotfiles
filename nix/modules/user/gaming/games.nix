# Global per-game gscope overrides, keyed by SteamAppId - the defaults a game
# needs everywhere, whatever the host. Hosts layer their own on top via
# dotfiles.gaming.gscope.games.<AppId> (host wins key-by-key). Keys/values land
# verbatim in ~/.config/gscope/<AppId>.env; see bin/gscope for the toggles.
{
	# "1174180" = { }; # Red Dead Redemption 2

	# Sons Of The Forest: 144 threads on a 24-thread CPU is ~500 pipe fds, ntsync
	# adds 300+ and keeps growing in multiplayer, so it reaches fd 1024 within
	# minutes and steamclient.so aborts it (2026-11-21, see NTSYNC in bin/gscope).
	"1326470" = { NTSYNC = 0; };
}
