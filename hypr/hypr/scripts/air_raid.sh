#!/usr/bin/env bash
# Air raid alerts. No argument: emit the waybar custom module JSON (and fire
# home-region notifications on level transitions). `toggle` (SUPER+A): show or
# dismiss the region list as a sticky notification - the bar tooltip on demand.
#
# Source A (preferred): the official alerts.in.ua API. Needs a personal token
# (request one at https://devs.alerts.in.ua), read from env ALERTS_IN_UA_TOKEN
# or ~/.config/alerts-in-ua-token - a plain file kept out of git and the nix
# store on purpose; chmod 600 it. Source B (tokenless fallback):
# vadimklimenko.com's mirror of the same feed.
#
# Both normalize to [{name, full, parts, since, lvl}] per alerted region:
# district-level alerts aggregate up to their region as "partial". lvl is "red"
# (siren) or "yellow" (advisory); the mirror often reports no level, and an
# active siren without one IS red, so that's the default. The
# permanently-occupied entries (on since 2022) are dropped - no signal. Region
# names stay as the feed spells them (Ukrainian) - they are data.
#
# HOME_REGION comes from hypr-local/air_raid.sh
# (dotfiles.hyprland.airRaidRegion). The bar plane tracks it - 󱡺  while it is
# under alert, 󱡻  when clear - and its level changes fire a notification; unset,
# the plane follows the nationwide state instead.

LOCAL_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/hypr-local/air_raid.sh"
[ -f "$LOCAL_CONFIG" ] && source "$LOCAL_CONFIG"

mode=${1:-status}
menu_id_file=${XDG_RUNTIME_DIR:-/tmp}/air-raid-menu-id

unknown() {
	if [ "$mode" = toggle ]; then
		notify-send -t 3000 -a air-raid-menu "Air raid alerts" "Alert feed unreachable"
	else
		printf '{"text": "<span foreground=\\"#565f89\\">󱡺</span>", "class": "unknown", "tooltip": "Alert feed unreachable"}\n'
	fi
	exit 0
}

# Dismissing the open popup needs no feed data - short-circuit before curl.
if [ "$mode" = toggle ] && [ -f "$menu_id_file" ]; then
	busctl --user call org.freedesktop.Notifications /org/freedesktop/Notifications \
		org.freedesktop.Notifications CloseNotification u "$(cat "$menu_id_file")" \
		>/dev/null 2>&1
	rm -f "$menu_id_file"
	exit 0
fi

token=${ALERTS_IN_UA_TOKEN:-}
token_file=${XDG_CONFIG_HOME:-$HOME/.config}/alerts-in-ua-token
[ -z "$token" ] && [ -f "$token_file" ] && token=$(<"$token_file")

