---
name: jules
description: >-
  Delegates implementation tasks, bug fixes, or feature requests to Jules (Google's asynchronous GitHub coding agent)
  via GitHub issues and pull requests. Activate when the user invokes '/jules <task>' or asks to delegate work to Jules.
---

# Jules Delegation Workflow (`/jules`)

This skill guides the agent through delegating development tasks to **Jules**, Google's asynchronous AI coding agent that runs in cloud virtual machines directly on GitHub repositories.

Delegation follows a 4-phase lifecycle:
1. **Local Research & Git Sanity**: Rapid local analysis without modifying source code.
2. **Issue Synthesis & Dispatch**: Formatting a high-context GitHub issue with the `jules` label.
3. **Async Lifecycle & Non-Blocking Tracking**: Monitoring Jules without burning local context or tokens in busy-wait loops.
4. **CI & Automated Review**: Inspecting Jules's pull request, checking CI test suites, and presenting a review summary to the user.

--------------------------------------------------------------------------------

## Phase 1: Local Research & Git Sanity

Before delegating to Jules, investigate the problem locally using read-only tools. **Do not modify source files directly.**

1. **Verify Git Tree State**:
   - Run `git status` and `git diff --stat origin/HEAD` (or `origin/main`).
   - *Crucial*: Jules checks out the remote branch from GitHub. If the user has relevant uncommitted or unpushed local changes, alert them immediately:
     > "Jules operates on the remote GitHub repository. You have unpushed local changes that Jules won't see. Would you like to commit/push them to a branch first?"

2. **Conduct Codebase Investigation**:
   - Use `grep_search`, `find_by_name`, and `view_file` to locate:
     - Exact target files and line ranges.
     - Existing test files covering the relevant modules.
     - Reproducible commands (e.g. `cargo test`, `pytest`, `go test ./...`, `npm test`).
   - Identify any constraints, API stability requirements, or style guidelines in `AGENTS.md`.

--------------------------------------------------------------------------------

## Phase 2: Issue Synthesis & Dispatch

Jules operates in a cloud VM and achieves the highest success rate when given explicit constraints and test commands rather than broad prompts.

1. **Format the Issue**:
   - Follow the template in [references/issue_template.md](./references/issue_template.md).
   - Structure the issue with:
     - **Overview**: High-level problem statement.
     - **Context & Key Locations**: Repository-relative paths (e.g., `src/worker.rs:45-72`).
     - **Current vs. Expected Behavior**: Concrete breakdown.
     - **Acceptance Criteria**: Bulleted checklist of required outcomes.
     - **Verification / Test Command**: Command Jules should execute in its VM.
     - **Constraints**: Conventions from `AGENTS.md` (e.g., commit rules, language standards).

2. **Dispatch via Helper Script or GitHub CLI**:
   - Use the included script:
     ```bash
     ./config/gemini/skills/jules/scripts/create_jules_issue.sh \
       --title "Fix: <Concise title>" \
       --body "<Formatted issue content>"
     ```
   - Alternatively, directly with `gh`:
     ```bash
     gh issue create --title "Fix: <Concise title>" --body "<Formatted issue content>" --label "jules"
     ```
   - **Immediately report the outcome to the user**:
     - Provide the issue number and clickable URL.
     - Confirm that Jules has been summoned via the `jules` label.

--------------------------------------------------------------------------------

## Phase 3: Async Lifecycle (Non-Blocking)

Jules takes between 5 to 15 minutes to clone, build, attempt fixes, and run tests.

> [!WARNING]
> **NEVER run an active spin-lock (`sleep 10` or continuous polling loop)** in the chat. Busy-waiting consumes unnecessary tokens and blocks the user from asking further questions.

1. **Initial Status Check**:
   - Check if a PR already exists (unlikely in the first 60 seconds, but verify):
     ```bash
     ./config/gemini/skills/jules/scripts/check_jules_pr.sh --issue <ISSUE_NUMBER>
     ```
2. **Yield Control with Scheduling**:
   - If the PR is not ready, inform the user:
     > "Issue #<N> has been created and tagged for Jules. Jules is analyzing the repo and running tests in its cloud VM. You can continue working; I will check back, or you can run `/jules check <ISSUE_NUMBER>` anytime."
   - If in an environment that supports one-shot reminders, schedule a check after 5 minutes rather than looping.

--------------------------------------------------------------------------------

## Phase 4: CI & Automated Code Review

Once Jules opens a Pull Request:

1. **Inspect PR & CI Status**:
   ```bash
   ./config/gemini/skills/jules/scripts/check_jules_pr.sh --issue <ISSUE_NUMBER> --checks --diff-stat
   ```
   Or via `gh`:
   ```bash
   gh pr view <PR_NUMBER>
   gh pr checks <PR_NUMBER>
   ```

2. **Conduct Automated Review of the PR Diff**:
   - Read the diff:
     ```bash
     gh pr diff <PR_NUMBER>
     ```
   - Evaluate against the original **Acceptance Criteria**:
     - Did Jules modify the expected files?
     - Are any unexpected files changed or deleted?
     - Did Jules add or update tests?
     - Did CI pass without warnings?

3. **Present Summary to the User**:
   - Provide a clean review summary:
     - PR link and branch name (`jules/...`).
     - CI status (green / failing checks).
     - Summary of changes and design assessment.
     - Checkout command for the user:
       ```bash
       gh pr checkout <PR_NUMBER>
       ```
