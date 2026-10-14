#!/usr/bin/env bash
# Build every period compiler for aarch64 (the architecture Android/Termux runs on) and package
# them the same way the decompals upstream releases are packaged, so the decompnet registry can
# install them unchanged. Runs on GitHub's arm64 runners and on any aarch64 Linux (e.g. Termux
# itself, where the same script can rebuild everything from source).
#
# Output: out/toolchains-aarch64/*.tar.gz (+ .zip for the GC/WII binutils, like upstream) + SHA256SUMS
# Every compiler's MIPS/ARM codegen is validated byte-for-byte against termux/reference/ by
# validate-toolchains.sh afterwards — the compiler's host must not change the code it emits.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
WORK=${WORK:-$PWD/.work}
OUT=${OUT:-$PWD/out/toolchains-aarch64}
mkdir -p "$WORK" "$OUT"
cd "$WORK"

JOBS=$(nproc)
echo "== building aarch64 toolchains with $JOBS jobs ==="
df -h / | tail -1
S=/data/data/com.termux/files/usr/bin/sh   # shims in release tarballs target Termux

# --------------------------------------------------------------- sources
git clone --depth 1 https://github.com/decompals/mips-binutils-2.6.git 2>/dev/null || true
git clone --depth 1 https://github.com/decompals/mips-gcc-2.7.2.git 2>/dev/null || true
git clone --depth 1 https://github.com/decompals/old-gcc.git 2>/dev/null || true
git clone --depth 1 https://github.com/decompals/ido-static-recomp.git 2>/dev/null || true
git clone --depth 1 https://github.com/pret/agbcc.git 2>/dev/null || true
git clone --depth 1 https://github.com/decompals/binutils-mips-ps2-decompals.git bmips-src 2>/dev/null || true
if [ ! -d binutils-2.42 ]; then
  wget -q https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.xz
  tar xJf binutils-2.42.tar.xz
fi

# --------------------------------------------------------------- N64 + PS1 shared assembler
df -h / | tail -1
clean_builds() { rm -rf "$PWD"/.build-* 2>/dev/null || true; }
clean_builds
bash "$HERE/build-binutils-2.6.sh" "$WORK/mips-binutils-2.6" "$OUT/stage-binutils-2.6"
tar -czf "$OUT/binutils-2.6-aarch64.tar.gz" -C "$OUT/stage-binutils-2.6" .

# --------------------------------------------------------------- N64: KMC GCC 2.7.2
df -h / | tail -1
clean_builds() { rm -rf "$PWD"/.build-* 2>/dev/null || true; }
clean_builds
bash "$HERE/build-gcc-2.7.2-kmc.sh" "$WORK/mips-gcc-2.7.2" "$OUT/stage-gcc-2.7.2-kmc"
tar -czf "$OUT/gcc-2.7.2-kmc-aarch64.tar.gz" -C "$OUT/stage-gcc-2.7.2-kmc" .

# --------------------------------------------------------------- PS1: GCC 2.7.2 / 2.8.1
df -h / | tail -1
clean_builds() { rm -rf "$PWD"/.build-* 2>/dev/null || true; }
clean_builds
GCC_C_FALLBACK="$WORK/mips-gcc-2.7.2/gcc.c" bash "$HERE/build-gcc-2.7.2-psx.sh" "$WORK/old-gcc" "$OUT/stage-gcc-2.7.2-psx"
tar -czf "$OUT/gcc-2.7.2-psx-aarch64.tar.gz" -C "$OUT/stage-gcc-2.7.2-psx" .

df -h / | tail -1
clean_builds() { rm -rf "$PWD"/.build-* 2>/dev/null || true; }
clean_builds
bash "$HERE/build-gcc-2.8.1-psx.sh" "$WORK/old-gcc" "$OUT/stage-gcc-2.8.1-psx"
tar -czf "$OUT/gcc-2.8.1-psx-aarch64.tar.gz" -C "$OUT/stage-gcc-2.8.1-psx" .

# --------------------------------------------------------------- N64: IDO 5.3 / 7.1
df -h / | tail -1
clean_builds() { rm -rf "$PWD"/.build-* 2>/dev/null || true; }
clean_builds
bash "$HERE/build-ido.sh" "$WORK/ido-static-recomp" 7.1 "$OUT/stage-ido-7.1"
tar -czf "$OUT/ido-7.1-recomp-aarch64.tar.gz" -C "$OUT/stage-ido-7.1" .
df -h / | tail -1
clean_builds() { rm -rf "$PWD"/.build-* 2>/dev/null || true; }
clean_builds
bash "$HERE/build-ido.sh" "$WORK/ido-static-recomp" 5.3 "$OUT/stage-ido-5.3"
tar -czf "$OUT/ido-5.3-recomp-aarch64.tar.gz" -C "$OUT/stage-ido-5.3" .

# --------------------------------------------------------------- arm-none-eabi binutils (GBA/DS)
df -h / | tail -1
clean_builds() { rm -rf "$PWD"/.build-* 2>/dev/null || true; }
clean_builds
ARM_CPP_SHBANG=$S bash "$HERE/build-arm-gnu.sh" "$WORK/binutils-2.42" "$OUT/stage-arm-gnu"
tar -czf "$OUT/arm-gnu-aarch64.tar.gz" -C "$OUT/stage-arm-gnu" arm-gnu-aarch64

# --------------------------------------------------------------- GBA: agbcc (needs arm as first)
df -h / | tail -1
clean_builds() { rm -rf "$PWD"/.build-* 2>/dev/null || true; }
clean_builds
bash "$HERE/build-agbcc.sh" "$WORK/agbcc" "$OUT/stage-agbcc" "$OUT/stage-arm-gnu/arm-gnu-aarch64/bin"
tar -czf "$OUT/agbcc-aarch64.tar.gz" -C "$OUT/stage-agbcc" .

# --------------------------------------------------------------- GC/Wii: powerpc-eabi binutils
df -h / | tail -1
clean_builds() { rm -rf "$PWD"/.build-* 2>/dev/null || true; }
clean_builds
bash "$HERE/build-gc-wii-binutils.sh" "$WORK/binutils-2.42" "$OUT/stage-gcwii"
(cd "$OUT/stage-gcwii" && zip -q -r "$OUT/gc-wii-binutils-aarch64.zip" .)

# --------------------------------------------------------------- modern MIPS binutils (maspsx flows)
df -h / | tail -1
clean_builds() { rm -rf "$PWD"/.build-* 2>/dev/null || true; }
clean_builds
bash "$HERE/build-binutils-mips.sh" "$WORK/bmips-src" "$OUT/stage-bmips"
tar -czf "$OUT/binutils-mips-aarch64.tar.gz" -C "$OUT/stage-bmips" .

# --------------------------------------------------------------- manifest
rm -rf "$OUT"/stage-*
(cd "$OUT" && sha256sum ./*.tar.gz ./*.zip > SHA256SUMS 2>/dev/null || sha256sum ./*.tar.gz > SHA256SUMS)
echo "== artifacts:"
ls -la "$OUT"
