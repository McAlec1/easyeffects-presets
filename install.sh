#!/usr/bin/env bash
set -euo pipefail

readonly VERSION="v7.0.0-dev"
readonly EXIT_GENERAL=1
readonly EXIT_INVALID_ARGUMENT=2
readonly EXIT_DEPENDENCY=3
readonly EXIT_BACKUP=4
readonly EXIT_INTERRUPTED=130

SCRIPT_DIR="$(
	script_dir="${BASH_SOURCE[0]%/*}"
	if [[ "$script_dir" == "${BASH_SOURCE[0]}" ]]; then
		script_dir="."
	fi
	cd -- "$script_dir" && pwd -P
)"
readonly SCRIPT_DIR
readonly SRC="$SCRIPT_DIR/presets"

DRY_RUN=0
REPLACE_OUTPUT=0
NON_INTERACTIVE=0
SHOW_HELP=0
SHOW_VERSION=0

declare -a PRESET_FILES=()
declare -a BACKUP_SOURCES=()
declare -a BACKUP_LABELS=()
declare -a BACKUP_SECTIONS=()
declare -a NEW_PRESETS=()
declare -a REPLACEMENT_PRESETS=()
declare -a IDENTICAL_PRESETS=()

ACTIVE_TEMP=""
BACKUP=""
FLATPAK_BASE=""
TARGET=""

log_info() {
	if [[ -z "${NO_COLOR+x}" && -t 1 ]]; then
		printf '\033[36mINFO:\033[0m %s\n' "$*"
	else
		printf 'INFO: %s\n' "$*"
	fi
}

log_warn() {
	if [[ -z "${NO_COLOR+x}" && -t 2 ]]; then
		printf '\033[33mWARN:\033[0m %s\n' "$*" >&2
	else
		printf 'WARN: %s\n' "$*" >&2
	fi
}

log_error() {
	if [[ -z "${NO_COLOR+x}" && -t 2 ]]; then
		printf '\033[31mERROR:\033[0m %s\n' "$*" >&2
	else
		printf 'ERROR: %s\n' "$*" >&2
	fi
}

log_success() {
	if [[ -z "${NO_COLOR+x}" && -t 1 ]]; then
		printf '\033[32mSUCCESS:\033[0m %s\n' "$*"
	else
		printf 'SUCCESS: %s\n' "$*"
	fi
}

die() {
	local exit_status="${1}"
	local message="${2}"

	log_error "$message"
	exit "$exit_status"
}

usage() {
	printf '%s\n' \
		'EasyEffects Presets Installer v7.0.0-dev' \
		'' \
		'Install device-specific EasyEffects output presets.' \
		'' \
		'USAGE' \
		'    install.sh [OPTIONS]' \
		'' \
		'OPTIONS' \
		'    -h, --help             Show this help message' \
		'    -V, --version          Show installer version' \
		'    -n, --dry-run          Preview changes without modifying files' \
		'        --replace-output   Replace existing output JSON presets after backup' \
		'        --non-interactive  Disable interactive prompts' \
		'' \
		'EXAMPLES' \
		'    bash install.sh' \
		'    bash install.sh --dry-run' \
		'    bash install.sh --replace-output' \
		'' \
		'DEFAULT BEHAVIOR' \
		'    Installs output presets into the existing Flatpak destination.' \
		'    Creates and verifies backups before modifying presets.' \
		'    Preserves unrelated output presets during normal installation.' \
		'    --replace-output removes only top-level output JSON presets after backup;' \
		'    input presets and non-JSON output files are preserved.' \
		'    This option does not prompt for confirmation and is intentionally explicit.' \
		'' \
		'BACKUPS' \
		'    Timestamped backups are stored under backups/ next to install.sh.' \
		'    Flatpak and native input/output, autoload, impulse response, and RNNoise' \
		'    directories are copied and verified before installation.' \
		'' \
		'DOCUMENTATION' \
		'    https://github.com/McAlec1/easyeffects-presets' \
		'' \
		'MINIMUM BASH' \
		'    Bash 4.0 or newer' \
		'' \
		'EXIT STATUS' \
		'    0    Success' \
		'    1    General failure' \
		'    2    Invalid arguments' \
		'    3    Missing dependencies' \
		'    4    Backup verification failure' \
		'    130  Interrupted'
}

print_version() {
	printf '%s\n' "$VERSION"
}

