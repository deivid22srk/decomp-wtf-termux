#!/usr/bin/env bash
# Build decompals/mips-gcc-2.7.2 (the KMC-compatible N64 compiler) for the host, statically linked.
# Usage: build-gcc-2.7.2-kmc.sh <source-tree> <out-dir> [<old-gcc-checkout>]
#   The optional old-gcc checkout provides the driver patch that makes gcc.c use strerror()
#   instead of glibc's x86-only sys_nerr/sys_errlist compat symbols (they never existed on
#   aarch64, where this port builds).
set -euo pipefail
SRC=${1:?source tree}; OUT=${2:?out dir}; OLDGCC=${3:-}
HERE=$(cd "$(dirname "$0")" && pwd)
BUILD=${BUILD:-$PWD/.build-gcc-2.7.2-kmc}
JOBS=$(nproc)

rm -rf "$BUILD" && cp -a "$SRC" "$BUILD" && cd "$BUILD"
patch -su -p1 < "$HERE/patches/gcc-2.7.2-aarch64-host.patch"
if [ -n "$OLDGCC" ]; then
  patch -u -p1 gcc.c -i "$OLDGCC/patches/gcc-2.5.7.c.patch"
fi
sh config.sub aarch64-unknown-linux >/dev/null

HOST_TRIPLE=aarch64-unknown-linux
[ "$(uname -m)" = "x86_64" ] && HOST_TRIPLE=x86_64-unknown-linux

export CFLAGS="-O2 -static -std=gnu89 -fno-stack-protector -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 \
 -Wno-error -Wno-return-type -Wno-implicit-function-declaration -Wno-int-conversion -DHAVE_STRERROR"
./configure --target=mips-mips-gnu --prefix="$OUT" --with-gnu-as --disable-gprof --disable-gdb \
  --disable-werror --host=$HOST_TRIPLE --build=$HOST_TRIPLE
unset CFLAGS

# c-parse.c is pre-generated in the repo; touch it so bison never runs (modern bison chokes on 1995 grammar)
touch c-parse.c
CF="-O2 -static -std=gnu89 -fno-stack-protector -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 -Wno-error -Wno-return-type -Wno-implicit-function-declaration -Wno-int-conversion -DHAVE_STRERROR"
make -j"$JOBS" CFLAGS="$CF" xgcc cc1 cc1plus cpp cccp g++

mkdir -p "$OUT"
cp xgcc "$OUT/gcc"
cp cc1 cc1plus cpp cccp g++ "$OUT/"
strip "$OUT"/* 2>/dev/null || true
echo "gcc-2.7.2-kmc packaged in $OUT"
