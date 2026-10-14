#!/usr/bin/env bash
# Build GCC 2.7.2 with the PlayStation patches (decompals/old-gcc) for the host, statically linked.
# This is the compiler behind PSY-Q-era PS1 code: the port's top priority.
#
# Usage: build-gcc-2.7.2-psx.sh <old-gcc-repo> <out-dir> [tarball-cache-dir]
#   <old-gcc-repo>: a checkout of https://github.com/decompals/old-gcc (provides patches + tests)
#   gcc-2.7.2.tar.gz comes from ftp.gnu.org (fast on CI; cached in /tmp/decompnet-gcc-src when possible)
set -euo pipefail
OLDGCC=${1:?old-gcc checkout}; OUT=${2:?out dir}; CACHE=${3:-/tmp/decompnet-gcc-src}
HERE=$(cd "$(dirname "$0")" && pwd)
BUILD=${BUILD:-$PWD/.build-gcc-2.7.2-psx}
JOBS=$(nproc)
mkdir -p "$CACHE"

if [ ! -f "$CACHE/gcc-2.7.2.tar.gz" ]; then
  echo "downloading gcc-2.7.2.tar.gz (vanilla source) from ftp.gnu.org"
  wget -q -O "$CACHE/gcc-2.7.2.tar.gz" "https://ftp.gnu.org/old-gnu/gcc/gcc-2.7.2.tar.gz"
fi

rm -rf "$BUILD" && mkdir -p "$BUILD" && cd "$BUILD"
tar xzf "$CACHE/gcc-2.7.2.tar.gz"
cd gcc-2.7.2
chmod -R u+w .   # the GNU tarball extracts read-only

# --- decompals/old-gcc recipe (gcc-2.7.2-psx.Dockerfile), verbatim order ---
sed -i -- 's/include <varargs.h>/include <stdarg.h>/g' *.c
P="$OLDGCC/patches"
patch -u -p1 obstack.h -i "$P/obstack-2.7.2.h.patch"
patch -u -p1 configure -i "$P/configure.patch"
patch -u -p1 config.sub -i "$P/config.sub.patch"
patch -u -p1 config/mips/mips.h -i "$P/mipsel-2.7.patch"
patch -su -p1 < "$P/psx-2.5.7.patch"
# aarch64 glibc has no sys_nerr/sys_errlist compat symbols (x86 legacy): the driver must
# use strerror(). old-gcc's gcc-2.5.7.c.patch carries that fix but predates 2.7.2, so it no
# longer applies; decompals/mips-gcc-2.7.2 ships the same fix already applied to its (same
# version) driver, and the driver is target-independent - take its gcc.c.
GCC_C="${GCC_C_FALLBACK:-}"
if [ -n "$GCC_C" ] && [ -f "$GCC_C" ]; then
  cp "$GCC_C" gcc.c
  echo "using the KMC tree's strerror-fixed gcc.c for the driver"
fi

# --- Termux port: teach the 1995 host machinery about 64-bit ARM/x86-64 Linux hosts ---
patch -su -p1 < "$HERE/patches/gcc-2.7.2-aarch64-host.patch"
sh config.sub aarch64-unknown-linux >/dev/null

HOST_TRIPLE=aarch64-unknown-linux
[ "$(uname -m)" = "x86_64" ] && HOST_TRIPLE=x86_64-unknown-linux

export CFLAGS="-O2 -std=gnu89 -static -fno-stack-protector -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 \
 -Wno-error -Wno-return-type -Wno-implicit-function-declaration -Wno-int-conversion -DHAVE_STRERROR"
./configure \
  --target=mips-sony-psx \
  --prefix="$OUT" \
  --with-endian-little \
  --with-gnu-as \
  --disable-gprof \
  --disable-gdb \
  --disable-werror \
  --host=$HOST_TRIPLE \
  --build=$HOST_TRIPLE
unset CFLAGS

# pre-generated parsers must stay newer than their .y sources (git clone gives
# every file the same mtime, and modern bison can't read 1995 grammars)
touch c-parse.c cp/parse.c cp/parse.h 2>/dev/null || true
make --jobs "$JOBS" cpp cc1 xgcc cc1plus g++ CFLAGS="-O2 -std=gnu89 -static -fno-stack-protector -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 -Wno-error -Wno-return-type -Wno-implicit-function-declaration -Wno-int-conversion -DHAVE_STRERROR"

# upstream's own smoke tests (must pass on any host: this is mipsel codegen)
./cc1 -quiet -O2 "$OLDGCC/tests/little_endian.c" -o /tmp/le.s && grep -E 'lbu\s\$2,0\(\$4\)' /tmp/le.s
./cc1 -quiet -O2 "$OLDGCC/tests/section_attribute.c" -o /tmp/sa.s
./cc1 -quiet -O2 "$OLDGCC/tests/host_wide_int.c" -o /tmp/hw.s && grep -E '# 0x80000000$' /tmp/hw.s

mkdir -p "$OUT"
mv xgcc "$OUT/gcc"
cp cpp cc1 cc1plus g++ "$OUT/"
strip "$OUT"/* 2>/dev/null || true
echo "gcc-2.7.2-psx packaged in $OUT"
