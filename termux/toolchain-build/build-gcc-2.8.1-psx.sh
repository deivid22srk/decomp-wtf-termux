#!/usr/bin/env bash
# Build GCC 2.8.1 with the PlayStation patches (decompals/old-gcc) for the host, statically linked.
# The later PSY-Q-era PS1 compiler.
#
# Usage: build-gcc-2.8.1-psx.sh <old-gcc-repo> <out-dir> [tarball-cache-dir]
set -euo pipefail
OLDGCC=${1:?old-gcc checkout}; OUT=${2:?out dir}; CACHE=${3:-/tmp/decompnet-gcc-src}
HERE=$(cd "$(dirname "$0")" && pwd)
BUILD=${BUILD:-$PWD/.build-gcc-2.8.1-psx}
JOBS=$(nproc)
mkdir -p "$CACHE"

if [ ! -f "$CACHE/gcc-2.8.1.tar.gz" ]; then
  echo "downloading gcc-2.8.1.tar.gz (vanilla source) from ftp.gnu.org"
  wget -q -O "$CACHE/gcc-2.8.1.tar.gz" "https://ftp.gnu.org/gnu/gcc/gcc-2.8.1.tar.gz"
fi

rm -rf "$BUILD" && mkdir -p "$BUILD" && cd "$BUILD"
tar xzf "$CACHE/gcc-2.8.1.tar.gz"
cd gcc-2.8.1
chmod -R u+w .   # the GNU tarball extracts read-only

# --- decompals/old-gcc recipe (gcc-2.8.1-psx.Dockerfile), verbatim order ---
sed -i -- 's/include <varargs.h>/include <stdarg.h>/g' *.c
P="$OLDGCC/patches"
patch -u -p1 obstack.h -i "$P/obstack-2.8.1.h.patch"
patch -u -p1 config/mips/mips.h -i "$P/mips.patch"
patch -su -p1 < "$P/psx.patch"

# --- Termux port: teach the host machinery about 64-bit ARM / x86-64 Linux hosts ---
python3 "$HERE/patch-gcc-host.py" .
sh config.sub aarch64-unknown-linux >/dev/null

HOST_TRIPLE=aarch64-unknown-linux
[ "$(uname -m)" = "x86_64" ] && HOST_TRIPLE=x86_64-unknown-linux

export CFLAGS="-O2 -std=gnu89 -static -fno-stack-protector -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 \
 -Wno-error -Wno-return-type -Wno-implicit-function-declaration -Wno-int-conversion"
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

touch insn-config.h   # upstream does the same: the generated header is committed staled in old trees
# pre-generated parsers must stay newer than their .y sources (git clone gives
# every file the same mtime, and modern bison can't read 1995 grammars)
touch c-parse.c cp/parse.c cp/parse.h 2>/dev/null || true
make --jobs "$JOBS" cpp cc1 xgcc cc1plus g++ CFLAGS="-O2 -std=gnu89 -static -fno-stack-protector -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 -Wno-error -Wno-return-type -Wno-implicit-function-declaration -Wno-int-conversion"

# upstream's own smoke tests (mipsel codegen must not depend on the compiler's host)
./cc1 -quiet -O2 "$OLDGCC/tests/little_endian.c" -o /tmp/le.s && grep -E 'lbu\s\$2,0\(\$4\)' /tmp/le.s
./cc1 -quiet -O2 "$OLDGCC/tests/section_attribute.c" -o /tmp/sa.s
./cc1 -quiet -O2 "$OLDGCC/tests/host_wide_int.c" -o /tmp/hw.s && grep -E '# 0x80000000$' /tmp/hw.s

mkdir -p "$OUT"
mv xgcc "$OUT/gcc"
cp cpp cc1 cc1plus g++ "$OUT/"
strip "$OUT"/* 2>/dev/null || true
echo "gcc-2.8.1-psx packaged in $OUT"
