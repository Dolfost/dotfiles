"""watchlist: look for new episodes and releases, and have Claude fetch them.

  watchlist list                    the items, and what is pending for each
  watchlist check NAME              look, fetch what is new, notify
  watchlist check NAME --dry-run    only say what would be fetched

The items come from Nix (dotfiles.watchlist.items, ./default.nix), which also
gives every item a timer that runs `check`. Finding out what is new costs
nothing: an episode guide (TVmaze) or MusicBrainz is compared with what is on
disk and with the state file. Claude Code is started only for a thing that is
actually missing, headless, with the shows or the music skill, and reports
back in one `WATCHLIST: ...` line. Something not on Soulseek yet stays
pending and is tried again on the next run, until giveUpDays have passed.
"""

import argparse
import datetime
import fcntl
import json
import os
import re
import shutil
import socket
import subprocess
import sys
import time
import urllib.error
import urllib.request

CONFIG = os.environ.get("WATCHLIST_CONFIG", os.path.expanduser("~/.config/watchlist/config.json"))
STATE = os.path.join(os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")), "watchlist")
# Where slsk puts its job folders (nix/modules/user/music/slsk.py).
DOWNLOADS = os.environ.get("SLSK_HOST_ROOT", "/storage/data/soulseek/claude")
AGENT = "watchlist/1 (personal use)"
VIDEO = {"mkv", "mp4", "m4v", "avi", "webm"}
EPISODE = re.compile(r"S(\d{1,2})E(\d{1,3})", re.I)
VERDICT = re.compile(r"^WATCHLIST:\s*(\S+)\s*(.*)$", re.M)
SETTLE_HOURS = 6   # an episode counts as out this long after it aired

UNATTENDED = """\
You are run by a timer and nobody is at the terminal: do not ask questions
and do not use ntfy-ask or ntfy-cmd, the caller sends the notification.
Only a fixed list of commands is allowed here, so keep every Bash call
simple: literal arguments, no shell variables, no $(...), no pipes except
into jq. Do not run anything in the background: wait for a download with
`slsk wait JOB --timeout 540` and repeat that while it still makes progress
(exit 2 means it ran out of time, 3 that the download stalled)."""


def today():
    return datetime.date.today().isoformat()


def fetch(url):
    request = urllib.request.Request(url, headers={"User-Agent": AGENT})
    for attempt in range(3):
        try:
            with urllib.request.urlopen(request, timeout=30) as reply:
                return json.load(reply)
        except (urllib.error.URLError, TimeoutError, ValueError) as error:
            last = error
            time.sleep(5 * (attempt + 1))
    sys.exit(f"watchlist: {url}: {last}")


def load_state(name):
    try:
        with open(os.path.join(STATE, f"{name}.json"), encoding="utf-8") as file:
            return json.load(file)
    except (OSError, ValueError):
        # `since`: an item with nothing to compare against only wants what
        # comes out from its first run on.
        return {"since": today(), "things": {}}


def save_state(name, state):
    path = os.path.join(STATE, f"{name}.json")
    with open(path + ".tmp", "w", encoding="utf-8") as file:
        json.dump(state, file, indent=1)
    os.replace(path + ".tmp", path)


# What is out and not here ---------------------------------------------------

def episodes_on_disk(path):
    have = set()
    for _root, _dirs, files in os.walk(path):
        for name in files:
            match = EPISODE.search(name)
            if match and name.rpartition(".")[2].lower() in VIDEO:
                have.add((int(match[1]), int(match[2])))
    return have


def show_wanted(item, state):
    """Aired regular episodes that are not on disk. Without `since`, only
    those after the newest episode on disk: the gaps further back are his."""

    have = episodes_on_disk(item["path"])
    newest = max(have, default=None)
    cutoff = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(hours=SETTLE_HOURS)
    wanted = []

    for episode in fetch(f"https://api.tvmaze.com/shows/{item['tvmaze']}/episodes"):
        if episode.get("type") != "regular" or not episode.get("number") or not episode.get("airstamp"):
            continue
        key = (episode["season"], episode["number"])
        if key in have or datetime.datetime.fromisoformat(episode["airstamp"]) > cutoff:
            continue
        if item.get("since"):
            new = episode["airdate"] >= item["since"]
        elif newest:
            new = key > newest
        else:
            new = episode["airdate"] >= state["since"]
        if new:
            title = (episode.get("name") or "").strip()
            wanted.append({
                "id": f"S{key[0]:02d}E{key[1]:02d}", "season": key[0], "number": key[1],
                "title": "" if title.upper() == "TBA" else title,
                "date": episode["airdate"], "runtime": episode.get("runtime") or 0,
            })

    return wanted


def artist_wanted(item, state):
    """Release groups of the wanted types, out since `since` (the first run
    when not set). A secondary type (Live, Compilation, Remix...) counts
    only when it is listed in `types` too."""

    since, types, wanted, offset = item.get("since") or state["since"], set(item["types"]), [], 0

    while True:
        page = fetch("https://musicbrainz.org/ws/2/release-group"
                     f"?artist={item['mbid']}&limit=100&offset={offset}&fmt=json")
        groups = page.get("release-groups", [])

        for group in groups:
            date = group.get("first-release-date") or ""
            if group.get("primary-type") not in types or not set(group.get("secondary-types") or []) <= types:
                continue
            # A bare year or month is an announcement, not a release day.
            if len(date) == 10 and since <= date <= today():
                wanted.append({"id": group["id"], "title": group["title"], "date": date,
                               "type": group["primary-type"]})

        offset += len(groups)
        if not groups or offset >= page.get("release-group-count", 0):
            return sorted(wanted, key=lambda thing: thing["date"])
        time.sleep(1.1)   # MusicBrainz: one request a second


def label(item, thing):
    if item["kind"] == "show":
        return f"{item['name']} {thing['id']}" + (f" \"{thing['title']}\"" if thing["title"] else "")
    return f"{item['name']} - {thing['title']} ({thing['type']}, {thing['date']})"


# Getting it -----------------------------------------------------------------

def prompt_for(item, thing, job):
    if item["kind"] == "show":
        return f"""\
Use the shows skill to download one TV episode from Soulseek:
{label(item, thing)}, aired {thing['date']}, a {thing['runtime']} minute slot.
Use the download job name {job}. Download and check it, but do not move it
into the library: the caller files it.

{UNATTENDED}

End your reply with exactly one of these lines:
WATCHLIST: downloaded /absolute/path/of/the/video/file
WATCHLIST: not-found
WATCHLIST: failed <the reason in one line>"""

    return f"""\
Use the music skill to add one release to the library:
{label(item, thing)}, MusicBrainz release group {thing['id']}.
Use the download job name {job}. If it is already in the library, change
nothing. Publishing is approved in advance when the album is complete and
flac-verify calls every track ok: then publish it and remove the job. With
anything less (a suspect track, an incomplete copy, tagging skipped) leave
it staged and say why. Leave the cover as music-tag fetched it.

{UNATTENDED}

End your reply with exactly one of these lines:
WATCHLIST: added <the album's path in the library>
WATCHLIST: staged <why it was not published, in one line>
WATCHLIST: have
WATCHLIST: not-found
WATCHLIST: failed <the reason in one line>"""


def ask_claude(config, prompt):
    command = ["claude", "-p", "--output-format", "json"]
    if config["claude"].get("model"):
        command += ["--model", config["claude"]["model"]]
    # Last: the option takes every argument after it. The prompt goes in on stdin.
    command += ["--allowedTools", *config["claude"]["allowedTools"]]

    try:
        run = subprocess.run(command, input=prompt, capture_output=True, text=True, cwd=STATE,
                             timeout=config["claude"]["timeoutMinutes"] * 60)
        text = json.loads(run.stdout).get("result") or ""
    except subprocess.TimeoutExpired:
        return "failed", "Claude did not finish in time"
    except (OSError, ValueError) as error:
        return "failed", f"could not run Claude: {error}"

    print(text, flush=True)   # for the journal
    verdicts = VERDICT.findall(text)
    if not verdicts:
        return "failed", "Claude gave no verdict" + (f" ({run.stderr.strip()[-200:]})" if run.stderr.strip() else "")
    return verdicts[-1][0], verdicts[-1][1].strip()


def file_episode(item, thing, source, job):
    """Move a downloaded episode into `path/Season NN/Show - SxxEyy - Title.ext`.
    The path is Claude's word, so it has to be a video inside the download
    root; nothing in the library is ever overwritten."""

    source = os.path.realpath(source)
    extension = source.rpartition(".")[2].lower()
    if not source.startswith(os.path.realpath(DOWNLOADS) + os.sep) or not os.path.isfile(source):
        raise ValueError(f"{source} is not a file under {DOWNLOADS}")
    if extension not in VIDEO or os.path.getsize(source) < 20 * 1024 * 1024:
        raise ValueError(f"{source} does not look like an episode")

    name = f"{item['name']} - {thing['id']}"
    if thing["title"]:
        name += " - " + re.sub(r"[/\\\0]", "-", thing["title"])
    folder = os.path.join(item["path"], f"Season {thing['season']:02d}")
    target = os.path.join(folder, f"{name}.{extension}")
    if os.path.exists(target):
        raise ValueError(f"{target} is already there")

    os.makedirs(folder, exist_ok=True)
    shutil.move(source, target)
    # The job folder is this run's own; what is left in it is the uploader's
    # nfo and samples.
    subprocess.run(["slsk", "clear", job], capture_output=True)
    shutil.rmtree(os.path.join(DOWNLOADS, job), ignore_errors=True)
    return target


def notify(config, message):
    message = f"{socket.gethostname()}: {message}"
    print(f"notify: {message}", flush=True)
    try:
        subprocess.run(["ntfy-cmd", config["topic"], message], timeout=30)
    except (OSError, subprocess.TimeoutExpired) as error:
        print(f"watchlist: ntfy-cmd: {error}", file=sys.stderr)


def get(config, item, name, thing):
    job = re.sub(r"[^a-z0-9]+", "-", f"watch-{name}-{thing['id'][:8]}".lower()).strip("-")
    verdict, detail = ask_claude(config, prompt_for(item, thing, job))

    if verdict == "downloaded" and item["kind"] == "show":
        try:
            return "added", file_episode(item, thing, detail, job)
        except (OSError, ValueError) as error:
            return "failed", str(error)
    if verdict in ("added", "staged", "have", "not-found") and (item["kind"] == "artist" or verdict == "not-found"):
        return verdict, detail
    return "failed", detail or f"unexpected verdict {verdict!r}"


# Commands -------------------------------------------------------------------

def item_of(config, name):
    if name not in config["items"]:
        sys.exit(f"watchlist: no item {name!r}; there are: {', '.join(sorted(config['items']))}")
    return config["items"][name]


def pending(item, state):
    wanted = show_wanted(item, state) if item["kind"] == "show" else artist_wanted(item, state)
    return [thing for thing in wanted if state["things"].get(thing["id"], {}).get("status") != "done"]


def cmd_check(config, args):
    item = item_of(config, args.name)
    os.makedirs(STATE, exist_ok=True)

    if args.dry_run:
        state = load_state(args.name)
        wanted = pending(item, state)
        for number, thing in enumerate(wanted):
            tries = state["things"].get(thing["id"], {}).get("tries", 0)
            print(("would get  " if number < config["maxPerRun"] else "later      ")
                  + label(item, thing) + (f"  [tried {tries}x]" if tries else ""))
        if not wanted:
            print("nothing new")
        return 0

    # One at a time across all items: they share Nicotine+ and the staging tree.
    lock = open(os.path.join(STATE, "lock"), "w")
    fcntl.flock(lock, fcntl.LOCK_EX)

    state = load_state(args.name)
    wanted = pending(item, state)
    save_state(args.name, state)   # pins `since` on the first run
    print(f"{args.name}: {len(wanted)} new" + (f", taking {config['maxPerRun']}" if len(wanted) > config["maxPerRun"] else ""))

    for thing in wanted[:config["maxPerRun"]]:
        entry = state["things"].setdefault(thing["id"], {"first": today(), "tries": 0, "title": label(item, thing)})
        age = (datetime.date.today() - datetime.date.fromisoformat(entry["first"])).days

        if age > config["giveUpDays"]:
            entry.update(status="done", result="gave up")
            notify(config, f"gave up on {label(item, thing)}: not on Soulseek after {age} days")
        else:
            print(f"getting {label(item, thing)}", flush=True)
            verdict, detail = get(config, item, args.name, thing)
            entry.update(tries=entry["tries"] + 1, result=f"{verdict} {detail}".strip(), last=today())
            print(f"{thing['id']}: {entry['result']}", flush=True)

            if verdict == "added":
                entry["status"] = "done"
                notify(config, f"added {label(item, thing)}")
            elif verdict == "staged":
                entry["status"] = "done"
                notify(config, f"{label(item, thing)} is downloaded but only staged, it needs you: {detail}")
            elif verdict == "have":
                entry["status"] = "done"
            elif verdict == "failed" and not entry.get("told"):
                # Once; it is tried again on the next run either way.
                entry["told"] = True
                notify(config, f"could not get {label(item, thing)}: {detail}. Will retry.")

        save_state(args.name, state)

    return 0


def cmd_list(config, _args):
    for name, item in sorted(config["items"].items()):
        things = load_state(name)["things"]
        waiting = [entry for entry in things.values() if entry.get("status") != "done"]
        source = f"tvmaze {item['tvmaze']}" if item["kind"] == "show" else f"mbid {item['mbid']}"
        print(f"{name:<20} {item['kind']:<7} {item['every']:<12} {item['name']}  ({source})"
              f"  {len(things) - len(waiting)} done, {len(waiting)} pending")
        for entry in waiting:
            print(f"    pending since {entry['first']}, tried {entry['tries']}x: {entry.get('title', '?')}"
                  f"  [{entry.get('result', '')}]")
    return 0


def main():
    parser = argparse.ArgumentParser(prog="watchlist", description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("list").set_defaults(run=cmd_list)
    check = sub.add_parser("check")
    check.add_argument("name")
    check.add_argument("--dry-run", action="store_true", help="say what would be fetched, fetch nothing")
    check.set_defaults(run=cmd_check)
    args = parser.parse_args()

    try:
        with open(CONFIG, encoding="utf-8") as file:
            config = json.load(file)
    except (OSError, ValueError) as error:
        sys.exit(f"watchlist: {CONFIG}: {error}")

    sys.exit(args.run(config, args))


if __name__ == "__main__":
    main()
