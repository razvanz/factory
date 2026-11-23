#!/usr/bin/env bash
# Runnable check for bin/stage-result and bin/summarize. No GitHub needed.
set -euo pipefail
cd "$(dirname "$0")/.."
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fails() { if "$@" >/dev/null; then echo "expected failure: $*"; exit 1; fi; }
export GITHUB_OUTPUT=$T/out GITHUB_STEP_SUMMARY=$T/summary

bin/stage-result qa skipped "no QA target" >/dev/null
fails bin/stage-result qa skipped ""          # skip without reason fails
fails bin/stage-result qa bogus x             # unknown status fails
bin/stage-result tdd done "" >/dev/null

N='{"tdd":{"result":"success","outputs":{"result":"{\"status\":\"done\",\"reason\":\"\"}"}},
    "qa":{"result":"success","outputs":{"result":"{\"status\":\"skipped\",\"reason\":\"no target\"}"}},
    "pr":{"result":"skipped","outputs":{}},
    "preflight":{"result":"failure","outputs":{"result":"{\"status\":\"blocked\",\"reason\":\"x\"}"}}}'
bin/summarize "$N" tdd qa >/dev/null
fails bin/summarize "$N" tdd qa pr            # a stage with no result fails the run
fails bin/summarize "$N" tdd qa preflight     # a blocked stage fails the run

: > "$GITHUB_OUTPUT"
fails bin/stage-result qa skipped ""
grep -qx "status=failed" "$GITHUB_OUTPUT"      # a skip without reason is recorded as failed
echo "selfcheck ok"
