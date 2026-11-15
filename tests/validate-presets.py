#!/usr/bin/env python3
"""Check EasyEffects v5 JSON structure, effect ordering, and collection metadata."""
import csv
import json
import math
from pathlib import Path
from collections import Counter

ROOT = Path(__file__).resolve().parents[1]
P = ROOT / "presets"
ALL = sorted(P.rglob("*.json"))
assert len(ALL) == 130, f"Expected 130 presets, found {len(ALL)}"
styles = Counter()
devices = {}
allowed = {"equalizer#0", "compressor#0", "limiter#0", "bass_enhancer#0", "bass_loudness#0", "filter#0", "stereo_tools#0", "crystalizer#0", "exciter#0"}
frequencies = [31,62,125,250,500,1000,2000,4000,8000,16000]
for path in ALL:
    obj = json.loads(path.read_text())
    assert list(obj) == ["output"], path
    out = obj["output"]
    order = out["plugins_order"]
    assert isinstance(order, list) and order and len(order) == len(set(order)), path
    assert all(name in out and name in allowed for name in order), path
    assert set(out.keys()) == {"plugins_order", "blocklist", *order}, path
    assert isinstance(out["blocklist"], list), path
    assert " - " in path.stem, path
    device, style = path.stem.rsplit(" - ", 1)
    manufacturer, separator, model = device.partition(" ")
    assert separator and path.parent.parent.name == manufacturer, path
    assert path.parent.name == model, path
    devices.setdefault(device, set()).add(style)
    styles[style] += 1
    for key in order:
        assert isinstance(out[key], dict), (path, key)
        for g in ["input-gain", "output-gain"]:
            if g in out[key]:
                assert math.isfinite(out[key][g]) and -24 <= out[key][g] <= 24, (path,key,g)
    eq = out.get("equalizer#0")
    if eq:
        assert eq["num-bands"] == 10, path
        for side in ["left", "right"]:
            assert len(eq[side]) == 10, path
            for i, freq in enumerate(frequencies):
                band = eq[side][f"band{i}"]
                assert band["frequency"] == freq, (path, side, i)
                assert -12 <= band["gain"] <= 12 and math.isfinite(band["gain"]), (path, side, i)
        assert eq["split-channels"] is False, path

assert len(devices) == 26, f"Expected 26 devices, got {len(devices)}"
assert all(len(x) == 5 and {"Balanced", "Bass", "Treble"} <= x for x in devices.values())
with (ROOT/"index.csv").open(newline="") as f:
    rows = list(csv.DictReader(f))
assert len(rows) == len(devices), len(rows)
assert {row["device"] for row in rows} == set(devices)
indexed_paths = set()
for row in rows:
    assert row["device"] == f'{row["manufacturer"]} {row["model"]}', row
    preset_names = json.loads(row["preset"])
    descriptions = json.loads(row["description"])
    effects = json.loads(row["effects"])
    assert len(preset_names) == len(set(preset_names)) == 5, row["device"]
    assert preset_names == sorted(preset_names), row["device"]
    assert len(descriptions) == len(effects) == len(preset_names), row["device"]
    for preset_name in preset_names:
        path = P / row["manufacturer"] / row["model"] / f'{row["device"]} - {preset_name}.json'
        assert path.is_file(), path
        indexed_paths.add(path)
assert indexed_paths == set(ALL), "CSV index and JSON files differ"
print(f"PASS: {len(ALL)} JSON profiles across {len(rows)} devices, complete CSV index")
