#!/usr/bin/env bash
# Build encounter/gc-wii-binutils (powerpc-eabi binutils 2.42) for the host, statically linked.
# The official linux-aarch64.zip is glibc-dynamic — Android can't run it, so the Termux port
# ships a static build of the same source at the same version.
#
# Usage: build-gc-wii-binutils.sh <binutils-source> <out-dir>
set -euo pipefail
SRC=${1:?binutils source}; OUT=${2:?out dir}
BUILD=${BUILD:-$PWD/.build-gcwii}
JOBS=$(nproc)

rm -rf "$BUILD" && cp -a "$SRC" "$BUILD" && cd "$BUILD"
HOST_TRIPLE=aarch64-unknown-linux-gnu
[ "$(uname -m)" = "x86_64" ] && HOST_TRIPLE=x86_64-unknown-linux-gnu

./configure --target=powerpc-eabi --host=$HOST_TRIPLE --build=$HOST_TRIPLE \
  --prefix="$OUT" --with-gnu-as --with-gnu-ld --disable-nls --disable-werror \
  --disable-sim --disable-gdb --disable-gprof \
  LDFLAGS="-static" CFLAGS="-O2 -fno-stack-protector"

make -j"$JOBS" all-binutils all-gas all-ld

# Package exactly like the upstream release: flat powerpc-eabi-* binaries
mkdir -p "$OUT"
for t in as ld ar ranlib strip objdump readelf nm objcopy c++filt size strings elfedit embedspu; do
  case $t in
    as) f=gas/as-new ;;
    ld) f=ld/ld-new ;;
    embedspu) f=binutils/embedspu ;;
    *) f=$(ls binutils/$t binutils/$t-new 2>/dev/null | head -1) ;;
  esac
  [ -f "$f" ] || { echo "note: missing $t, skipping"; continue; }
  cp "$f" "$OUT/powerpc-eabi-$t"
done
strip "$OUT"/powerpc-eabi-* 2>/dev/null || true
echo "gc-wii-binutils packaged in $OUT"
