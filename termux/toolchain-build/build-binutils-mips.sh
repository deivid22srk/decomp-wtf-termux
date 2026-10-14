#!/usr/bin/env bash
# Build decompals/binutils-mips-ps2-decompals (the modern MIPS assembler/linker used with
# maspsx for PSX/PS2/N64 projects) for the host, statically linked.
#
# Usage: build-binutils-mips.sh <binutils-source> <out-dir>
#   <binutils-source>: the source tree inside decompals/binutils-mips-ps2-decompals
set -euo pipefail
SRC=${1:?binutils source}; OUT=${2:?out dir}
BUILD=${BUILD:-$PWD/.build-bmips}
JOBS=$(nproc)

rm -rf "$BUILD" && cp -a "$SRC" "$BUILD" && cd "$BUILD"
HOST_TRIPLE=aarch64-unknown-linux-gnu
[ "$(uname -m)" = "x86_64" ] && HOST_TRIPLE=x86_64-unknown-linux-gnu

./configure --target=mips-ps2-decompals --host=$HOST_TRIPLE --build=$HOST_TRIPLE \
  --prefix="$OUT" --with-gnu-as --with-gnu-ld --disable-nls --disable-werror \
  --disable-sim --disable-gdb --disable-gprof \
  LDFLAGS="-static" CFLAGS="-O2 -fno-stack-protector"

make -j"$JOBS" all-binutils all-gas all-ld

mkdir -p "$OUT"
for t in as ld ar ranlib strip objdump readelf nm objcopy c++filt size strings; do
  case $t in
    as) f=gas/as-new ;;
    ld) f=ld/ld-new ;;
    *) f=$(ls binutils/$t binutils/$t-new 2>/dev/null | head -1) ;;
  esac
  [ -f "$f" ] || { echo "note: missing $t, skipping"; continue; }
  cp "$f" "$OUT/mips-ps2-decompals-$t"
done
strip "$OUT"/mips-ps2-decompals-* 2>/dev/null || true
echo "binutils-mips packaged in $OUT"