parse_args() {
	local argument

	for argument in "$@"; do
		case "$argument" in
		-h | --help)
			SHOW_HELP=1
			;;
		-V | --version)
			SHOW_VERSION=1
			;;
		-n | --dry-run)
			DRY_RUN=1
			;;
		--replace-output)
			REPLACE_OUTPUT=1
			;;
		--non-interactive)
			NON_INTERACTIVE=1
			;;
		*)
			printf 'Unknown option: %s\n' "$argument" >&2
			printf 'Run "bash install.sh --help" for usage.\n' >&2
			exit "$EXIT_INVALID_ARGUMENT"
			;;
		esac
	done
}

validate_args() {
	if ((SHOW_HELP && SHOW_VERSION)); then
		die "$EXIT_INVALID_ARGUMENT" "--help and --version cannot be used together."
	fi
}

check_dependencies() {
	local dependency

	for dependency in python3 cmp cp diff mktemp mkdir mv chmod rm basename dirname date; do
		if ! command -v "$dependency" >/dev/null 2>&1; then
			die "$EXIT_DEPENDENCY" "Missing required dependency '$dependency'. Install it before running the installer."
		fi
	done
}

initialize_paths() {
	local native_base="${HOME:-}"

	if [[ -z "$native_base" ]]; then
		die "$EXIT_GENERAL" "HOME is not set. Set HOME to a valid user directory and try again."
	fi

	FLATPAK_BASE="${EASYEFFECTS_FLATPAK_BASE:-$native_base/.var/app/com.github.wwmm.easyeffects}"
	TARGET="$FLATPAK_BASE/data/easyeffects/output"

	local flatpak_data="$FLATPAK_BASE/data/easyeffects"
	local flatpak_old_config="$FLATPAK_BASE/config/easyeffects"
	local native_data="$native_base/.local/share/easyeffects"
	local native_old_config="$native_base/.config/easyeffects"

	BACKUP_SOURCES=(
		"$flatpak_data"
		"$flatpak_old_config"
		"$native_data"
		"$native_old_config"
	)
	BACKUP_LABELS=("flatpak-data" "flatpak-legacy-config" "native-data" "native-legacy-config")
	BACKUP_SECTIONS=("input" "output" "autoload" "irs" "rnnoise")
}

