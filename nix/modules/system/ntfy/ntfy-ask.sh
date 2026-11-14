# shellcheck shell=bash
# ntfy-ask [-t SECONDS] QUESTION [OPTION OPTION [OPTION]]
#
# A question on the `claude` topic, then wait for the answer and print it
# (Claude Code's notify skill, claude/skills/notify). Each question gets a
# two-character code, shown in the title, and an answer is any message on
# that same topic that starts with it, so concurrent questions stay apart
# and the thread reads like a chat:
#   "k7 2"           option 2, which is what its button sends
#   "k7 keep both"   free text, typed into the topic from any ntfy client
# A button is an ntfy http action: the phone itself posts the message, so
# the notification has to carry a token. That one is claude-pub's, which
# can only write to `claude`, never the fleet's; it posts at min priority
# so the tap does not come back as a buzz. ntfy allows three buttons.
#   exit 0: "<n>) <option>" or "text: <reply>"    exit 2: no answer in time
#
# Not run as is: default.nix wraps it (shebang, strict mode, curl and jq on
# the PATH) and sets the three variables below.
url="${NTFY_URL:?}"
auth="Authorization: Bearer $(cat "${NTFY_TOKEN_FILE:?}")"
reply_token="$(cat "${NTFY_REPLY_TOKEN_FILE:?}")"

timeout=3600
if [ "${1:-}" = "-t" ]; then timeout="$2"; shift 2; fi
[ $# -ge 1 ] && [ $# -ne 2 ] && [ $# -le 4 ] || { echo "usage: ntfy-ask [-t SECONDS] QUESTION [OPTION OPTION [OPTION]]" >&2; exit 1; }
question="$1"; shift

# No 0/o or 1/l/i: it is read off a lock screen and typed on a phone.
letters=abcdefghjkmnpqrstuvwxyz digits=23456789
code="${letters:RANDOM % ${#letters}:1}${digits:RANDOM % ${#digits}:1}"

body="$question" actions="" n=0
for option in "$@"; do
	n=$((n + 1))
	body="$body"$'\n'"$n) $option"
	actions="$actions${actions:+; }http, Option $n, $url/claude, method=POST, headers.Authorization=Bearer $reply_token, headers.Priority=min, body=$code $n, clear=true"
done
body="$body"$'\n'"Or write here: $code your answer"

sent="$(curl -fsS -m 10 -H "$auth" -H "Title: $(uname -n): Claude asks [$code]" -H "Actions: $actions" \
	--data-binary "$body" "$url/claude")"

# One JSON string per answer: the text after the code, whatever case the
# phone's keyboard gave it. The question itself is skipped by id. jq quits
# at the first one (first/inputs), which ends the wait; curl then dies on
# its next write, the server's keepalive, instead of idling out the timeout.
answer="$(curl -sS -N -m "$timeout" -H "$auth" "$url/claude/json?since=$(jq -r .time <<<"$sent")" 2>/dev/null \
	| jq -n --unbuffered -c --arg c "$code" --arg q "$(jq -r .id <<<"$sent")" '
		first(inputs | select(.event == "message" and .id != $q) | .message
		| select((.[0:2] | ascii_downcase) == $c) | .[2:]
		| sub("^[\\s:,.)-]+"; "") | select(length > 0))')" || true
[ -n "${answer:-}" ] || { echo "no answer within $timeout s" >&2; exit 2; }
answer="$(jq -r . <<<"$answer")"
case "$answer" in
	[1-9]) [ "$answer" -le $# ] && { echo "$answer) ${!answer}"; exit 0; } ;;
esac
echo "text: $answer"
