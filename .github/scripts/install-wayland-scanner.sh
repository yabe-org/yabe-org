#!/usr/bin/env bash
# Builds and installs the native wayland-scanner whose version matches the wayland
# subproject of the compositor.
#
# When the compositor is cross-compiled, the wayland subproject looks up the
# build-machine wayland-scanner with pkg-config and requires exactly its own
# version, which distribution packages do not provide. The source is taken from
# the given wayland.wrap so that the version always follows the compositor.
#
# Usage: install-wayland-scanner.sh <path to compositor/subprojects/wayland.wrap>
# Requires: curl, tar (xz), meson, ninja, a C compiler, and expat headers.
set -euo pipefail

wrap="$1"
wrap_value() {
  sed -n "s/^$1[[:space:]]*=[[:space:]]*//p" "$wrap"
}
source_url="$(wrap_value source_url)"
source_hash="$(wrap_value source_hash)"
source_filename="$(wrap_value source_filename)"
directory="$(wrap_value directory)"

sudo=""
if [ "$(id -u)" -ne 0 ]; then
  sudo=sudo
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

curl -fsSL -o "$work/$source_filename" "$source_url"
echo "$source_hash  $work/$source_filename" | sha256sum -c -
tar -xf "$work/$source_filename" -C "$work"

meson setup "$work/build" "$work/$directory" \
  --prefix=/usr/local --buildtype=release \
  -Dlibraries=false -Dscanner=true -Dtests=false \
  -Ddocumentation=false -Ddtd_validation=false
ninja -C "$work/build"
$sudo ninja -C "$work/build" install

pkg-config --modversion wayland-scanner
