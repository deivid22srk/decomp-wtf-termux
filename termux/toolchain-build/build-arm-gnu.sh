#!/usr/bin/env bash
# Build GNU binutils for arm-none-eabi (as/ld/ar/... used by agbcc and DS projects), statically
# linked, for the host. Arm's official aarch64-host release is glibc-dynamic, which Android
# cannot run: for Termux this static build replaces it (same 2.42-era binutils the GC/Wii
# toolchain uses upstream; modern binutils needs no patches for aarch64 hosts).
#
# Usage: build-arm-gnu.sh <binutils-source> <out-dir>
set -euo pipefail
SRC=${1:?binutils source}; OUT=${2:?out dir}
BUILD=${BUILD:-$PWD/.build-arm-gnu}
JOBS=$(nproc)

rm -rf "$BUILD" && cp -a "$SRC" "$BUILD" && cd "$BUILD"
HOST_TRIPLE=aarch64-unknown-linux-gnu
[ "$(uname -m)" = "x86_64" ] && HOST_TRIPLE=x86_64-unknown-linux-gnu

./configure --target=arm-none-eabi --host=$HOST_TRIPLE --build=$HOST_TRIPLE \
  --prefix="$OUT" --with-gnu-as --with-gnu-ld --disable-nls --disable-werror \
  --disable-sim --disable-gdb --disable-gprof \
  LDFLAGS="-static" CFLAGS="-O2 -fno-stack-protector"

make -j"$JOBS" all-binutils all-gas all-ld

mkdir -p "$OUT/arm-gnu-aarch64/bin"
make -j"$JOBS" all-utils >/dev/null 2>&1 || true
for t in as ld ar ranlib strip objdump readelf nm objcopy c++filt size strings elfedit; do
  case $t in
    as) f=gas/as-new ;;
    ld) f=ld/ld-new ;;
    c++filt) f=$(ls binutils/cxxfilt 2>/dev/null | head -1) ;;
    *) f=$(ls binutils/$t binutils/$t-new 2>/dev/null | head -1) ;;
  esac
  if [ -z "$f" ] || [ ! -f "$f" ]; then
    case $t in as|ld|ar) echo "missing required $t"; exit 1 ;; *) echo "note: optional $t missing, skipping"; continue ;; esac
  fi
  cp "$f" "$OUT/arm-gnu-aarch64/bin/arm-none-eabi-$t"
done

# arm-none-eabi-cpp: a shim over the host's preprocessor (agbcc only preprocesses text).
# The shebang is rendered for Termux by the release build; the CI validation re-renders it.
SHBANG=${ARM_CPP_SHBANG:-/bin/sh}
cat > "$OUT/arm-gnu-aarch64/bin/arm-none-eabi-cpp" <<EOF
#!$SHBANG
# Termux port shim: arm-none-eabi-cpp over the host preprocessor (agbcc only needs text).
for c in \$PREFIX/bin/cpp \$PREFIX/bin/clang-cpp \$PREFIX/bin/clang \$PREFIX/bin/gcc cpp clang-cpp clang gcc cc; do
  if command -v "\$c" >/dev/null 2>&1; then exec "\$c" "\$@"; fi
done
echo "arm-none-eabi-cpp shim: no host preprocessor found" >&2
exit 1
EOF
chmod +x "$OUT/arm-gnu-aarch64/bin/"*
strip "$OUT/arm-gnu-aarch64/bin/"arm-none-eabi-{as,ld,ar,ranlib,strip,objdump,readelf,nm,objcopy,c++filt,size,strings,elfedit} 2>/dev/null || true
echo "arm-gnu packaged in $OUT/arm-gnu-aarch64"
