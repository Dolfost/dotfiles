"""mlib: the file-shuffling half of adding an album to the music library.

  mlib prep DIR             strip embedded pictures, resample to 44.1 kHz (bit depth kept)
  mlib tidy DIR             drop the empty tags beets leaves behind, capitalise genres
  mlib organize DIR         plan the move of tagged FLACs into the staging tree
  mlib organize --apply DIR ... and do it
  mlib lyrics DIR           .lrc (synced) or .txt (plain) next to every track, from LRCLIB
  mlib artist-art DIR       artist.jpg for an artist folder that has none, from Deezer
  mlib cover ALBUMDIR       the staged cover's size, and a covers.musichoarders.xyz link to pick a better one
  mlib cover ALBUMDIR URL   save the picked image as the album's cover
  mlib publish [ALBUMDIR]   move staged albums into the library; never overwrites

The layout is the library's own, as Picard's naming script made it:

  Artist/{Albums,EPs,Singles,Live,Compilations,...}/YEAR - Album/[D-]NN [Artist - ]Title.flac

YEAR is the original release year. The track artist is in the file name only
when the album's tracks are not all by the same artist; D- only on multi-disc
releases. organize reads MusicBrainz tags, so it comes after tagging.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import unicodedata
import urllib.error
import urllib.parse
import urllib.request

LIBRARY = os.environ.get("MUSIC_LIBRARY", "/storage/2.5/media/music")
STAGE = os.environ.get("MUSIC_STAGE", "/storage/data/soulseek/claude/stage")
AGENT = "mlib/1 (personal music library script)"

# Secondary release types win over the primary one, in this order.
TYPE_FOLDERS = (
    ("soundtrack", "Soundtracks"), ("live", "Live"), ("remix", "Remixes"), ("dj-mix", "Remixes"),
    ("compilation", "Compilations"), ("demo", "Demos"), ("mixtape/street", "Mixtapes"),
    ("ep", "EPs"), ("single", "Singles"), ("album", "Albums"),
)


def flacs(root):
    found = []
    for folder, _dirs, names in os.walk(root):
        found += [os.path.join(folder, name) for name in names if name.lower().endswith(".flac")]
    return sorted(found)


def tags(path):
    out = subprocess.run(["metaflac", "--export-tags-to=-", path], capture_output=True, text=True, check=True).stdout
    result = {}
    for line in out.splitlines():
        key, sep, value = line.partition("=")
        if sep:
            result.setdefault(key.upper(), []).append(value)
    return result


def first(tag, *keys, default=""):
    for key in keys:
        if tag.get(key):
            return tag[key][0]
    return default


def clean(name, folder=False):
    """A file or folder name the way Picard writes it with Windows compatibility on."""
    name = re.sub(r'[/\\:*?"<>|]', "_", name)
    name = re.sub(r"[\x00-\x1f]", "", name).strip()
    if folder:
        name = name.rstrip(". ")  # Windows cannot open a folder that ends in a dot
    return name or "_"


def fingerprint(name):
    name = unicodedata.normalize("NFKD", name).casefold()
    return "".join(c for c in name if c.isalnum())


def artist_folder(artist):
    """The library's existing folder for this artist, however it was spelled (AC-DC, suicideboys)."""
    wanted = fingerprint(artist)
    try:
        for name in sorted(os.listdir(LIBRARY)):
            if fingerprint(name) == wanted and os.path.isdir(os.path.join(LIBRARY, name)):
                return name, True
    except OSError:
        pass
    return clean(artist, folder=True), False


def type_folder(tag):
    types = {t.strip().lower() for value in tag.get("RELEASETYPE", []) + tag.get("ALBUMTYPE", [])
             for t in re.split(r"[;,]", value)}
    for release_type, folder in TYPE_FOLDERS:
        if release_type in types:
            return folder
    return "Albums"


def number(value):
    match = re.match(r"\d+", value or "")
    return int(match.group()) if match else 0


