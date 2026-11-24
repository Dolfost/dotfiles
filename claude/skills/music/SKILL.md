---
name: music
description: Add music to Vladyslav's library on aorus - find an album on Soulseek through his running Nicotine+, download it, check the FLACs are genuine (not lossy transcodes or upsampled), tag from MusicBrainz, resample, ReplayGain, lyrics, cover and artist art, and file it in the library layout. Use when he asks to get, download or add an album, artist or track, to check whether FLACs are fake, or to tag or organize music he already has.
---

# Adding music to the library

Everything happens on **aorus**: the library (`/storage/2.5/media/music`,
served by Navidrome), the Nicotine+ container, and the commands below. On
any other machine prefix each command with `ssh daorus` (quote the remote
command as one string; paths have spaces). If ssh does not answer, say so
and stop; do not try to wake the machine.

| path | what |
|---|---|
| `/storage/2.5/media/music` | the library. Only `mlib publish` writes to it |
| `/storage/data/soulseek/claude/<job>` | one download per job folder |
| `/storage/data/soulseek/claude/stage` | albums named and ready, awaiting publish |

The library layout, which `mlib` produces and you never build by hand:
`Artist/{Albums,EPs,Singles,Live,Compilations,Soundtracks,…}/YEAR - Album/NN [Artist - ]Title.flac`,
with `cover.jpg` and `.lrc`/`.txt` lyrics beside the tracks and `artist.jpg`
in the artist folder. 44.1 kHz FLAC, bit depth as released, no embedded art.

## The run

Each command has `--help` with the details; this is the order and the
judgment in between.

### 1. Pin down the release

Find it on MusicBrainz first, so you know what a complete copy looks like.
One request a second at most, with a User-Agent:

```sh
curl -s -A 'music-skill/1 (personal use)' \
  'https://musicbrainz.org/ws/2/release?fmt=json&limit=15&query=artist:"Burial" AND release:"Untrue"' \
  | jq -r '.releases[] | [.id, .date, .country, (.media|map(.format)|join("+")), ."track-count", .title, (.disambiguation // "")] | @tsv'
```

Pick the edition he most likely means: the standard one, CD or Digital
Media, not a deluxe or regional variant unless he asked. Note its id, track
count and total length (`/ws/2/release/ID?inc=recordings&fmt=json`, lengths
are in ms). If the editions differ in a way that matters (bonus tracks,
remaster) and he did not say, ask.

Check the library before downloading anything: `ls` the artist's folder.

### 2. Search and choose

```sh
slsk search --tracks 13 --duration 3050 burial untrue
slsk show 1234567 2        # the files of candidate 2
```

Soulseek matches words against file paths: a few plain words, no
punctuation, no "flac". No results at all for a well-known album usually
means the server filters the artist's name; search the album title alone,
or a track title.

The list is already ranked (track count and length against what you passed,
free upload slot, speed, rip log). Read it anyway:

- The track count must match the release you picked, or be explained
  (`show` it: a hidden track, a bonus disc).
- `24/96`-style formats are fine, they get resampled, but do not prefer
  them: they are bigger, slower and more often fake.
- `log` and `cue` mean a CD rip with its evidence. That is the best
  provenance on offer.
- `q57` is a queue 57 long; a slower user with a free slot finishes first.

### 3. Download

```sh
slsk get 1234567 2 --job burial-untrue
slsk wait burial-untrue      # run it in the background, it exits when done
```

`wait` exits 0 when everything arrived, 3 if nothing moved for ten minutes,
2 on timeout. Stalled or a file failed: `slsk ls JOB` to see why, `slsk
retry JOB` once, then give up on that user: `slsk clear JOB`, remove the
job folder, take the next candidate under a new job name. Do not queue the
same album from several users at once; it occupies their upload slots.

### 4. Verify

```sh
flac-verify --spectrograms /tmp/spec-burial /storage/data/soulseek/claude/burial-untrue
```

- **fail** (does not decode, or a brick wall at 16 kHz): discard and take
  another candidate.
