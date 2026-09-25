#!/usr/bin/env python3
"""
Chintamani Library — Database Migration Script
Export data from local WSL PostgreSQL → Neon Cloud PostgreSQL

Usage:
  pip install psycopg2-binary
  python migrate_to_neon.py

Set NEON_URL before running:
  $env:NEON_URL = "postgresql://user:pass@host.neon.tech/chintamani_library?sslmode=require"
"""

import os
import subprocess
import sys

LOCAL_DB = "postgresql://chintamani:chintamani_secret@172.31.160.213:5432/chintamani_library"
NEON_URL = os.environ.get("NEON_URL", "")

DUMP_FILE = "chintamani_local_dump.sql"


def run(cmd, check=True, **kwargs):
    print(f"  $ {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True, **kwargs)
    if result.stdout.strip():
        print("  STDOUT:", result.stdout.strip()[:500])
    if result.stderr.strip():
        print("  STDERR:", result.stderr.strip()[:500])
    if check and result.returncode != 0:
        print(f"  ERROR: Command failed with code {result.returncode}")
        sys.exit(1)
    return result


def main():
    if not NEON_URL:
        print("ERROR: Set the NEON_URL environment variable first!")
        print("  e.g.: $env:NEON_URL = 'postgresql://user:pass@host.neon.tech/chintamani_library?sslmode=require'")
        sys.exit(1)

    print("=" * 60)
    print("CHINTAMANI LIBRARY — CLOUD DB MIGRATION")
    print("=" * 60)

    # Step 1: Dump local data
    print("\n[1/3] Dumping local PostgreSQL database...")
    run(
        f'pg_dump "{LOCAL_DB}" '
        f'--no-owner --no-acl --if-exists --clean '
        f'--format=plain '
        f'--exclude-table="_prisma_migrations" '
        f'-f "{DUMP_FILE}"'
    )
    size = os.path.getsize(DUMP_FILE) / 1024
    print(f"  Dump complete: {DUMP_FILE} ({size:.1f} KB)")

    # Step 2: Run Prisma migrations on Neon to create schema
    print("\n[2/3] Applying Prisma migrations to Neon...")
    env = os.environ.copy()
    env["DATABASE_URL"] = NEON_URL
    subprocess.run(
        "npx prisma migrate deploy",
        shell=True,
        env=env,
        cwd=os.path.join(os.path.dirname(__file__), "apps", "backend"),
    )

    # Step 3: Restore data to Neon
    print("\n[3/3] Restoring data to Neon cloud database...")
    run(f'psql "{NEON_URL}" -f "{DUMP_FILE}" 2>&1 | tail -20')

    print("\n" + "=" * 60)
    print("✅ MIGRATION COMPLETE!")
    print("   Next: Deploy backend to Railway with NEON_URL as DATABASE_URL")
    print("=" * 60)


if __name__ == "__main__":
    main()
