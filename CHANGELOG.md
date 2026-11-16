# Changelog

## v6

- Reorganizes the entire preset collection into manufacturer- and model-specific directories using the `presets/<manufacturer>/<model>/` structure.
- Standardizes directory names and preset filenames to improve navigation, consistency, and maintainability.
- Refines the collection to **115 output presets across 23 speaker systems**, retaining five profiles per device.
- Removes support for the Apple MacBook Pro 14-inch M4 (2024), Sonos Arc Ultra surround configuration, and Sony HT-A9 + SA-SW5 systems.
- Renames the Framework Laptop 13 and Lenovo ThinkPad T470 preset files for consistency with the new directory structure.
- Replaces the previous preset indexes with a consolidated `index.csv` containing one record per supported device.
- Expands device metadata with standardized categories, hardware channel configurations, preset revisions, target EasyEffects versions, and hardware verification status.
- Populates device categories and channel configurations using manufacturer specifications.
- Introduces stricter CSV validation for supported categories, channel formats, positive preset revisions, EasyEffects version formats, and boolean verification flags.
- Adds validation for device names, duplicate entries, preset definitions, descriptions, and reference URLs.
- Improves JSON validation with checks for file structure, effect ordering, equalizer parameters, and preset consistency.
- Updates the installation script to recursively discover presets within manufacturer/model directories.
- Removes hardcoded preset and device counts from the installer and validation scripts.
- Adds validation for directory layouts, filename conventions, and duplicate output preset names before installation.
- Preserves timestamped, verified backups of existing EasyEffects input/output presets, autoload configurations, impulse responses, and RNNoise resources.
- Retains the `--dry-run` option for previewing installation changes without modifying existing files.
- Improves testing of the `--replace-output` option, verifying backup preservation, removal of stale output presets, retention of non-JSON files, and successful reinstallation.
- Introduces comprehensive isolated installation tests covering backups, preset replacement, preservation of unrelated presets, and input preset safety.
- Consolidates GitHub Actions into a version-independent validation workflow.
- Enables automated validation on pushes and pull requests, alongside manual workflow execution.
- Adds `CONTRIBUTING.md` with guidelines for new devices, preset submissions, metadata requirements, and validation procedures.
- Documents hardware verification requirements, distinguishing successful physical-device testing from JSON validation and manufacturer specification checks.
- Adds the MIT license and standardized `.gitattributes` rules for consistent LF line endings.
- Improves README documentation covering installation, directory organization, PipeWire requirements, CD audio routing, stereo PCM processing, surround sound limitations, and gain considerations.
- Removes obsolete index files, historical release-note files, and the v4-specific release workflow.
- Preserves the audio processing and equalization settings of retained presets during the repository restructuring.

## v5

- Adds 15 documented devices and 75 stereo PCM output presets (now 130 across 26 systems).
- Adds source/assumption list, JSON/CSV validation and simulated backup/installation tests in CI.
- Updates installer expected preset count to 130 without changing full-backup behavior.
- Does not alter any of the original v4 preset JSON files.

## v4

- Initial public GitHub release containing 55 output presets across 11 speaker systems.
- Redesigns all five Creative Pebble V1/V2 profiles to address flat sound, excessive processing, and reduced perceived loudness.
- Removes stacked Bass Enhancer and Bass Loudness processing, unnecessary compression, Crystalizer, and stereo widening from the Creative Pebble profiles.
- Introduces a neutral, flat EQ-only Balanced preset for comparing EasyEffects processing against bypassed audio.
- Simplifies Creative Pebble Bass, Treble, Warm & Rich, and Desktop Gaming profiles with more conservative EQ and gain management.
- Adds a timestamped, verified backup system that preserves all existing EasyEffects input and output presets before installation.
- Extends backup coverage to Flatpak and native configurations, including autoload settings, impulse responses, and RNNoise resources.
- Adds `--dry-run` for previewing changes and `--replace-output` for safely replacing existing output presets after backup verification.
- Improves installation safety with JSON validation, backup verification, and atomic preset replacement.
- Publishes the collection to GitHub with release notes, an installation guide, preset indexes, and downloadable release archives.

