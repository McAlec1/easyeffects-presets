#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
export HOME="$tmp/home"
export EASYEFFECTS_FLATPAK_BASE="$HOME/.var/app/com.github.wwmm.easyeffects"
mkdir -p "$EASYEFFECTS_FLATPAK_BASE/data/easyeffects/output" "$EASYEFFECTS_FLATPAK_BASE/data/easyeffects/input"
printf 'my preexisting output file\n' > "$EASYEFFECTS_FLATPAK_BASE/data/easyeffects/output/Personal.json"
printf 'my preexisting input file\n' > "$EASYEFFECTS_FLATPAK_BASE/data/easyeffects/input/Voice.json"
(
  cd "$ROOT"
  bash install.sh --dry-run > "$tmp/dryrun.log"
  bash install.sh > "$tmp/install.log"
)
count="$(find "$EASYEFFECTS_FLATPAK_BASE/data/easyeffects/output" -maxdepth 1 -type f -name '*.json' | wc -l)"
test "$count" -eq 131 || { echo "Expected 130 new + 1 personal, got $count" >&2; exit 1; }
test -e "$EASYEFFECTS_FLATPAK_BASE/data/easyeffects/output/Personal.json"
test -e "$EASYEFFECTS_FLATPAK_BASE/data/easyeffects/input/Voice.json"
backup="$(find "$ROOT/backups" -mindepth 1 -maxdepth 1 -type d | sort | tail -1)"
test -f "$backup/flatpak-data/output/Personal.json"
test -f "$backup/flatpak-data/input/Voice.json"
echo "PASS: dry-run, all 130 imports, personal files kept, input/output full backup"
