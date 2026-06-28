#!/usr/bin/env bash
# Stamp syntax/vim.vim with the vimlrs version it was checked against.
#
# vimlrs ports a curated subset of Neovim's eval-engine surface (statements,
# ex commands, scope sigils, and the funcs.c builtin subset), so the keyword /
# builtin lists are hand-curated in syntax/vim.vim — there is no 10k-builtin
# reflection table to dump like stryke. This script keeps the one volatile
# piece — the "verified against vimlrs vX.Y.Z" line and the dynamically-counted
# token totals — in sync with the binary.
#
#   ./scripts/gen_syntax.sh        # uses `vimlrs` on $PATH
#   VIMLRS=/path/to/vimlrs ./scripts/gen_syntax.sh
set -euo pipefail

vimlrs="${VIMLRS:-vimlrs}"
here="$(cd "$(dirname "$0")/.." && pwd)"
out="$here/syntax/vim.vim"

ver="$("$vimlrs" --version 2>/dev/null | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
ver="${ver:-unknown}"

# Count the curated token surface straight out of the syntax file (source of
# truth), so the reported numbers never drift from what is highlighted.
count() { grep -hoE "syntax keyword $1 .*" "$out" | sed -E "s/syntax keyword $1 //" | tr ' ' '\n' | grep -c .; }
nfunc="$(count vimFunction)"
nstmt="$(count vimStatement)"

# Rewrite only the single "Verified against ..." stamp line in place.
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
sed -E "s|^\" Verified against vimlrs .*|\" Verified against vimlrs ${ver} — Neovim eval engine port (fusevm).|" "$out" > "$tmp"
mv "$tmp" "$out"

echo "stamped $out (vimlrs ${ver}; ${nfunc} builtin functions, ${nstmt} statement keywords)"
