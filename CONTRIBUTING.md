# Contributing

Contributions are welcome for new devices, EQ profiles, and installer improvements.

## Preset contributions

- Store each JSON preset at `presets/<manufacturer>/<model>/<device> - <style>.json`.
- Add five profiles per device: **Balanced**, **Bass**, **Treble**, and two device-oriented styles. Keep the filename format `Device - Style.json`.
- Add the device's metadata, five profile names and descriptions, and a source reference to `index.csv`.
- Include the device name, speaker type, and a short description of each profile in your pull request.
- Treat EQ curves as subjective starting points, not measured corrections. Consider the speaker's form factor and stated configuration; avoid boosting frequencies the speakers cannot reproduce.
- If available, include a frequency-response graph or screenshot of the EasyEffects EQ curve in your pull request.

### Hardware verification

Set `hardware_verified` to `true` only after testing the exact make and model in `manufacturer` and `model`, using the setup described by `configuration`. Import and apply all five listed presets in EasyEffects on that device, and confirm they load and process playback on the intended output without a routing or channel-layout mismatch. Set it to `false` if the device was not available for direct testing; manufacturer specifications, testing a similar model, or validating the preset JSON alone are not sufficient. This flag records basic on-device compatibility, not measured frequency response or objective sound quality.

The installer reads this nested repository layout and places preset files directly in EasyEffects' flat output directory.

## Issues

For missing devices, incorrect tuning, or installer problems, include the device name and speaker type where relevant, along with a clear description. A frequency-response graph or EasyEffects EQ screenshot is helpful for tuning reports.

## Validation

Before opening a pull request, run:

```sh
python3 tests/validate-csv.py
python3 tests/validate-json.py
python3 tests/validate-presets.py
bash install.sh --dry-run
bash tests/test-install.sh
```
