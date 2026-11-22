# EasyEffects Presets — v7 Development Roadmap

**Status:** Planned
**Baseline:** v6
**Target:** v7
**Primary goal:** Build a standardized, safe, cross-distribution EasyEffects preset installer with comprehensive documentation and reliable testing.

---

# Phase 1 — Foundation

**Difficulty:** Easy–Moderate
**Priority:** P0
**Objective:** Standardize the installer and repository before introducing cross-distribution functionality.

## 1. Bash Script Standardization

### 1.1 Coding conventions

- [x] Standardize indentation and formatting using `shfmt`.
- [x] Add ShellCheck validation.
- [x] Retain `#!/usr/bin/env bash`.
- [x] Retain strict mode with `set -euo pipefail`.
- [x] Standardize function names using `lower_snake_case`.
- [x] Use `UPPER_SNAKE_CASE` for constants and environment configuration.
- [x] Use local variables within functions where appropriate.
- [x] Quote variable expansions correctly.
- [x] Handle filenames and directories containing spaces.
- [x] Use Bash arrays for file collections.
- [x] Avoid unnecessary external dependencies.
- [x] Document the minimum supported Bash version.

### 1.2 Installer architecture

- [x] Introduce a `main()` entry point.
- [x] Separate argument parsing from execution.
- [x] Create reusable logging functions.
- [x] Create centralized error-handling functions.
- [x] Separate preset discovery and validation.
- [ ] Separate environment and distribution detection.
- [x] Separate backup creation and verification.
- [x] Separate installation and reporting logic.
- [x] Eliminate duplicated operations.
- [x] Keep the script reasonably modular without overengineering it.
- [x] Preserve existing v6 installation behavior during the initial refactor.

### 1.3 Error handling

- [x] Define consistent exit codes.
- [x] Return nonzero status for failures.
- [x] Produce descriptive error messages.
- [x] Validate dependencies before operations that require them.
- [x] Detect failed commands and interrupted operations.
- [x] Avoid hiding errors with overly broad fallback behavior.
- [x] Handle unexpected or missing environment variables.

## 2. Command-Line Interface Standardization

### 2.1 General options

- [x] `-h`, `--help`
- [x] `-V`, `--version`
- [x] `-n`, `--dry-run`
- [x] `--non-interactive`

### 2.2 Installation options

- [ ] `-t`, `--target TARGET`
- [ ] `-d`, `--device DEVICE`
- [ ] `--all-devices`
- [x] Preserve `--replace-output`.
- [ ] Add an explicit custom installation path option.

### 2.3 Information and management options

- [ ] `--list-targets`
- [ ] `--list-presets`
- [ ] `--status`
- [ ] `--backup-only`
- [ ] `--update` (P1)
- [ ] `--uninstall` (P1)

### 2.4 Argument validation

- [x] Reject unknown arguments.
- [ ] Reject missing option values.
- [ ] Validate accepted target values.
- [x] Detect conflicting options.
- [x] Prevent destructive operations from executing accidentally.
- [x] Handle repeated arguments consistently.
- [x] Support commands in noninteractive environments.
- [x] Keep option behavior backward-compatible where reasonable.

**Implementation rule:** Introduce CLI options alongside their functionality. Do not advertise unimplemented options as available.

## 3. Help System & Terminal Output

### 3.1 Standardized `--help`

- [x] Display the installer name and current version.
- [x] Provide a concise description of the utility.
- [x] Display a standardized usage synopsis.
- [x] Group arguments by category.
- [x] Explain defaults.
- [x] Include examples of common operations.
- [x] Document supported installation targets.
- [x] Explain backups and destructive operations.
- [x] Document exit codes.
- [x] Include links to project documentation.
- [x] Ensure help is readable without terminal colors.
- [x] Ensure `--help` and `--version` work without EasyEffects installed.

### 3.2 Terminal output

