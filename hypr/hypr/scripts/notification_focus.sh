#!/bin/sh
# Run by swaync when a notification is clicked (run-on: action). Apps' own
# xdg-activation loses the race against misc:focus_on_activate=false, so
# instead focus the sender's window directly: match the notification's
# desktop-entry/app-name against client classes (case-insensitive contains,
# either direction) and dispatch a focus - that also summons the workspace,
# special ones included.
export HYPRLAND_INSTANCE_SIGNATURE=${HYPRLAND_INSTANCE_SIGNATURE:-$(ls -t /run/user/$(id -u)/hypr | head -1)}

app=${SWAYNC_DESKTOP_ENTRY:-$SWAYNC_APP_NAME}
app=${app%.desktop}
[ -z "$app" ] && exit 0

addr=$(hyprctl clients -j | jq -r --arg app "$app" '
	[.[]
	| (.class | ascii_downcase) as $c
	| ($app | ascii_downcase) as $a
	| select(($c | contains($a)) or ($a | contains($c)))]
	| .[0].address // empty')
[ -z "$addr" ] && exit 0

hyprctl dispatch "hl.dsp.focus({window='address:$addr'})" >/dev/null
