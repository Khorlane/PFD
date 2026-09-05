#!/usr/bin/env python3
"""Validated PostgreSQL change runner for the PFD permanent database."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATABASE_ROOT = PROJECT_ROOT / "database"
DEFAULT_MANIFEST = DATABASE_ROOT / "manifests" / "core_build_manifest.json"


class BuildError(RuntimeError):
  pass


def sha256(path: Path) -> str:
  digest = hashlib.sha256()
  with path.open("rb") as source:
    for block in iter(lambda: source.read(1024 * 1024), b""):
      digest.update(block)
  return digest.hexdigest()


def sql_literal(value: str) -> str:
  return "'" + value.replace("'", "''") + "'"


def run_psql(dsn_name: str, sql: str, tuples_only: bool = False) -> str:
  command = ["psql", "-X", "--quiet", "--set=ON_ERROR_STOP=1", "--dbname", f"service={dsn_name}"]
  if tuples_only:
    command.extend(["--tuples-only", "--no-align"])
  result = subprocess.run(command, input=sql, text=True, capture_output=True)
  if result.returncode:
    detail = result.stderr.strip() or result.stdout.strip() or "psql failed"
    raise BuildError(detail)
  return result.stdout.strip()


def load_manifest(path: Path) -> dict:
  try:
    manifest = json.loads(path.read_text(encoding="utf-8"))
  except (OSError, json.JSONDecodeError) as exc:
    raise BuildError(f"Cannot read manifest {path}: {exc}") from exc
  if manifest.get("manifest_format_version") != "1":
    raise BuildError("Unsupported manifest format")
  numbers = [item.get("number", "") for item in manifest.get("changes", [])]
  if not numbers or any(not re.fullmatch(r"[0-9]{4}", number) for number in numbers):
    raise BuildError("Manifest change numbers must be four digits")
  if len(numbers) != len(set(numbers)) or numbers != sorted(numbers):
    raise BuildError("Manifest change numbers must be unique and ordered")
  expected = [f"{number:04d}" for number in range(1, len(numbers) + 1)]
  if numbers != expected or manifest.get("expected_final_change") != numbers[-1]:
    raise BuildError("Manifest change sequence is not contiguous or final-change metadata differs")
  return manifest


def validate_files(manifest: dict) -> None:
  for section in ("bootstrap", "changes", "reference_data", "verification", "tests"):
    for item in manifest.get(section, []):
      path = DATABASE_ROOT / item["file"]
      if not path.is_file():
        raise BuildError(f"Manifest file is missing: {item['file']}")
      if sha256(path) != item["sha256"]:
        raise BuildError(f"Checksum mismatch: {item['file']}")


def server_version(dsn_name: str) -> int:
  value = run_psql(dsn_name, "SHOW server_version_num;", tuples_only=True)
  return int(value)


def applied_changes(dsn_name: str) -> dict[str, str]:
  exists = run_psql(
    dsn_name,
    "SET ROLE pfd_database_owner; SELECT to_regclass('core.database_change') IS NOT NULL;",
    tuples_only=True,
  )
  if exists != "t":
    return {}
  output = run_psql(
    dsn_name,
    "SET ROLE pfd_database_owner; SELECT change_number || '|' || file_checksum FROM core.database_change ORDER BY change_number;",
    tuples_only=True,
  )
  records: dict[str, str] = {}
  for line in output.splitlines():
    if line:
      number, checksum = line.split("|", 1)
      records[number] = checksum
  return records


def validate_target(dsn_name: str, manifest: dict) -> dict[str, str]:
  if shutil.which("psql") is None:
    raise BuildError("psql was not found on PATH")
  minimum = int(manifest["minimum_postgresql_major"])
  actual = server_version(dsn_name) // 10000
  if actual < minimum:
    raise BuildError(f"PostgreSQL {minimum}+ is required; target reports {actual}")
  applied = applied_changes(dsn_name)
  expected = {item["number"]: item["sha256"] for item in manifest["changes"]}
  unknown = sorted(set(applied) - set(expected))
  if unknown:
    raise BuildError(f"Target has change numbers absent from this manifest: {', '.join(unknown)}")
  mismatched = sorted(number for number in applied if applied[number] != expected[number])
  if mismatched:
    raise BuildError(f"Applied change checksum mismatch: {', '.join(mismatched)}")
  ordered = [item["number"] for item in manifest["changes"]]
  positions = [ordered.index(number) for number in applied]
  if positions and sorted(positions) != list(range(max(positions) + 1)):
    raise BuildError("Target change history has a gap")
  return applied


def build(dsn_name: str, principal: str, manifest: dict, manifest_path: Path) -> None:
  applied = validate_target(dsn_name, manifest)
  pending = [item for item in manifest["changes"] if item["number"] not in applied]
  if not pending:
    print("Database is current; no changes applied.")
    return
  script = ["\\set ON_ERROR_STOP on", "SELECT pg_advisory_lock(hashtextextended('pfd_database_build', 0));"]
  for item in pending:
    change_sql = (DATABASE_ROOT / item["file"]).read_text(encoding="utf-8")
    script.extend([
      f"\\echo Applying {item['number']} {item['name']}",
      "BEGIN;",
      change_sql,
      "INSERT INTO core.database_change (change_number, change_name, file_name, file_checksum, "
      "manifest_name, manifest_version, applied_at, applied_by_principal_code, execution_duration_ms) VALUES ("
      f"{sql_literal(item['number'])}, {sql_literal(item['name'])}, {sql_literal(item['file'])}, {sql_literal(item['sha256'])}, "
      f"{sql_literal(manifest['name'])}, {sql_literal(manifest['version'])}, clock_timestamp(), {sql_literal(principal)}, "
      "greatest(0, floor(extract(epoch FROM clock_timestamp() - transaction_timestamp()) * 1000))::bigint);",
      "COMMIT;",
    ])
  script.append("SELECT pg_advisory_unlock(hashtextextended('pfd_database_build', 0));")
  run_psql(dsn_name, "\n".join(script) + "\n")
  print(f"Applied {len(pending)} change(s) from {manifest_path.name}.")


def verify(dsn_name: str) -> None:
  verify_path = DATABASE_ROOT / "verification" / "verify_core_build.sql"
  command = ["psql", "-X", "--quiet", "--set=ON_ERROR_STOP=1", "--dbname", f"service={dsn_name}", "--file", str(verify_path)]
  result = subprocess.run(command)
  if result.returncode:
    raise BuildError("Core verification failed")


def status(dsn_name: str, manifest: dict) -> None:
  applied = validate_target(dsn_name, manifest)
  for item in manifest["changes"]:
    state = "APPLIED" if item["number"] in applied else "PENDING"
    print(f"{item['number']}  {state:7}  {item['name']}")


def parse_args() -> argparse.Namespace:
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("mode", choices=("status", "validate", "build", "verify", "build-and-verify"))
  parser.add_argument("--dsn-name", required=True, help="libpq service name; credentials stay outside this package")
  parser.add_argument("--principal", default="DATABASE_BUILD", help="core.principal code recorded in change history")
  parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
  return parser.parse_args()


def main() -> int:
  args = parse_args()
  try:
    if not re.fullmatch(r"[A-Za-z0-9_.-]+", args.dsn_name):
      raise BuildError("DSN service name contains unsupported characters")
    manifest = load_manifest(args.manifest)
    validate_files(manifest)
    if args.mode == "status":
      status(args.dsn_name, manifest)
    elif args.mode == "validate":
      validate_target(args.dsn_name, manifest)
      print("Manifest, files, PostgreSQL version, and target history are valid.")
    elif args.mode == "build":
      build(args.dsn_name, args.principal, manifest, args.manifest)
    elif args.mode == "verify":
      validate_target(args.dsn_name, manifest)
      verify(args.dsn_name)
    else:
      build(args.dsn_name, args.principal, manifest, args.manifest)
      verify(args.dsn_name)
    return 0
  except (BuildError, ValueError) as exc:
    print(f"ERROR: {exc}", file=sys.stderr)
    return 1


if __name__ == "__main__":
  raise SystemExit(main())