- [x] Standardize `INFO`, `WARN`, `ERROR`, and success messages.
- [x] Send normal information to stdout.
- [x] Send errors and warnings to stderr.
- [x] Add optional colored output.
- [x] Respect the `NO_COLOR` convention.
- [x] Disable colors automatically when output is not a terminal.
- [x] Avoid unnecessary terminal decorations.
- [ ] Clearly identify detected EasyEffects installations.
- [x] Display the selected installation destination.
- [x] Show backup locations.
- [x] Report added, updated, unchanged, skipped, and removed presets.
- [x] Display useful next steps after installation.
- [x] Correct misleading messages when `--replace-output` is used.

### 3.3 Command behavior

- [x] Ensure help and version commands are side-effect-free.
- [x] Ensure informational commands do not require administrator privileges.
- [x] Return appropriate exit statuses.
- [x] Provide actionable guidance after common failures.
- [x] Ensure dry-run output accurately represents planned changes.

## 4. Documentation & Repository Organization

### 4.1 README improvements

- [ ] Rewrite the quick-start section.
- [ ] Explain native versus Flatpak installation.
- [ ] Explain automatic installation detection.
- [ ] Document basic installation commands.
- [ ] Explain the repository's preset organization.
- [ ] Clarify EasyEffects version compatibility.
- [ ] Explain backup behavior.
- [ ] Add links to detailed documentation.
- [ ] Include project status and contribution information.

### 4.2 Documentation structure

- [ ] Create `docs/INSTALLATION.md`.
- [ ] Create `docs/CLI.md`.
- [ ] Create `docs/COMPATIBILITY.md`.
- [ ] Create `docs/TROUBLESHOOTING.md`.
- [ ] Create `docs/DEVELOPMENT.md`.
- [ ] Update `CONTRIBUTING.md`.
- [ ] Standardize documentation formatting.
- [ ] Use copy-pasteable command examples.
- [ ] Avoid duplicating large sections across files.
- [ ] Clearly distinguish implemented features from planned features.

### 4.3 Contributor documentation

- [ ] Document the contribution workflow.
- [ ] Recommend development branches and pull requests.
- [ ] Explain commit-message conventions.
- [ ] Explain how to add speaker presets.
- [ ] Explain how to update device metadata.
- [ ] Document hardware verification requirements.
- [ ] Document local validation commands.
- [ ] Describe how compatibility testing should be reported.

### 4.4 GitHub Issue Templates

**Directory:** `.github/ISSUE_TEMPLATE/`

#### Bug report — `bug_report.yml`

- [ ] Create a structured bug report form.
- [ ] Include Linux distribution and version.
- [ ] Include EasyEffects version.
- [ ] Include native/Flatpak installation method.
- [ ] Include installer version.
- [ ] Include steps to reproduce.
- [ ] Include expected behavior.
- [ ] Include actual behavior.
- [ ] Include error messages and optional logs.
- [ ] Include a checklist confirming the user reviewed troubleshooting documentation.

#### Feature request — `feature_request.yml`

- [ ] Create a structured feature request form.
- [ ] Include a feature description.
- [ ] Ask what problem the feature solves.
- [ ] Include proposed behavior.
- [ ] Include optional alternatives.
- [ ] Include an optional implementation discussion.

#### Device/preset request — `device_request.yml`

- [ ] Create a dedicated speaker-system request form.
- [ ] Request manufacturer and exact model.
- [ ] Request device category.
- [ ] Request channel configuration.
- [ ] Request connection type.
- [ ] Request manufacturer specifications or references.
- [ ] Allow users to suggest listening profiles.
- [ ] Ask whether the user owns the hardware.
- [ ] Ask whether hardware testing is available.
- [ ] Avoid claiming untested presets are hardware-verified.

#### Compatibility report — `compatibility_report.yml`

- [ ] Create a dedicated compatibility reporting form.
- [ ] Request distribution name and version.
- [ ] Request EasyEffects version.
- [ ] Request PipeWire version when relevant.
- [ ] Request installation type.
- [ ] Request installer version.
- [ ] Record successful and unsuccessful functionality.
- [ ] Include optional logs and troubleshooting notes.
- [ ] Support reports for previously untested distributions.

#### Issue template configuration

- [ ] Create `.github/ISSUE_TEMPLATE/config.yml`.
- [ ] Provide useful template descriptions.
- [ ] Configure labels for each issue category.
- [ ] Ensure referenced labels exist.
- [ ] Link troubleshooting and contribution documentation.
- [ ] Avoid unnecessarily restrictive submission requirements.
- [ ] Do not require users to expose private system information.