- **suspect**: look before deciding. A spectrogram PNG is written for every
  file that is not ok; read it (copy it over first when you are not on
  aorus). A transcode shows a flat-topped spectrum with a hard edge and
  nothing above; real music thins out gradually. The album line matters
  most: "every track is cut at the same 18.6 kHz" is a transcode, one
  suspect track on an otherwise clean album is usually just a dull
  recording.
- A wall near 20 kHz on a release that only ever existed as a web download
  (Bandcamp, SoundCloud artists) is often how the artist made it, and no
  better copy exists. Say so and let him decide.
- **ok** does not prove lossless: MP3 V0 and good AAC pass. A rip log
  counts for more than a clean spectrum.

When in doubt, a second copy from another user is cheap: if it has the same
flaw, the flaw is the release.

### 5. Prepare, tag, file

```sh
J=/storage/data/soulseek/claude/burial-untrue
mlib prep "$J"                       # strip embedded art, resample to 44.1 kHz
music-tag "$J" RELEASE-MBID          # tags + cover.jpg; exits 1 if beets skipped it
mlib organize "$J"                   # the plan: read it
mlib organize --apply "$J"           # into the staging tree
rsgain easy -m 4 '/storage/data/soulseek/claude/stage/Burial/Albums/2007 - Untrue'
mlib lyrics /storage/data/soulseek/claude/stage
```

- `music-tag` prints the candidate and its distance. Skipped with the right
  id means the files differ from the release: usually another edition, so
  find the edition that fits (track count, lengths) rather than reaching
  for `--loose`. Use `--loose` only when you can name the difference.
- Read the `organize` plan for the things it flags: INCOMPLETE, no cover,
  ALREADY IN THE LIBRARY, a new artist folder. Check that the type folder
  is the right one (an EP filed under Albums is a MusicBrainz quirk worth
  mentioning).
- Cover: `mlib cover STAGED-ALBUM` prints the size of what `music-tag`
  fetched and a search link for Covers by MusicHoarders
  (https://covers.musichoarders.xyz), prefilled with the artist and album.
  When there is no cover, or it is under 1000 px, not square, or he wants
  a better one, give him that link and say it is that site. He picks there
  and pastes the image's address back; `mlib cover STAGED-ALBUM URL` saves
  it in place of the old one. The choosing is his: the site forbids
  automated use, so never fetch the site or its API yourself, and do not
  hold the rest of the run for it; the link goes with the report in step 6.
- New artist folder: `mlib artist-art STAGE/Artist`, then look at the
  picture; Deezer has namesakes. If it is wrong or missing, leave it out
  and tell him.
- ReplayGain runs on the staged album folder, after organize: that is the
  point where a multi-disc album is one folder, which is what makes the
  album gain right.

### 6. Publish

Show him what is staged: the album path, track count, format, the cover's
size, the verify verdict and anything you were unsure about. Then, on his word:

```sh
mlib publish            # everything staged; refuses to overwrite
slsk clear burial-untrue && rm -r /storage/data/soulseek/claude/burial-untrue
```

Publishing is the one step that needs his go-ahead, unless the request
already gave it ("get it and add it"). Navidrome picks the album up on its
next scan.

## Rules

- Never write into the library except through `mlib publish`, and never
  replace or delete what is already there. If he wants a better copy of an
  album he has, stage the new one and let him swap.
- A suspect or incomplete album is never published silently. Either it is
  fixed, or he was told and chose to keep it.
- Be a decent peer: a handful of searches per album, one uploader at a
  time, no retry loops against a user who is offline.
- `slsk` answers "no answer on the socket" when the container is down or
  the Agent API plugin is off (Nicotine+ > Preferences > Plugins). The
  service is `systemctl --user status nicotine` on aorus; restarting it
  interrupts his uploads and downloads, so ask first.

## Other uses

- "Is this FLAC real?" / "check my library": `flac-verify PATH...` reads
  only, and works on library folders. For a big sweep add `--json` and
  summarize; do not print thousands of lines.
- Music he already has (a folder of files, a Bandcamp download): start at
  step 4 with that folder in place of the job folder. `mlib prep` and
  `music-tag` change files in place, so work on a copy if the folder is
  not a throwaway.
