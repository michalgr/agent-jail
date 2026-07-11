#!/usr/bin/env bash

# Read stdin to retrieve the event JSON context
input=$(cat)

# Parse event and tool name using GNU grep (fast, light, and dependency-free)
event=$(echo "$input" | grep -oP '"event":\s*"\K[^"]+')
tool=$(echo "$input" | grep -oP '"tool":\s*"\K[^"]+')

# If not running inside tmux, proceed normally
if [ -z "$TMUX_PANE" ]; then
    echo '{"decision": "allow"}'
    exit 0
fi

# Map lifecycle events and tools to appropriate status messages
case "$event" in
    PreInvocation|BeforeAgent)
        msg="Thinking..."
        ;;
    PreToolUse|BeforeTool)
        if [ -n "$tool" ]; then
            msg="Executing $tool..."
        else
            msg="Running tool..."
        fi
        ;;
    PostToolUse|AfterTool)
        msg="Thinking..."
        ;;
    PostInvocation|AfterAgent)
        msg="Idle"
        ;;
    Stop|SessionEnd)
        msg=""
        ;;
    *)
        msg=""
        ;;
esac

# Propagate status to tmux session using session option @status_line
tmux set-option -q -t "$TMUX_PANE" @status_line "$msg"

# Always return allow decision to prevent blocking agent tools
echo '{"decision": "allow"}'
exit 0
