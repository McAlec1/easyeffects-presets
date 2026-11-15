# v4 — Speaker preset collection

Initial public release of the EasyEffects 8.3.x speaker preset collection.

- 55 output presets covering 11 speaker systems, five profiles per device.
- Every device includes Balanced, Bass, and Treble, plus two device-specific profiles.
- Revised Creative Pebble V1/V2 presets to reduce overprocessing; the Balanced profile is a flat reference.
- Linux Flatpak installer includes a verified, timestamped backup of all existing input/output presets and related autoload/IR/RNNoise resources before installing.
- Optional `--replace-output` for a clean slate after backup; `--dry-run` for preview.
- Presets target stereo PCM, not native multichannel surround/Atmos signals.

These are subjective listening starting points, not independently measured equalization curves.

**Installation:** download the attached ZIP, extract it, then run `bash install.sh --dry-run` followed by `bash install.sh`.
