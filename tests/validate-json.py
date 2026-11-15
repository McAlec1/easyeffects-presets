#!/usr/bin/env python3
"""Validate JSON syntax for every preset file."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRESETS = sorted((ROOT / "presets").rglob("*.json"))

if not PRESETS:
	raise SystemExit("No preset JSON files found")

errors = 0
for path in PRESETS:
	try:
		with path.open(encoding="utf-8") as preset_file:
			json.load(preset_file)
	except (json.JSONDecodeError, UnicodeDecodeError) as error:
		errors += 1
		if isinstance(error, json.JSONDecodeError):
			print(f"FAIL: {path.relative_to(ROOT)}:{error.lineno}:{error.colno}: {error.msg}")
		else:
			print(f"FAIL: {path.relative_to(ROOT)}: invalid UTF-8")

if errors:
	raise SystemExit(f"FAIL: {errors} of {len(PRESETS)} preset files are invalid JSON")

print(f"PASS: {len(PRESETS)} preset files contain valid JSON")
