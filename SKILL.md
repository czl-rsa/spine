---
name: spine
description: >-
  Crystallize-then-advance planning loop. Use whenever the user runs `/spine`, `/spine new`,
  `/spine drop`, or `/spine help` (`-help`/`--help`/`?` → print the cheat-sheet), or says
  "crystallize this / lock this decision / open a spine / what did we crystallize / continue the
  plan / advance to the next planning question". The user handles context surgery with native
  `/rewind` ("summarize from here") and `/clear`; THIS skill ONLY manages `drafts/spine/<topic>.spine.md`
  — seed a node, gate each crystal by its TYPE (factual→cite · decision→why+rejected · definition→was+why-not ·
  open→blocks+resolve; a bare "yes" passes nothing), commit it, and on a fresh chat re-inject the spine's
  ESSENCE so the plan resumes. Reach for it for any "let's plan X / distil the golden thought" work, even
  when unnamed. Repo-agnostic — works in any project.
allowed-tools: Read, Write, Edit, Bash
---

# spine — the file is the message, the chat is the re-run

## Read this first (the model)
The append-only chat is **disposable scratch**; the durable "message you keep editing" is one git-tracked
file: `drafts/spine/<topic>.spine.md`. This skill **never** does context surgery — the user does that with
native `/rewind` → *"summarize from here"* (compress a messy node in place, no reboot) and `/clear`.
Your only job is the spine FILE: seed a node, gate a crystal, commit it, reload the spine.

Why this shape: in the CLI you cannot edit a past message, so the editable thing is moved into a file and the
chat is treated as throwaway — the noisy turns live only in the conversation and never touch disk.

**Output is ALWAYS English, terse, lead-with-the-answer (no thinking out loud).** Resolve the working root
once per run: `ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"` — all paths below are under `$ROOT`
(works in any git repo or plain dir).

## Mode — infer from $ARGUMENTS + `drafts/spine/.active`
| Invocation | Mode |
|---|---|
| `/spine help` · `/spine -help` · `/spine --help` · `/spine ?` | **HELP** — print the cheat-sheet, touch nothing |
| `/spine new "<topic/question>"` | **SEED** a new topic + node 1 |
| `/spine` on a fresh/just-rebooted chat (nothing to crystallize) | **LOAD** the active spine |
| `/spine` after the user has reached a settled answer in chat | **CRYSTALLIZE** the current node |
| `/spine drop` | **DROP** the current DRAFTING node body |

### HELP — `/spine help` (also `-help` · `--help` · `?`)
Read/write NOTHING. Do not touch `.active` or any file. Print this cheat-sheet **verbatim**, then stop:
```
/spine — planning that stays a file instead of drowning in the chat.

The idea. The chat is a draft: think out loud all you want, then don't mind wiping it. The file
drafts/spine/<topic>.spine.md is the clean copy: settled decisions land there one at a time.
The noise stays in the chat while the plan grows in the file and is never rewritten behind your
back — come back tomorrow and you see exactly what you concluded.

When. You're working a task or plan out in pieces and want the decisions to survive across
sessions and not get mixed into the draft noise.

Commands.
  /spine new "question"   Open a new topic — the plan gets its own file. Then think freely.
  /spine                  Write the settled decision: a short entry lands in the file — what you
                          decided and why (for a fact, with a source cite). Then the next question
                          opens. Nothing to write (fresh chat)? — it re-injects the essence of the
                          past decisions so you can keep thinking.
  /spine drop             Wipe the current unfinished entry and restate it from scratch.
                          Never touches decisions already written.
  /spine help             This help.

The empty-"yes" gate. /spine won't write an entry with no substance: a FACT needs a source cite
(file:line); a DECISION — why + what you rejected; a DEFINITION — was → now; an OPEN question —
what's blocked + what would close it. A bare "yes" passes nothing.

Example.
  /spine new "which database?"
  … you weigh options in the chat …
  /spine   → entry 1 lands: "SQLite — single-writer is enough" + why + cite (bench.md:12).
             Question 2 opens.
  /clear   → chat wiped, decisions kept in the file. /spine re-injects their essence — keep going.

The chat is disposable, you clear it yourself: /clear wipes the whole chat, /rewind compresses a
slice. /spine only ever touches the file, never the chat. One topic = one file = a chain of
entries in order (1, 2, 3 …).
```

### SEED — `/spine new "<q>"`
1. Slugify the topic → `<slug>`; path = `drafts/spine/<slug>.spine.md`.
2. If it already exists, **refuse and point at it** (never clobber). Otherwise create it exactly as:
   ```
   ---
   topic: <slug>
   status: node 1
   ---
   # Spine — <topic>

   ## Node 1 — <question>  [DRAFTING]
   ```
3. Write `drafts/spine/.active` = that path (one line).
4. Reply terse, onboarding voice: «Topic opened · entry 1: "<question>". Think freely in the chat; once you
   land a decision, `/spine` writes it to the file and then `/clear` is safe. New here? — `/spine help`.»

### LOAD — `/spine` on a fresh chat (re-inject the ESSENCE after /clear or /rewind)
The READ half of the smart-compact loop: the user shed the chat, so re-seed the conversation with **just enough
distilled state to RESUME THINKING** — not the raw chat (dropped on purpose), not only bare one-liners.
1. Read `drafts/spine/.active` → the path; Read that file.
2. Re-inject the ESSENCE, compact: per frozen node ONE line = its `Crystal` + the KEY reason/what-was-rejected
   (gist of `Why`/`Rejected`/`Was`/`Why-not`/`How it works`, ≤1 line); then the current `[DRAFTING]` node's open
   question, stated sharply. This is the working context to think FROM.
