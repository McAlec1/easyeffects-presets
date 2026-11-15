# v5 (proposed) — 15 additional devices

Adds **75 new EasyEffects 8.3.x output JSON profiles** for **15 new speaker setups**, increasing the collection from **55 / 11** to **130 / 26**. Each device receives **Balanced**, **Bass**, **Treble** plus two oriented profiles. The 55 existing v4 preset files are unchanged.

New coverage: three laptop speaker configurations, five powered/studio stereo sets, three CD micro-hi-fi speaker systems, and four surround/home-theater setups. See `v5-additions.csv` and `preset-index.csv`.

- Balanced is a flat, zero-preamp EQ-only control; no overprocessed bass.
- Moderate gain-staged Bass and Treble tuning based on the broad device category; no dynamic compression on studio monitors.
- Two device-aware additional profiles per model, with light compression limited to night/quiet/dialogue variants where appropriate.
- No software pseudo-surround or stereo widening; home theater profiles are **stereo PCM only**.
- Updated backup-first installer to expect 130 files, plus self-checks, shell backup tests and PR CI.

**Important:** CD player presets do not modify the stereo's own CD playback; only Linux PCM supplied through an external audio input. Home-theater Atmos/DTS:X or discrete 5.1 passes directly to the receiver, with EasyEffects bypassed. Audio on the target hardware has not been auditioned or calibrated. No automatic release/tag creation on this PR.