### 4.5 Pull Request Template

**File:** `.github/pull_request_template.md`

- [ ] Add a change summary.
- [ ] Add motivation/context.
- [ ] Include related issue references.
- [ ] Include a change-type checklist.
- [ ] Include a testing checklist.
- [ ] Include tested distributions.
- [ ] Include tested EasyEffects versions.
- [ ] Include native/Flatpak compatibility information.
- [ ] Include installer safety considerations.
- [ ] Include an optional screenshots/logs section.
- [ ] Include documentation-update confirmation.
- [ ] Include regression-testing confirmation.
- [ ] Keep the template concise enough for small contributions.

### 4.6 Template validation and Gitea compatibility

- [ ] Validate Issue Form YAML syntax.
- [ ] Test the forms in GitHub's interface.
- [ ] Verify required fields and dropdown options.
- [ ] Verify GitHub labels.
- [ ] Test the PR template.
- [ ] Check documentation links.
- [ ] Verify Gitea's handling of the templates.
- [ ] Provide Markdown-based fallbacks if necessary.
- [ ] Ensure contributors on GitHub and Gitea can report issues effectively.

---

# Phase 2 — Linux Compatibility

**Difficulty:** Moderate
**Priority:** P0
**Objective:** Support native and Flatpak EasyEffects installations across major Linux distributions.

## 5. Linux Distribution & Package Manager Detection

### 5.1 Distribution identification

- [ ] Read `/etc/os-release`.
- [ ] Detect `ID`.
- [ ] Detect `ID_LIKE`.
- [ ] Detect `VERSION_ID`.
- [ ] Detect `PRETTY_NAME`.
- [ ] Recognize Debian.
- [ ] Recognize Ubuntu.
- [ ] Recognize Linux Mint and other Debian/Ubuntu derivatives.
- [ ] Recognize Fedora.
- [ ] Recognize compatible Fedora/RPM-based systems.
- [ ] Recognize Arch Linux.
- [ ] Recognize EndeavourOS and Manjaro.
- [ ] Recognize openSUSE Leap and Tumbleweed.
- [ ] Handle unknown distributions gracefully.

### 5.2 Package manager detection

- [ ] Detect APT.
- [ ] Detect DNF.
- [ ] Detect Pacman.
- [ ] Detect Zypper.
- [ ] Detect Flatpak.
- [ ] Identify whether EasyEffects is available through the configured repositories where practical.
- [ ] Display appropriate installation commands.
- [ ] Avoid automatically running privileged installation commands.
- [ ] Keep system-package installation separate from preset installation.

### 5.3 Distribution-independent design

- [ ] Do not derive preset paths solely from distribution names.
- [ ] Allow compatible installations on unknown distributions.
- [ ] Respect custom XDG directories.
- [ ] Avoid distro-specific assumptions in core installation logic.
- [ ] Document unsupported environments accurately.

## 6. EasyEffects Detection & Compatibility

### 6.1 Installation discovery

- [ ] Detect native EasyEffects installations.
- [ ] Detect user-level Flatpak installations.
- [ ] Detect system-level Flatpak installations.
- [ ] Detect multiple installed versions.
- [ ] Detect missing installations.
- [ ] Distinguish actual installations from leftover configuration directories.
- [ ] Report executable paths and detected versions where available.

### 6.2 Version compatibility

- [ ] Establish the validated EasyEffects 8.3.x baseline.
- [ ] Test compatibility with EasyEffects 8.2.x.
- [ ] Test compatibility with EasyEffects 8.1.x.
- [ ] Investigate compatibility with EasyEffects 7.x.
- [ ] Determine the minimum supported EasyEffects version.
- [ ] Check preset JSON compatibility across tested versions.
- [ ] Warn about unsupported or unverified versions.
- [ ] Avoid silently installing into incompatible installations.
- [ ] Update metadata when compatibility is confirmed.
- [ ] Publish a tested-version compatibility matrix.

### 6.3 Filesystem detection

