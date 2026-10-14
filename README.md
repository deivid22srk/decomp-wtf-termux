# decomp.wtf para Termux

**Port não oficial do [decomp.wtf](https://github.com/i12bp8/decomp.wtf) para Termux (Android, aarch64, sem root)** — com os **compiladores de época** que o julgamento byte a byte exige, em especial o do **PlayStation 1**.

> decomp.wtf (What The Function) é um app local, open source (MIT), onde seu agente de IA decompila jogos que você possui em C que **compila exatamente para os mesmos bytes**, com visualização ao vivo. Este port traz tudo isso para o celular, incluindo compiladores originais dos anos 90/2000 reconstruídos para ARM64.
>
> Todo o crédito da ferramenta original é de [sam wolfs (i12bp8)](https://github.com/i12bp8) e da comunidade de decompilação. Este repositório mantém a licença **MIT** e o [`LICENSE`](LICENSE) original; as mudanças do port estão listadas [abaixo](#o-que-mudou-em-relação-ao-upstream).

---

## Instalação

Um único comando, dentro do Termux:

```bash
curl -fsSL https://raw.githubusercontent.com/deivid22srk/decomp-wtf-termux/main/install.sh | bash
```

O que ele faz: instala os pacotes necessários, o decomp.wtf (via `uv`), os compiladores de época com build aarch64 (PS1 primeiro), os comandos `decomp`/`decomp-update`/`decomp-uninstall` e roda um **teste de sanidade** que prova que o compilador do PS1 reproduz a demo **byte a byte**. IDO (proprietário) só entra se você aceitar a licença (`--with-ido` ou depois, dentro do app em *Setup*).

Atualizar e desinstalar:

```bash
decomp-update      # atualiza o port e os compiladores
decomp-uninstall   # remove tudo (seus projetos em ~/Decomp ficam)
```

## Requisitos

- **Android 8.0+** com **Termux do F-Droid ou do GitHub** (a versão da Play Store é antiga e quebrada — não funciona)
- **aarch64** (qualquer celular/arm de 64 bits dos últimos anos; `armv7` não é suportado)
- ~**2 GB livres** (o app e os compiladores usam pouco; projetos e o Ghidra opcional podem crescer)
- **4 GB de RAM** recomendados (2 GB funcionam para PS1/N64/GBA; compiladores pesados podem ser mortos pelo Android)
- Um agente de IA é opcional: Claude Code, Codex CLI e opencode rodam nativamente no Termux (`decomp connect`)

## Compatibilidade no Termux

| Plataforma | Estado | Compilador | Como roda |
|---|---|---|---|
| **PS1** | ✅ nativo | GCC 2.7.2 / 2.8.1 (estilo PSY-Q) + binutils 2.6 + maspsx | **A** — fonte compilada para aarch64 (estático); linking com `ld.lld` do Termux |
| **N64** | ✅ nativo | KMC GCC 2.7.2 + binutils 2.6; **IDO 5.3/7.1** (proprietário) | **A** — GCC/binutils da fonte; IDO via `ido-static-recomp` |
| **GBA** | ✅ nativo | agbcc (pret) + binutils arm-none-eabi | **A** — fonte compilada para aarch64 |
| **GC/Wii** | ❌ não suportado | CodeWarrior (Windows) via wibo | wibo é x86_64-only e não há CodeWarrior para Linux/ARM |
| **DS** | ❌ não suportado | mwccarm (Windows) via wibo | mesmo motivo acima; `dsd` (extração) chegou como build aarch64 no upstream |
| **PS2** | ❌ não suportado | EE-GCC 2.96 | só existem binários i386 proprietários-modificados, sem fonte pública: impossível recompilar para aarch64 |

Ferramentas de apoio: `m2c` (rascunho do decompilador), `maspsx`, `luvdis`, `splat`/`spimdisasm`, `objdiff-cli`, `dtk`, `cloudflared` — Python/Rust/Go com binários aarch64 nativos quando existem. `objdiff-cli`, `dtk`, `dsd` e `coddog` ainda não têm build estático aarch64 neste port ( funcionam via upstream glibc em outros Linux); sem eles, os fluxos GC/Wii/DS continuam bloqueados pelos compiladores de qualquer forma.

## Como os compiladores funcionam no Android

O Termux roda **bionic, sem glibc e sem root**: nenhum binário x86-64 pré-compilado executa nele. O port usa três estratégias, nesta ordem:

1. **A — Compilação nativa aarch64 (a usada por todos os ✅):** o código-fonte de cada compilador de época é compilado para aarch64 **estaticamente ligado**, com patches mínimos e documentados em `termux/toolchain-build/patches/` (o `configure` de 1995 aprende que aarch64 existe; `-fcommon`, `-std=gnu89`, K&R). O *codegen MIPS/ARM não depende da máquina do compilador*: o CI valida a cada build que os objetos são **byte a byte idênticos** aos das releases oficiais x86-64 (referências em `termux/reference/`).
2. **B — Emulação x86 (box64/qemu):** não usada neste port — lenta em celular e ainda precisaria de glibc via proot.
3. **C — proot-distro (Debian aarch64):** não usada; tudo roda nativo no Termux. Fica como plano B documentado para quem quiser os compiladores ❌.

O que cada um recebe:

- **PS1 — GCC 2.7.2/2.8.1**: fonte vanilla do GNU + patches da comunidade (`decompals/old-gcc`) + patch de host aarch64 deste port. Ligação final com `ld.lld`/`llvm-objcopy`/`llvm-nm` (`pkg install lld llvm`), como no upstream.
- **N64 — KMC GCC 2.7.2**: mesmo esquema (fonte pré-patcheada de `decompals/mips-gcc-2.7.2`). **IDO**: `ido-static-recomp` recompila os binários SGI para C portátil — roda em qualquer arquitetura, inclusive aarch64 (o app exige aceitação da licença antes de instalar).
- **GBA — agbcc**: o fluxo do pret (cpp → agbcc → `arm-none-eabi-as`) com binutils arm-none-eabi construídos estaticamente (a release oficial da Arm para hosts aarch64 é glibc-dinâmica e não roda no Android); o `arm-none-eabi-cpp` é um shim sobre o pré-processador do host, porque agbcc só recebe C pré-processado.
- **GC/Wii/DS**: `wibo` (emulador de Windows x86) não existe para aarch64 e os CodeWarrior só existem como binários Windows — ❌ honesto, sem gambiarras.

## Dicas de desempenho e bateria

- O comando `decomp` já segura um **wake lock**; desligar a tela não para as compilações.
- Nas configurações do Android, desative a **otimização de bateria** para o Termux.
- Cada compilação roda com limite de memória (ulimit) e timeout — um agente entusiasta não derruba o celular.
- Para compilações muito longas, o **Phantom Process Killer** do Android 12+ pode matar filhos do Termux; veja a próxima seção.

## Usando com agentes de IA

```bash
pkg install nodejs-lts        # se ainda não tiver
npm install -g @anthropic-ai/claude-code   # ou: opencode / codex
decomp                        # inicia o app e abre no navegador
decomp connect                # conecta os agentes que detectar
```

Daí em diante é igual ao upstream: *“decompile meu jogo em ~/roms/game.z64”*. O `decomp connect` também serve para Claude Code, Codex e opencode instalados no Termux.

## Solução de problemas

- **"Phantom process está matando meus processos"** (Android 12+): rode no computador com adb:
  `adb shell device_config put activity_manager max_phantom_processes 2147483647`
  (e/ou desative a otimização de bateria do Termux). O Android recria o limite ao reiniciar.
- **Porta ocupada** (`no free port`): o app usa a 6464 em diante; feche outra instância com `decomp stop`.
- **Falta de espaço**: os compiladores vivem em `~/.local/share/decompnet/toolchains`; `decompnet toolchain list` mostra o que está instalado.
- **`ld.lld: command not found`**: `pkg install lld llvm` (necessário para montar as demos PS1/N64).
- **Compilador baixado não roda**: confirme que é Termux aarch64 (`uname -m`); builds armv7/x86 não são distribuídos.
- **zlib 1.1.4 não baixa**: o port usa espelho alternativo fixado (o site do zlib removeu o arquivo); se ainda falhar, baixe manualmente e rode `uv run python projects/zlib-n64/prepare.py`.

## Uso responsável (do projeto original)

decomp.wtf existe para estudos, preservação e modificações de **jogos que você possui**. O projeto **não fornece ROMs, ISOs, BIOS** nem código de jogos comerciais, e não serve para burlar proteções. Projetos só podem ser importados com base legal declarada (código próprio, open source, homebrew ou permissão do detentor) — o app recusa o resto.

---

## English (short version)

This is an **unofficial port of [decomp.wtf](https://github.com/i12bp8/decomp.wtf) (MIT) to Termux/Android (aarch64, no root)**, focused on the **period compilers** that byte-exact matching needs — the PlayStation 1 ones first. Install with:

```bash
curl -fsSL https://raw.githubusercontent.com/deivid22srk/decomp-wtf-termux/main/install.sh | bash
```

Every compiler that ships here is **built from source for aarch64, statically linked** (Android has no glibc): PS1 GCC 2.7.2/2.8.1, N64 KMC GCC 2.7.2, IDO 5.3/7.1 (via `ido-static-recomp`, license-gated), GBA agbcc, plus the MIPS/arm/powerpc binutils they need. CI proves each build's **MIPS/ARM codegen is byte-for-byte identical to the official x86-64 releases** (references in `termux/reference/`); the on-device sanity test re-proves it after install. GC/Wii/DS (CodeWarrior through `wibo`) and PS2 (i386-only EE-GCC 2.96, no public source) are honestly unsupported — see the table above. Original tool and credits: sam wolfs (i12bp8) and the decomp community; this port keeps upstream's MIT `LICENSE`.

## O que mudou em relação ao upstream

Lista completa para facilitar rebase e um eventual pull request. O histórico do upstream é preservado; cada mudança é um commit pequeno em cima dele (`upstream` aponta para `i12bp8/decomp.wtf`).

1. **`src/decompnet/compiler.py`** — no Termux (sem bwrap/prlimit), os limites por compilação (`--as/--fsize`) são aplicados com um wrapper `ulimit` do shell; `DECOMP_NO_ULIMIT=1` desativa.
2. **`src/decompnet/app/cli.py`** — abre o navegador com `termux-open-url`/`termux-open` quando disponíveis.
3. **`src/decompnet/app/launcher.py`** — Android não tem menu de apps; retorna uma mensagem clara.
4. **`src/decompnet/toolchains.toml`** — partes `linux-aarch64` para os compiladores de época (builds estáticos deste repo, release `toolchains-v1`), pin de checksums por SHA-256 como no upstream; o `cmd` do agbcc usa `sh` do PATH em vez de `/bin/sh`.
5. **`projects/zlib-n64/prepare.py`** — espelho alternativo fixado para o zlib 1.1.4 (o site do zlib removeu o tarball; o checksum continua obrigatório).
6. **`termux/`** (novo) — `install.sh`, comandos `decomp`/`decomp-update`/`decomp-uninstall`, `sanity-test.sh`, scripts de build dos compiladores (`toolchain-build/`) com patches de host, e as referências byte a byte (`reference/`).
7. **`.github/workflows/`** (novo) — `ci.yml` (shellcheck + pytest x86-64) e `toolchains.yml` (build aarch64 nos runners ARM64, validação de codegen contra as referências e suite pytest PSX/N64/GBA).
8. **`README.md`** — reescrito para o port (pt-BR + resumo em inglês); `LICENSE` original intacto.

Não alterado de propósito: política de licenças proprietárias (IDO/CodeWarrior exigem aceitação explícita), sandbox em outros sistemas, servidor MCP, API web e toda a lógica de julgamento byte a byte.
