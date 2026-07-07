#!/usr/bin/env bash
# spine-gate.sh — v1.2 TYPED crystallization gate. Deterministic grep/sed/tr/sort — commit-path safe (no LLM).
# The "mechanism, not approval" rule, generalized: each crystal TYPE has its own minimal
# "what makes it non-empty gold" — a bare "yes"/empty FAILS for EVERY type.
#   type is read DETERMINISTICALLY from the node header tag  [GOLDEN·<type>]  (·/space/✓ tolerated):
#     factual   (default when untagged — backward-compatible) : Crystal + How-it-works with a REAL cite
#     decision  : Crystal + **Why:**(substance) + **Rejected:**(non-bare, names the killed alternative)
#     definition: Crystal + **Was:**(non-bare, the old meaning) + **Why-not:**(substance)
#     open      : Crystal + **Blocks:**(non-bare, what's blocked) + **Resolve:**(substance, what closes it)
# Usage: spine-gate.sh <node-block-file>  |  printf '%s' "$block" | spine-gate.sh -
# Exit: 0 = PASS · 1 = gate FAIL · 2 = bad usage / no file.
set -euo pipefail

SRC="${1:?usage: spine-gate.sh <node-block-file|->}"
if [ "$SRC" = "-" ]; then
  BLOCK="$(cat)"
else
  [ -f "$SRC" ] || { echo "gate: no such file: $SRC" >&2; exit 2; }
  BLOCK="$(cat "$SRC")"
fi

# --- cite regex (factual regression guard) ----------------------------------------------------------
# A REAL cite = file path WITH extension + :line (MainScreen.tsx:542) OR a § ref (§6.4, §Limitations).
CITE_RE='([A-Za-z0-9_./-]+\.[A-Za-z0-9]+:[0-9]+|§[[:space:]]*[0-9A-Z])'
# Approval / filler tokens (whole-token, case-insensitive). Not a ceiling — a floor: it only zeroes a
# token's "content", so the DISTINCT-non-filler count is the real tooth.
FILLER_ALT='yes|yeah|yep|yup|ya|ok|okay|k|kk|no|nope|nah|sure|fine|done|go|agreed|approved|approve|lgtm|right|correct|good|great|1'
MIN_WORDS=3        # a substance field must carry at least this many whitespace/punct-split tokens
MIN_CONTENT=2      # ...of which at least this many are DISTINCT non-filler tokens

fail=0
err(){ echo "gate FAIL${TYPE:+ [$TYPE]}: $1" >&2; fail=1; }

# value after a **Label:** (first occurrence, trimmed). Hyphen in $1 (Why-not) is a literal in ERE/sed.
field(){ { grep -iE "^[[:space:]]*\*\*$1:\*\*" <<<"$BLOCK" || true; } | head -1 \
         | sed -E "s/^[[:space:]]*\*\*$1:\*\*[[:space:]]*//; s/[[:space:]]+$//"; }

# tokenize a value -> one token per line (delete em/en-dash BYTES first so a UTF-8 locale can't smuggle
# a "—"-only value past the strip; then split on whitespace + ASCII punctuation).
toks(){ printf '%s' "$1" | tr -d '\342\200\224\342\200\223' | tr '[:space:][:punct:]' '\n' \
        | { grep -vE '^[[:space:]]*$' || true; }; }

# non-bare: present AND not empty/dash-only/punct-only AND has >=1 non-filler token.
# Kills "yes", "yes yes", "—", "+1", "" — allows a short real name like "online-first" / "peak-amplitude".
nonbare(){ local v t c; v="$(field "$1")"; [ -n "$v" ] || return 1
  t="$(toks "$v")"; [ -n "$t" ] || return 1
  c="$(printf '%s\n' "$t" | { grep -ivxE "$FILLER_ALT" || true; })"; [ -n "$c" ]; }

# substance: the primary "why" field. >=MIN_WORDS tokens AND >=MIN_CONTENT distinct non-filler tokens.
# Kills "yes", "yes yes yes" (0 content), "yes yes x" (1 content) — allows "because there is no signal in the field".
substance(){ local v t tot nf; v="$(field "$1")"; [ -n "$v" ] || return 1
  t="$(toks "$v")"
  tot="$(printf '%s\n' "$t" | sed '/^$/d' | wc -l | tr -d ' ')"
  nf="$(printf '%s\n' "$t" | sed '/^$/d' | { grep -ivxE "$FILLER_ALT" || true; } | sort -u | sed '/^$/d' | wc -l | tr -d ' ')"
  [ "$tot" -ge "$MIN_WORDS" ] && [ "$nf" -ge "$MIN_CONTENT" ]; }

# --- node-block sanity: exactly one [GOLDEN header (no cross-node field bleed) -----------------------
ngold="$(grep -c '\[GOLDEN' <<<"$BLOCK" || true)"
[ "$ngold" -ge 1 ] || { echo "gate FAIL: no [GOLDEN] node header" >&2; exit 1; }
[ "$ngold" -le 1 ] || { echo "gate FAIL: multiple [GOLDEN] nodes — pass EXACTLY one node per check" >&2; exit 1; }

# --- deterministic type detection from the header tag -----------------------------------------------
# skip any non-ASCII-letter run after GOLDEN (space, ·U+00B7, ✓, :) and take the next word.
# empty (bare [GOLDEN]/[GOLDEN ✓]) => factual (backward-compat). unknown word => FAIL closed.
TYPE="$(grep -m1 '\[GOLDEN' <<<"$BLOCK" \
        | sed -n 's/.*\[GOLDEN[^A-Za-z]*\([A-Za-z][A-Za-z-]*\).*/\1/p' | tr 'A-Z' 'a-z')"
[ -n "$TYPE" ] || TYPE=factual

# --- universal floor: Crystal present and NON-BARE for every type (bare "yes" dies here) ------------
nonbare Crystal || err "**Crystal:** empty or a bare approval ('yes'/'—') — the thought itself is required"

# --- per-type teeth ---------------------------------------------------------------------------------
case "$TYPE" in
  factual)   # How-it-works line carrying a REAL cite
    how="$(grep -iE 'How it works' <<<"$BLOCK" || true)"
    if [ -z "$how" ]; then err "no 'How it works' (mechanism, not approval)"
    elif ! grep -qE "$CITE_RE" <<<"$how"; then
      err "'How it works' has no REAL cite (file.ext:line or §section) — 'v1:2' does not count"; fi ;;
  decision)
    substance Why      || err "**Why:** empty/one-word — the reason for the decision (>=$MIN_WORDS words, not 'yes')"
    nonbare   Rejected || err "**Rejected:** empty/bare — name the alternative you turned down" ;;
  definition)
    nonbare   Was      || err "**Was:** empty/bare — the old meaning being redefined"
    substance Why-not  || err "**Why-not:** empty/one-word — why the old meaning is wrong (>=$MIN_WORDS words, not 'yes')" ;;
  open)
    nonbare   Blocks   || err "**Blocks:** empty/bare — what is blocked while it's unresolved"
    substance Resolve  || err "**Resolve:** empty/one-word — what would close the question (>=$MIN_WORDS words, not 'yes')" ;;
  *) err "unknown type '$TYPE' in the [GOLDEN·<type>] tag — allowed: factual|decision|definition|open" ;;
esac

[ "$fail" -eq 0 ] || exit 1
echo "gate PASS ($TYPE)"
