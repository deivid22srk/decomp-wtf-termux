#!/usr/bin/env bash
# Sanity test for the Termux port: the PS1 compiler installed by decompnet must reproduce
# byte-for-byte the object files the OFFICIAL (x86_64) release of the same compiler produces.
# The reference objects ship in termux/reference/ — same source, same flags, any host.
set -euo pipefail

REPO_URL="https://github.com/deivid22srk/decomp-wtf-termux"
fail() { printf '\033[31m✗ %s\033[0m\n' "$*" >&2; exit 1; }
ok() { printf '\033[32m✓ %s\033[0m\n' "$*"; }
step() { printf '\033[36m▸\033[0m %s\n' "$*"; }

BIN="$(uv tool dir --bin 2>/dev/null || echo "$PREFIX/bin")"
decompnet="$BIN/decompnet"
[ -x "$decompnet" ] || fail "decompnet não encontrado"

SRC_ROOT="${DECOMP_PORT_SRC:-$HOME/.decomp-port-src}"
REF="$SRC_ROOT/termux/reference/psx-gcc272"
[ -f "$REF/libc.o" ] || REF="$(cd "$(dirname "$0")" && pwd)/reference/psx-gcc272"
[ -f "$REF/libc.o" ] || fail "referências do port não encontradas"

TMP="$(mktemp -d "${TMPDIR:-$PREFIX/tmp}/decomp-sanity.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

step "garantindo o compilador do PS1 (gcc-2.7.2-psx)"
"$decompnet" toolchain install gcc-2.7.2-psx >/dev/null 2>&1 || true
TC="$("$decompnet" toolchain path gcc-2.7.2-psx 2>/dev/null || true)"
[ -n "$TC" ] && [ -x "$TC/gcc" ] ||
  fail "gcc-2.7.2-psx não instalado: rode 'decompnet toolchain install gcc-2.7.2-psx'"
ok "$(basename "$TC") pronto"

command -v ld.lld >/dev/null 2>&1 || echo "  (aviso: ld.lld ausente — pkg install lld para builds completos)"

# The real check, the same one the CI does: compile the demo source with the registry flags
# (-O2 -G8, little-endian gas) and compare bytes with the official compiler's object.
step "compilando a demo libc.c com as flags do registro (-O2 -G8 -Wa,-EL)"
"$TC/gcc" -B"$TC/" -c -O2 -G8 -Wa,-EL "$SRC_ROOT/projects/demo-rom/src/libc.c" -o "$TMP/libc.o" ||
  fail "o compilador do PS1 não rodou"
test -s "$TMP/libc.o" || fail "o compilador do PS1 não produziu objeto"
ok "compilou ($(stat -c%s "$TMP/libc.o") bytes)"

step "comparando byte a byte com o objeto do compilador oficial (x86_64)"
a=$(sha256sum < "$TMP/libc.o" | cut -d' ' -f1)
b=$(sha256sum < "$REF/libc.o" | cut -d' ' -f1)
if [ "$a" = "$b" ]; then
  ok "libc.o idêntico byte a byte — score 0 garantido no Termux"
else
  fail "libc.o difere do oficial ($a != $b) — reporte em $REPO_URL/issues"
fi
echo ""
echo "✅ Teste de sanidade do PS1 passou."
