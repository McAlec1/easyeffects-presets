#!/usr/bin/env python3
"""Validate the CSV structure and metadata in the device index."""
import csv
import json
import re
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
INDEX = ROOT / "index.csv"
EXPECTED_COLUMNS = [
	"manufacturer",
	"model",
	"device",
	"category",
	"channels",
	"preset_revision",
	"target_version",
	"hardware_verified",
	"configuration",
	"description",
	"presets",
	"reference",
]
REQUIRED_PRESETS = {"Balanced", "Bass", "Treble"}
VALID_CATEGORIES = {
	"desktop_2.1",
	"desktop_speakers",
	"home_theater",
	"laptop",
	"micro_hifi",
	"powered_bookshelf",
	"soundbar",
	"studio_monitors",
}
CHANNELS_PATTERN = re.compile(r"[1-9][0-9]*(?:\.[0-9]+){1,2}\Z")
REVISION_PATTERN = re.compile(r"[1-9][0-9]*\Z")
TARGET_VERSION_PATTERN = re.compile(r"[0-9]+\.[0-9]+\.(?:[0-9]+|x)\Z")
VALID_HARDWARE_VERIFIED = {"true", "false"}


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
			if row["category"] not in VALID_CATEGORIES:
				errors.append(
					f"line {line_number}: category must be one of {sorted(VALID_CATEGORIES)}"
				)
			if not CHANNELS_PATTERN.fullmatch(row["channels"]):
				errors.append(
					f"line {line_number}: channels must contain two or three dot-separated numbers"
				)
			if not REVISION_PATTERN.fullmatch(row["preset_revision"]):
				errors.append(
					f"line {line_number}: preset_revision must be a positive integer"
				)
			if not TARGET_VERSION_PATTERN.fullmatch(row["target_version"]):
				errors.append(
					f"line {line_number}: target_version must use major.minor.patch format"
				)
			if row["hardware_verified"] not in VALID_HARDWARE_VERIFIED:
				errors.append(
					f"line {line_number}: hardware_verified must be 'true' or 'false'"
				)

			preset_names = None
			descriptions = None
			if row["device"] != f'{row["manufacturer"]} {row["model"]}':
				errors.append(
					f"line {line_number}: device must equal manufacturer + model"
				)
			if row["device"] in devices:
				errors.append(f"line {line_number}: duplicate device {row['device']!r}")
			devices.add(row["device"])

			for column in ("description", "presets"):
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
				elif column == "presets":
					preset_names = data
					if len(data) != 5 or len(data) != len(set(data)):
						errors.append(f"line {line_number}: presets must contain five unique names")
					if not REQUIRED_PRESETS.issubset(data):
						errors.append(f"line {line_number}: presets must include {sorted(REQUIRED_PRESETS)}")
				else:
					descriptions = data

			if preset_names is not None and descriptions is not None:
				if len(descriptions) != len(preset_names):
					errors.append(f"line {line_number}: description count must match preset count")

			reference = urlparse(row["reference"])
			if reference.scheme != "https" or not reference.netloc:
				errors.append(f"line {line_number}: reference must be an HTTPS URL")

		if row_count == 0:
			errors.append("index.csv contains no data rows")
except (OSError, UnicodeDecodeError, csv.Error) as error:
	fail(f"cannot read index.csv: {error}")

if errors:
	for error in errors:
		print(f"FAIL: {error}")
	raise SystemExit(f"FAIL: {len(errors)} CSV validation error(s)")

print(f"PASS: {row_count} index rows contain valid CSV and device metadata")
