# Contributing to spine

Thanks for the interest. spine is small and deliberately so — the value is the discipline, not features.

## Run the tests
```bash
cd tests && for c in node-*.md; do bash ../scripts/spine-gate.sh "$c"; done
```
`gate.yml` runs the full 14-fixture matrix on every push (the **gate** badge). Any change to
`scripts/spine-gate.sh` must keep all 14 verdicts green and, if it changes behaviour, add a fixture.

## Design line
The gate is a **floor, not a ceiling** — it's a deterministic shell script that refuses empty crystals,
not a semantic judge. Keep it that way: no LLM in the commit path, no dependencies beyond POSIX shell.

## License of contributions
By contributing you agree your contribution is licensed under the project's
[PolyForm Noncommercial 1.0.0](LICENSE). Commercial use of the project (yours or anyone's) still requires
a separate license from the author — open a **Commercial license request** issue.
