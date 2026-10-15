#!/usr/bin/env bash
# Seeds your copy of this repository with the demo starting state:
#   - branch demo/stale-telemetry-boundary with one intentionally failing test
#   - an open PR from that branch (CI goes red)
#   - two independent issues for the Cloud agent and Autopilot exercises
# Safe to re-run: anything that already exists is skipped.
#
# Usage: scripts/setup-demo.sh [--request-review]
#   --request-review  also request a Copilot code review on the PR (presenter
#                     backup; attendees normally request it live in module 2)
set -euo pipefail

request_review=false
case "${1:-}" in
  "") ;;
  --request-review) request_review=true ;;
  *) echo "usage: $0 [--request-review]" >&2; exit 2 ;;
esac

BRANCH="demo/stale-telemetry-boundary"
PR_TITLE="Guard automation runs against stale telemetry"
ISSUE_HISTORY_TITLE="Add device telemetry history"
ISSUE_DRYRUN_TITLE="Add automation dry-run explanations"

root="$(git rev-parse --show-toplevel)"
seed="$root/scripts/demo-seed"
cd "$root"

for tool in git gh; do
  command -v "$tool" >/dev/null || { echo "error: '$tool' is required" >&2; exit 1; }
done
gh auth status >/dev/null 2>&1 || { echo "error: run 'gh auth login' first" >&2; exit 1; }

repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
echo "Seeding demo in $repo"
export GH_PAGER=""

git fetch --quiet origin main

if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null; then
  echo "- Branch $BRANCH already exists on origin, skipping"
else
  tmp="$(mktemp -d)"
  trap 'git -C "$root" worktree remove --force "$tmp" >/dev/null 2>&1 || true' EXIT
  git worktree add --quiet --detach "$tmp" origin/main
  git -C "$tmp" apply "$seed/stale-telemetry-boundary.patch"
  git -C "$tmp" add -A
  git -C "$tmp" commit --quiet -m "Add stale telemetry guard for automations"
  git -C "$tmp" push --quiet origin "HEAD:refs/heads/$BRANCH"
  echo "- Pushed $BRANCH"
fi

pr="$(gh pr list --repo "$repo" --head "$BRANCH" --state open --json number --jq '.[0].number // empty')"
if [[ -n "$pr" ]]; then
  echo "- PR #$pr already open, skipping"
else
  url="$(gh pr create --repo "$repo" --base main --head "$BRANCH" --title "$PR_TITLE" --body-file "$seed/pr-body.md")"
  pr="${url##*/}"
  echo "- Opened PR #$pr"
fi

create_issue() {
  local title="$1" body="$2" existing
  existing="$(gh issue list --repo "$repo" --state open --limit 500 --json number,title \
    --jq ".[] | select(.title == \"$title\") | .number" | head -1)"
  if [[ -n "$existing" ]]; then
    echo "- Issue #$existing '$title' already open, skipping"
  else
    echo "- Opened $(gh issue create --repo "$repo" --title "$title" --body-file "$body")"
  fi
}
create_issue "$ISSUE_HISTORY_TITLE" "$seed/issue-telemetry-history.md"
create_issue "$ISSUE_DRYRUN_TITLE" "$seed/issue-automation-dry-run.md"

if [[ "$request_review" == true ]]; then
  if gh pr edit "$pr" --repo "$repo" --add-reviewer @copilot >/dev/null 2>&1; then
    echo "- Requested Copilot code review on PR #$pr"
  else
    echo "- Could not request Copilot code review automatically; request it from the PR's Reviewers menu"
  fi
fi

echo
echo "Done. Open https://github.com/$repo/pull/$pr and wait for the red 'build-and-test' check."
