"""slsk: search Soulseek and download through the running Nicotine+.

The client of the Agent API plugin (containers/nicotine/plugins/agent_api),
which listens on a unix socket in Nicotine+'s data folder. Runs on the host
that runs the nicotine container.

  slsk status
  slsk search TERM...            folders that match, best first
  slsk show SEARCH N             the files of candidate N
  slsk get SEARCH N [--job J]    download candidate N into the job folder
                                 (--only: just the files the search matched)
  slsk wait JOB                  block until the job is done, stalls or times out
  slsk ls [JOB]                  transfers
  slsk retry|abort|clear JOB     clear forgets the transfers, files stay
"""

import argparse
import json
import os
import re
import socket
import sys
import time

SOCKET = os.environ.get("SLSK_SOCKET", "/storage/2.5/nicotine/data/agent_api.sock")
# download_root of the plugin (/downloads/claude in the container), as the host sees it
HOST_ROOT = os.environ.get("SLSK_HOST_ROOT", "/storage/data/soulseek/claude")
CONTAINER_ROOT = "/downloads/claude"
CACHE = os.path.join(os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")), "slsk")

LOSSLESS = {"flac"}
AUDIO = LOSSLESS | {"mp3", "m4a", "ogg", "opus", "ape", "wv", "wav", "aiff", "aif", "wma", "dsf"}
DISC_FOLDER = re.compile(r"^(cd|disc|disk|dvd|vinyl|lp|side)[ ._-]*[0-9a-d]{1,2}\b", re.I)
BITRATE, DURATION, SAMPLE_RATE, BIT_DEPTH = "0", "1", "4", "5"
FAILED = {"User logged off", "Connection closed", "Connection timeout", "Cancelled", "Paused",
          "Download folder error", "Local file error", "Filtered"}


def call(cmd, **args):
    try:
        with socket.socket(socket.AF_UNIX) as sock:
            sock.settimeout(30)
            sock.connect(SOCKET)
            sock.sendall(json.dumps({"cmd": cmd, **args}).encode() + b"\n")
            reply = json.loads(sock.makefile("rb").readline())
    except (OSError, ValueError) as error:
        sys.exit(f"slsk: no answer on {SOCKET} ({error}). Is the nicotine container up, "
                 "and the Agent API plugin enabled in Preferences > Plugins?")

    if not reply["ok"]:
        sys.exit(f"slsk: {reply['error']}")

    return reply["result"]


def ext(path):
    return path.rpartition(".")[2].lower() if "." in path.rpartition("\\")[2] else ""


def human(size):
    for unit in ("B", "K", "M", "G"):
        if size < 1024 or unit == "G":
            return f"{size:.0f}{unit}" if unit in "BK" else f"{size:.1f}{unit}"
        size /= 1024


def clock(seconds):
    return f"{seconds // 60}:{seconds % 60:02d}"


def fold(responses):
    """One candidate per user and album folder; disc subfolders go to their parent."""

    candidates = {}

    for response in responses:
        for path, size, attributes in response["files"]:
            folder = path.rpartition("\\")[0]
            parent, _, leaf = folder.rpartition("\\")

            if DISC_FOLDER.match(leaf) and parent:
                folder = parent

            candidate = candidates.setdefault((response["user"], folder), {
                "user": response["user"], "folder": folder, "free": response["free"],
                "speed": response["speed"], "queue": response["queue"], "files": [],
            })
            candidate["files"].append([path, size, attributes or {}])

    return list(candidates.values())


def describe(candidate):
    files = candidate["files"]
    audio = [f for f in files if ext(f[0]) in AUDIO]
    lossless = [f for f in audio if ext(f[0]) in LOSSLESS]
    names = [f[0].rpartition("\\")[2].lower() for f in files]
    formats = sorted({
        f"{f[2].get(SAMPLE_RATE, 0) / 1000:g}/{f[2].get(BIT_DEPTH, '?')}" for f in lossless if f[2].get(SAMPLE_RATE)
    })

    candidate.update({
        "tracks": len(lossless),
        "other_audio": len(audio) - len(lossless),
        "size": sum(f[1] for f in files),
        "duration": sum(f[2].get(DURATION, 0) for f in lossless),
        "formats": formats,
        "log": any(n.endswith(".log") for n in names),
        "cue": any(n.endswith(".cue") for n in names),
    })
    return candidate


def rank(candidate, tracks, duration):
    score = 0.0

    if tracks:
        score -= 6 * abs(candidate["tracks"] - tracks)
    if duration and candidate["duration"]:
        score -= min(abs(candidate["duration"] - duration) / 5, 20)

    score += 4 if candidate["free"] else -min(candidate["queue"], 200) / 25
    score += min(candidate["speed"] / 1_000_000, 4)   # bytes/s; 4 points at 4 MB/s
    score += 2 if candidate["log"] else 0
    score += 1 if candidate["cue"] else 0
    score -= 3 if candidate["other_audio"] else 0     # mixed formats: someone's working folder
    return score


def cache_path(search):
    return os.path.join(CACHE, f"{search}.json")


def load(search, number):
    try:
        with open(cache_path(search), encoding="utf-8") as file:
            candidates = json.load(file)["candidates"]
        return candidates[number - 1]
    except (OSError, IndexError, ValueError):
        sys.exit(f"slsk: no candidate {number} in search {search} (searches are kept in {CACHE})")


def cmd_status(_args):
    print(json.dumps(call("status"), indent=1))


def cmd_search(args):
    term = " ".join(args.term)
    search = call("search", term=term)
    token, count, quiet_since = search["token"], -1, time.time()
    deadline = time.time() + args.wait

    # Answers trickle in from peers for a while; stop once they have dried up.
    while time.time() < deadline:
        time.sleep(1)
        responses = call("results", token=token)["responses"]

        if len(responses) != count:
            count, quiet_since = len(responses), time.time()
        elif count and time.time() - quiet_since > 4:
            break

    call("search-close", token=token)

    candidates = [describe(c) for c in fold(responses)]
    if not args.any:
        candidates = [c for c in candidates if c["tracks"]]
    if args.tracks and args.exact:
        candidates = [c for c in candidates if c["tracks"] == args.tracks]

    candidates.sort(key=lambda c: rank(c, args.tracks, args.duration), reverse=True)

    os.makedirs(CACHE, exist_ok=True)
    with open(cache_path(token), "w", encoding="utf-8") as file:
        json.dump({"term": term, "time": time.time(), "candidates": candidates}, file)

    print(f"search {token}: {search['term']!r}, {count} users answered, "
          f"{len(candidates)} folders" + ("" if args.any else " with FLAC"))

    for number, c in enumerate(candidates[:args.top], 1):
        slot = "free" if c["free"] else f"q{c['queue']}"
        extras = "+".join(name for name in ("log", "cue") if c[name]) or "-"
        mixed = f" +{c['other_audio']} lossy" if c["other_audio"] else ""
        # Not music at all (--any, a video): the count is of the matched files.
        count = f"{c['tracks']:>3} flac{mixed}" if c["tracks"] or c["other_audio"] else f"{len(c['files']):>3} files"
        print(f"{number:>3}  {count}  {clock(c['duration']):>7}  {human(c['size']):>6}  "
              f"{','.join(c['formats']) or '?':<9} {extras:<7} {slot:<5} {c['speed'] / 1_000_000:>4.1f}MB/s  "
              f"{c['user']}  {c['folder']}")

    if len(candidates) > args.top:
        print(f"... {len(candidates) - args.top} more, see --top")


def cmd_show(args):
    candidate = load(args.search, args.n)
    print(f"{candidate['user']}  {candidate['folder']}")

    for path, size, attributes in sorted(candidate["files"]):
        duration = clock(attributes[DURATION]) if DURATION in attributes else ""
        rate = attributes.get(SAMPLE_RATE)
        fmt = f"{rate / 1000:g}/{attributes.get(BIT_DEPTH, '?')}" if rate else ""
        print(f"  {duration:>6}  {human(size):>6}  {fmt:<8} {path[len(candidate['folder']) + 1:]}")


def cmd_get(args):
    candidate = load(args.search, args.n)
    job = args.job or f"{args.search}-{args.n}"
    files, folder = candidate["files"], candidate["folder"]

    if args.match:
        files = [f for f in files if re.search(args.match, f[0], re.I)]
        if not files:
            sys.exit(f"slsk: no file of candidate {args.n} matches {args.match!r}")
    if args.only or args.match:
        # With a folder the plugin asks the user for all of it: right for an
        # album (cover, log), a whole season when one episode was wanted.
        folder = None

    result = call("download", user=candidate["user"], job=job, folder=folder, files=files)
    print(f"job {job}: {result['queued']} files queued from {candidate['user']}")
    print(os.path.join(HOST_ROOT, job))


def summary(transfers):
    done = sum(1 for t in transfers if t["status"] == "Finished")
    size = sum(t["size"] for t in transfers)
    have = sum(t["size"] if t["status"] == "Finished" else t["offset"] for t in transfers)
    speed = sum(t["speed"] for t in transfers if t["status"] == "Transferring")
    states = {}
    for t in transfers:
        if t["status"] != "Finished":
            states[t["status"]] = states.get(t["status"], 0) + 1
    queue = max((t["queue"] for t in transfers if t["status"] == "Queued"), default=0)

    line = f"{done}/{len(transfers)} files, {human(have)}/{human(size)}"
    if speed:
        line += f", {human(speed)}/s"
    if states:
        line += ", " + ", ".join(f"{n} {s.lower()}" for s, n in sorted(states.items()))
    if queue:
        line += f" (place {queue} in the uploader's queue)"
    return line, done, have


def cmd_wait(args):
    start = last_change = last_print = time.time()
    last_have = -1

    while True:
        transfers = call("transfers", job=args.job)
        line, done, have = summary(transfers)
        now = time.time()

        if transfers and done == len(transfers):
            # The folder listing arrives after the visible files were queued,
            # so give late additions (cover, log) a moment to show up.
            time.sleep(5)
            if len(call("transfers", job=args.job)) == len(transfers):
                print(f"done: {line}")
                print(os.path.join(HOST_ROOT, args.job))
                return 0
            continue

        if have != last_have:
            last_have, last_change = have, now

        if now - last_print >= args.every:
            print(line, flush=True)
            last_print = now

        if now - last_change > args.stall:
            print(f"stalled, nothing arrived for {args.stall}s: {line}")
            return 3
        if now - start > args.timeout:
            print(f"timeout: {line}")
            return 2

        time.sleep(5)


def cmd_ls(args):
    transfers = call("transfers", job=args.job)

    for t in sorted(transfers, key=lambda t: (t["folder"], t["path"])):
        percent = 100 * t["offset"] // t["size"] if t["size"] else 0
        state = t["status"] if t["status"] != "Transferring" else f"{percent}% {human(t['speed'])}/s"
        if t["status"] == "Queued" and t["queue"]:
            state += f" #{t['queue']}"
        folder = t["folder"]
        if folder.startswith(CONTAINER_ROOT):
            folder = HOST_ROOT + folder[len(CONTAINER_ROOT):]
        print(f"{state:<18} {human(t['size']):>6}  {t['user']}  "
              f"{os.path.join(folder, t['path'].rpartition(chr(92))[2])}")

    if transfers:
        print(summary(transfers)[0])


def cmd_act(args):
    print(json.dumps(call(args.command, job=args.job)))


def main():
    parser = argparse.ArgumentParser(prog="slsk", description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("status").set_defaults(run=cmd_status)

    search = sub.add_parser("search")
    search.add_argument("term", nargs="+")
    search.add_argument("--tracks", type=int, help="track count of the release wanted; candidates off it sink")
    search.add_argument("--exact", action="store_true", help="with --tracks: drop candidates with another count")
    search.add_argument("--duration", type=int, help="total length of the release in seconds, same use")
    search.add_argument("--any", action="store_true", help="also folders without FLAC")
    search.add_argument("--top", type=int, default=15)
    search.add_argument("--wait", type=int, default=25, help="longest time to collect answers, seconds")
    search.set_defaults(run=cmd_search)

    for name, run in (("show", cmd_show), ("get", cmd_get)):
        command = sub.add_parser(name)
        command.add_argument("search", type=int)
        command.add_argument("n", type=int)
        command.set_defaults(run=run)
        if name == "get":
            command.add_argument("--job", help="folder name under the download root (default SEARCH-N)")
            command.add_argument("--only", action="store_true",
                                 help="just the files the search matched, not the rest of the folder")
            command.add_argument("--match", metavar="REGEX",
                                 help="of those, just the ones whose path matches (implies --only)")

    wait = sub.add_parser("wait")
    wait.add_argument("job")
    wait.add_argument("--timeout", type=int, default=3600)
    wait.add_argument("--stall", type=int, default=600, help="give up after this long without a byte")
    wait.add_argument("--every", type=int, default=60, help="progress line interval")
    wait.set_defaults(run=cmd_wait)

    ls = sub.add_parser("ls")
    ls.add_argument("job", nargs="?")
    ls.set_defaults(run=cmd_ls)

    for name in ("retry", "abort", "clear"):
        command = sub.add_parser(name)
        command.add_argument("job")
        command.set_defaults(run=cmd_act)

    args = parser.parse_args()
    sys.exit(args.run(args))


if __name__ == "__main__":
    main()
