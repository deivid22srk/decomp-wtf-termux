#!/usr/bin/env bash
# decomp.wtf for Termux: one-command installer.
#
#   curl -fsSL https://raw.githubusercontent.com/deivid22srk/decomp-wtf-termux/main/install.sh | bash
#
# Unofficial port of i12bp8/decomp.wtf (MIT) to Termux/Android, aarch64, no root.
# What it does, and nothing else:
#   1. checks that this really is Termux on aarch64
#   2. installs the Termux packages decomp.wtf needs (python, uv, llvm/lld, build tools)
#   3. installs decomp.wtf itself with uv, in its own environment
#   4. installs the period compilers that have aarch64 builds (checksum-pinned), PS1 first
#   5. adds the `decomp`, `decomp-update` and `decomp-uninstall` commands
#   6. runs a sanity test: the PS1 compiler must reproduce a demo function byte for byte
#
# Your projects go to ~/Decomp. Nothing is sent anywhere.
# Options: --no-toolchains (skip step 4) --no-sanity (skip step 6) --with-ido (accept IDO's license)
set -euo pipefail

REPO="${DECOMP_PORT_REPO:-https://github.com/deivid22srk/decomp-wtf-termux}"
BRANCH="${DECOMP_PORT_BRANCH:-main}"
WITH_IDO=0
WITH_TOOLCHAINS=1
WITH_SANITY=1
for arg in "$@"; do
  case "$arg" in
    --no-toolchains) WITH_TOOLCHAINS=0 ;;
    --no-sanity) WITH_SANITY=0 ;;
    --with-ido) WITH_IDO=1 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
step() { printf '\033[36m▸\033[0m %s\n' "$*"; }
fail() { printf '\033[31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

bold "decomp.wtf para Termux (port não oficial)"
echo "  upstream: https://github.com/i12bp8/decomp.wtf (MIT) — port: $REPO"

# ------------------------------------------------------------------ 1. the right device?
[ -n "${TERMUX_VERSION:-}" ] || [ "${PREFIX:-}" = "/data/data/com.termux/files/usr" ] ||
  fail "isto não parece Termux. Instale o Termux pelo F-Droid ou GitHub (não pela Play Store) e rode lá."
ARCH=$(uname -m)
case "$ARCH" in
  aarch64) ;;
  armv7*|armv8l) fail "arquitetura $ARCH detectada: este port distribui binários aarch64. Termux de 64 bits (aarch64) é necessário." ;;
  x86_64) fail "x86_64 (emulador?). O port é compilado para aarch64; em emuladores use o decomp.wtf original." ;;
  *) fail "arquitetura $ARCH não suportada por este port." ;;
esac
command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 || fail "curl ou wget é necessário"
step "Termux $TERMUX_VERSION em $ARCH"

# ------------------------------------------------------------------ 2. packages
APK() { pkg install -y "$@" >/dev/null 2>&1 || pkg install -y "$@"; }
step "instalando pacotes do Termux (isso pode levar alguns minutos)"
yes | pkg update -y >/dev/null 2>&1 || true
APK python git clang make cmake ninja binutils pkg-config libffi openssl libxml2 libxslt \
    curl wget tar xz-utils unzip lld llvm rust
command -v python >/dev/null 2>&1 || fail "python não instalou; rode 'pkg install python' e tente de novo"
PYVER=$(python -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')
step "python $PYVER, $(command -v lld >/dev/null 2>&1 && lld --version | head -1 || echo 'lld ausente (PS1 linking precisa dele)')"

# ------------------------------------------------------------------ 3. uv + decomp.wtf
if ! command -v uv >/dev/null 2>&1; then
  step "instalando uv"
  if ! APK uv; then pip install --no-cache-dir uv; fi
fi
command -v uv >/dev/null 2>&1 || fail "uv não instalou: rode 'pkg install uv' e tente de novo"
step "uv $(uv --version | cut -d' ' -f2)"

SRC="${DECOMP_PORT_SRC:-$HOME/.decomp-port-src}"
if [ -d "$SRC/.git" ]; then
  step "atualizando o código do port em $SRC"
  git -C "$SRC" fetch origin "$BRANCH" --quiet
  git -C "$SRC" reset --hard "origin/$BRANCH" --quiet
else
  step "baixando o código do port para $SRC"
  rm -rf "$SRC.tmp"
  git clone --depth 1 -b "$BRANCH" "$REPO.git" "$SRC.tmp"
  rm -rf "$SRC" && mv "$SRC.tmp" "$SRC"
fi

step "instalando decomp.wtf (decompnet) com uv"
uv tool install --force --python "$(command -v python)" "$SRC" 2>&1 | rg -v "^$" || true
BIN="$(uv tool dir --bin)"
export PATH="$BIN:$PATH"
command -v decomp >/dev/null 2>&1 || fail "decompnet não instalou: veja os erros acima"

# ------------------------------------------------------------------ 4. toolchains
if [ "$WITH_TOOLCHAINS" = 1 ]; then
  step "compiladores de época: instalando os que têm build aarch64"
  for tc in gcc-2.7.2-psx gcc-2.8.1-psx gcc-2.7.2-kmc m2c maspsx objdiff-cli; do
    if "$BIN/decompnet" toolchain install "$tc"; then
      step "  ok: $tc"
    else
      echo "  ! $tc não instalou (o app mostra como resolver); seguindo" >&2
    fi
  done
  if [ "$WITH_IDO" = 1 ]; then
    step "IDO (compilador proprietário da SGI): instalando com a licença aceita por --with-ido"
    "$BIN/decompnet" toolchain install ido-7.1 --accept-license ||
      echo "  ! ido-7.1 não instalou; seguindo" >&2
    "$BIN/decompnet" toolchain install ido-5.3 --accept-license || true
  else
    echo "  IDO (a maioria dos jogos N64 de primeira parte) é proprietário:"
    echo "  quando quiser, aceite a licença dele dentro do app (Setup) ou rode:"
    echo "    decompnet toolchain install ido-7.1 --accept-license"
  fi
fi

# ------------------------------------------------------------------ 5. shortcuts
step "instalando os comandos decomp, decomp-update e decomp-uninstall"
SCRIPTS="$SRC/termux"
for c in decomp decomp-update decomp-uninstall; do
  cp "$SCRIPTS/$c" "$PREFIX/bin/$c"
  chmod +x "$PREFIX/bin/$c"
done

# ------------------------------------------------------------------ 6. sanity test
if [ "$WITH_SANITY" = 1 ]; then
  step "teste de sanidade: o compilador do PS1 precisa reproduzir a função demo byte a byte"
  if bash "$SCRIPTS/sanity-test.sh"; then
    :
  else
    echo "  ! o teste de sanidade falhou — o app instala, mas reporte em $REPO/issues" >&2
  fi
fi

# ------------------------------------------------------------------ battery tips (once)
NOTE="$HOME/.decomp-port-battery-note"
if [ ! -f "$NOTE" ]; then
  cat <<'EOF'
  Dicas para o Android não matar o decomp.wtf:
    - rode `termux-wake-lock` enquanto ele estiver trabalhando (o comando `decomp` já faz isso)
    - nas configurações do Android, desative a otimização de bateria para o Termux
    - compilações longas podem ser mortas pelo "Phantom Process Killer": veja o README
      (seção "Solução de problemas") para desativá-lo via adb
EOF
  touch "$NOTE"
fi

bold "✅ Instalado! Digite: decomp"
