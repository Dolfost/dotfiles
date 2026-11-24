# The watchlist: things to look for on a schedule and fetch when they come
# out. A new episode of a show, a new release of an artist:
#
#   dotfiles.watchlist = {
#     enable = true;
#     items.south-park = {
#       kind = "show"; name = "South Park"; tvmaze = 112;
#       path = "/storage/2.5/media/shows/South_Park";
#       every = "daily";
#     };
#     items.burial = {
#       kind = "artist"; name = "Burial";
#       mbid = "9ddce51c-2b75-4b3e-ac8c-1db09e7c89c6";
#       every = "weekly"; types = [ "Album" "EP" "Single" ];
#     };
#   };
#
# Every item gets a user timer, watchlist-<name>, that runs
# `watchlist check <name>` (./watchlist.py). The check itself is a plain
# script against TVmaze or MusicBrainz; Claude Code is started, headless,
# only for something that is actually new, with the shows or the music skill
# (claude/skills), and what happened arrives on the phone through ntfy-cmd
# (modules/system/ntfy). Only useful on the host with the nicotine container
# and the libraries, so it is set from hosts/aorus/services/watchlist.nix.
#
#   watchlist list                        items, and what is still pending
#   watchlist check south-park --dry-run  what a run would fetch
#   systemctl --user start watchlist-south-park    a run now
#   journalctl --user -u watchlist-south-park      what Claude said
{ config, lib, pkgs, ... }:

let
	cfg = config.dotfiles.watchlist;
	inherit (lib) mkOption mkIf types mapAttrs mapAttrs' mapAttrsToList nameValuePair;

	watchlist = pkgs.writers.writePython3Bin "watchlist" {
		doCheck = false;
	} (builtins.readFile ./watchlist.py);

	item = { name, ... }: {
		options = {
			kind = mkOption {
				type = types.enum [ "show" "artist" ];
				description = "show: new episodes, by TVmaze. artist: new releases, by MusicBrainz.";
			};
			name = mkOption {
				type = types.str;
				default = name;
				description = "The show or artist as it is written: in the search, the notification and an episode's file name.";
			};
			every = mkOption {
				type = types.str;
				default = "daily";
				example = "Thu,Fri 08:00";
				description = "How often to look: a systemd OnCalendar expression.";
			};
			since = mkOption {
				type = types.nullOr types.str;
				default = null;
				example = "2026-01-01";
				description = ''
					Want everything out since this day. Unset, a show wants the
					episodes after the newest one on disk, and an artist (or a show
					with nothing on disk) what comes out after the first run.
				'';
			};
			tvmaze = mkOption {
				type = types.nullOr types.int;
				default = null;
				description = "show: its TVmaze id (api.tvmaze.com/singlesearch/shows?q=...).";
			};
			path = mkOption {
				type = types.nullOr types.str;
				default = null;
				description = "show: its folder in the library, the one with the `Season NN` folders.";
			};
			mbid = mkOption {
				type = types.nullOr types.str;
				default = null;
				description = "artist: the MusicBrainz artist id.";
			};
			types = mkOption {
				type = types.listOf types.str;
				default = [ "Album" "EP" ];
				description = ''
					artist: MusicBrainz release group types to want. A secondary
					type (Live, Compilation, Remix, Soundtrack...) has to be listed
					too, or a release that carries it is passed over.
				'';
			};
		};
	};
in
{
	options.dotfiles.watchlist = {
		enable = mkOption {
			type = types.bool;
			default = false;
			description = "The watchlist timers and the `watchlist` command.";
		};
		items = mkOption {
			type = types.attrsOf (types.submodule item);
			default = { };
			description = "What to look for; the attribute name is the timer's.";
		};
		maxPerRun = mkOption {
			type = types.int;
			default = 2;
			description = "The most things one run of one item fetches; the rest wait for the next run.";
		};
		giveUpDays = mkOption {
			type = types.int;
			default = 30;
			description = "Stop retrying something that is still not on Soulseek after this many days, and say so.";
		};
		topic = mkOption {
			type = types.str;
			default = "watchlist";
			description = "The ntfy topic the results go to.";
		};
		claude = {
			model = mkOption {
				type = types.nullOr types.str;
				default = null;
				example = "sonnet";
				description = "Model for the fetching sessions; null is whatever ~/.claude/settings.json says.";
			};
			timeoutMinutes = mkOption {
				type = types.int;
				default = 120;
				description = "The longest one fetch may take.";
			};
			allowedTools = mkOption {
				type = types.listOf types.str;
				# Nobody is there to approve a tool call, so a headless session
				# gets exactly these and is refused the rest. Enough for the
				# two skills: search and download, look at the files, tag and
				# publish music. Filing an episode is watchlist.py's own job,
				# so nothing here writes into the shows library.
				default = [
					"Read" "Glob" "Grep" "Skill"
					"Bash(slsk *)"
					"Bash(ffprobe *)"
					"Bash(flac-verify *)"
					"Bash(mlib *)"
					"Bash(music-tag *)"
					"Bash(rsgain *)"
					"Bash(curl *)"
					"Bash(jq *)"
					"Bash(ls *)"
					"Bash(find *)"
					"Bash(du *)"
					"Bash(stat *)"
					"Bash(sleep *)"
					"Bash(rm -r /storage/data/soulseek/claude/*)"
				];
				description = "Claude Code permission rules of the fetching sessions (`--allowedTools`).";
			};
		};
	};

	config = mkIf cfg.enable {
		assertions = mapAttrsToList (name: item: {
			assertion = if item.kind == "show"
				then item.tvmaze != null && item.path != null
				else item.mbid != null;
			message = "dotfiles.watchlist.items.${name}: a show needs tvmaze and path, an artist needs mbid.";
		}) cfg.items;

		home.packages = [ watchlist ];

		xdg.configFile."watchlist/config.json".text = builtins.toJSON {
			inherit (cfg) items maxPerRun giveUpDays topic claude;
		};

		systemd.user.services = mapAttrs' (name: _: nameValuePair "watchlist-${name}" {
			Unit = {
				Description = "Watchlist: look for new ${name}";
				After = [ "nicotine.service" ];
			};
			Service = {
				Type = "oneshot";
				ExecStart = "${watchlist}/bin/watchlist check ${name}";
				# claude, slsk and the music tools are in the home profile,
				# ntfy-cmd in the system one; a user unit has neither on PATH.
				Environment = "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/run/wrappers/bin";
				# maxPerRun fetches, plus the wait for another item's run.
				TimeoutStartSec = "8h";
			};
		}) cfg.items;

		systemd.user.timers = mapAttrs' (name: item: nameValuePair "watchlist-${name}" {
			Unit.Description = "Watchlist: look for new ${name}";
			Timer = {
				OnCalendar = item.every;
				# A run missed while the machine was off or hibernated happens
				# once it is back.
				Persistent = true;
				RandomizedDelaySec = "15m";
			};
			Install.WantedBy = [ "timers.target" ];
		}) cfg.items;
	};
}
