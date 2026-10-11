#!/usr/bin/env bash
# uninstall.sh - remove a per-user omarchy-ytmp3 install.
#
# Removes the binaries, shared library, launcher entry and (with --purge) the
# history log. Does NOT touch downloaded media or the Hyprland keybind.
#
# Usage: ./uninstall.sh [--purge]

set -euo pipefail

BIN_DIR="${HOME}/.local/bin"
LIB_DIR="${HOME}/.local/lib/omarchy-ytmp3"
APPS_DIR="${HOME}/.local/share/applications"
ICON_DIR="${HOME}/.local/share/icons/hicolor"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/omarchy-ytmp3"

PURGE=false
while (($# > 0)); do
  case "$1" in
    --purge) PURGE=true; shift ;;
    -h|--help)
      printf 'Usage: %s [--purge]\n' "$0"
      printf '  --purge   also delete %s\n' "$DATA_DIR"
      exit 0 ;;
    *) printf 'error: unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
done

rm -f "$BIN_DIR/ytmp3" "$BIN_DIR/ytmp3-prompt"
rm -f "$APPS_DIR/omarchy-ytmp3.desktop"
rm -f "$ICON_DIR/scalable/apps/omarchy-ytmp3.svg"
for size in 16 24 32 48 64 128 256 512; do
  rm -f "$ICON_DIR/${size}x${size}/apps/omarchy-ytmp3.png"
done
gtk-update-icon-cache -f -t "$ICON_DIR" >/dev/null 2>&1 || true
rm -rf "$LIB_DIR"
rmdir "$BIN_DIR" 2>/dev/null || true

if command -v omarchy-refresh-applications >/dev/null 2>&1; then
  omarchy-refresh-applications >/dev/null 2>&1 || true
elif command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
fi

if $PURGE; then
  rm -rf "$DATA_DIR"
  echo "Removed program and data ($DATA_DIR)."
else
  echo "Removed program files. History kept at $DATA_DIR (use --purge to delete)."
fi
echo "Note: the Super+Y entry in ~/.config/hypr/bindings.lua was left in place."
