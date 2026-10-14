#!/usr/bin/env bash
# Build the PS1/N64 binutils 2.6 (decompals/mips-binutils-2.6) for the host, statically linked.
# Usage: build-binutils-2.6.sh <source-tree> <out-dir>
set -euo pipefail
SRC=${1:?source tree}; OUT=${2:?out dir}
HERE=$(cd "$(dirname "$0")" && pwd)
BUILD=${BUILD:-$PWD/.build-binutils-2.6}
JOBS=$(nproc)

rm -rf "$BUILD" && cp -a "$SRC" "$BUILD" && cd "$BUILD"
patch -su -p1 < "$HERE/patches/binutils-2.6-aarch64-host.patch"
sh config.sub aarch64-unknown-linux >/dev/null

HOST_TRIPLE=aarch64-unknown-linux
[ "$(uname -m)" = "x86_64" ] && HOST_TRIPLE=x86_64-unknown-linux

# This 1995 cygnus configure treats every non-option argument as the host triple,
# so CFLAGS must travel through the environment, never as `CFLAGS=... ./configure`.
export CFLAGS="-O2 -static -fno-stack-protector -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 \
 -Wno-error -Wno-implicit-function-declaration -Wno-int-conversion -Wno-return-type"
./configure --target=mips-kmc-elf --prefix="$OUT" --disable-gprof --disable-gdb --disable-werror \
  --host=$HOST_TRIPLE --build=$HOST_TRIPLE
unset CFLAGS

CF="-O2 -static -fno-stack-protector -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 -Wno-error -Wno-implicit-function-declaration -Wno-int-conversion"
make -j"$JOBS" -C bfd      CFLAGS="$CF"
make -j"$JOBS" -C opcodes  CFLAGS="$CF"
make -j"$JOBS" -C libiberty CFLAGS="$CF"
make -j"$JOBS" -C gas      CFLAGS="$CF"
make -j"$JOBS" -C binutils CFLAGS="$CF"

# Package exactly like the upstream release tarball: ar, as, strip, objcopy, c++filt
mkdir -p "$OUT"
cp binutils/ar "$OUT/ar"
cp gas/as.new "$OUT/as"
cp binutils/strip.new "$OUT/strip"
cp binutils/objcopy "$OUT/objcopy"
cp binutils/cxxfilt "$OUT/c++filt" 2>/dev/null || cp binutils/c++filt "$OUT/c++filt"
strip "$OUT"/* 2>/dev/null || true
echo "binutils-2.6 packaged in $OUT"
