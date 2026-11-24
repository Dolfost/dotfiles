---
name: shows
description: Get an episode of a TV show or cartoon for Vladyslav's Jellyfin library on aorus - find it on Soulseek through his running Nicotine+, download the one file, check it really is that episode and plays, and file it in the shows layout. Use when he asks to get, download or add an episode or a season of a show, and when the watchlist timer asks for a new episode.
---

# Adding an episode to the shows library

Everything happens on **aorus**: the libraries, the Nicotine+ container and
the commands below. On any other machine prefix each command with
`ssh daorus`. If ssh does not answer, say so and stop.

| path | what |
|---|---|
| `/storage/2.5/media/shows`, `/storage/3.5/media/shows` | the libraries Jellyfin serves; a show lives in one of them |
| `/storage/data/soulseek/claude/<job>` | one download per job folder |

The layout: `Show/Season NN/Show - SxxEyy - Title.mkv`. The show's folder
may be spelled differently from its name (`South_Park`): `ls` both
libraries and use the folder that exists.

## The run

### 1. Pin down the episode

Know the season and episode number, the title and the running time before
searching. TVmaze has them, free and without a key:

```sh
curl -s 'https://api.tvmaze.com/singlesearch/shows?q=south+park&embed=episodes' \
  | jq -r '._embedded.episodes[-5:][] | [.season, .number, .airdate, .runtime, .name] | @tsv'
```

`runtime` is the broadcast slot: a 30 minute slot is about 22 minutes of
episode. Check the season folder first; if the episode is there, stop.

### 2. Search and choose

```sh
slsk search --any south park s29e05
slsk show 1234567 2        # the files of candidate 2
```

`--any` is what makes `slsk` list folders without FLAC. Soulseek matches
words against file paths, so a few plain words and the `s29e05` code. No
results: try the other spelling (`29x05`), then the episode's title. Soulseek
is a music network; a new episode often is not there for days, and "not
found" is a normal outcome, not something to work around.

A candidate is a folder, but only the files that matched the search are in
it. Pick by the file:

- It names the right show, season and episode. A whole-season pack that
  matched only by its folder name is the wrong thing for one episode.
- 1080p when there is one, else 720p. A 22 minute episode is roughly
  200 MB to 1.5 GB; far below that is a sample or a phone encode.
- The original English audio unless he asked for a dub.
- A free slot beats speed; `q57` is a queue 57 long.

### 3. Download

```sh
slsk get 1234567 2 --only --match s29e05 --job south-park-s29e05
slsk wait south-park-s29e05
```

`--only` takes just the matched files; without it `slsk` asks for the
uploader's whole folder, which for a show is the whole season. `--match`
narrows them further (a regex on the path, case ignored).

Stalled or failed: `slsk ls JOB`, `slsk retry JOB` once, then `slsk clear
JOB`, remove the job folder and take the next candidate under a new job
name. One uploader at a time.

### 4. Check it

```sh
ffprobe -v error -show_entries format=duration:stream=codec_type,codec_name,height \
  -of json '/storage/data/soulseek/claude/south-park-s29e05/FILE.mkv'
```

It has a video and an audio stream, the height matches what the name
claimed, and the duration is that of the episode (within a couple of
minutes). A wrong length means a different episode, a sample or a cut:
discard it and take another candidate.

### 5. File it

When the watchlist timer asked, stop here and report the file's path: it
files the episode itself. Otherwise:

```sh
mkdir -p '/storage/2.5/media/shows/South_Park/Season 29'
mv -n '/storage/data/soulseek/claude/south-park-s29e05/FILE.mkv' \
  '/storage/2.5/media/shows/South_Park/Season 29/South Park - S29E05 - We Be Clubbin'\''.mkv'
slsk clear south-park-s29e05 && rm -r /storage/data/soulseek/claude/south-park-s29e05
```

Jellyfin notices the new file on its own; its `.nfo` and thumbnail appear
with the next library scan.

## Rules

- Never overwrite or delete what is in the library (`mv -n`). If he wants a
  better copy of an episode he has, download it and let him swap.
- Be a decent peer: a handful of searches per episode, one uploader at a
  time, no retry loops against a user who is offline.
- `slsk` answers "no answer on the socket" when the container is down or
  the Agent API plugin is off. The service is `systemctl --user status
  nicotine` on aorus; restarting it interrupts his transfers, so ask first.
