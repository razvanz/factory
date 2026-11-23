# factory

A deterministic stage graph for coding agents, run as a reusable GitHub Actions workflow.

A caller repo starts `ship.yml` for one merged task spec. The workflow runs every stage in a fixed order. Each stage records `done`, `skipped`, `failed` or `blocked`, with a reason. A summary job fails the run when a stage recorded no result, so a stage can be skipped but never forgotten.

## Layout

- `.github/workflows/ship.yml`: the stage graph (`workflow_call`).
- `bin/stage-result`: records one stage result as job outputs.
- `bin/summarize`: checks that every stage recorded a result.
- `tests/selfcheck.sh`: runnable check for both scripts.

## Use

```yaml
jobs:
  ship:
    uses: razvanz/factory/.github/workflows/ship.yml@main
    with:
      spec_path: specs/0001-example.md
      factory_ref: main   # keep equal to the ref in the uses line
    secrets:
      claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
```
