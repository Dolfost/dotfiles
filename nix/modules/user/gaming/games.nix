# Global per-game gscope overrides, keyed by SteamAppId - the defaults a game
# needs everywhere, whatever the host. Hosts layer their own on top via
# dotfiles.gaming.gscope.games.<AppId> (host wins key-by-key). Keys/values land
# verbatim in ~/.config/gscope/<AppId>.env; see bin/gscope for the toggles.
{
	# LSFG_PROCESS selects the lsfg-vk frame-gen preset ([[game]] exe in
	# lsfg-vk/conf.toml at the repo root); harmless on hosts without
	# dotfiles.gaming.lsfg - no layer, nothing reads it.
	"1174180".LSFG_PROCESS = "rdr2"; # Red Dead Redemption 2
	"1874880".LSFG_PROCESS = "reforger"; # Arma Reforger
}
