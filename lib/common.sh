#!/usr/bin/env bash
# common.sh - shared helpers for omarchy-ytmp3.
#
# Sourced by bin/ytmp3 and bin/ytmp3-prompt. Do not run this file directly.

YTMP3_APP="ytmp3"
# shellcheck disable=SC2034  # part of the sourced library interface
YTMP3_VERSION="2.0.0"

# log <message...>  - write to stderr so stdout stays clean.
log() { printf '%s\n' "$*" >&2; }

# have <command> - true when the command exists on PATH.
have() { command -v "$1" >/dev/null 2>&1; }

# trim <string> - strip surrounding whitespace and stray newlines (copy-paste).
trim() {
  printf '%s' "$1" | tr -d '\r\n' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

# notify <urgency> <headline> [description]
# Prefers the Omarchy notification helper, falls back to libnotify.
notify() {
  local urgency="${1:-low}" headline="${2:-$YTMP3_APP}" desc="${3:-}"
  if have omarchy-notification-send; then
    omarchy-notification-send -u "$urgency" -g "󰇚" --app-name "$YTMP3_APP" \
      "$headline" "$desc" >/dev/null 2>&1 || true
  elif have notify-send; then
    notify-send -u "$urgency" -a "$YTMP3_APP" "$headline" "$desc" >/dev/null 2>&1 || true
  fi
}

# osd <percent 0-100> [message]
# No-op unless the Omarchy on-screen display helper is available.
osd() {
  have omarchy-osd || return 0
  local percent="$1" message="${2:-}"
  if [[ -n "$message" ]]; then
    omarchy-osd -i "󰇚" -p "$percent" -m "$message" -d 8000 >/dev/null 2>&1 || true
  else
    omarchy-osd -i "󰇚" -p "$percent" -d 8000 >/dev/null 2>&1 || true
  fi
}

# is_youtube_url <string>
is_youtube_url() {
  [[ "${1:-}" =~ ^https?://(www\.|m\.|music\.)?(youtube\.com|youtu\.be)/ ]]
}

# is_playlist_url <string> - true for playlist pages or links carrying a list= id.
is_playlist_url() {
  [[ "${1:-}" =~ /(playlist|mix)([/?#]|$) ]] || [[ "${1:-}" =~ [?\&]list= ]]
}

# need_cmd <command> - exit with a friendly error when a dependency is missing.
need_cmd() {
  if ! have "$1"; then
    log "error: missing required command: $1"
    notify critical "$YTMP3_APP: missing $1" "Install it, then retry."
    exit 1
  fi
}