# prep #

def cmd_prep(args):
    files = flacs(args.dir)
    if not files:
        sys.exit("mlib: no .flac files there")

    for path in files:
        subprocess.run(["metaflac", "--remove", "--block-type=PICTURE,PADDING", "--dont-use-padding", path], check=True)
        subprocess.run(["metaflac", "--remove-tag=COVERART", "--remove-tag=METADATA_BLOCK_PICTURE",
                        "--dont-use-padding", path], check=True)

        rate, bits = subprocess.run(["metaflac", "--show-sample-rate", "--show-bps", path],
                                    capture_output=True, text=True, check=True).stdout.split()
        if rate == "44100":
            continue

        # -G leaves headroom if the filter overshoots; `rate -v` is sox's best
        # quality. Bit depth is kept, so nothing is dithered.
        temp = path + ".resample.flac"
        subprocess.run(["sox", "-G", path, "-b", bits, temp, "rate", "-v", "44100"], check=True)
        os.replace(temp, path)
        print(f"{int(rate) / 1000:g} kHz -> 44.1 kHz ({bits}-bit)  {os.path.relpath(path, args.dir)}")

    print(f"prepared {len(files)} files")


# tidy #

def cmd_tidy(args):
    for path in flacs(args.dir):
        tag = tags(path)
        command = ["metaflac", "--dont-use-padding"]

        for key, values in tag.items():
            if not any(values) or (key in {"BPM", "COMPILATION"} and set(values) == {"0"}):
                command.append(f"--remove-tag={key}")

        genres = [g.title() for g in tag.get("GENRE", []) if g][:5]
        if genres and genres != tag["GENRE"]:
            command.append("--remove-tag=GENRE")
            command += [f"--set-tag=GENRE={genre}" for genre in genres]

        if len(command) > 2:
            subprocess.run(command + [path], check=True)


# organize #

def plan(source):
    albums = {}
    untagged = []

    for path in flacs(source):
        tag = tags(path)
        album_id = first(tag, "MUSICBRAINZ_ALBUMID")
        if not album_id:
            untagged.append(path)
            continue
        albums.setdefault(album_id, []).append((path, tag))

    moves, notes = [], []

    for album_id, tracks in albums.items():
        tag = tracks[0][1]
        album_artist = first(tag, "ALBUMARTIST", "ALBUM ARTIST", "ARTIST")
        artist_dir, known = artist_folder(album_artist)
        year = first(tag, "ORIGINALDATE", "ORIGINALYEAR", "DATE", "YEAR")[:4] or "0000"
        album_dir = os.path.join(artist_dir, type_folder(tag), f"{year} - {clean(first(tag, 'ALBUM'), folder=True)}")

        discs = max(number(first(t, "DISCTOTAL", "TOTALDISCS", "DISCNUMBER", default="1")) for _p, t in tracks)
        various = len({first(t, "ARTIST") for _p, t in tracks}) > 1
        total = number(first(tag, "TRACKTOTAL", "TOTALTRACKS"))

        for path, t in tracks:
            name = f"{number(first(t, 'DISCNUMBER', default='1'))}-" if discs > 1 else ""
            name += f"{number(first(t, 'TRACKNUMBER')):02d} "
            name += f"{first(t, 'ARTIST')} - " if various else ""
            name += first(t, "TITLE")
            moves.append((path, os.path.join(album_dir, clean(name) + ".flac")))

        cover = next((os.path.join(folder, name)
                      for folder in sorted({os.path.dirname(p) for p, _t in tracks})
                      for name in sorted(os.listdir(folder), key=lambda n: (n != n.lower(), n))  # beets' own first
                      if re.fullmatch(r"cover\.(jpe?g|png)", name, re.I)), None)
        if cover:
            moves.append((cover, os.path.join(album_dir, os.path.basename(cover).lower())))
        else:
            notes.append(f"{album_dir}: no cover image")

        notes.append(f"{album_dir}: {len(tracks)} tracks"
                     + (f" of {total}, INCOMPLETE" if total and len(tracks) < total else "")
                     + ("" if known else f"; new artist folder {artist_dir!r}, it needs artist.jpg"))
        if os.path.exists(os.path.join(LIBRARY, album_dir)):
            notes.append(f"{album_dir}: ALREADY IN THE LIBRARY, publish will refuse")

    return moves, notes, untagged


