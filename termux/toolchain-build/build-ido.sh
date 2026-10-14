#!/usr/bin/env bash
# Build IDO 5.3 / 7.1 via decompals/ido-static-recomp for the host.
# The recompilation is portable C++ by design: builds on any arch, including aarch64/Termux.
# Proprietary SGI code inside: the user accepts the license in the app before installing.
#
# Usage: build-ido.sh <ido-static-recomp-checkout> <version: 5.3|7.1> <out-dir>
set -euo pipefail
RECOMP=${1:?ido-static-recomp checkout}; VER=${2:?version}; OUT=${3:?out dir}
BUILD=${BUILD:-$PWD/.build-ido-$VER}
JOBS=$(nproc)

rm -rf "$BUILD" && cp -a "$RECOMP" "$BUILD" && cd "$BUILD"
make setup > /dev/null 2>&1 || make setup   # builds the recomp driver binary
make VERSION=$VER RELEASE=1 -j"$JOBS"

mkdir -p "$OUT"
cp build/$VER/out/* "$OUT/"
echo "ido-$VER-recomp packaged in $OUT ($(ls "$OUT" | wc -l) files)"