- [ ] Support native EasyEffects 8.x data directories.
- [ ] Support Flatpak EasyEffects data directories.
- [ ] Respect `XDG_DATA_HOME`.
- [ ] Account for legacy configuration paths when applicable.
- [ ] Handle custom home directories.
- [ ] Handle directory names containing spaces.
- [ ] Avoid writing into system-owned application directories.

## 7. Installation Target Selection

### 7.1 Supported targets

- [ ] Implement `--target auto`.
- [ ] Implement `--target native`.
- [ ] Implement `--target flatpak`.
- [ ] Implement `--target all`.
- [ ] Implement `--list-targets`.
- [ ] Implement custom output-directory selection.

### 7.2 Automatic selection

- [ ] Select the installation automatically when exactly one compatible target exists.
- [ ] Detect multiple installations.
- [ ] Prompt interactively when selection is ambiguous.
- [ ] Require explicit selection in ambiguous noninteractive environments.
- [ ] Validate the selected destination.
- [ ] Display the final destination before installation.
- [ ] Avoid silently choosing an incorrect target.

### 7.3 Native installation

- [ ] Implement native output-preset installation.
- [ ] Preserve unrelated native presets.
- [ ] Create and verify native backups.
- [ ] Confirm installation results.
- [ ] Preserve existing Flatpak functionality.
- [ ] Support explicit multi-target installation.

---

# Phase 3 — Reliability & Preset Management

**Difficulty:** Moderate–Hard
**Priority:** P0 for data safety, P1 for advanced management
**Objective:** Improve backup handling, recovery, and long-term preset maintenance.

## 8. Backup & Recovery System

### 8.1 Backup storage

- [ ] Preserve backup-first behavior.
- [ ] Back up the selected installation.
- [ ] Preserve native and Flatpak preset directories.
- [ ] Preserve input presets, output presets, autoload data, IRS, and RNNoise resources.
- [ ] Support a configurable backup directory.
- [ ] Consider `XDG_STATE_HOME` as the default backup location.
- [ ] Avoid requiring the repository directory to be writable.
- [ ] Retain separate backups for distinct installations.

### 8.2 Backup integrity

- [ ] Verify copied files.
- [ ] Abort installation when backup verification fails.
- [ ] Record source directories and timestamps.
- [ ] Improve backup manifests.
- [ ] Detect insufficient storage.
- [ ] Detect permission failures.
- [ ] Preserve existing backups when a later operation fails.

### 8.3 Restoration

- [ ] Document manual restoration.
- [ ] Support safe rollback after installation failures.
- [ ] Handle interrupted installations.
- [ ] Consider an explicit restore command (P1).
- [ ] Protect unrelated user files during restoration.
- [ ] Test failure recovery.

## 9. Preset Management

**Priority:** P1

### 9.1 Selective installation

- [ ] Implement `--device`.
- [ ] Implement `--all-devices`.
- [ ] Allow installation of one device's five profiles.
- [ ] Validate selected device names.
- [ ] Skip identical preset files.
- [ ] Report installed, updated, and skipped profiles.

### 9.2 Preset tracking

- [ ] Introduce a managed-preset installation manifest.
- [ ] Track installed preset filenames.
- [ ] Track source revisions or checksums.
- [ ] Identify locally modified presets.
- [ ] Identify missing managed presets.
- [ ] Detect renamed presets between releases.
- [ ] Warn about affected autoload associations.

### 9.3 Updates

- [ ] Implement `--update`.
- [ ] Preserve user modifications unless explicitly overridden.
- [ ] Show planned changes before updating.
- [ ] Support dry-run updates.
- [ ] Create backups before overwriting modified presets.
- [ ] Report update results.

### 9.4 Uninstallation

- [ ] Implement `--uninstall`.
- [ ] Remove only files identified as project-managed.
- [ ] Support uninstalling one device's presets.
- [ ] Preserve unrelated presets.
- [ ] Preserve user-modified files unless explicitly confirmed.
- [ ] Back up files before removal.
- [ ] Provide clear uninstall summaries.

### 9.5 Status reporting

