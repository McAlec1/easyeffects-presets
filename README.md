# EasyEffects 8.3.x Speaker Preset Collection — v5 (proposed)

**130 presets across 26 speaker and audio systems.** Five output presets per system: **Balanced**, **Bass**, **Treble**, and two device-oriented styles. No headphone tuning. v4's 55 JSON presets are unchanged; v5 proposes 75 additional presets for 15 new systems.

> All EQ curves are *subjective starting points* constrained by speaker form factor and manufacturer's stated configuration—not measured frequency-response corrections. The best profile depends on placement, input, volume and your taste. Compare at matched loudness, don't force bass that the speakers cannot reproduce, and switch effects off if it sounds worse.

## Getting started

1. Download the source ZIP for this branch or clone the repo; keep the extracted directory writable so backups are saved beside `install.sh`.
2. Run `bash install.sh --dry-run` to review all changes and backup locations.
3. Run `bash install.sh` as your normal user (no `sudo`).
4. Open EasyEffects → **Output → Presets** and select a profile.

The installer first snapshots and verifies all existing Flatpak/native **input**, **output**, **autoload**, **IRS** and **RNNoise** directories to `backups/<timestamp>/` **alongside the installer**, then adds or replaces 130 JSON output presets. Existing unrelated presets are kept. To remove older output presets only **after verification of the backup**, use `bash install.sh --replace-output` (this is destructive to the current output folder, but recoverable from backup).

Default Flatpak path: `~/.var/app/com.github.wwmm.easyeffects/data/easyeffects/output/`.

### Crucial compatibility notes

- **EasyEffects 8.3.x is a Linux PipeWire processing application.** The macOS laptop hardware profile is for a MacBook running compatible Linux audio, not instructions to run EasyEffects on macOS. Linux driver sound processing can vary.
- **CD micro hi-fi systems:** these presets only affect PCM *originating from the Linux computer* and entering the stereo over compatible input. A CD spinning in the unit, its radio, and its own Bluetooth sources are **not processed** by EasyEffects.
- **Surround, Atmos, DTS:X, studio speakers:** EasyEffects profiles are for a **stereo PCM** chain, not discrete 5.1, lossless HDMI bitstream, or object-based surround. Bypass EasyEffects and let receivers/soundbars decode original multichannel material. Do not stack stereo widening with spatial processing. Studio monitors should be flat for critical mixing unless measured room correction is available.
- **Subwoofers:** designs with an actual subwoofer get modest 62–125 Hz EQ; tiny laptop drivers get modest 125–250 Hz warmth instead. The v5 profiles avoid Bass Loudness, Crystalizer, Exciter and any artificial stereo widening. Two laptop Bass profiles use *mild* Bass Enhancer, never combined with Bass Loudness.
- **Gain:** tonal profiles reserve negative preamp headroom to limit clipping, so louder isn't necessarily better. Balanced is a neutral flat EQ-only control (0 dB preamp) to compare against EasyEffects bypass. Output DAC sample rate is not determined by analog speaker hardware.

## New v5 systems (15)

| Category | Device | Two device-oriented presets |
|---|---|---|
| Laptop | Apple MacBook Pro 14-inch M4 (2024) | Movie Dialogue; Low-Volume Comfort |
| Laptop | Dell XPS 13 9340 | Movie Dialogue; Low-Volume Comfort |
| Laptop | Framework Laptop 13 AMD Ryzen 7040 | Speech Clarity; Laptop Fullness |
| Powered Stereo | Audioengine A2+ (Original) | Desktop Nearfield; Warm Listening |
| Powered Stereo | Kanto YU4 | Bookshelf Warmth; TV Dialogue |
| Studio Monitors | Edifier MR4 | Studio Reference; Casual Listening |
| Studio Monitors | JBL 305P MkII Pair | Mix Reference; Low-Level Monitoring |
| Powered Stereo | Klipsch The Fives | Hi-Fi Warmth; TV Dialogue |
| CD Mini Hi-Fi | Denon D-M41 + SC-M41 | CD-Style Warmth; Low-Volume Listening |
| CD Mini Hi-Fi | Yamaha MCR-B370 | Acoustic Detail; Evening Listening |
| CD Mini Hi-Fi | Panasonic SC-PM250 | Compact Hi-Fi Warmth; Vocal Clarity |
| Home Theater | Logitech Z906 | Movie Dialogue; Stereo Gaming |
| Home Theater | Yamaha YHT-5960U | Stereo Cinema; Stereo Music |
| Home Theater | Sonos Arc Ultra + Sub 4 + 2x Era 300 | Stereo Cinema; Night Dialogue |
| Home Theater | Sony HT-A9 + SA-SW5 | Stereo Cinema; Speech Focus |

See [v5-additions.csv](v5-additions.csv) for detailed hardware assumptions, cautions and manufacturer sources. See [preset-index.csv](preset-index.csv) for all 130 preset curves and processing chains.

## Existing v4 systems (11, unchanged)

Creative Pebble V1-V2; Logitech S120; ThinkPad T470; LG Soundbar S80QR; Edifier R1280DB; Logitech Z623; Klipsch ProMedia 2.1 THX; Bose Companion 2 Series III; Creative Stage V2; Samsung HW-Q990F; Sony HT-S40R.

## Testing and limitations

Run `python3 tests/validate_presets.py` and `bash tests/verify_installer.sh`. CI also runs these on every pull request. These checks verify structure, preset counts, naming, JSON, device metadata and backup-before-import behavior; **they cannot measure actual acoustics or verify import/sound quality on your personal equipment**.

See [RELEASE_NOTES_v5.md](RELEASE_NOTES_v5.md) for the proposed changelog. The published `v4` tag/release remains untouched until this PR is reviewed and merged. No v5 GitHub Release is created by this pull request.
