#!/usr/bin/env bash
# create_jules_issue.sh
# Creates a GitHub issue with the 'jules' label to delegate tasks to Jules.

set -euo pipefail

usage() {
  local exit_code="${1:-1}"
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -t, --title <title>          Issue title (required)
  -b, --body <body>            Issue body markdown content
  -f, --body-file <file>       Path to markdown file with issue body
  -R, --repo <owner/repo>      Target repository (defaults to current git repo)
  -h, --help                   Show this help message

Examples:
  $(basename "$0") -t "Fix worker pool memory leak" -f ./issue.md
  $(basename "$0") -t "Add unit test for parser" -b "Details here..."
EOF
  exit "$exit_code"
}

TITLE=""
BODY=""
BODY_FILE=""
REPO_ARG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--title)
      TITLE="$2"
      shift 2
      ;;
    -b|--body)
      BODY="$2"
      shift 2
      ;;
    -f|--body-file)
      BODY_FILE="$2"
      shift 2
      ;;
    -R|--repo)
      REPO_ARG="--repo $2"
      shift 2
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

if [[ -z "$TITLE" ]]; then
  echo "Error: --title is required." >&2
  usage
fi

if [[ -z "$BODY" && -z "$BODY_FILE" ]]; then
  echo "Error: Either --body or --body-file must be provided." >&2
  usage
fi

if [[ -n "$BODY_FILE" ]]; then
  if [[ ! -f "$BODY_FILE" ]]; then
    echo "Error: Body file '$BODY_FILE' does not exist." >&2
    exit 1
  fi
  BODY_ARGS=(--body-file "$BODY_FILE")
else
  BODY_ARGS=(--body "$BODY")
fi

# 1. Verify GitHub CLI is available
if ! command -v gh >/dev/null 2>&1; then
  echo "Error: 'gh' (GitHub CLI) is not installed or not in PATH." >&2
  exit 1
fi

# 2. Check auth status
if ! gh auth status >/dev/null 2>&1; then
  echo "Error: 'gh' is not authenticated. Run 'gh auth login' first." >&2
  exit 1
fi

# 3. Ensure 'jules' label exists
# shellcheck disable=SC2086
if ! gh label list $REPO_ARG --limit 100 2>/dev/null | grep -qw "jules"; then
  echo "Label 'jules' not found. Creating label 'jules'..." >&2
  # shellcheck disable=SC2086
  gh label create jules --description "Tasks delegated to Jules agent" --color "0E8A16" --force $REPO_ARG >/dev/null 2>&1 || true
fi

# 4. Create the issue
echo "Creating GitHub issue tagged for Jules..." >&2
# shellcheck disable=SC2086
ISSUE_URL=$(gh issue create --title "$TITLE" "${BODY_ARGS[@]}" --label "jules" $REPO_ARG)

if [[ -z "$ISSUE_URL" ]]; then
  echo "Error: Failed to create issue." >&2
  exit 1
fi

ISSUE_NUM=$(basename "$ISSUE_URL")

echo "Created Jules issue successfully!"
echo "Issue Number: $ISSUE_NUM"
echo "Issue URL:    $ISSUE_URL"

# Output machine-readable JSON for agent consumption on stdout if needed
cat <<EOF
{
  "status": "created",
  "issue_number": "$ISSUE_NUM",
  "issue_url": "$ISSUE_URL"
}
EOF
