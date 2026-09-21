#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p ~/bobac_match/scripts ~/.reinovo/maps ~/bobac_match_logs
cp "$ROOT"/maps/site_0827_new.* ~/.reinovo/maps/
cp "$ROOT"/scripts/* ~/bobac_match/scripts/
chmod +x ~/bobac_match/scripts/*.sh ~/bobac_match/scripts/*.py 2>/dev/null || true

echo "RESTORE_OK"
echo "scripts: ~/bobac_match/scripts"
echo "maps: ~/.reinovo/maps/site_0827_new.yaml/.pgm"
