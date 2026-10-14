#!/usr/bin/env bash
# Build pret/agbcc (the GBA compiler, a rebuilt GCC for the GBA's CPU) for the host.
# pret's release tarball is x86_64-only; the source builds anywhere gcc/clang lives.
#
# Usage: build-agbcc.sh <agbcc-checkout> <out-dir> [arm-none-eabi-binutils-bin-dir]
#   The 3rd argument is a directory containing arm-none-eabi-as / arm-none-eabi-ar
#   (on the CI arm64 runner: the just-built arm-gnu toolchain; locally: any binutils install).
set -euo pipefail
AGBCC=${1:?agbcc checkout}; OUT=${2:?out dir}; ARMBIN=${3:-}
BUILD=${BUILD:-$PWD/.build-agbcc}
CCOPT=${CC:-}; CXXOPT=${CXX:-}

if [ -n "$ARMBIN" ]; then export PATH="$ARMBIN:$PATH"; fi
command -v arm-none-eabi-as >/dev/null || { echo "need arm-none-eabi-as on PATH (build arm-gnu first)"; exit 1; }
command -v arm-none-eabi-ar >/dev/null || { echo "need arm-none-eabi-ar on PATH"; exit 1; }

rm -rf "$BUILD" && cp -a "$AGBCC" "$BUILD" && cd "$BUILD"

# gcc_arm's configure hardcodes --host=i386-linux-gnu; use the host we're actually on
HOST_TRIPLE=aarch64-unknown-linux-gnu
[ "$(uname -m)" = "x86_64" ] && HOST_TRIPLE=x86_64-unknown-linux-gnu
sed -i "s|--target=arm-elf --host=i386-linux-gnu|--target=arm-elf --host=$HOST_TRIPLE|" build.sh

CCOPTARG=""; [ -n "$CCOPT" ] && CCOPTARG="CC=$CCOPT"
CXXOPTARG=""; [ -n "$CXXOPT" ] && CXXOPTARG="CXX=$CXXOPT"

# upstream build.sh, run for real (it builds old_agbcc, agbcc, agbcc_arm, libgcc.a, libc.a)
bash build.sh $CCOPTARG $CXXOPTARG

# Package exactly like pret's release: bin/, include/, lib/
mkdir -p "$OUT/bin" "$OUT/include" "$OUT/lib"
cp agbcc old_agbcc agbcc_arm "$OUT/bin/"
cp -R libc/include/. "$OUT/include/"
cp ginclude/* "$OUT/include/"
cp libgcc.a libc.a "$OUT/lib/"

# agbcc's flow preprocesses with arm-none-eabi-cpp, which no binutils build ships. Provide a
# shim over the host's preprocessor: agbcc's input is preprocessed C, purely textual.
# The shebang must match where the shell lives: Termux's prefix on Android, /bin/sh elsewhere.
SHBANG=/bin/sh
[ -n "${TERMUX_VERSION:-}" ] && [ -n "${PREFIX:-}" ] && SHBANG="$PREFIX/bin/sh"
if [ "${TERMUX_SHEBANG:-}" = 1 ]; then SHBANG=/data/data/com.termux/files/usr/bin/sh; fi
cat > "$OUT/bin/arm-none-eabi-cpp" <<EOF
#!$SHBANG
# Termux port shim: arm-none-eabi-cpp over the host preprocessor (agbcc only needs text).
for c in \$PREFIX/bin/cpp \$PREFIX/bin/clang-cpp \$PREFIX/bin/clang \$PREFIX/bin/gcc cpp clang-cpp clang gcc cc; do
  if command -v "\$c" >/dev/null 2>&1; then exec "\$c" "\$@"; fi
done
echo "arm-none-eabi-cpp shim: no host preprocessor found" >&2
exit 1
EOF
chmod +x "$OUT/bin/arm-none-eabi-cpp"

echo "agbcc packaged in $OUT"
