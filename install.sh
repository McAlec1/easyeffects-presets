#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SRC="$SCRIPT_DIR/presets"
FLATPAK_BASE="${EASYEFFECTS_FLATPAK_BASE:-$HOME/.var/app/com.github.wwmm.easyeffects}"
FLATPAK_DATA="$FLATPAK_BASE/data/easyeffects"
FLATPAK_OLD_CONFIG="$FLATPAK_BASE/config/easyeffects"
NATIVE_DATA="$HOME/.local/share/easyeffects"
NATIVE_OLD_CONFIG="$HOME/.config/easyeffects"
TARGET="$FLATPAK_DATA/output"
DRY_RUN=0
REPLACE_OUTPUT=0

usage() {
  cat <<'HELP'
Usage: bash install.sh [--dry-run] [--replace-output]

BACKUP FIRST: snapshot all existing EasyEffects input/output presets and associated autoload/IR/RNNoise directories from Flatpak and native locations into backups/<timestamp>/ next to this script, BEFORE installing new JSON files.
The installer then adds/replaces 130 output presets in the Flatpak folder.
Unrelated presets are NEVER removed. No audio settings or rates are changed.

--dry-run         Show backup sources and file changes; write nothing.
--replace-output  After verified backup, remove old Flatpak OUTPUT *.json files before installing the new 130. Existing INPUT presets are kept.
HELP
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --replace-output) REPLACE_OUTPUT=1 ;;
    --help|-h) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ ! -d "$SRC" ]]; then
  echo "ERROR: missing presets/ folder next to installer." >&2; exit 1
fi
shopt -s globstar nullglob
files=("$SRC"/**/*.json)
if [[ ${#files[@]} -ne 130 ]]; then
  echo "ERROR: expected 130 .json files; found ${#files[@]}. Aborting before making changes." >&2
  exit 1
fi

python3 - "$SRC" <<'PYVALID'
import json,sys,pathlib
src=pathlib.Path(sys.argv[1]); files=sorted(src.rglob('*.json'))
for file in files:
    data=json.loads(file.read_text())
    output=data['output']
    order=output['plugins_order']
    if not isinstance(order,list) or len(set(order)) != len(order):
        raise ValueError(f'Bad plugin order in {file}')
    for plugin in order:
        if plugin not in output: raise ValueError(f'Plugin {plugin} missing in {file}')
print(f'Validated {len(files)} output preset JSON files.')
PYVALID

roots=("$FLATPAK_DATA" "$FLATPAK_OLD_CONFIG" "$NATIVE_DATA" "$NATIVE_OLD_CONFIG")
labels=("flatpak-data" "flatpak-legacy-config" "native-data" "native-legacy-config")
sections=("input" "output" "autoload" "irs" "rnnoise")

printf '\nExisting EasyEffects folders to back up (if present):\n'
found=0
for i in "${!roots[@]}"; do
  for section in "${sections[@]}"; do
    if [[ -d "${roots[$i]}/$section" ]]; then
      printf '  %s/%s: %s\n' "${labels[$i]}" "$section" "${roots[$i]}/$section"
      found=$((found+1))
    fi
  done
done
if (( found==0 )); then echo '  No existing preset directories found (fresh installation).'; fi

new=0; overwritten=0; identical=0
for file in "${files[@]}"; do
  dst="$TARGET/$(basename -- "$file")"
  if [[ -f "$dst" ]]; then
    if cmp -s -- "$file" "$dst"; then
      identical=$((identical+1))
    else
      overwritten=$((overwritten+1))
    fi
  else
    new=$((new+1))
  fi
done
printf '\nPlanned: %d new, %d replacements, %d unchanged; %d existing directories to snapshot.\n' \
  "$new" "$overwritten" "$identical" "$found"
if (( REPLACE_OUTPUT )); then
  old_output_files=("$TARGET"/*.json)
  printf "Replace-output requested: %d existing OUTPUT JSON preset files will be cleared AFTER backup.\n" "${#old_output_files[@]}"
fi
if (( DRY_RUN )); then
  echo 'Dry run: no backups created or files changed.'
  exit 0
fi

if [[ ! -w "$SCRIPT_DIR" ]]; then
  echo "ERROR: script directory is not writable, cannot save backups there: $SCRIPT_DIR" >&2
  exit 1
fi
mkdir -p -- "$SCRIPT_DIR/backups"
BACKUP="$(mktemp -d "$SCRIPT_DIR/backups/$(date +%Y%m%d-%H%M%S)-XXXXXXXX")"
printf 'EasyEffects snapshot — %s\n' "$(date -Is)" > "$BACKUP/manifest.txt"
printf 'Host user home: %s\n' "$HOME" >> "$BACKUP/manifest.txt"

for i in "${!roots[@]}"; do
  for section in "${sections[@]}"; do
    source="${roots[$i]}/$section"
    [[ -d "$source" ]] || continue
    target="$BACKUP/${labels[$i]}/$section"
    mkdir -p -- "$target"
    cp -a -- "$source/." "$target/"
    if ! diff -qr -- "$source" "$target" >/dev/null; then
      echo "ERROR: backup verification failed: $source; no presets have been installed." >&2
      exit 1
    fi
    printf '%s\t%s\n' "$source" "${labels[$i]}/$section" >> "$BACKUP/manifest.txt"
  done
done
printf '\nBackup complete and verified: %s\n' "$BACKUP"

mkdir -p -- "$TARGET"
if (( REPLACE_OUTPUT )); then
  existing_output=("$TARGET"/*.json)
  for old_file in "${existing_output[@]}"; do rm -f -- "$old_file"; done
  printf 'Cleared %d old OUTPUT JSON presets after verified backup.\n' "${#existing_output[@]}"
  identical=0
fi
changed=0
for file in "${files[@]}"; do
  destination="$TARGET/$(basename -- "$file")"
  if [[ -f "$destination" ]] && cmp -s -- "$file" "$destination"; then continue; fi
  temp="$(mktemp "$TARGET/.easyeffects-import-XXXXXXXX")"
  cp -- "$file" "$temp"
  chmod 644 -- "$temp"
  mv -f -- "$temp" "$destination"
  changed=$((changed+1))
done
printf 'Installed/replaced %d output presets; %d already identical.\n' "$changed" "$identical"
echo "All previous input/output/autoload presets and audio resources remain in $BACKUP"
echo 'Unrelated existing EasyEffects presets have been retained.'
echo 'Now open EasyEffects > Output > Presets to select one (no auto-selection).'