def cmd_organize(args):
    moves, notes, untagged = plan(args.dir)

    targets = [target for _source, target in moves]
    clashes = {t for t in targets if targets.count(t) > 1}

    for source, target in moves:
        print(f"{os.path.relpath(source, args.dir)}\n  -> {target}" + ("   CLASH" if target in clashes else ""))
    for path in untagged:
        print(f"untagged, left where it is: {os.path.relpath(path, args.dir)}")
    for note in notes:
        print(f"* {note}")

    if clashes:
        sys.exit("mlib: two files want the same name, nothing moved")
    if not moves:
        sys.exit("mlib: nothing to organize (no MUSICBRAINZ_ALBUMID tags: tag first)")
    if not args.apply:
        print(f"\nplan only; --apply moves these under {args.stage}")
        return

    for source, target in moves:
        target = os.path.join(args.stage, target)
        if os.path.exists(target):
            sys.exit(f"mlib: {target} exists, stopped midway")
        os.makedirs(os.path.dirname(target), exist_ok=True)
        shutil.move(source, target)

    print(f"\nstaged under {args.stage}:")
    for album in sorted({os.path.dirname(target) for _source, target in moves}):
        print(os.path.join(args.stage, album))


# lyrics #

def fetch(url):
    request = urllib.request.Request(url, headers={"User-Agent": AGENT})
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.read()


def cmd_lyrics(args):
    counts = {"synced": 0, "plain": 0, "instrumental": 0, "missing": 0, "kept": 0}

    for path in flacs(args.dir):
        base = os.path.splitext(path)[0]
        if os.path.exists(base + ".lrc") or os.path.exists(base + ".txt"):
            counts["kept"] += 1
            continue

        tag = tags(path)
        samples, rate = subprocess.run(["metaflac", "--show-total-samples", "--show-sample-rate", path],
                                       capture_output=True, text=True, check=True).stdout.split()
        query = urllib.parse.urlencode({
            "artist_name": first(tag, "ARTIST"), "track_name": first(tag, "TITLE"),
            "album_name": first(tag, "ALBUM"), "duration": round(int(samples) / int(rate)),
        })

        try:
            found = json.loads(fetch("https://lrclib.net/api/get?" + query))
        except urllib.error.HTTPError as error:
            if error.code != 404:
                print(f"LRCLIB answered {error.code} for {os.path.basename(path)}")
            found = {}
        except (urllib.error.URLError, TimeoutError, ValueError) as error:
            sys.exit(f"mlib: LRCLIB unreachable ({error})")

        if found.get("syncedLyrics"):
            kind, extension, text = "synced", ".lrc", found["syncedLyrics"]
        elif found.get("plainLyrics"):
            kind, extension, text = "plain", ".txt", found["plainLyrics"]
        else:
            counts["instrumental" if found.get("instrumental") else "missing"] += 1
            continue

        with open(base + extension, "w", encoding="utf-8") as file:
            file.write(text.rstrip("\n") + "\n")
        counts[kind] += 1

    print(", ".join(f"{n} {kind}" for kind, n in counts.items() if n) or "no tracks")


# artist art #

