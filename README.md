# omarchy-ytmp3

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![AUR version](https://img.shields.io/aur/version/omarchy-ytmp3?label=AUR)](https://aur.archlinux.org/packages/omarchy-ytmp3)
[![AUR git version](https://img.shields.io/aur/version/omarchy-ytmp3-git?label=AUR%20git)](https://aur.archlinux.org/packages/omarchy-ytmp3-git)

A tiny, Omarchy-native YouTube downloader.

Copy a link, press `Super+Y`, choose **MP3** or **MP4** and a folder — done.
No browser tab, no sketchy converter site. Audio and video are pulled directly
with [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) and converted locally with
`ffmpeg`, with metadata and cover art embedded.

```
 ┌─ Super+Y ─────────────────────────────────────────────┐
 │  1. URL   →  clipboard (or paste when asked)          │
 │  2. Format →  MP3 audio   /   MP4 video (high quality) │
 │  3. Folder →  existing / new (nested) / browse         │
 │  4. Done  →  notification + OSD progress               │
 └────────────────────────────────────────────────────────┘
```

> **Personal use only.** Download and keep only content you have the right to.
> Respect YouTube's Terms of Service and your local copyright law.

## Features

- **Launcher-first workflow** — `Super+Y` grabs the copied YouTube link, or
  prompts for one, then guides you through format and folder.
- **Works from the terminal too** — `ytmp3 <url>` for scripts, aliases and cron.
- **MP3 and MP4** — best-quality audio (~320 kbps MP3) or best video + audio
  merged into MP4.
- **Playlists** — one numbered file per track, organised into a subfolder.
- **Proper files** — embedded title/artist metadata and thumbnail cover art.
- **Native Omarchy integration** — menu pickers, OSD progress and notifications,
  with graceful fallbacks (`gum`, `notify-send`, plain `select`).
- **No browser, no third-party sites** — everything runs locally over `yt-dlp`.

## Requirements

- **Omarchy** (Arch + Hyprland) is the intended target, but any Arch-based
  desktop works thanks to the fallbacks.
- `bash`, `yt-dlp`, `ffmpeg`.
- Optional: `wl-clipboard` (clipboard URL detection) and `gum` (terminal menus).

Install the hard dependencies on Omarchy:

```bash
omarchy pkg add yt-dlp ffmpeg
```

## Installation

### AUR (recommended)

```bash
# stable, tracks tagged releases
omarchy pkg aur add omarchy-ytmp3        # or: yay -S omarchy-ytmp3

# bleeding edge, tracks the git branch
omarchy pkg aur add omarchy-ytmp3-git    # or: yay -S omarchy-ytmp3-git
```

After installing, add the keybinding (see [Keybinding](#keybinding)) — the
package itself never edits your dotfiles.

### From source (no package manager)

```bash
git clone https://github.com/diwash-9/omarchy-ytmp3
cd omarchy-ytmp3
./install.sh
```

`install.sh` installs into `~/.local/`, adds the `Super+Y` binding, refreshes
the launcher database and reports missing dependencies. Pass `--no-bind` to
skip the keybinding. Ensure `~/.local/bin` is on your `PATH`.

## Usage

### Launcher (Super+Y)

1. Copy a YouTube link (video, short, `youtu.be`, `music.youtube.com`, playlist).
2. Press `Super+Y`.
3. Pick the format: **MP3 — audio only** or **MP4 — video, high quality**.
4. Pick a folder: an existing subfolder, a **new** one (type `Nepali/Pop` for
   nested folders), or **browse anywhere** on disk.
5. Wait for the completion notification. Progress shows in the OSD.

The app is also in the launcher as **YT to MP3**.

### Command line

```bash
ytmp3 <url> [options]

# a single song as MP3
ytmp3 "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# high-quality MP4 into a specific folder
ytmp3 "https://youtu.be/dQw4w9WgXcQ" --mp4 --dir ~/Videos/Concerts

# a whole playlist, sorted into its own subfolder
ytmp3 "https://www.youtube.com/playlist?list=PLxxxx" --dir ~/Music/YT/Nepali-Pop

# just one track from a "watch?v=...&list=..." link
ytmp3 "https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=PLxxxx" --no-playlist
```

#### Options

| Option | Description |
| --- | --- |
| `--format mp3\|mp4` | Output format. Default `mp3`. |
| `--mp3`, `--mp4` | Shorthands for `--format`. |
| `--dir DIR` | Output directory. Overrides env vars and defaults. |
| `--playlist` | Force playlist mode (one file per entry). |
| `--no-playlist` | Force single-video mode. |
| `--version` | Print the version and exit. |
| `-h`, `--help` | Show help and exit. |

#### Output layout

```
Single video:   <dir>/<title>.<mp3|mp4>
Playlist:       <dir>/<playlist title>/<NN> - <title>.<mp3|mp4>
Metadata and thumbnail cover art are embedded in both formats.
```

#### Environment variables

| Variable | Default | Meaning |
| --- | --- | --- |
| `YTMP3_DIR` | `~/Music/YT` | Default output folder for MP3. |
| `YTMP4_DIR` | `~/Videos/YT` | Default output folder for MP4. |
| `XDG_DATA_HOME` | `~/.local/share` | Base for the history log. |

Precedence for the output folder: `--dir` → environment variable → default.

## Keybinding

Packages do not touch your configuration. To bind the launcher to `Super+Y`,
add this to `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + Y", "YT to MP3", "ytmp3-prompt")
```

Then apply it:

```bash
hyprctl reload
```

> Use `hyprctl reload`, **not** `omarchy refresh hyprland` — the latter resets
> your custom binds.

## Configuration

- **Default folders** — set `YTMP3_DIR` / `YTMP4_DIR` in your shell environment.
- **History log** — every download is appended (timestamp, mode, format, URL,
  destination) to `~/.local/share/omarchy-ytmp3/history.log`.

## How it works

- `ytmp3` is a single-purpose CLI. It validates the URL, decides playlist vs.
  single, then calls `yt-dlp` with `ffmpeg` embedding metadata and cover art.
  In a terminal it shows yt-dlp's own progress bar; when launched from the menu
  it streams progress to the Omarchy OSD.
- `ytmp3-prompt` is the launcher: it resolves the URL, asks for format and
  folder with the Omarchy menu helpers, then runs `ytmp3` (detached so the menu
  can close while the download continues).
- Both scripts share helpers (`lib/common.sh`): notifications, OSD, URL checks.

## Project layout

```
bin/ytmp3                    core downloader (installed as `ytmp3`)
bin/ytmp3-prompt             launcher/clipboard flow (installed as `ytmp3-prompt`)
lib/common.sh                shared helpers
desktop/omarchy-ytmp3.desktop  launcher entry
icons/                       app icon (scalable SVG + hicolor PNGs)
install.sh                   per-user installer (source installs)
uninstall.sh                 per-user uninstaller
packaging/omarchy-ytmp3/     AUR PKGBUILD (tagged releases)
packaging/omarchy-ytmp3-git/ AUR PKGBUILD (git)
.github/workflows/           shell checks + release/packaging
```

## Uninstall

```bash
# AUR
omarchy pkg drop omarchy-ytmp3        # or: sudo pacman -Rns omarchy-ytmp3

# source install
./uninstall.sh            # add --purge to also delete the history log
```

Downloaded media and the `Super+Y` binding are never removed automatically.

## Troubleshooting

- **"not a YouTube URL"** — only `youtube.com`, `youtu.be`, `m.youtube.com` and
  `music.youtube.com` links are accepted.
- **Download fails / "Sign in to confirm"** — YouTube changed something; update
  `yt-dlp` (`sudo pacman -Syu` or `omarchy pkg add yt-dlp`).
- **No notification or OSD** — these need the Omarchy helpers; on other setups
  `notify-send` is used for notifications and the OSD is skipped.
- **`ytmp3: command not found`** — add `~/.local/bin` to your `PATH`, or use the
  AUR package which installs to `/usr/bin`.

## Credits

Built on the excellent [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) and
[`ffmpeg`](https://ffmpeg.org/). Made for [Omarchy](https://omarchy.org) by DHH.

## Contributing

Pull requests are welcome. Keep the shell scripts `bash -n` clean and
`shellcheck` friendly, and test both the CLI and the `Super+Y` flow.

## Releasing (maintainers)

Releases are automated in `.github/workflows/release.yml`. Pushing a version
tag builds the package in an Arch container, pins the source checksum, attaches
the built `.pkg.tar.zst` to a GitHub Release, and (optionally) publishes to the
AUR.

```bash
# 1. bump the version in lib/common.sh and packaging/omarchy-ytmp3/PKGBUILD
# 2. commit and tag
git commit -am "Release v2.0.0"
git tag v2.0.0
git push origin master --tags
```

To let the workflow publish to the AUR, set these under
**Settings → Secrets and variables → Actions**:

- Repository variable `PUBLISH_AUR` = `true`
- Secrets `AUR_USERNAME`, `AUR_EMAIL`, `AUR_SSH_PRIVATE_KEY` (an AUR SSH key)

Without the variable the AUR job is skipped and only the GitHub Release is
created. To publish manually instead:

```bash
cd packaging/omarchy-ytmp3
updpkgsums && makepkg --printsrcinfo > .SRCINFO
# push this directory to ssh://aur@aur.archlinux.org/omarchy-ytmp3.git
```

The `omarchy-ytmp3-git` package needs no checksum bumping; push its directory to
`ssh://aur@aur.archlinux.org/omarchy-ytmp3-git.git` once.

## License

[MIT](LICENSE) © 2026 Diwash
