#!/usr/bin/env bash
# Usage: sign-apk.sh <input.apk> <output.apk>
# Aligns and signs an APK with the release keystore given through
# ANDROID_KEYSTORE_BASE64, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS and ANDROID_KEY_PASSWORD.
set -euo pipefail

in=$1
out=$2

build_tools=$(ls -d "$ANDROID_HOME"/build-tools/* | sort -V | tail -n 1)
keystore="$RUNNER_TEMP/release.keystore"
aligned="$RUNNER_TEMP/aligned.apk"
trap 'rm -f "$keystore" "$aligned"' EXIT

printf '%s' "$ANDROID_KEYSTORE_BASE64" | base64 -d > "$keystore"

"$build_tools/zipalign" -f -P 16 4 "$in" "$aligned"
"$build_tools/apksigner" sign \
  --ks "$keystore" \
  --ks-pass env:ANDROID_KEYSTORE_PASSWORD \
  --ks-key-alias "$ANDROID_KEY_ALIAS" \
  --key-pass env:ANDROID_KEY_PASSWORD \
  --out "$out" "$aligned"
"$build_tools/apksigner" verify --print-certs "$out"