discover_presets() {
	if [[ ! -d "$SRC" ]]; then
		die "$EXIT_GENERAL" "Missing presets/ folder next to install.sh: $SRC"
	fi

	shopt -s globstar nullglob
	PRESET_FILES=("$SRC"/**/*.json)
	if ((${#PRESET_FILES[@]} == 0)); then
		die "$EXIT_GENERAL" "No JSON preset files found under presets/. No files were changed."
	fi
}

validate_presets() {
	local validated_count

	if ! validated_count="$(
		python3 - "$SRC" <<'PYVALID'
import json
import pathlib
import sys

src = pathlib.Path(sys.argv[1])
files = sorted(src.rglob("*.json"))
output_names = set()

try:
    for file in files:
        relative = file.relative_to(src)
        if len(relative.parts) != 3:
            raise ValueError(
                f"Expected presets/<manufacturer>/<model>/<device> - <style>.json: {file}"
            )
        manufacturer, model, filename = relative.parts
        if not filename.startswith(f"{manufacturer} {model} - "):
            raise ValueError(
                f"Filename does not match manufacturer/model folders: {file}"
            )
        if filename in output_names:
            raise ValueError(f"Duplicate output preset filename: {filename}")
        output_names.add(filename)

        data = json.loads(file.read_text(encoding="utf-8"))
        output = data["output"]
        order = output["plugins_order"]
        if not isinstance(order, list) or len(set(order)) != len(order):
            raise ValueError(f"Bad plugin order in {file}")
        for plugin in order:
            if plugin not in output:
                raise ValueError(f"Plugin {plugin} missing in {file}")
except (KeyError, json.JSONDecodeError, OSError, ValueError) as error:
    print(f"ERROR: preset validation failed: {error}", file=sys.stderr)
    raise SystemExit(1)

print(len(files))
PYVALID
	)"; then
		die "$EXIT_GENERAL" "Preset validation failed. No files or backups were created."
	fi

	log_success "Preset validation: $validated_count repository JSON preset(s) passed."
}

discover_backup_sources() {
	local root_index
	local section
	local source
	local found=0

	log_info "Existing directories available for backup:"
	for root_index in "${!BACKUP_SOURCES[@]}"; do
		for section in "${BACKUP_SECTIONS[@]}"; do
			source="${BACKUP_SOURCES[$root_index]}/$section"
			if [[ -d "$source" ]]; then
				printf '  %s/%s: %s\n' "${BACKUP_LABELS[$root_index]}" "$section" "$source"
				found=$((found + 1))
			fi
		done
	done
	if ((found == 0)); then
		log_info "  No existing preset directories found (fresh installation)."
	fi
}

calculate_installation_changes() {
	local file
	local destination

	NEW_PRESETS=()
	REPLACEMENT_PRESETS=()
	IDENTICAL_PRESETS=()

	for file in "${PRESET_FILES[@]}"; do
		destination="$TARGET/$(basename -- "$file")"
		if [[ -f "$destination" ]]; then
			if cmp -s -- "$file" "$destination"; then
				IDENTICAL_PRESETS+=("$file")
			else
				REPLACEMENT_PRESETS+=("$file")
			fi
		else
			NEW_PRESETS+=("$file")
		fi
	done
}

print_installation_plan() {
	local existing_output_count=0
	local existing_output_files=()

	log_info "Preset validation: ${#PRESET_FILES[@]} repository preset(s)."
	log_info "Target output directory: $TARGET"

	if ((REPLACE_OUTPUT)); then
		shopt -s nullglob
		existing_output_files=("$TARGET"/*.json)
		existing_output_count=${#existing_output_files[@]}
		if ((DRY_RUN)); then
			log_warn "Destructive replacement preview: $existing_output_count existing top-level output JSON preset(s) would be removed."
			log_info "Repository presets: ${#PRESET_FILES[@]} repository preset(s) would be installed."
			log_info "Unrelated output JSON presets would be removed."
			log_info "Input presets and non-JSON output files would be retained."
		else
			log_warn "Destructive replacement: $existing_output_count existing top-level output JSON preset(s) will be removed."
			log_info "Planned install: ${#PRESET_FILES[@]} repository preset(s); unrelated JSON presets will not be retained."
			log_info "Planned preserve: input presets and all non-JSON output files."
		fi
	else
		log_info "Planned additions: ${#NEW_PRESETS[@]}"
		log_info "Planned replacements: ${#REPLACEMENT_PRESETS[@]}"
		log_info "Identical/skipped: ${#IDENTICAL_PRESETS[@]}"
		log_info "Normal mode will preserve unrelated output presets."
	fi
}

create_backup() {
	local root_index
	local section
	local source
	local backup_target

	if [[ ! -w "$SCRIPT_DIR" ]]; then
		die "$EXIT_GENERAL" "Cannot write backups beside install.sh: $SCRIPT_DIR is not writable."
	fi

	mkdir -p -- "$SCRIPT_DIR/backups" || die "$EXIT_GENERAL" "Could not create backup directory under $SCRIPT_DIR."
	if ! BACKUP="$(mktemp -d "$SCRIPT_DIR/backups/$(date +%Y%m%d-%H%M%S)-XXXXXXXX")"; then
		die "$EXIT_GENERAL" "Could not create a timestamped backup directory."
	fi

	printf 'EasyEffects snapshot — %s\n' "$(date -Is)" >"$BACKUP/manifest.txt"
	printf 'Host user home: %s\n' "${HOME:-unknown}" >>"$BACKUP/manifest.txt"
	printf 'Installer version: %s\n' "$VERSION" >>"$BACKUP/manifest.txt"

	for root_index in "${!BACKUP_SOURCES[@]}"; do
		for section in "${BACKUP_SECTIONS[@]}"; do
			source="${BACKUP_SOURCES[$root_index]}/$section"
			[[ -d "$source" ]] || continue
			backup_target="$BACKUP/${BACKUP_LABELS[$root_index]}/$section"
			mkdir -p -- "$backup_target" || die "$EXIT_BACKUP" "Could not prepare backup target: $backup_target"
			cp -a -- "$source/." "$backup_target/" || die "$EXIT_BACKUP" "Could not copy backup source: $source"
			if ! diff -qr -- "$source" "$backup_target" >/dev/null; then
				die "$EXIT_BACKUP" "Backup verification failed for $source. No presets were modified."
			fi
			printf '%s\t%s\n' "$source" "${BACKUP_LABELS[$root_index]}/$section" >>"$BACKUP/manifest.txt"
		done
	done

	log_success "Backup created and verified: $BACKUP"
}

verify_backup() {
	local manifest="$BACKUP/manifest.txt"

	if [[ ! -f "$manifest" ]]; then
		die "$EXIT_BACKUP" "Backup verification failed: manifest missing at $manifest"
	fi
	log_success "Backup verification status: passed."
}

replace_output_presets() {
	local existing_output_files=()
	local old_file
	local removed=0

	shopt -s nullglob
	existing_output_files=("$TARGET"/*.json)
	for old_file in "${existing_output_files[@]}"; do
		rm -f -- "$old_file" || die "$EXIT_GENERAL" "Could not remove existing output preset: $old_file"
		removed=$((removed + 1))
	done
	log_info "Actual old output JSON presets removed: $removed"
}

install_presets() {
	local file
	local destination
	local temp_file
	local new=0
	local replaced=0
	local identical=0

	mkdir -p -- "$TARGET" || die "$EXIT_GENERAL" "Could not create target output directory: $TARGET"

	if ((REPLACE_OUTPUT)); then
		replace_output_presets
	fi

	for file in "${PRESET_FILES[@]}"; do
		destination="$TARGET/$(basename -- "$file")"
		if [[ -f "$destination" ]] && cmp -s -- "$file" "$destination"; then
			identical=$((identical + 1))
			continue
		fi

		if [[ -f "$destination" ]]; then
			replaced=$((replaced + 1))
		else
			new=$((new + 1))
		fi
		if ! temp_file="$(mktemp "$TARGET/.easyeffects-import-XXXXXXXX")"; then
			die "$EXIT_GENERAL" "Could not create a temporary preset file in $TARGET."
		fi
		ACTIVE_TEMP="$temp_file"
		if ! cp -- "$file" "$temp_file"; then
			die "$EXIT_GENERAL" "Could not copy preset to temporary file: $(basename -- "$file")"
		fi
		if ! chmod 644 -- "$temp_file"; then
			die "$EXIT_GENERAL" "Could not set permissions on temporary preset: $(basename -- "$file")"
		fi
		if ! mv -f -- "$temp_file" "$destination"; then
			die "$EXIT_GENERAL" "Could not replace preset atomically: $(basename -- "$destination")"
		fi
		ACTIVE_TEMP=""
	done

	print_installation_summary "$new" "$replaced" "$identical"
}

print_installation_summary() {
	local new="${1}"
	local replaced="${2}"
	local identical="${3}"

	if ((REPLACE_OUTPUT)); then
		log_success "Actual repository presets installed: $((new + replaced + identical))"
		log_info "Actual newly installed: $new"
		log_info "Actual existing presets replaced: $replaced"
		log_info "Actual identical presets skipped: $identical"
		log_info "Actual presets not modified: $identical"
	else
		log_success "Actual newly installed: $new"
		log_info "Actual existing presets replaced: $replaced"
		log_info "Actual identical presets skipped: $identical"
		log_info "Actual presets not modified: $identical"
	fi
	log_success "Backup location: $BACKUP"

	if ((REPLACE_OUTPUT)); then
		log_info "Replacement mode preserved input presets and non-JSON output files."
	else
		log_info "Normal mode preserved unrelated output presets."
	fi
	log_info "Now open EasyEffects > Output > Presets to select a profile (no preset is selected automatically)."
}

handle_interrupt() {
	log_error "Installer interrupted. No rollback or recovery system is configured for partially completed installation."
	exit "$EXIT_INTERRUPTED"
}

handle_exit() {
	if [[ -n "$ACTIVE_TEMP" && -e "$ACTIVE_TEMP" ]]; then
		rm -f -- "$ACTIVE_TEMP" || true
	fi
}

main() {
	if ((BASH_VERSINFO[0] < 4)); then
		printf 'ERROR: Bash 4.0 or newer is required (found Bash %s).\n' "$BASH_VERSION" >&2
		exit "$EXIT_GENERAL"
	fi

	parse_args "$@"
	validate_args

	if ((SHOW_HELP)); then
		usage
		exit 0
	fi
	if ((SHOW_VERSION)); then
		print_version
		exit 0
	fi

	trap 'handle_interrupt' HUP INT TERM
	trap 'handle_exit' EXIT

	if ((NON_INTERACTIVE)); then
		log_info "Non-interactive mode: no prompts will be shown."
	fi

	check_dependencies
	initialize_paths
	discover_presets
	validate_presets
	discover_backup_sources
	calculate_installation_changes
	print_installation_plan

	if ((DRY_RUN)); then
		log_info "Dry run: no backup directories were created and no preset files were changed."
		exit 0
	fi

	create_backup
	verify_backup
	install_presets
}

main "$@"
