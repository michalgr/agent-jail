#!/usr/bin/env bash
# check_jules_pr.sh
# Finds and checks status of PRs created by Jules for an issue or branch.

set -euo pipefail

usage() {
  local exit_code="${1:-1}"
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -i, --issue <number>       GitHub issue number to find associated PR
  -p, --pr <number>          Specific PR number to inspect
  -R, --repo <owner/repo>    Target repository (defaults to current git repo)
  --checks                   Also inspect and report CI status checks
  --diff-stat                Show summary of modified files in the PR
  -h, --help                 Show this help message

Examples:
  $(basename "$0") -i 42
  $(basename "$0") -p 43 --checks
EOF
  exit "$exit_code"
}

ISSUE_NUM=""
PR_NUM=""
REPO_ARG=""
CHECK_CI=false
CHECK_DIFF=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--issue)
      ISSUE_NUM="$2"
      shift 2
      ;;
    -p|--pr)
      PR_NUM="$2"
      shift 2
      ;;
    -R|--repo)
      REPO_ARG="--repo $2"
      shift 2
      ;;
    --checks)
      CHECK_CI=true
      shift
      ;;
    --diff-stat)
      CHECK_DIFF=true
      shift
      ;;
    -h|--help)
      usage 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      ;;
  esac
done

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: 'gh' (GitHub CLI) is not installed or not in PATH." >&2
  exit 1
fi

# 1. If PR number not explicitly provided, discover PR by issue number or jules branches
if [[ -z "$PR_NUM" ]]; then
  if [[ -n "$ISSUE_NUM" ]]; then
    # Search for PRs mentioning the issue number or with branch matching jules/*
    # shellcheck disable=SC2086
    PR_NUM=$(gh pr list $REPO_ARG --search "$ISSUE_NUM" --json number -q '.[0].number' 2>/dev/null || true)
    
    if [[ -z "$PR_NUM" || "$PR_NUM" == "null" ]]; then
      # Fallback: search for PRs from branch containing the issue number or label jules
      # shellcheck disable=SC2086
      PR_NUM=$(gh pr list $REPO_ARG --search "head:jules" --json number -q '.[0].number' 2>/dev/null || true)
    fi
  else
    # Fallback to latest PR with label or head jules
    # shellcheck disable=SC2086
    PR_NUM=$(gh pr list $REPO_ARG --search "head:jules" --json number -q '.[0].number' 2>/dev/null || true)
  fi
fi

if [[ -z "$PR_NUM" || "$PR_NUM" == "null" ]]; then
  echo '{"status": "waiting_for_pr", "message": "No Jules pull request found yet."}'
  exit 0
fi

# 2. Query PR details
# shellcheck disable=SC2086
PR_INFO=$(gh pr view "$PR_NUM" $REPO_ARG --json number,title,state,isDraft,url,headRefName,author)

echo "Found PR #$PR_NUM" >&2
echo "$PR_INFO"

# 3. Query CI checks if requested
if [[ "$CHECK_CI" == true ]]; then
  echo "--- CI Checks ---" >&2
  # shellcheck disable=SC2086
  gh pr checks "$PR_NUM" $REPO_ARG || true
fi

# 4. Show diff stat if requested
if [[ "$CHECK_DIFF" == true ]]; then
  echo "--- Diff Stat ---" >&2
  # shellcheck disable=SC2086
  gh pr diff "$PR_NUM" $REPO_ARG --stat || true
fi
