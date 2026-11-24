"""flac-verify: is this FLAC what it says it is?

  flac-verify [--json] [--spectrograms DIR] PATH...

For every .flac under the paths:

  integrity   `flac -t` decodes the whole file and compares the MD5 of the audio
              with the one in the header. Truncated and corrupt files fail here.
  lossy       a lossy encoder cuts everything above some frequency (16 kHz at
              128k MP3, 19 kHz at 192k, 20.1 kHz at 320k, 20 kHz for Opus), and
              that brick wall survives being re-encoded to FLAC. The average
              spectrum of the track is searched for the steepest drop that is
              followed by nothing; where it sits decides the verdict.
  shelf       MP3 at high bitrates (V0, 320k) may keep content up to 22 kHz but
              starves the band above 16 kHz, which leaves a step there.
  upsampled   a 96 kHz file whose content ends at 22 or 24 kHz was resampled
              from CD or 48 kHz material.
  padded      a 24-bit file whose low 8 bits are always zero is 16-bit audio.

Verdicts: ok, suspect (look at the spectrogram, compare with another source)
and fail. A cut-off is evidence, not proof: old recordings, broadcasts and
some masters are low-passed for real, so a whole album sharing one clean
cut-off below 20 kHz is the strong signal, a single dull track is not.

What it cannot see: MP3 V0 and good AAC keep the full band and pass. A rip
log with AccurateRip matches, or a second source to compare with, is the
only evidence against those.

Exit status: 0 all ok, 1 something suspect, 2 something failed.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

import numpy as np

NFFT = 8192
# Thresholds come from 400 random tracks of the library against transcodes
# made from four of them: real music rarely drops more than 10 dB across
# 600 Hz, transcodes drop 14 to 27 (not more, because decoded lossy audio
# clips and the distortion fills the emptied band).
CLIFF_DB = 12        # drop that counts as a brick wall
EMPTY_DB = 8         # how far below the pre-cliff level the rest must stay
SHELF_DB = 9         # extra step at 16 kHz, over the local slope


def run(*command):
    return subprocess.run(command, capture_output=True, text=True, errors="replace", check=False)


def spectrum(path):
    """Average power spectrum (dB) of the mono mix, plus the bits in use."""

    info = run("metaflac", "--show-sample-rate", "--show-bps", "--show-channels", "--show-md5sum",
               "--show-total-samples", path)
    if info.returncode:
        raise RuntimeError(info.stderr.strip() or "metaflac failed")
    rate, bits, channels, md5, samples = info.stdout.split()
    rate, bits, channels = int(rate), int(bits), int(channels)

    decoder = subprocess.Popen(
        ["ffmpeg", "-v", "error", "-nostdin", "-i", path, "-map", "0:a:0", "-f", "s32le", "-c:a", "pcm_s32le", "-"],
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)

    window = np.hanning(NFFT).astype(np.float32)
    power = np.zeros(NFFT // 2 + 1)
    frames = 0
    used = 0
    block = NFFT * channels * 4 * 64

    while True:
        data = decoder.stdout.read(block)
        if not data:
            break

        pcm = np.frombuffer(data[:len(data) - len(data) % (4 * channels)], dtype="<i4")
        if not pcm.size:
            continue
        used |= int(np.bitwise_or.reduce(pcm))

        mono = pcm.reshape(-1, channels).mean(axis=1, dtype=np.float64).astype(np.float32) / 2 ** 31
        whole = mono.size // NFFT
        if whole:
            chunk = mono[:whole * NFFT].reshape(whole, NFFT) * window
            power += (np.abs(np.fft.rfft(chunk, axis=1)) ** 2).sum(axis=0)
            frames += whole

    decoder.wait()

    if not frames:
        raise RuntimeError("no audio decoded")

    low_zero_bits = (used & -used).bit_length() - 1 if used else 32
    db = 10 * np.log10(power / frames + 1e-20)

    return {
        "rate": rate, "bits": bits, "channels": channels,
        "md5": md5.strip("0") != "",
        "seconds": int(samples) / rate if rate else 0,
        "effective_bits": max(32 - low_zero_bits, 0),
        "db": db,
    }


def band(db, hz_per_bin, low, high):
    low, high = int(low / hz_per_bin), max(int(high / hz_per_bin), int(low / hz_per_bin) + 1)
    return float(np.mean(db[low:high]))


def analyse(path):
    result = {"file": path, "verdict": "ok", "notes": []}

    def flag(verdict, note):
        order = ("ok", "suspect", "fail")
        if order.index(verdict) > order.index(result["verdict"]):
            result["verdict"] = verdict
        result["notes"].append(note)

    test = run("flac", "-t", "-s", path)
    if test.returncode:
        message = (test.stderr.strip().splitlines() or ["flac -t failed"])[-1]
        flag("fail", "does not decode cleanly: " + message.split(": ", 1)[-1])

    try:
        data = spectrum(path)
    except RuntimeError as error:
        flag("fail", str(error))
        return result

    db = data.pop("db")
    rate = data["rate"]
    nyquist = rate / 2
    hz = nyquist / (NFFT // 2)
    result.update(data)

    if not data["md5"]:
        flag("ok", "no MD5 in the header (encoder did not write one, integrity is unchecked)")

    # Smooth over ~150 Hz so single partials and noise don't look like edges.
    width = max(int(150 / hz), 3)
    smooth = np.convolve(db, np.ones(width) / width, mode="same")

    # Steepest edge: level in the 300 Hz before f against the 300 Hz after it.
    best_drop, cutoff = 0.0, None
    f = 14000.0
    while f < nyquist - 600:
        drop = band(smooth, hz, f - 400, f - 100) - band(smooth, hz, f + 100, f + 400)
        if drop > best_drop:
            best_drop, cutoff = drop, f
        f += 50

    wall = False
    if cutoff and best_drop >= CLIFF_DB:
        before = band(smooth, hz, cutoff - 400, cutoff - 100)
        after = smooth[int((cutoff + 300) / hz):int((nyquist - 200) / hz)]
        wall = after.size == 0 or float(np.mean(after < before - EMPTY_DB)) > 0.9

    result["cutoff"] = round(cutoff) if wall else None
    result["drop"] = round(best_drop, 1) if wall else None

    if wall:
        khz = f"{cutoff / 1000:.1f} kHz"
        if cutoff < 16700 and best_drop >= 16:
            flag("fail", f"brick wall at {khz}: transcode from low-bitrate lossy (128k MP3 or worse)")
        elif cutoff < 19800:
            flag("suspect", f"brick wall at {khz}: looks like a 128-256k lossy source")
        elif cutoff < 20400:
            flag("suspect", f"brick wall at {khz}: 320k MP3 or Opus source, or a low-passed master")
        elif cutoff < 20900:
            flag("ok", f"low-passed at {khz}, as early CD masters are (and some AAC)")
        elif cutoff < 0.46 * rate:
            flag("suspect", f"nothing above {khz} in a {rate / 1000:g} kHz file: upsampled")

    # The 16 kHz step of MP3's last scalefactor band, measured against the
    # slope the spectrum already has just below it.
    if not (wall and cutoff < 17000) and nyquist > 17500:
        slope = band(smooth, hz, 14400, 15100) - band(smooth, hz, 15200, 15900)
        step = band(smooth, hz, 15200, 15900) - band(smooth, hz, 16100, 16800)
        result["shelf"] = round(step - max(slope, 0), 1)
        if result["shelf"] >= SHELF_DB:
            flag("suspect", f"{result['shelf']:.0f} dB step at 16 kHz: MP3-like shelf")

    if data["effective_bits"] < data["bits"]:
        note = f"{data['bits']}-bit file uses {data['effective_bits']} bits"
        if data["bits"] > 16 and data["effective_bits"] <= 16:
            flag("suspect", note + ": 16-bit audio padded to 24")
        else:
            flag("ok", note)

    tags = run("metaflac", "--export-tags-to=-", path).stdout
    if re.search(r"^(MQAENCODER|ORIGINALSAMPLERATE)=", tags, re.M | re.I):
        flag("suspect", "MQA-encoded (lossy fold; decodes as noisy 44.1/48k without an MQA decoder)")

    return result


def spectrogram(path, folder):
    os.makedirs(folder, exist_ok=True)
    target = os.path.join(folder, os.path.splitext(os.path.basename(path))[0] + ".png")
    run("ffmpeg", "-v", "error", "-nostdin", "-y", "-i", path, "-lavfi",
        "showspectrumpic=s=1200x600:legend=1:scale=log:gain=4", target)
    return target


def rip_logs(paths):
    notes = []
    for root in paths:
        for folder, _dirs, names in os.walk(root) if os.path.isdir(root) else ():
            for name in names:
                if not name.lower().endswith(".log"):
                    continue
                with open(os.path.join(folder, name), "rb") as file:
                    raw = file.read(2_000_000)
                text = raw.decode("utf-16" if raw[:2] in (b"\xff\xfe", b"\xfe\xff") else "utf-8", errors="replace")
                ripper = ("EAC" if "Exact Audio Copy" in text else "XLD" if "X Lossless Decoder" in text
                          else "whipper" if "whipper" in text else "unknown ripper")
                good = bool(re.search(r"No errors occurr?ed|All tracks accurately ripped", text))
                accurate = len(re.findall(r"Accurately ripped", text, re.I))
                notes.append(f"{name}: {ripper}" + (", no errors" if good else ", ERRORS or incomplete log")
                             + (f", AccurateRip confirmed {accurate}x" if accurate else ""))
    return notes


def main():
    parser = argparse.ArgumentParser(prog="flac-verify", description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("paths", nargs="+")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--spectrograms", metavar="DIR", help="write a PNG for every file that is not ok")
    parser.add_argument("--all-spectrograms", action="store_true", help="with --spectrograms: for every file")
    args = parser.parse_args()

    files, others = [], []
    for root in args.paths:
        walk = os.walk(root) if os.path.isdir(root) else [(os.path.dirname(root), [], [os.path.basename(root)])]
        for folder, _dirs, names in walk:
            for name in sorted(names):
                extension = name.rpartition(".")[2].lower()
                if extension == "flac":
                    files.append(os.path.join(folder, name))
                elif extension in {"mp3", "m4a", "ogg", "opus", "ape", "wv", "wav", "wma"}:
                    others.append(os.path.join(folder, name))
    files.sort()

    if not files:
        sys.exit("flac-verify: no .flac files there")

    with ThreadPoolExecutor(max_workers=min(os.cpu_count() or 2, 6)) as pool:
        results = list(pool.map(analyse, files))

    for result in results:
        if args.spectrograms and (args.all_spectrograms or result["verdict"] != "ok"):
            result["spectrogram"] = spectrogram(result["file"], args.spectrograms)

    worst = max(results, key=lambda r: ("ok", "suspect", "fail").index(r["verdict"]))["verdict"]
    formats = sorted({f"{r['rate'] / 1000:g}kHz/{r['bits']}bit" for r in results if "rate" in r})
    # Walls from 20.4 kHz up are masters and resamplers, not encoders.
    cutoffs = sorted(r["cutoff"] for r in results if r.get("cutoff") and r["cutoff"] < 20400)
    walled = len(cutoffs)
    logs = rip_logs(args.paths)

    album = []
    if len(formats) > 1:
        album.append("mixed formats: " + ", ".join(formats))
    if walled and walled == len(results) and len(results) > 2 and max(cutoffs) - min(cutoffs) <= 300:
        album.append(f"every track is cut at the same {cutoffs[0] / 1000:.1f} kHz: one lossy encoder made them all")
    elif walled:
        album.append(f"{walled} of {len(results)} tracks have a brick wall below 20.4 kHz")
    if others:
        album.append(f"{len(others)} audio files are not FLAC")

    if args.json:
        json.dump({"verdict": worst, "album": album, "logs": logs, "files": results}, sys.stdout, indent=1)
        print()
    else:
        common = os.path.commonpath(files) if len(files) > 1 else os.path.dirname(files[0])
        for r in results:
            fmt = f"{r['rate'] / 1000:g}/{r['bits']}" if "rate" in r else "?"
            print(f"{r['verdict']:<8}{fmt:<8} {os.path.relpath(r['file'], common)}")
            for note in r["notes"]:
                print(f"          - {note}")
            if "spectrogram" in r:
                print(f"          > {r['spectrogram']}")
        print(f"\n{worst.upper()}: {len(results)} files, {', '.join(formats)}")
        for line in album + logs:
            print(f"  {line}")
        if not logs:
            print("  no rip log")

    sys.exit({"ok": 0, "suspect": 1, "fail": 2}[worst])


if __name__ == "__main__":
    main()
