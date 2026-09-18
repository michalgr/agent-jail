---
name: jules
description: >-
  Delegates implementation tasks, bug fixes, or feature requests to Jules (Google's asynchronous GitHub coding agent)
  via GitHub issues and pull requests. Activate when the user invokes '/jules <task>' or asks to delegate work to Jules.
---

# Jules Delegation Workflow (`/jules`)

This skill guides the agent through delegating development tasks to **Jules**, Google's asynchronous AI coding agent that runs in cloud virtual machines directly on GitHub repositories.

Delegation follows a 5-step lifecycle:
1. **Local Research & Git Sanity**: Rapid local analysis without modifying source code.
2. **Brainstorming & User Alignment**: Discussing details and trade-offs with the user (unless trivial).
3. **Plan Artifact Review**: Presenting the issue sketch/plan as an artifact for user approval before filing.
4. **Issue Dispatch & Async Tracking**: Creating the GitHub issue tagged `jules` and non-blocking monitoring.
5. **CI & Automated Review**: Inspecting Jules's pull request, checking CI test suites, and delivering an explicit verdict (Merge As-Is, Request Changes, or Merge with Follow-up Nits).

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

## Phase 2: Brainstorming, Plan Artifact & Issue Dispatch

Jules operates in a cloud VM and achieves the highest success rate when given explicit constraints and test commands rather than broad prompts. To ensure Jules receives the best instructions and avoid filing premature GitHub issues:

1. **Brainstorm with the User (Unless Trivial)**:
   - For non-trivial tasks (multiple implementation approaches, ambiguous scope, architectural trade-offs, or API design), actively discuss and brainstorm the details with the user first.
   - Align on the chosen approach, trade-offs, and edge cases before drafting.
   - For trivial, unambiguous tasks (e.g. self-evident fix with a single obvious solution), brainstorming can be skipped, but the plan artifact must still be presented.

2. **Present the Plan as an Artifact for Review**:
   - Format the proposed issue following [references/issue_template.md](./references/issue_template.md).
   - Write the plan/sketch as a user-facing **Artifact** (e.g., `jules_plan.md` in the conversation artifact directory) so the user can review it cleanly:
     - **Overview & Motivation**
     - **Target Files & Line Ranges**
     - **Acceptance Criteria Checklist**
     - **Verification / Test Commands**
     - **Constraints & Architectural Rules**
   - **Obtain User Approval**: Explicitly wait for the user to review and approve the drafted plan artifact before creating the GitHub issue.

3. **Dispatch via Helper Script or GitHub CLI**:
   - Once the user approves the artifact, dispatch the issue using the included script:
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
     - Did Jules modify the expected files without unintended side-effects?
     - Are any unexpected files changed or deleted?
     - Did Jules add or update tests?
     - Did CI pass without errors or warnings?

3. **Formulate Explicit Verdict & Merge Recommendation**:
   Deliver a definitive recommendation with one of three outcomes:
   - **Merge As-Is**:
     - *When to use*: All acceptance criteria are satisfied, CI checks pass cleanly, and the design adheres to repository guidelines without regressions.
     - *Command*:
       ```bash
       gh pr merge <PR_NUMBER> --squash
       ```
   - **Request Changes (Explicitly State What Is Wrong)**:
     - *When to use*: Core acceptance criteria failed, tests or CI are failing, logic bugs or regressions were introduced, or architectural/security rules were violated.
     - *Action*: Explicitly detail what is broken, why it is incorrect, and post or propose a changes-requested review for Jules:
       ```bash
       gh pr review <PR_NUMBER> --request-changes --body "<Detailed breakdown of what is wrong and required fixes>"
       ```
   - **Merge with Follow-Up Fixes & Nits**:
     - *When to use*: The primary fix/feature is functionally correct and solid, but minor cosmetic issues, formatting nits, documentation polish, or small refactor opportunities remain.
     - *Action*: Do not block the PR for minor issues. Recommend merging the PR and explicitly enumerate the suggested nits/follow-up items to address locally or in a subsequent task.

4. **Present Review Summary to the User**:
   - **PR Overview**: Link, title, and branch name (`jules/...`).
   - **CI Status**: Pass/fail breakdown of checks.
   - **Diff Assessment**: Files modified, test coverage added.
   - **Verdict**: Clearly state **Merge As-Is**, **Request Changes**, or **Merge with Follow-Up Nits**.
   - **Next Steps & Checkout**:
     ```bash
     gh pr checkout <PR_NUMBER>
     ```
