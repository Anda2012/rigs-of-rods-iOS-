#!/usr/bin/env bash
# Package a built .app directory into an unsigned .ipa.
# Usage: tools/ios/make_ipa.sh path/to/App.app [output.ipa]
set -euo pipefail
APP="${1:?usage: make_ipa.sh path/to/App.app [output.ipa]}"
OUT="${2:-RigsOfRods-iOS.ipa}"
[ -d "$APP" ] || { echo "not a directory: $APP" >&2; exit 1; }
OUT_DIR="$(dirname "$OUT")"
mkdir -p "$OUT_DIR"
OUT_PATH="$(cd "$OUT_DIR" && pwd)/$(basename "$OUT")"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/Payload"
cp -R "$APP" "$TMP/Payload/"
( cd "$TMP" && zip -qry "$OUT_PATH" Payload )
echo "Created $OUT_PATH"
