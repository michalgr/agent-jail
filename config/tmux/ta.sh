#!/usr/bin/env bash
# Attach to an existing tmux session by name or create a new one if it doesn't exist

if [ -z "$1" ]; then
  if [ -n "$TMUX" ]; then
    tmux switch-client -l 2>/dev/null || tmux list-sessions
  else
    tmux attach-session 2>/dev/null || exec tmux new-session
  fi
elif [ -n "$TMUX" ]; then
  session="$1"
  tmux has-session -t "$session" 2>/dev/null || tmux new-session -d -s "$session"
  tmux switch-client -t "$session"
else
  session="$1"
  shift
  exec tmux new-session -A -s "$session" "$@"
fi
