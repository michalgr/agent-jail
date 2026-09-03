# Agent Rules & Guidelines

These rules apply to all AI agents working in this project.

## 1. Git Commit Policy
* **Never commit changes on your own.** You must not execute `git commit` or any automated commit commands autonomously.
* **Always ask for explicit approval.** Before any commit is made, you must present the proposed commit to the user.
* **Present clear commit metadata.** You must show:
  * A clear and descriptive commit **Title**.
  * A detailed commit **Description** explaining *what* changed and *why*.
  * The exact command or changes you wish to pass to git.
* Wait for the user to explicitly approve or accept the commit before running it.

## 2. Design & Implementation Philosophy
* **Prefer proper fixes over short-term hacks.** Do not resort to quick workarounds, copy-paste hacks, or temporary fixes that add technical debt. Focus on writing robust, correct, and clean solutions.
* **Understand the Agentic Era Economy:**
  * The economy of code writing and maintenance is different when working with AI agents. Because writing, refactoring, and maintaining clean code is highly accessible, we can afford to spend the effort to "do the right thing" from the start.
  * Always prioritize the long-term maintainability, clean design, and structural correctness of the codebase.

## 3. Tmux Status Propagation
* **Update status inside tmux sessions.** When running within a tmux session (indicated by the presence of `$TMUX` and `$TMUX_PANE` environment variables), you can propagate your current action/status to the `tmux-control-panel` TUI.
* **How to update.** Run the following shell command to set the session's `@status_line` option:
  `tmux set-option -q -t "$TMUX_PANE" @status_line "Your status message..."`
* **When to use.** Do this before executing long-running compilation, test suites, or large search operations, so the user gets visual feedback in the control panel.

## 4. Language Standards
* **Write code and comments in English.** Always author code, comments, docstrings, documentation, and commit messages in English—even if the user communicates in another language—unless the repository has explicitly established conventions to the contrary.

## 5. Communicating with Jules
* **Communicate via GitHub Issues.** Interact with Jules by creating and managing GitHub Issues using the GitHub CLI (`gh issue ...`).
* **Triggering Tasks:** Create an issue with clear instructions, scope, and acceptance criteria, and apply the `jules` label to prompt Jules to autonomously pick up the task and generate a pull request.