def cmd_artist_art(args):
    folder = args.dir.rstrip("/")
    existing = [n for n in os.listdir(folder) if re.fullmatch(r"artist\.(jpe?g|png|webp)", n, re.I)]
    if existing:
        print(f"already there: {existing[0]}")
        return

    name = args.name or os.path.basename(folder)
    found = json.loads(fetch("https://api.deezer.com/search/artist?" + urllib.parse.urlencode({"q": name})))
    # Namesakes and tribute acts share the name; the one people follow is the one meant.
    match = max((a for a in found.get("data", []) if fingerprint(a["name"]) == fingerprint(name)),
                key=lambda a: a.get("nb_fan", 0), default=None)

    # Deezer hands out a grey placeholder for artists without a picture; its URL has no image hash.
    if match is None or "/artist//" in match.get("picture_xl", "/artist//"):
        sys.exit(f"mlib: Deezer has no picture for {name!r}; find one by hand and save it as {folder}/artist.jpg")

    with open(os.path.join(folder, "artist.jpg"), "wb") as file:
        file.write(fetch(match["picture_xl"]))
    print(f"{folder}/artist.jpg  (Deezer: {match['name']}, {match.get('nb_fan', 0)} fans; look at it, namesakes exist)")


# cover #

COVERS = "https://covers.musichoarders.xyz/"


def image_info(data):
    """(extension, width, height) of a JPEG or PNG, or None."""
    if data[:8] == b"\x89PNG\r\n\x1a\n":
        return "png", int.from_bytes(data[16:20], "big"), int.from_bytes(data[20:24], "big")
    if data[:2] != b"\xff\xd8":
        return None
    at = 2
    while at + 9 < len(data) and data[at] == 0xFF:
        marker, length = data[at + 1], int.from_bytes(data[at + 2:at + 4], "big")
        # The frame header (SOF0-SOF15, bar the three that are tables) holds the size.
        if 0xC0 <= marker <= 0xCF and marker not in (0xC4, 0xC8, 0xCC):
            return "jpg", int.from_bytes(data[at + 7:at + 9], "big"), int.from_bytes(data[at + 5:at + 7], "big")
        at += 2 + length
    return None


def covers_in(folder):
    return sorted(n for n in os.listdir(folder) if re.fullmatch(r"cover\.(jpe?g|png)", n, re.I))


def cmd_cover(args):
    folder = os.path.abspath(args.dir)
    if os.path.commonpath([folder, os.path.abspath(LIBRARY)]) == os.path.abspath(LIBRARY):
        sys.exit("mlib: cover works on a staged album, not on the library")
    tracks = [p for p in flacs(folder) if os.path.dirname(p) == folder]
    if not tracks:
        sys.exit(f"mlib: no .flac files in {folder}: give the album folder")

    if args.image is None:
        for name in covers_in(folder):
            with open(os.path.join(folder, name), "rb") as file:
                info = image_info(file.read())
            print(f"now: {name}  " + (f"{info[1]}x{info[2]}" if info else "not a JPEG or PNG"))
        if not covers_in(folder):
            print("now: no cover")

        tag = tags(tracks[0])
        query = {"artist": first(tag, "ALBUMARTIST", "ARTIST"), "album": first(tag, "ALBUM")}
        if first(tag, "RELEASECOUNTRY").lower() not in ("", "xw", "xe"):
            query["country"] = first(tag, "RELEASECOUNTRY").lower()
        print("pick one at covers.musichoarders.xyz (Covers by MusicHoarders), then: mlib cover DIR IMAGE-URL")
        print(COVERS + "?" + urllib.parse.urlencode(query, quote_via=urllib.parse.quote))
        return

    # The site is for a person to choose on; what it hands back is the image's
    # address at the shop it came from, and that is all this fetches.
    if urllib.parse.urlparse(args.image).netloc.endswith("musichoarders.xyz"):
        sys.exit("mlib: that is the search page; give the address of the image picked on it")

    if re.match(r"https?://", args.image):
        data = fetch(args.image)
    else:
        with open(args.image, "rb") as file:
            data = file.read()

    info = image_info(data)
    if info is None:
        sys.exit("mlib: that is not a JPEG or PNG (a web page, or WebP?); nothing changed")

    extension, width, height = info
    for name in covers_in(folder):
        os.remove(os.path.join(folder, name))
    with open(os.path.join(folder, "cover." + extension), "wb") as file:
        file.write(data)

    notes = [n for n in ("under 1000 px" if min(width, height) < 1000 else "",
                         "not square" if abs(width - height) > max(width, height) * 0.02 else "") if n]
    print(f"{folder}/cover.{extension}  {width}x{height}, {len(data) // 1024}K" + (f"  ({', '.join(notes)})" if notes else ""))


