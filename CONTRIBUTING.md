# Contributing

Contributions are welcome for new devices, EQ profiles, and installer improvements.

## Preset contributions

- Use the filename format `Device - Style.json` and keep presets in JSON format.
- Include the device name, speaker type, and a short description of each profile.
- Treat EQ curves as subjective starting points, not measured corrections. Consider the speaker's form factor and stated configuration; avoid boosting frequencies the speakers cannot reproduce.
- If available, include a frequency-response graph or screenshot of the EasyEffects EQ curve in your pull request.

## Issues

For missing devices, incorrect tuning, or installer problems, include the device name and speaker type where relevant, along with a clear description. A frequency-response graph or EasyEffects EQ screenshot is helpful for tuning reports.

## Validation

Before opening a pull request, run:

```sh
python3 tests/validate-json.py
python3 tests/validate-presets.py
```
