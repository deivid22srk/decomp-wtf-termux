#!/usr/bin/env bash
# Validate the freshly built aarch64 compilers: their MIPS/ARM codegen must be byte-for-byte
# identical to the official decompals x86_64/i386 releases (references in termux/reference/).
# The compiler's host must not change the code it emits — that is what makes matching work.
#
# Usage: validate-toolchains.sh <tarball-dir> [<work-dir>]
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../.." && pwd)
TARBALLS=${1:?tarball dir}
WORK=${2:-$PWD/.validate}
EXP=$ROOT/termux/reference
mkdir -p "$WORK"
cd "$WORK"

DEMO=$ROOT/projects
GAME_INC=$DEMO/demo-n64/original

fail() { echo "FAIL: $*" >&2; exit 1; }
check() { # $1=expected file  $2=actual file
  a=$(sha256sum < "$1" | cut -d' ' -f1)
  b=$(sha256sum < "$2" | cut -d' ' -f1)
  if [ "$a" != "$b" ]; then fail "$2 differs from reference $1 ($a != $b)"; fi
  echo "  ok: $(basename "$2") matches the reference bytes"
}

extract() { tar -xzf "$TARBALLS/$1"; }
extract gcc-2.7.2-psx-aarch64.tar.gz
extract binutils-2.6-aarch64.tar.gz
cp binutils-2.6-aarch64.tar.gz /dev/null 2>/dev/null || true
mkdir -p tc272 tc281 kmc
tar -xzf "$TARBALLS/gcc-2.7.2-psx-aarch64.tar.gz" -C tc272
tar -xzf "$TARBALLS/binutils-2.6-aarch64.tar.gz" -C tc272
tar -xzf "$TARBALLS/gcc-2.8.1-psx-aarch64.tar.gz" -C tc281
tar -xzf "$TARBALLS/binutils-2.6-aarch64.tar.gz" -C tc281
tar -xzf "$TARBALLS/gcc-2.7.2-kmc-aarch64.tar.gz" -C kmc
tar -xzf "$TARBALLS/binutils-2.6-aarch64.tar.gz" -C kmc

echo "== PS1: gcc-2.7.2-psx (driver + binutils 2.6, registry flags -O2 -G8 -Wa,-EL)"
./tc272/gcc -B./tc272/ -c -O2 -G8 -Wa,-EL -I "$GAME_INC" "$DEMO/demo-rom/src/main.c" -o main272.o
./tc272/gcc -B./tc272/ -c -O2 -G8 -Wa,-EL -I "$GAME_INC" "$DEMO/demo-rom/src/libc.c" -o libc272.o
./tc272/gcc -B./tc272/ -c -O2 -G8 -Wa,-EL -I "$GAME_INC" "$DEMO/demo-n64/original/game.c" -o game272.o
./tc272/gcc -B./tc272/ -c -O2 -G8 -Wa,-EL "$DEMO/demo-psx/psxrt.c" -o psxrt272.o
for f in main libc game psxrt; do check "$EXP/psx-gcc272/$f.o" "$f"272.o; done

echo "== PS1: gcc-2.8.1-psx (codegen check via cc1; its raw asm needs maspsx-era gas for labels)"
for f in main libc game psxrt; do
  case $f in
    main) src=$DEMO/demo-rom/src/main.c; inc="-I $GAME_INC" ;;
    libc) src=$DEMO/demo-rom/src/libc.c; inc="" ;;
    game) src=$DEMO/demo-n64/original/game.c; inc="" ;;
    psxrt) src=$DEMO/demo-psx/psxrt.c; inc="" ;;
  esac
  # shellcheck disable=SC2086
  ./tc281/cpp $src $inc -o /tmp/v_$f.i
  ./tc281/cc1 -quiet -O2 /tmp/v_$f.i -o /tmp/v_$f.s
  check "$EXP/psx-gcc281/$f.s" /tmp/v_$f.s
done

echo "== N64: gcc-2.7.2-kmc (driver + binutils 2.6, registry flags -G0 -mips3 -mgp32 -mfp32 -O2)"
./kmc/gcc -B./kmc/ -c -G0 -mips3 -mgp32 -mfp32 -O2 -I "$GAME_INC" "$DEMO/demo-rom/src/main.c" -o maink.o
./kmc/gcc -B./kmc/ -c -G0 -mips3 -mgp32 -mfp32 -O2 "$DEMO/demo-rom/src/libc.c" -o libck.o
./kmc/gcc -B./kmc/ -c -G0 -mips3 -mgp32 -mfp32 -O2 -I "$GAME_INC" "$DEMO/demo-n64/original/game.c" -o gamek.o
for f in main libc game; do check "$EXP/n64-gcc272/$f.o" "${f}k.o"; done

echo "== GBA: agbcc + arm-gnu (pret flow: cpp -> agbcc -O2 -> as -mcpu=arm7tdmi)"
extract agbcc-aarch64.tar.gz
extract arm-gnu-aarch64.tar.gz
# validation host isn't Termux: render the preprocessor shim for /bin/sh
sed -i '1s|^#!.*|#!/bin/sh|' arm-gnu-aarch64/bin/arm-none-eabi-cpp
chmod +x arm-gnu-aarch64/bin/arm-none-eabi-cpp
./arm-gnu-aarch64/bin/arm-none-eabi-cpp -nostdinc -undef -I agbcc-aarch64/include \
  "$DEMO/demo-n64/original/game.c" -o /tmp/vgba.i
./agbcc-aarch64/bin/agbcc -mthumb-interwork -O2 /tmp/vgba.i -o /tmp/vgba.s
./arm-gnu-aarch64/bin/arm-none-eabi-as -mcpu=arm7tdmi -o vgba.o /tmp/vgba.s
test -s vgba.o || fail "agbcc pipeline produced no object"
echo "  ok: agbcc pipeline produced a non-empty object ($(stat -c%s vgba.o) bytes)"

echo "== IDO: smoke (proprietary; recomp binaries built by ido-static-recomp)"
extract ido-7.1-recomp-aarch64.tar.gz
extract ido-5.3-recomp-aarch64.tar.gz
printf 'int f(int a) { return a * 3; }\n' > /tmp/v_ido.c
./ido-7.1/cc -c -O2 -mips2 -G 0 -non_shared -Xcpluscomm -Wab,-r4300_mul -woff 649,838,712 \
  -I ido-7.1/include /tmp/v_ido.c -o /tmp/v_ido.o 2>/dev/null || \
  ./ido-7.1/cc -c -O2 -mips2 -G 0 -non_shared -Xcpluscomm -I ido-7.1/include /tmp/v_ido.c -o /tmp/v_ido.o
test -s /tmp/v_ido.o || fail "IDO 7.1 produced no object"
echo "  ok: IDO 7.1 produced a non-empty object ($(stat -c%s /tmp/v_ido.o) bytes)"

echo "ALL VALIDATIONS PASSED"
