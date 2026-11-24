# shellcheck shell=bash
# music-tag [--loose] DIR [RELEASE-MBID]
#
# Tags the album in DIR from MusicBrainz with beets and fetches cover.jpg,
# in place, without a question asked. With a release id that exact release
# is the only candidate; without one beets searches by the tags and names
# the files came with.
#
# beets applies a match only when it is close (track count, lengths, titles),
# otherwise it skips the album and this exits 1. --loose widens that for a
# release you have checked yourself and that differs for a known reason
# (a hidden track, lengths off by a few seconds). Missing tracks count
# against a match too: an incomplete download is skipped, as it should be.
#
# Not run as is: default.nix wraps it (shebang, strict mode, beet and mlib
# on the PATH) and points BEETS_CONFIG at ./beets.yaml.
loose=
if [ "${1:-}" = --loose ]; then loose=1; shift; fi
dir="${1:?usage: music-tag [--loose] DIR [RELEASE-MBID]}"
id="${2:-}"

# beets wants a library database; it gets one that dies with this run, so
# it knows nothing about the real library and remembers nothing.
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp "${BEETS_CONFIG:?}" "$work/config.yaml"
if [ -n "$loose" ]; then
	printf 'match:\n  strong_rec_thresh: 0.25\n' >> "$work/config.yaml"
fi

# -v is the only way to learn how far off a skipped candidate was; of all it
# prints, the candidates and their distance are worth reading. Distance 0 is
# a perfect match; beets applies up to 0.04, with --loose up to 0.25.
BEETSDIR="$work" beet -v -l "$work/library.db" import ${id:+--search-id "$id"} "$dir" 2>&1 \
	| grep -E '^(Candidate: |Success\. Distance: |Skipping\.|No match|.*Match \(|.*≠ |.*musicbrainz\.org/release/)' || true

mlib tidy "$dir"

total=0 tagged=0 releases=
while IFS= read -r -d '' file; do
	total=$((total + 1))
	release="$(metaflac --show-tag=MUSICBRAINZ_ALBUMID "$file" | head -n 1 | cut -d= -f2)"
	if [ -n "$release" ] && { [ -z "$id" ] || [ "$release" = "$id" ]; }; then
		tagged=$((tagged + 1))
		case " $releases " in *" $release "*) ;; *) releases="$releases $release" ;; esac
	fi
done < <(find "$dir" -type f -iname '*.flac' -print0)

if [ "$total" -gt 0 ] && [ "$tagged" -eq "$total" ]; then
	echo "tagged $tagged files: https://musicbrainz.org/release/${releases# }"
else
	echo "NOT TAGGED: $tagged of $total files carry ${id:-a} release id. beets skipped the album;" \
		"give it the right release id, or --loose if this is the right one." >&2
	exit 1
fi
