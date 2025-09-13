# Contributing

- Use Bash + `jq`.
- Keep hooks ≤ ~60 lines; prefer utils for shared logic.
- Run CI locally:
  - `shellcheck $(git ls-files '*.sh')`
  - Install `bats` and run `bats -r tests/bats`
- PRs must not add telemetry. Keep defaults safe.