# publish #

def cmd_publish(args):
    if args.album:
        albums = [os.path.relpath(os.path.abspath(a), args.stage) for a in args.album]
        if any(a.startswith("..") for a in albums):
            sys.exit(f"mlib: publish takes album folders under {args.stage}")
    else:
        albums = sorted({os.path.relpath(os.path.dirname(p), args.stage) for p in flacs(args.stage)})

    if not albums:
        sys.exit(f"mlib: nothing staged under {args.stage}")

    for album in albums:
        source, target = os.path.join(args.stage, album), os.path.join(LIBRARY, album)

        if os.path.exists(target):
            print(f"SKIPPED, already in the library: {target}")
            continue

        # Staging and the library are different disks: copy, compare, then drop the staged copy.
        os.makedirs(os.path.dirname(target), exist_ok=True)
        shutil.copytree(source, target)
        for name in os.listdir(source):
            if os.path.getsize(os.path.join(source, name)) != os.path.getsize(os.path.join(target, name)):
                sys.exit(f"mlib: {name} differs after the copy; both copies kept, look at {target}")
        shutil.rmtree(source)
        print(target)

        # The artist picture rides along with the first album of a new artist.
        artist = album.split(os.sep)[0]
        for name in os.listdir(os.path.join(args.stage, artist)):
            staged = os.path.join(args.stage, artist, name)
            if os.path.isfile(staged) and not os.path.exists(os.path.join(LIBRARY, artist, name)):
                shutil.move(staged, os.path.join(LIBRARY, artist, name))
                print(os.path.join(LIBRARY, artist, name))

    for folder, _dirs, _names in os.walk(args.stage, topdown=False):
        if folder != args.stage and not os.listdir(folder):
            os.rmdir(folder)


def main():
    parser = argparse.ArgumentParser(prog="mlib", description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)

    prep = sub.add_parser("prep")
    prep.add_argument("dir")
    prep.set_defaults(run=cmd_prep)

    tidy = sub.add_parser("tidy")
    tidy.add_argument("dir")
    tidy.set_defaults(run=cmd_tidy)

    organize = sub.add_parser("organize")
    organize.add_argument("dir")
    organize.add_argument("--apply", action="store_true")
    organize.add_argument("--stage", default=STAGE)
    organize.set_defaults(run=cmd_organize)

    lyrics = sub.add_parser("lyrics")
    lyrics.add_argument("dir")
    lyrics.set_defaults(run=cmd_lyrics)

    art = sub.add_parser("artist-art")
    art.add_argument("dir", help="the artist's folder, staged or in the library")
    art.add_argument("--name", help="artist name to search for, if the folder name is not it")
    art.set_defaults(run=cmd_artist_art)

    cover = sub.add_parser("cover")
    cover.add_argument("dir", help="a staged album folder")
    cover.add_argument("image", nargs="?", help="URL or file of the picked image; without it, print the search link")
    cover.set_defaults(run=cmd_cover)

    publish = sub.add_parser("publish")
    publish.add_argument("album", nargs="*", help="staged album folders (default: everything staged)")
    publish.add_argument("--stage", default=STAGE)
    publish.set_defaults(run=cmd_publish)

    args = parser.parse_args()
    args.run(args)


if __name__ == "__main__":
    main()
