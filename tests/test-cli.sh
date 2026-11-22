#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
BASH_BIN="$(command -v bash)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TEMP_DIR"' EXIT

STAGED_REPO="$TEMP_DIR/repo"
TEST_HOME="$TEMP_DIR/home"
FLATPAK_BASE="$TEMP_DIR/flatpak"
mkdir -p -- "$STAGED_REPO" "$TEST_HOME"
cp -a -- "$REPO_ROOT/install.sh" "$STAGED_REPO/install.sh"

fail() {
	local message="$1"
	printf 'ERROR: %s\n' "$message" >&2
	exit 1
}

assert_exit() {
	local expected="$1"
	local message="$2"
	shift 2

	set +e
	"$@" >/dev/null 2>&1
	local status=$?
	set -e
	if ((status != expected)); then
		fail "$message (expected exit $expected, got $status)"
	fi
}

HELP_OUT="$TEMP_DIR/help.out"
VERSION_OUT="$TEMP_DIR/version.out"

if ! bash "$STAGED_REPO/install.sh" --help >"$HELP_OUT" 2>"$TEMP_DIR/help.err"; then
	fail "--help did not exit successfully"
fi
grep -q 'EasyEffects Presets Installer v7.0.0-dev' "$HELP_OUT" ||
	fail "--help output did not contain the installer name and version"
grep -q -- '--replace-output' "$HELP_OUT" || fail "--help omitted --replace-output"
[[ ! -s "$TEMP_DIR/help.err" ]] || fail "--help wrote to stderr"
[[ ! -d "$STAGED_REPO/backups" ]] || fail "--help created backups"

if ! bash "$STAGED_REPO/install.sh" -h >"$HELP_OUT" 2>"$TEMP_DIR/help.err"; then
	fail "-h did not exit successfully"
fi

if ! env -i PATH=/nonexistent HOME="$TEST_HOME" "$BASH_BIN" "$STAGED_REPO/install.sh" --help >"$HELP_OUT"; then
	fail "--help failed without dependencies"
fi

if ! bash "$STAGED_REPO/install.sh" --version >"$VERSION_OUT" 2>"$TEMP_DIR/version.err"; then
	fail "--version did not exit successfully"
fi
[[ "$(cat "$VERSION_OUT")" == "v7.0.0-dev" ]] || fail "--version returned the wrong version"
[[ ! -s "$TEMP_DIR/version.err" ]] || fail "--version wrote to stderr"

if ! bash "$STAGED_REPO/install.sh" -V >"$VERSION_OUT" 2>"$TEMP_DIR/version.err"; then
	fail "-V did not exit successfully"
fi
[[ "$(cat "$VERSION_OUT")" == "v7.0.0-dev" ]] || fail "-V returned the wrong version"

if ! env -i PATH=/nonexistent HOME="$TEST_HOME" "$BASH_BIN" "$STAGED_REPO/install.sh" --version >"$VERSION_OUT"; then
	fail "--version failed without dependencies"
fi

if env -i PATH=/nonexistent HOME="$TEST_HOME" "$BASH_BIN" "$STAGED_REPO/install.sh" --unknown >"$TEMP_DIR/unknown.out" 2>"$TEMP_DIR/unknown.err"; then
	fail "unknown option unexpectedly succeeded"
else
	status=$?
	((status == 2)) || fail "unknown option returned exit $status instead of 2"
fi
grep -q 'Unknown option' "$TEMP_DIR/unknown.err" || fail "unknown option lacked an actionable error"
[[ ! -d "$STAGED_REPO/backups" ]] || fail "invalid arguments created backups"

assert_exit 2 "help and version should conflict" bash "$STAGED_REPO/install.sh" --help --version
assert_exit 2 "dry-run and replace-output should conflict" bash "$STAGED_REPO/install.sh" --dry-run --replace-output

cp -a -- "$REPO_ROOT/presets" "$STAGED_REPO/presets"

if ! NO_COLOR=1 HOME="$TEST_HOME" EASYEFFECTS_FLATPAK_BASE="$FLATPAK_BASE" \
	bash "$STAGED_REPO/install.sh" --dry-run --dry-run --non-interactive --non-interactive \
	>"$TEMP_DIR/dry.out" 2>"$TEMP_DIR/dry.err"; then
	fail "repeated valid flags did not run"
fi
grep -q 'Dry run:' "$TEMP_DIR/dry.out" || fail "dry run omitted its dry-run status"
[[ ! -d "$STAGED_REPO/backups" ]] || fail "dry run created backups"
[[ ! -d "$FLATPAK_BASE" ]] || fail "dry run created the Flatpak destination"
if grep -q $'\033' "$TEMP_DIR/dry.out" "$TEMP_DIR/dry.err"; then
	fail "NO_COLOR output contained an escape sequence"
fi

if ! HOME="$TEST_HOME" EASYEFFECTS_FLATPAK_BASE="$FLATPAK_BASE" \
	NO_COLOR=1 bash "$STAGED_REPO/install.sh" -n --non-interactive \
	>"$TEMP_DIR/noninteractive.out" 2>"$TEMP_DIR/noninteractive.err"; then
	fail "-n and --non-interactive did not run"
fi
grep -q 'Dry run:' "$TEMP_DIR/noninteractive.out" || fail "-n did not activate dry-run mode"
[[ ! -d "$STAGED_REPO/backups" ]] || fail "-n created backups"

printf 'CLI regression verified: help, version, dry-run, non-interactive, repeated, and invalid options.\n'
