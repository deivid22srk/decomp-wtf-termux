#!/usr/bin/env python3
"""Teach an old GCC tree's configure/config.sub about aarch64/x86_64 Linux hosts.

gcc 2.8.1's configure validates the host triple against explicit cases; the 1995-1998
config.sub doesn't know aarch64. The host settings old GCC needs are arch-independent
(POSIX/USG defines + alloca), so route modern Linux hosts through the i386 Linux case,
the same approach decompals uses for arm-apple-darwin hosts on the KMC compiler.

Usage: patch-gcc-host.py <gcc-tree-root>
"""
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])

# ---- config.sub: recognize aarch64/x86_64 as CPUs with company name ----
sub = root / "config.sub"
s = sub.read_text()
if "aarch64" not in s:
    patterns = [
        # gcc 2.7.2 era: "vax-* | tahoe-* | i[345]86-* | ..." list
        (r"(\tvax-\* \| tahoe-\* \| i\[345\]86-\* \| i860-\* \| m68k-\* \| m68000-\* \| m88k-\* \\)",
         r"\1\n\t      | aarch64-* | x86_64-* \\"),
        # gcc 2.8.1 era: bare-CPU list ends with "| sparc | ... | v850)"
        (r"(\t\t\| sparc \| sparclet \| sparclite \| sparc64 \| v850\))",
         r"\t\t| aarch64 | x86_64 \\\n\1"),
        # gcc 2.8.1 era: CPU-with-company list ends with "| f301-*)"
        (r"(\t      \| f301-\*\))",
         r"\t      | aarch64-* | x86_64-* \\\n\1"),
    ]
    changed = False
    for pat, rep in patterns:
        s2 = re.sub(pat, rep, s, count=1)
        if s2 != s:
            s = s2
            changed = True
    if not changed:
        sys.exit(f"config.sub: no known anchor found in {sub} — inspect it and extend patch-gcc-host.py")
    sub.write_text(s)
    print("config.sub: added aarch64/x86_64")
else:
    print("config.sub: already patched")

# ---- configure: add a host case ----
conf = root / "configure"
s = conf.read_text()
if "aarch64-*-linux*" in s:
    print("configure: already patched")
    sys.exit(0)

case = """	aarch64-*-linux* | x86_64-*-linux*)	# 64-bit ARM / x86-64 Linux (Termux port)
		xm_file=i386/xm-linux.h
		xmake_file=x-linux
		fixincludes=Makefile.in
		broken_install=yes
		gnu_ld=yes
		;;
"""
anchors = [
    # gcc 2.7.2 era: the first i386 linux case
    "\ti[345]86-*-linux*oldld*)\t# Intel 80386's running Linux\n",
    # gcc 2.8.1 era: the first i386 linux case
    "\ti[34567]86-*-linux-gnuoldld*)\t# Intel 80386's running GNU/Linux\n",
]
inserted = False
for anchor in anchors:
    if anchor in s:
        s = s.replace(anchor, case + anchor, 1)
        inserted = True
        break
if not inserted:
    # fall back to any "i[3-7]86-*-linux*" case start and insert before it
    m = re.search(r"\n(\ti\[34567\]86-\*-linux[^\n]*\n)", s)
    if not m:
        sys.exit(f"configure: no i386-linux case found in {conf} — inspect it and extend patch-gcc-host.py")
    s = s[:m.start(1)] + case + s[m.start(1):]
conf.write_text(s)
print("configure: added aarch64/x86_64 linux host case")