3. Reply terse: «Resuming: node N — <question>. Frozen: …(essence)…». Do **not** re-derive the discarded
   branches; wait for the user to think on the open question.

### CRYSTALLIZE — `/spine` after a settled answer
1. Draft the crystal as a **tight, length-capped block** (rewrite — never paste raw chat). **Pick the TYPE** from
   the node's nature; the type is the ASCII suffix in the header tag `[GOLDEN·<type>]` (untagged `[GOLDEN ✓]` =
   **factual**, legacy default). **Only `factual` needs a cite.**
   ```
   ## Node N — <question>  [GOLDEN·factual]        # how something works (has a cite)
   **Crystal:** <the settled thought>
   **How it works:** <mechanism> (cite: <file.ext:line | §section>)
   **Epitaphs:** <one line per discarded branch — optional>

   ## Node N — <choice question>  [GOLDEN·decision]     # a settled choice (no cite)
   **Crystal:** <the decision itself>
   **Why:** <why this way — a phrase, ≥3 words, not "yes">
   **Rejected:** <the alternative you turned down — a short name is fine>

   ## Node N — what is "<term>"?  [GOLDEN·definition]    # a (re)definition
   **Crystal:** <term = new meaning>
   **Was:** <the old meaning being replaced>
   **Why-not:** <why the old meaning is wrong — a phrase, ≥3 words>

   ## Node N — <open question>?  [GOLDEN·open]      # a parked, unresolved question — also gold
   **Crystal:** <the question, sharply stated, marked "unresolved">
   **Blocks:** <what is blocked while it's open>
   **Resolve:** <what would close it — a phrase, ≥3 words>
   ```
2. **Gate (soft, v1.2 typed):** PIPE the candidate straight into the bundled gate — **no temp file**:
   `printf '%s' "$block" | scripts/spine-gate.sh -`. It reads the TYPE from the `[GOLDEN·<type>]` header and applies
   per-type teeth: **factual** → `How it works` line with a REAL cite (`file.ext:line`/`§section`); **decision** →
   `**Why:**` (≥3 words, substance) + `**Rejected:**` (named, non-bare); **definition** → `**Was:**` + `**Why-not:**`;
   **open** → `**Blocks:**` + `**Resolve:**`. Every type needs a non-bare `**Crystal:**`. A bare "yes"/"—"/repeat
   "yes yes yes" passes NOTHING; an unknown type suffix or a multi-node block FAIL closed. **FAIL → print exactly
   what's missing in English, write NOTHING, stay in the node.** The "mechanism, not approval" rule, per type.
3. **On PASS:** append the block to the active spine file (append-only); bump `status:`; **if an `INBOX.md`
   exists at `$ROOT`**, append ONE line to it — `YYYY-MM-DD | user | <crystal one-liner>` (skip if absent — the
   skill is repo-agnostic); then seed the next `## Node N+1 — <next q>  [DRAFTING]`.
4. **Commit (only if `$ROOT` is a git repo):** `git add` the spine file (and `INBOX.md` if present) and
   `git commit -m "spine(<slug>): node N — <short>"`. Let the commit hooks run — never bypass them. If the commit
   fails, show the error terse and stop — do not retry blindly. If `$ROOT` is not a git repo, skip the commit
   (the spine file still persists on disk).
5. Reply terse + **recommend the reset (close the loop):** «node N committed ✓ — the essence is in the file; you can
   reset context now: `/clear` (whole chat) or `/rewind` (a slice), then `/spine` re-injects the essence» + the next
   seed question. **Do NOT** write any external decision doc per node unless the user explicitly asks.

### DROP — `/spine drop`
Blank the current `[DRAFTING]` node body in the file. **Warn honestly:** this clears the FILE draft, not the
chat — the conversation noise is still in context; use `/rewind` or `/clear` to actually evict it.

## Hard lines (keep the skill reversible + lint-clean)
- Write ONLY under `drafts/spine/` (and, where it exists, append to `INBOX.md`). Never write elsewhere, never
  edit a frozen `[GOLDEN]` node, never touch another repo's source. **The gate takes the candidate on STDIN
  (`spine-gate.sh -`) — no scratch file, so nothing is written outside `drafts/spine/`.**
- The gate is the **floor, not the ceiling**: **v1.2** reads the crystal TYPE from `[GOLDEN·<type>]` and gates each by
  its own teeth (factual→cite · decision→Why+Rejected · definition→Was+Why-not · open→Blocks+Resolve); a bare
  "yes"/"—"/"yes yes yes" fails every type, unknown-type + multi-node fail closed. But a shape-valid cite / a
  real-looking 3-word "why" can still be wrong — that stays the user's read. **v2** hardens: RESOLVE the cite
  (`test -f`/`git cat-file`) + a tracked `.githooks/` pre-commit gate. Tests (14, all verified): `node-golden` PASS ·
  `node-bare`, `node-fakecite` FAIL (factual guards) · `node-decision`/`definition`/`open` PASS ·
  `node-*-bare`/`repeat`/`punct`/`rejbare`/`wasdash`/`open-missing`/`badtype`/`multi` FAIL (attack guards).
- Output English / terse / lead-with-the-answer; never think out loud.
