# McAlec's EasyEffects Preset Collection

Five output presets per system: **Balanced**, **Bass**, **Treble**, and two device-oriented styles.

> All EQ curves are *subjective starting points* constrained by speaker form factor and manufacturer's stated configuration—not measured frequency-response corrections. The best profile depends on placement, input, volume and your taste. Compare at matched loudness, don't force bass that the speakers cannot reproduce, and switch effects off if it sounds worse.

## Getting started

1. Download the source ZIP for this branch or clone the repo; keep the extracted directory writable so backups are saved beside `install.sh`.
2. Run `bash install.sh --dry-run` to review all changes and backup locations.
3. Run `bash install.sh` as your normal user (no `sudo`).
4. Open EasyEffects → **Output → Presets** and select a profile.

Presets are organized in the repository as `presets/<manufacturer>/<model>/<device> - <style>.json`. The installer validates and flattens these files into EasyEffects' output folder, where presets are stored by filename. It first snapshots and verifies all existing Flatpak/native **input**, **output**, **autoload**, **IRS** and **RNNoise** directories to a uniquely named folder under `backups/` **alongside the installer**, then adds or replaces the repository's JSON output presets. Existing unrelated presets are kept. To remove existing top-level output JSON files only **after verification of the backup**, use `bash install.sh --replace-output` (this is destructive to the current output folder, but recoverable from backup).

Default Flatpak path: `~/.var/app/com.github.wwmm.easyeffects/data/easyeffects/output/`.

For contribution guidelines and validation steps, see [CONTRIBUTING.md](CONTRIBUTING.md).

## Compatibility

- **Windows, macOS, Android, iOS:**
  EasyEffects is not available for Windows, macOS, Android, or iOS. PipeWire is required for audio processing; applications using ALSA or PulseAudio compatibility can still be processed when correctly routed through PipeWire.

- **CD Players:**
  CD audio can be processed when routed through a Linux/PipeWire system and EasyEffects, using either a digital connection or an analog input. A standalone CD player playing directly through its own amplifier cannot be affected.

- **Surround, Atmos, DTS:X, studio speakers:**
  EasyEffects is a **stereo PCM** processor, not discrete 5.1, lossless HDMI bitstream, or object-based surround. Bypass EasyEffects and let receivers/soundbars decode original multichannel material.

- **Subwoofers:**
  Get modest 62–125 Hz EQ; tiny laptop drivers get modest 125–250 Hz warmth instead. Two laptop Bass profiles use *mild* Bass Enhancer, never combined with Bass Loudness.

- **Volume and Gain:**
  Toned presets reserve negative preamp headroom to limit clipping, so louder isn't necessarily better. Some Balanced presets are neutral flat-EQ controls at 0 dB preamp; others use gentle tonal adjustments. Output DAC sample rate is not determined by analog speaker hardware.
