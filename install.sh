#!/usr/bin/env bash
# install.sh - per-user install of omarchy-ytmp3 (no package manager needed).
#
# Installs the binaries to ~/.local/bin, the shared library to
# ~/.local/lib/omarchy-ytmp3, the launcher entry to ~/.local/share/applications,
# and optionally adds the Super+Y Hyprland binding.
#
# Usage: ./install.sh [--no-bind] [--help]

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
LIB_DIR="${HOME}/.local/lib/omarchy-ytmp3"
APPS_DIR="${HOME}/.local/share/applications"
ICON_DIR="${HOME}/.local/share/icons/hicolor"
BINDINGS="${HOME}/.config/hypr/bindings.lua"
BIND_LINE='o.bind("SUPER + Y", "YT to MP3", "ytmp3-prompt")'

ADD_BIND=true
while (($# > 0)); do
  case "$1" in
    --no-bind) ADD_BIND=false; shift ;;
    -h|--help)
      printf 'Usage: %s [--no-bind]\n' "$0"
      printf '  --no-bind   do not touch ~/.config/hypr/bindings.lua\n'
      exit 0 ;;
    *) printf 'error: unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
done

mkdir -p "$BIN_DIR" "$LIB_DIR" "$APPS_DIR" "${HOME}/.local/share/omarchy-ytmp3"

install -m 755 "$REPO_DIR/bin/ytmp3"        "$BIN_DIR/ytmp3"
install -m 755 "$REPO_DIR/bin/ytmp3-prompt" "$BIN_DIR/ytmp3-prompt"
install -m 644 "$REPO_DIR/lib/common.sh"    "$LIB_DIR/common.sh"
install -m 644 "$REPO_DIR/desktop/omarchy-ytmp3.desktop" "$APPS_DIR/omarchy-ytmp3.desktop"
install -Dm644 "$REPO_DIR/icons/omarchy-ytmp3.svg" \
  "$ICON_DIR/scalable/apps/omarchy-ytmp3.svg"
for size in 16 24 32 48 64 128 256 512; do
  install -Dm644 "$REPO_DIR/icons/hicolor/${size}x${size}/apps/omarchy-ytmp3.png" \
    "$ICON_DIR/${size}x${size}/apps/omarchy-ytmp3.png"
done
gtk-update-icon-cache -f -t "$ICON_DIR" >/dev/null 2>&1 || true

# Refresh the launcher database if a helper is available.
if command -v omarchy-refresh-applications >/dev/null 2>&1; then
  omarchy-refresh-applications >/dev/null 2>&1 || true
elif command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
fi

# Add the Super+Y binding if requested and not already present.
if $ADD_BIND; then
  if [[ -f "$BINDINGS" ]] && grep -q 'ytmp3-prompt' "$BINDINGS"; then
    echo "Keybind already present in $BINDINGS"
  else
    mkdir -p "$(dirname "$BINDINGS")"
    printf '\n-- YT to MP3 (added by omarchy-ytmp3 install.sh)\n%s\n' "$BIND_LINE" >> "$BINDINGS"
    echo "Added Super+Y to $BINDINGS"
  fi
fi

echo "Checking dependencies..."
for cmd in yt-dlp ffmpeg; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "  ok: $cmd"
  else
    echo "  MISSING: $cmd  (install it: omarchy pkg add $cmd)"
  fi
done
for cmd in wl-paste gum; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "  ok: $cmd (optional)"
  else
    echo "  optional: $cmd not found"
  fi
done

cat <<'EOF'

Done. Usage:
  1. Copy a YouTube link
  2. Press Super+Y (run `hyprctl reload` first if the bind is new)
  3. Pick format (MP3/MP4) and a folder

Or non-interactively:
  ytmp3 "<url>" [--format mp3|mp4] [--dir DIR]

Defaults: ~/Music/YT (mp3), ~/Videos/YT (mp4)
Make sure ~/.local/bin is on your PATH.
EOF