- [ ] Implement `--status`.
- [ ] Show detected installations.
- [ ] Show installed preset counts.
- [ ] Identify modified presets.
- [ ] Identify missing presets.
- [ ] Report available updates when local metadata permits.

## 10. Installation Safety & Transaction Handling

### 10.1 Filesystem protection

- [ ] Retain atomic file replacement.
- [ ] Validate destination paths.
- [ ] Reject unsafe path traversal.
- [ ] Handle symlinks safely.
- [ ] Reject duplicate destination filenames.
- [ ] Detect failed writes.
- [ ] Verify results after installation.

### 10.2 Destructive operations

- [ ] Preserve `--replace-output`.
- [ ] Clearly explain what replacement removes.
- [ ] Require explicit confirmation when appropriate.
- [ ] Require explicit opt-in for destructive noninteractive execution.
- [ ] Never delete existing input presets as part of output replacement.
- [ ] Preserve backups.
- [ ] Correct replacement-mode completion messages.

### 10.3 Transaction behavior

- [ ] Define what constitutes a completed installation.
- [ ] Avoid reporting success after partial failure.
- [ ] Handle interruptions consistently.
- [ ] Roll back modified files when safe.
- [ ] Preserve recovery information if rollback fails.
- [ ] Test failures during copying and replacement.

---

# Phase 4 — Validation, Documentation & Release

**Difficulty:** Moderate–Hard
**Priority:** P0/P1
**Objective:** Confirm that the complete v7 installer works reliably before publishing.

## 11. Automated Testing & CI

### 11.1 Static validation

- [ ] Add ShellCheck to GitHub Actions.
- [ ] Add `shfmt` checks.
- [ ] Preserve Bash syntax validation.
- [ ] Preserve JSON validation.
- [ ] Preserve CSV validation.
- [ ] Preserve preset-structure validation.
- [ ] Validate repository metadata consistency.

### 11.2 CLI tests

- [ ] Test `--help`.
- [ ] Test `--version`.
- [ ] Test `--dry-run`.
- [ ] Test each installation target.
- [ ] Test selective device installation.
- [ ] Test informational commands.
- [ ] Test missing arguments.
- [ ] Test unknown arguments.
- [ ] Test conflicting arguments.
- [ ] Test noninteractive execution.
- [ ] Verify informational commands cause no filesystem changes.

### 11.3 Installation tests

- [ ] Test native-only installation.
- [ ] Test Flatpak-only installation.
- [ ] Test multiple installed versions.
- [ ] Test both native and Flatpak installations.
- [ ] Test missing EasyEffects installations.
- [ ] Test unknown distributions.
- [ ] Test custom XDG paths.
- [ ] Test filenames containing spaces.
- [ ] Test backup verification failures.
- [ ] Test insufficient permissions.
- [ ] Test interrupted installation.
- [ ] Test rollback behavior.
- [ ] Test `--replace-output`.
- [ ] Test update and uninstall functionality if implemented.

### 11.4 Cross-distribution validation

- [ ] Test Debian.
- [ ] Test Ubuntu.
- [ ] Test Fedora.
- [ ] Test Arch Linux.
- [ ] Test openSUSE.
- [ ] Use containers or isolated environments where practical.
- [ ] Validate actual application compatibility separately from filesystem tests.
- [ ] Test real preset loading in EasyEffects.
- [ ] Perform audio playback checks on representative hardware.
- [ ] Record supported combinations of distribution, installation method, and EasyEffects version.

### 11.5 GitHub workflow improvements

- [ ] Run static checks automatically.
- [ ] Run installer unit and integration tests.
- [ ] Include cross-distribution test jobs where practical.
- [ ] Validate Issue Form YAML syntax.
- [ ] Validate relevant documentation links.
- [ ] Require successful checks before merging release changes.
- [ ] Keep CI reasonably fast for contributors.

## 12. Final Documentation & Templates

### 12.1 Installation documentation

- [ ] Finalize Debian/Ubuntu instructions.
- [ ] Finalize Fedora instructions.
- [ ] Finalize Arch instructions.
- [ ] Finalize openSUSE instructions.
- [ ] Finalize Flatpak instructions.
- [ ] Document automatic target selection.
- [ ] Document explicit target selection.
- [ ] Document selective preset installation.
- [ ] Document custom installation paths.

