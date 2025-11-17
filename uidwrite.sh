#!/usr/bin/env bash
# scan_uid.sh
# Continuously poll proxmark3 for a tag and save UID to UID.txt, then exit.

set -euo pipefail

DEVICE="/dev/ttyACM0"
PROXMARK_BIN="$(command -v proxmark3 || echo /usr/bin/proxmark3)"
TIMEOUT=6
POLL_INTERVAL=2

run_proxmark_cmd() {
  local cmd="$1"
  timeout "$TIMEOUT" sudo "$PROXMARK_BIN" "$DEVICE" -c "$cmd" 2>&1 || true
}

extract_uid() {
  local out="$1"
  local uid_line
  uid_line="$(printf "%s\n" "$out" | awk 'tolower($0) ~ /uid/ { print; exit }' || true)"
  if [[ -n "$uid_line" ]]; then
    printf "%s\n" "$uid_line" |
      grep -Eo '([0-9A-Fa-f]{2}([ :\-]?|$)){4,8}' |
      head -n1 | tr -d ' :-'
    return 0
  fi

  # fallback
  printf "%s\n" "$out" |
    grep -Eo '([0-9A-Fa-f]{2}[: -]?){4,8}' |
    head -n1 | tr -d ' :-' || true
}

echo "Scanning for tag..."

while true; do
  OUT="$(run_proxmark_cmd "hf 14a info")"
  UIDHEX="$(extract_uid "$OUT" || true)"

  if [[ -n "$UIDHEX" ]]; then
    echo "Tag detected: $UIDHEX"
    echo "$UIDHEX" > UID.txt
    echo "Saved to UID.txt"
    exit 0
  fi

  sleep "$POLL_INTERVAL"
done
