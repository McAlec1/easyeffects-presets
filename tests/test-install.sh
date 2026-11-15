#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TEMP_DIR"' EXIT

STAGED_REPO="$TEMP_DIR/repo"
TEST_HOME="$TEMP_DIR/home"
FLATPAK_BASE="$TEMP_DIR/flatpak"
mkdir -p -- "$STAGED_REPO" "$TEST_HOME"
cp -a -- "$REPO_ROOT/install.sh" "$REPO_ROOT/presets" "$STAGED_REPO/"

flatpak_data="$FLATPAK_BASE/data/easyeffects"
flatpak_old_config="$FLATPAK_BASE/config/easyeffects"
native_data="$TEST_HOME/.local/share/easyeffects"
native_old_config="$TEST_HOME/.config/easyeffects"
source_roots=("$flatpak_data" "$flatpak_old_config" "$native_data" "$native_old_config")
backup_labels=(flatpak-data flatpak-legacy-config native-data native-legacy-config)
sections=(input output autoload irs rnnoise)

for i in "${!source_roots[@]}"; do
  for section in "${sections[@]}"; do
    fixture="${source_roots[$i]}/$section"
    mkdir -p -- "$fixture"
    printf 'fixture %s/%s\n' "${backup_labels[$i]}" "$section" > "$fixture/install-test-marker.txt"
  done
done

mapfile -t presets < <(find "$STAGED_REPO/presets" -type f -name '*.json' -print | sort)
if [[ ${#presets[@]} -eq 0 ]]; then
  echo 'ERROR: no preset files found for installation test.' >&2
  exit 1
fi

first_preset="${presets[0]}"
conflicting_name="$(basename -- "$first_preset")"
printf 'previous version\n' > "$flatpak_data/output/$conflicting_name"
printf 'unrelated preset\n' > "$flatpak_data/output/unrelated-install-test.json"

HOME="$TEST_HOME" EASYEFFECTS_FLATPAK_BASE="$FLATPAK_BASE" \
  bash "$STAGED_REPO/install.sh"

backups=("$STAGED_REPO"/backups/*)
if [[ ${#backups[@]} -ne 1 || ! -d "${backups[0]}" ]]; then
  echo 'ERROR: expected exactly one isolated backup directory.' >&2
  exit 1
fi
backup="${backups[0]}"

for i in "${!source_roots[@]}"; do
  for section in "${sections[@]}"; do
    source_marker="${source_roots[$i]}/$section/install-test-marker.txt"
    backup_marker="$backup/${backup_labels[$i]}/$section/install-test-marker.txt"
    if ! cmp -s -- "$source_marker" "$backup_marker"; then
      echo "ERROR: backup missing or differs from $source_marker" >&2
      exit 1
    fi
  done
done

if ! cmp -s -- "$first_preset" "$flatpak_data/output/$conflicting_name"; then
  echo "ERROR: repository preset was not installed: $conflicting_name" >&2
  exit 1
fi
if ! cmp -s -- "$backup/flatpak-data/output/$conflicting_name" <(printf 'previous version\n'); then
  echo "ERROR: prior preset was not preserved in the backup: $conflicting_name" >&2
  exit 1
fi
if ! cmp -s -- "$flatpak_data/output/unrelated-install-test.json" <(printf 'unrelated preset\n'); then
  echo 'ERROR: unrelated output file was not retained.' >&2
  exit 1
fi

for preset in "${presets[@]}"; do
  installed="$flatpak_data/output/$(basename -- "$preset")"
  if ! cmp -s -- "$preset" "$installed"; then
    echo "ERROR: installed preset missing or differs from source: $(basename -- "$preset")" >&2
    exit 1
  fi
done

printf 'Isolated installation verified: %d presets copied and all existing fixture directories backed up.\n' "${#presets[@]}"