### 12.2 CLI documentation

- [ ] Document all implemented commands.
- [ ] Document all implemented options.
- [ ] Document default behavior.
- [ ] Document exit codes.
- [ ] Document environment variables.
- [ ] Include common usage examples.
- [ ] Ensure documentation matches actual `--help` output.

### 12.3 Compatibility and troubleshooting

- [ ] Publish the tested EasyEffects version matrix.
- [ ] Publish the tested distribution matrix.
- [ ] Explain native and Flatpak limitations.
- [ ] Document backup restoration.
- [ ] Document missing preset troubleshooting.
- [ ] Document audio routing considerations.
- [ ] Clarify unsupported configurations.

### 12.4 GitHub and Gitea templates

- [ ] Verify Bug Report form.
- [ ] Verify Feature Request form.
- [ ] Verify Device/Preset Request form.
- [ ] Verify Compatibility Report form.
- [ ] Verify Pull Request template.
- [ ] Verify labels and links.
- [ ] Verify contribution instructions.
- [ ] Validate YAML.
- [ ] Confirm usable reporting workflows on Gitea.
- [ ] Resolve template incompatibilities or document platform differences.

## 13. Release Preparation

### 13.1 Release acceptance

- [ ] Complete all P0 requirements.
- [ ] Review remaining P1 requirements.
- [ ] Pass all automated validation.
- [ ] Pass ShellCheck and shfmt.
- [ ] Verify native installation.
- [ ] Verify Flatpak installation.
- [ ] Verify version compatibility claims.
- [ ] Verify backup and recovery behavior.
- [ ] Confirm no unintended changes to preset audio processing.
- [ ] Confirm all 115 existing presets remain available.

### 13.2 Repository preparation

- [ ] Update `CHANGELOG.md`.
- [ ] Update version references.
- [ ] Finalize README.
- [ ] Finalize `CONTRIBUTING.md`.
- [ ] Finalize `docs/`.
- [ ] Review Issue and Pull Request templates.
- [ ] Open a PR from `v7` into `master`.
- [ ] Review the complete diff.
- [ ] Confirm GitHub Actions passes.

### 13.3 Publishing

- [ ] Merge the v7 pull request.
- [ ] Create the `v7` tag on the merged `master` commit.
- [ ] Publish the GitHub Release.
- [ ] Synchronize GitHub and Gitea.
- [ ] Push branches and tags to both repositories.
- [ ] Verify release downloads and archive contents.
- [ ] Confirm the released installer works from a clean checkout.

---

# Deferred / Future Development (P2)

These improvements are outside the required v7 scope.

## Native distribution packages

- [ ] Investigate official EasyEffects Community Presets packaging.
- [ ] Create a `.deb` package for the preset collection.
- [ ] Create an `.rpm` package.
- [ ] Create an Arch Linux `PKGBUILD`.
- [ ] Investigate openSUSE packaging.
- [ ] Investigate NixOS/Home Manager integration.
- [ ] Consider distribution repository submissions.

## Advanced management

- [ ] Optional graphical installer.
- [ ] Interactive terminal preset browser.
- [ ] Automatic update notifications.
- [ ] Advanced PipeWire diagnostic tools.
- [ ] Automatic profile recommendations.
- [ ] More extensive hardware-backed audio compatibility testing.

---

# Final v7 Definition of Done

The release is complete when:

- [ ] The installer follows standardized Bash conventions.
- [ ] The CLI has consistent, useful help and error handling.
- [ ] GitHub Issue and Pull Request templates are implemented.
- [ ] Documentation accurately describes all supported features.
- [ ] Native and Flatpak EasyEffects installations are supported.
- [ ] Distribution and package-manager detection works reliably.
- [ ] Unsupported EasyEffects versions are handled safely.
- [ ] Target selection is explicit and predictable.
- [ ] Existing presets and user data are protected.
- [ ] Backups are created and verified before destructive operations.
- [ ] All required tests pass.
- [ ] Compatibility claims are based on actual testing.
- [ ] v6 functionality remains intact.
- [ ] v7 is merged, tagged, and released successfully.