## v3

- Expands the collection to 55 output presets covering 11 speaker systems.
- Standardizes every device around five profiles: Balanced, Bass, Treble, and two device-specific sound profiles.
- Preserves consistent filenames using the `Device - Style.json` convention.
- Includes the four original devices: Creative Pebble V1/V2, Logitech S120, ThinkPad T470, and LG Soundbar S80QR.
- Adds seven popular speaker systems:
  - Edifier R1280DB
  - Logitech Z623
  - Klipsch ProMedia 2.1 THX
  - Bose Companion 2 Series III
  - Creative Stage V2
  - Samsung HW-Q990F
  - Sony HT-S40R
- Revises Balanced profiles to use gentler equalization and reduced processing.
- Introduces dedicated Bass profiles tuned according to speaker size, bass capabilities, and subwoofer availability.
- Introduces dedicated Treble profiles for improved clarity, presence, and detail.
- Uses restrained Bass Enhancer processing for smaller speakers while favoring conventional low-frequency EQ for systems with dedicated subwoofers.
- Reduces unnecessary compression, Crystalizer, and stereo-widening effects across the collection.
- Maintains stereo PCM compatibility for soundbars and home-theater systems without attempting to replace native Dolby Atmos or surround decoding.
- Includes installation scripts, documentation, and a preset comparison index.
- Validates all 55 preset JSON files and tests installation behavior in an isolated environment.

## v2

- Expands the initial preset collection to four speaker systems with three profiles per device, totaling 12 presets.
- Introduces standardized profiles for Creative Pebble V1/V2, Logitech S120, ThinkPad T470, and LG Soundbar S80QR.
- Establishes the `Device - Style.json` naming convention.
- Adds Balanced, bass-oriented, and device-specific listening profiles for each speaker system.
- Introduces separate tuning approaches for compact desktop speakers, integrated laptop speakers, and soundbars with dedicated subwoofers.
- Adds Creative Pebble profiles for Balanced Reference, Warm & Rich, and Cinema & Gaming.
- Adds Logitech S120 profiles for Balanced Warm, Bigger Bass, and Voice & Podcasts.
- Adds ThinkPad T470 profiles for Balanced, Warm & Rich, and Voice & Night.
- Adds LG S80QR profiles for Balanced, Cinema, and Night & Dialogue.
- Revises the Creative Pebble presets after reports of flat sound and reduced bass compared with bypassed processing.
- Reduces aggressive high-pass filtering, negative input gain, and excessive compression in the revised Creative Pebble profiles.
- Increases upper-bass emphasis and introduces more noticeable bass enhancement and loudness processing.
- Improves installation packaging with individual JSON presets, installation scripts, and setup documentation.
- Provides an updated complete collection containing the revised Creative Pebble presets alongside the other speaker profiles.

## v1

- Creates the initial EasyEffects 8.3.0 speaker preset collection for Linux and PipeWire.
- Introduces five listening profiles for Logitech S120 stereo speakers:
  - Balanced Warm
  - Bigger Bass
  - Voice & Podcasts
  - Cinematic Wide
  - Night Cozy
- Introduces five listening profiles for Creative Pebble V1/V2 stereo speakers:
  - Balanced Reference
  - Warm & Rich
  - Rock & Metal
  - Cinema & Gaming
  - Low Volume Comfort
- Provides 10 importable EasyEffects JSON presets across two speaker systems.
- Introduces device-specific equalization focused on improving bass presence, vocal clarity, and overall tonal balance.
- Experiments with Bass Enhancer, Bass Loudness, Crystalizer, Exciter, Compressor, Limiter, and Stereo Tools.
- Uses bass harmonics and lower-midrange equalization to improve perceived bass on compact speakers without dedicated subwoofers.
- Introduces dedicated presets for music, gaming, movies, podcasts, and low-volume listening.
- Adds an installation script for importing presets into the EasyEffects Flatpak output preset directory.
- Includes setup instructions and a preset comparison sheet.
- Establishes the foundation for expanding the collection to additional speaker systems and listening environments.
