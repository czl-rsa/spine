# spine — gate fixtures (v1.2 typed)

The deterministic gate (`scripts/spine-gate.sh`, v1.2), not the model, decides whether a node is crystallizable.
Type is read from the header tag `[GOLDEN·<type>]`; untagged `[GOLDEN ✓]` = factual (legacy). Only `factual` needs a cite.

| Fixture | Exit | Type | Why |
|---|---|---|---|
| `node-golden.md` | 0 PASS | factual (untagged) | Crystal + How-it-works with `§Limitations`; backward-compat anchor |
| `node-bare.md` | 1 FAIL | factual | "Yes, ship it", no How-it-works |
| `node-fakecite.md` | 1 FAIL | factual | cite is `v1:2` (no ext) — cite regression guard |
| `node-decision.md` | 0 PASS | decision | Crystal + Why(≥3w) + Rejected named |
| `node-definition.md` | 0 PASS | definition | Crystal + Was + Why-not(≥3w) |
| `node-open.md` | 0 PASS | open | Crystal + Blocks + Resolve(≥3w) |
| `node-decision-bare.md` | 1 FAIL | decision | Why=`yes`, Rejected=`yes` |
| `node-decision-repeat.md` | 1 FAIL | decision | Why=`yes yes x` → <2 distinct non-filler |
| `node-decision-punct.md` | 1 FAIL | decision | Why=`yes, go — ok!` + Rejected=`—` (punct/em-dash) |
| `node-decision-rejbare.md` | 1 FAIL | decision | valid Why but Rejected=`yes` (bare in secondary field) |
| `node-definition-wasdash.md` | 1 FAIL | definition | Was=`—` (em-dash-only) |
| `node-open-missing.md` | 1 FAIL | open | missing **Blocks:** |
| `node-badtype.md` | 1 FAIL | — | `[GOLDEN·factua]` typo → unknown type → fail closed |
| `node-multi.md` | 1 FAIL | — | two `[GOLDEN]` nodes → cross-node-bleed guard |

Run the matrix:
```bash
for f in node-golden:0 node-bare:1 node-fakecite:1 node-decision:0 node-definition:0 node-open:0 \
         node-decision-bare:1 node-decision-repeat:1 node-decision-punct:1 node-decision-rejbare:1 \
         node-definition-wasdash:1 node-open-missing:1 node-badtype:1 node-multi:1; do
  n=${f%:*}; w=${f#*:}; bash ../scripts/spine-gate.sh $n.md >/dev/null 2>&1; g=$?
  [ "$g" = "$w" ] && echo "OK $n" || echo "FAIL $n want$w got$g"
done
```
