# pedal-mode: what the foot pedals mean right now. Wrapped by
# writeShellApplication (nix/modules/system/pedal), which adds the shebang and
# `set -euo pipefail`; keyd comes from there, hyprctl and walker from the
# session.
#
#   pedal-mode              pick a mode in walker (SUPER + Z)
#   pedal-mode desktop      chords; Hyprland runs its pedal binds
#   pedal-mode app          chords; every chord reaches the focused window
#   pedal-mode game <name>  pedals become the plain held keys of that profile
#   pedal-mode status       print the current mode
#
# Chord modes leave keyd alone: the pedal config's `pedal` layout types
# Ctrl+Alt+Shift+Fn. A game profile rebinds that layout live with `keyd bind`
# (needs the keyd group); the layout name exists in no other keyd config, so
# the keyboard's F row is untouched. Hyprland reads the mode file on reload and
# gets told on every change, and it shows the notification.

state=${XDG_RUNTIME_DIR:-/tmp}/pedal-mode
games=/etc/pedal-mode/games

current() { cat "$state" 2>/dev/null || echo desktop; }

profiles() {
	local f
	for f in "$games"/*; do [ -e "$f" ] || continue; basename "$f"; done
}

usage() {
	cat <<-EOF
		pedal-mode              pick a mode in walker
		pedal-mode desktop      chords; Hyprland runs its pedal binds
		pedal-mode app          chords; every chord reaches the focused window
		pedal-mode game <name>  pedals become the plain held keys of that profile
		pedal-mode status       print the current mode
	EOF
}

set_mode() {
	local mode=$1
	case $mode in
		desktop | app)
			# Only a game profile leaves bindings behind.
			case $(current) in game:*) keyd bind reset > /dev/null ;; esac
			;;
		game:*)
			local file=$games/${mode#game:} key value
			local -a exprs=()
			[ -f "$file" ] || { echo "pedal-mode: no game profile '${mode#game:}' in $games" >&2; exit 1; }
			while IFS='=' read -r key value; do
				key=${key//[[:space:]]/}
				[ -z "$key" ] && continue
				exprs+=("pedal.$key = ${value#"${value%%[![:space:]]*}"}")
			done < "$file"
			keyd bind reset "${exprs[@]}" > /dev/null
			;;
	esac
	printf '%s\n' "$mode" > "$state"
	hyprctl eval "pedals_apply('$mode')" > /dev/null
}

menu() {
	local choice
	choice=$({
		echo desktop
		echo app
		profiles | sed 's/^/game:/'
	} | walker --dmenu --placeholder 'Pedal mode' --current "$(current)") || true
[ -n "$choice" ] && set_mode "$choice"
}

case ${1-} in
	'') menu ;;
	status) current ;;
	desktop | app) set_mode "$1" ;;
	game) [ -n "${2-}" ] || { echo "pedal-mode game <name>; profiles: $(profiles | tr '\n' ' ')" >&2; exit 1; }
		set_mode "game:$2" ;;
	*) usage >&2; exit 1 ;;
esac