if [ -n "$token" ]; then
	json=$(curl -sf --max-time 10 -H "Authorization: Bearer $token" \
		https://api.alerts.in.ua/v1/alerts/active.json) || unknown
	active=$(jq -c '
		[ .alerts[]
		  | { region: (if .location_type == "oblast" then .location_title
		               else .location_oblast // "" end),
		      title: .location_title,
		      # region-wide: an oblast alert, or a city that IS the region (м. Київ)
		      region_wide: (.location_type == "oblast"
		                    or .location_title == .location_oblast),
		      since: .started_at,
		      lvl: (.alert_level // "red") }
		  | select(.region != "") ]
		| group_by(.region)
		| map({ name: .[0].region,
		        full: (map(select(.region_wide)) | length > 0),
		        since: [.[] | select(.region_wide) | .since][0],
		        parts: [.[] | select(.region_wide | not) | .title],
		        lvl: (if any(.[]; .lvl == "red") then "red" else "yellow" end) })
	' <<<"$json") || unknown
else
	json=$(curl -sf --max-time 10 https://vadimklimenko.com/map/statuses.json) || unknown
	active=$(jq -c '
		[ .states | to_entries[]
		  | ([.value.districts // {} | .[] | select(.enabled)
		      | .alert_level // "red"]) as $dlvls
		  | { name: .key,
		      full: .value.enabled,
		      since: .value.enabled_at,
		      parts: [.value.districts // {} | to_entries[]
		              | select(.value.enabled) | .key],
		      lvl: (if .value.enabled then .value.alert_level // "red"
		            elif ($dlvls | index("red")) then "red"
		            else "yellow" end) }
		  | select(.full or (.parts | length > 0)) ]
	' <<<"$json") || unknown
fi

out=$(jq -c --arg home "${HOME_REGION:-}" '
	def t: sub("\\.\\d+"; "") | sub("\\+00:00$"; "Z")
	       | fromdate | strflocaltime("%H:%M");
	def color: {red: "#f7768e", yellow: "#e0af68"}[.];
	["АР Крим", "Севастополь", "Луганська область"] as $perm
	| map(select(.name as $k | $perm | index($k) | not)) as $active
	| ($active | length) as $n
	| ($active | map(select(.lvl == "red")) | length) as $reds
	| (if ($active | any(.lvl == "red")) then "red"
	   elif $n > 0 then "yellow" else "" end) as $top
	| (if $home == "" then "none"
	   else ([$active[] | select(.name == $home) | .lvl][0] // "off") end
	  ) as $home_state
	| ($active | map(
	    "<span foreground=\"\(.lvl | color)\">"
	    + (if .full
	       then "󱡺  \(.name)" + (if .since then " (since \(.since | t))" else "" end)
	       else "• \(.name) (partial: \(.parts | length))" end)
	    + "</span>")
	   | join("\n")) as $lines
	| (if $n > 0 then "Air raid alerts - \($reds) red, \($n - $reds) yellow"
	   else "No alerts" end) as $summary
	# plane = home region state (color and form), number = nationwide level;
	# one waybar module has one CSS color, so both are colored inline
	| (if $home_state == "red" or $home_state == "yellow"
	   then "<span foreground=\"\($home_state | color)\">󱡺</span>"
	   elif $home_state == "off" or $n == 0
	   then "<span foreground=\"#9ece6a\">󱡻</span>"
	   else "<span foreground=\"\($top | color)\">󱡺</span>" end) as $plane
	| { home: $home_state,
	    popup: { summary: $summary, body: $lines },
	    waybar: {
	      text: ($plane + (if $n > 0
	        then " <span foreground=\"\($top | color)\">\($n)</span>"
	        else "" end)),
	      class: (if $home_state == "red" or $home_state == "yellow"
	              then "home-\($home_state)"
	              elif $n > 0 then $top else "clear" end),
	      tooltip: (if $n > 0 then "\($summary):\n\($lines)"
	                else $summary end) } }
' <<<"$active") || unknown

if [ "$mode" = toggle ]; then
	notify-send -p -t 0 -a air-raid-menu \
		"$(jq -r '.popup.summary' <<<"$out")" \
		"$(jq -r '.popup.body' <<<"$out")" > "$menu_id_file"
	exit 0
fi

jq -cM '.waybar' <<<"$out"

# Level transitions for the home region; only reached on a successful fetch, so
# a network blip can't fake an all-clear.
home_state=$(jq -r '.home' <<<"$out")
if [ "$home_state" != "none" ]; then
	state_file=${XDG_RUNTIME_DIR:-/tmp}/air-raid-home-state
	prev=$(cat "$state_file" 2>/dev/null)
	if [ "$home_state" != "$prev" ]; then
		id_file=${XDG_RUNTIME_DIR:-/tmp}/air-raid-notify-id
		id=$(cat "$id_file" 2>/dev/null)
		case "$home_state" in
		red)    notify-send -p -u critical -a air-raid ${id:+-r "$id"} "󱡺 Air raid alert" "$HOME_REGION" > "$id_file" ;;
		yellow) notify-send -p -u normal   -a air-raid ${id:+-r "$id"} "󱡺 Threat advisory (yellow)" "$HOME_REGION" > "$id_file" ;;
		off)    [ -n "$prev" ] &&
		        notify-send -p -u normal   -a air-raid ${id:+-r "$id"} "All clear" "$HOME_REGION" > "$id_file" ;;
		esac
	fi
	echo "$home_state" > "$state_file"
fi
