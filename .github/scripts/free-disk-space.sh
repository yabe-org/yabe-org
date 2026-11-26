#!/usr/bin/env bash
# Removes large preinstalled toolchains that no job in this repository uses.
set -euo pipefail

df -h /
sudo rm -rf \
  /usr/share/dotnet \
  /usr/local/.ghcup \
  /opt/ghc \
  /opt/hostedtoolcache/CodeQL \
  /usr/local/share/boost \
  /usr/local/share/powershell
df -h /
