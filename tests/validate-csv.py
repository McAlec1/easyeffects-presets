#!/usr/bin/env python3
"""Validate the CSV structure and metadata in the device index."""
import csv
import json
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
INDEX = ROOT / "index.csv"
EXPECTED_COLUMNS = [
	"manufacturer",
	"model",
	"device",
	"category",
	"version",
	"tested_version",
	"configuration",
	"description",
	"preset",
	"ref",
]
REQUIRED_PRESETS = {"Balanced", "Bass", "Treble"}


def fail(message):
	raise SystemExit(f"FAIL: {message}")


try:
	with INDEX.open(newline="", encoding="utf-8-sig") as index_file:
		reader = csv.reader(index_file, strict=True)
		columns = next(reader, None)
		if columns != EXPECTED_COLUMNS:
			fail(f"expected columns {EXPECTED_COLUMNS}, found {columns}")

		errors = []
		devices = set()
		row_count = 0
		for line_number, values in enumerate(reader, start=2):
			row_count += 1
			if len(values) != len(EXPECTED_COLUMNS):
				errors.append(
					f"line {line_number}: expected {len(EXPECTED_COLUMNS)} fields, found {len(values)}"
				)
				continue

			row = dict(zip(EXPECTED_COLUMNS, values))
			for column, value in row.items():
				if not value.strip():
					errors.append(f"line {line_number}: {column} must not be empty")

			preset_names = None
			descriptions = None
			if row["device"] != f'{row["manufacturer"]} {row["model"]}':
				errors.append(
					f"line {line_number}: device must equal manufacturer + model"
				)
			if row["device"] in devices:
				errors.append(f"line {line_number}: duplicate device {row['device']!r}")
			devices.add(row["device"])

			for column in ("description", "preset"):
				try:
					data = json.loads(row[column])
				except json.JSONDecodeError as error:
					errors.append(
						f"line {line_number}: {column} is not valid JSON ({error.msg})"
					)
					continue
				if not isinstance(data, list) or not all(
					isinstance(item, str) and item.strip() for item in data
				):
					errors.append(f"line {line_number}: {column} must be a list of non-empty strings")
				elif column == "preset":
					preset_names = data
					if len(data) != 5 or len(data) != len(set(data)):
						errors.append(f"line {line_number}: preset must contain five unique names")
					if not REQUIRED_PRESETS.issubset(data):
						errors.append(f"line {line_number}: preset must include {sorted(REQUIRED_PRESETS)}")
				else:
					descriptions = data

			if preset_names is not None and descriptions is not None:
				if len(descriptions) != len(preset_names):
					errors.append(f"line {line_number}: description count must match preset count")

			reference = urlparse(row["ref"])
			if reference.scheme != "https" or not reference.netloc:
				errors.append(f"line {line_number}: ref must be an HTTPS URL")

		if row_count == 0:
			errors.append("index.csv contains no data rows")
except (OSError, UnicodeDecodeError, csv.Error) as error:
	fail(f"cannot read index.csv: {error}")

if errors:
	for error in errors:
		print(f"FAIL: {error}")
	raise SystemExit(f"FAIL: {len(errors)} CSV validation error(s)")

print(f"PASS: {row_count} index rows contain valid CSV and device metadata")
