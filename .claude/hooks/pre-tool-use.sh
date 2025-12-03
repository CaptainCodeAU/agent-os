#!/bin/bash
# Pre-Tool-Use Hook for Agent OS Development
# Blocks file modifications on protected branches (main, master, develop, production, staging)
# Allows:
# - Read operations on all branches
# - .claude-workspace/ modifications on all branches
# - File modifications on feature branches only

set -e

# Get the tool being used and its arguments from environment variables
TOOL_NAME="${TOOL_NAME:-}"
TOOL_ARGS="${TOOL_ARGS:-}"

# Parse JSON arguments if available
FILE_PATH=""
if [[ -n "$TOOL_ARGS" ]]; then
    # Try to extract file_path from JSON (handles Write, Edit, NotebookEdit tools)
    FILE_PATH=$(echo "$TOOL_ARGS" | grep -o '"file_path":"[^"]*"' | sed 's/"file_path":"//;s/"$//' || echo "")

    # If no file_path, try notebook_path (for NotebookEdit)
    if [[ -z "$FILE_PATH" ]]; then
        FILE_PATH=$(echo "$TOOL_ARGS" | grep -o '"notebook_path":"[^"]*"' | sed 's/"notebook_path":"//;s/"$//' || echo "")
    fi
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

# Define protected branches
PROTECTED_BRANCHES=("main" "master" "develop" "production" "staging")

# Check if on protected branch
IS_PROTECTED=false
for branch in "${PROTECTED_BRANCHES[@]}"; do
    if [[ "$CURRENT_BRANCH" == "$branch" ]]; then
        IS_PROTECTED=true
        break
    fi
done

# If not on protected branch, allow all operations
if [[ "$IS_PROTECTED" == false ]]; then
    exit 0
fi

# On protected branches, check the tool and file path
case "$TOOL_NAME" in
    "Write"|"Edit"|"NotebookEdit")
        # Allow modifications to .claude-workspace/ on any branch
        if [[ "$FILE_PATH" =~ ^.*\.claude-workspace/ ]]; then
            exit 0
        fi

        # Block all other file modifications on protected branches
        echo "ERROR: Cannot modify files on protected branch '$CURRENT_BRANCH'"
        echo "File: $FILE_PATH"
        echo ""
        echo "To make changes:"
        echo "1. Create a feature branch: git checkout -b feature/your-feature-name"
        echo "2. Make your changes on the feature branch"
        echo "3. Push and create a PR when ready"
        echo ""
        echo "Note: You can still modify files in .claude-workspace/ on any branch"
        exit 1
        ;;

    "Bash")
        # Parse bash command to check for dangerous operations
        COMMAND=$(echo "$TOOL_ARGS" | grep -o '"command":"[^"]*"' | sed 's/"command":"//;s/"$//' || echo "")

        # Block git operations that modify state (but allow read-only operations)
        if [[ "$COMMAND" =~ ^git[[:space:]]+(commit|push|merge|rebase|cherry-pick|reset|stash|tag) ]]; then
            echo "ERROR: Cannot perform git state-changing operations on protected branch '$CURRENT_BRANCH'"
            echo "Command: $COMMAND"
            echo ""
            echo "To make changes:"
            echo "1. Create a feature branch: git checkout -b feature/your-feature-name"
            echo "2. Make your changes on the feature branch"
            exit 1
        fi

        # Block package installation commands
        if [[ "$COMMAND" =~ (npm[[:space:]]+install[^:]|pip[[:space:]]+install|yarn[[:space:]]+add|bundle[[:space:]]+install|composer[[:space:]]+install) ]]; then
            echo "ERROR: Cannot install packages on protected branch '$CURRENT_BRANCH'"
            echo "Command: $COMMAND"
            echo ""
            echo "To install packages:"
            echo "1. Create a feature branch: git checkout -b feature/your-feature-name"
            echo "2. Install packages on the feature branch"
            exit 1
        fi

        # Warn about cd usage (should use __zoxide_cd instead)
        if [[ "$COMMAND" =~ ^cd[[:space:]] ]] && [[ ! "$COMMAND" =~ ^__zoxide_cd ]]; then
            echo "WARNING: Use '__zoxide_cd' instead of 'cd' for directory navigation"
            echo "Command: $COMMAND"
            echo "Suggested: __zoxide_cd ${COMMAND#cd }"
            # Don't block, just warn
        fi

        # Allow other bash commands (read-only operations, git status, git diff, etc.)
        exit 0
        ;;

    "Read"|"Glob"|"Grep"|"Task"|"TodoWrite"|"AskUserQuestion")
        # Always allow read operations and task management
        exit 0
        ;;

    *)
        # Allow other tools by default
        exit 0
        ;;
esac

exit 0
