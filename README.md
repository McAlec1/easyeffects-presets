# EasyEffects Speaker Presets

EasyEffects 8.3.x output presets for 11 speaker systems (55 profiles). Five per device: Balanced, Bass, Treble, and two speaker-specific styles.

**v4** revises the five Creative Pebble V1/V2 profiles to avoid stacked processing and negative gain issues. The collection is for stereo PCM; use native surround/Atmos decoding instead of EasyEffects for multichannel soundbars.

## Install

Download the v4 release archive, extract it to a writable folder, then run:

```bash
bash install.sh --dry-run
bash install.sh
```

The installer snapshots **all existing** EasyEffects input/output presets, autoload configurations, IRs, and RNNoise resources (Flatpak and native locations) to `backups/` beside the script **before** changing presets. `--replace-output` is optional and only removes old Flatpak output JSON files *after* a verified backup.

Presets are community sound-signature starting points, not individually measured/calibrated responses. Compare playback at matched loudness, and lower bass boosts if speakers distort.
