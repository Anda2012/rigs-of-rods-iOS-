#!/usr/bin/env bash
# Package a built RoR.app into an unsigned .ipa.
# LiveContainer re-signs apps itself (JIT-less mode uses your SideStore/AltStore certificate), so no signing here.
# Usage: tools/ios/make_ipa.sh path/to/RoR.app [output.ipa]
set -euo pipefail
APP="${1:?usage: make_ipa.sh path/to/RoR.app [output.ipa]}"
OUT="${2:-RigsOfRods-iOS.ipa}"
[ -d "$APP" ] || { echo "not a directory: $APP" >&2; exit 1; }
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/Payload"
cp -R "$APP" "$TMP/Payload/"
( cd "$TMP" && zip -qry "$OLDPWD/$OUT" Payload )
echo "Created $OUT"
