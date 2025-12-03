#!/bin/bash
# Pre-Tool-Use Hook for Agent OS Development
# Enforces branch protection and package manager consistency
#
# Protected branches: main, master, develop, production, staging
#
# Allows on protected branches:
# - Read operations (Read, Glob, Grep, WebFetch, WebSearch)
# - Branch switching (git checkout, git switch)
# - Getting updates (git pull, git fetch, git stash)
# - .claude/ and .claude-workspace/ modifications
#
# Blocks on protected branches:
# - File modifications outside .claude/
# - Git state changes (commit, push, merge, rebase, reset)
# - Package installations
# - Wrong package manager usage

set -euo pipefail

# Get the tool being used and its arguments from environment variables
TOOL_NAME="${TOOL_NAME:-}"
TOOL_ARGS="${TOOL_ARGS:-}"

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Parse JSON arguments
FILE_PATH=""
COMMAND=""
if [[ -n "$TOOL_ARGS" ]]; then
    # Extract file_path (for Write, Edit, NotebookEdit)
    FILE_PATH=$(echo "$TOOL_ARGS" | grep -o '"file_path":"[^"]*"' | sed 's/"file_path":"//;s/"$//' || echo "")

    # If no file_path, try notebook_path
    if [[ -z "$FILE_PATH" ]]; then
        FILE_PATH=$(echo "$TOOL_ARGS" | grep -o '"notebook_path":"[^"]*"' | sed 's/"notebook_path":"//;s/"$//' || echo "")
    fi

    # Extract command (for Bash)
    COMMAND=$(echo "$TOOL_ARGS" | grep -o '"command":"[^"]*"' | sed 's/"command":"//;s/"$//' || echo "")
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

# Helper function to show error with box formatting
show_error() {
    local action="$1"
    local details="$2"

    echo "" >&2
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}" >&2
    echo -e "${BOLD}${CYAN}║${NC}           ${BOLD}${RED}🚫 BLOCKED: Protected Branch Detected${NC}                ${BOLD}${CYAN}║${NC}" >&2
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}" >&2
    echo "" >&2
    echo -e "${BOLD}📍 Current branch:${NC} ${YELLOW}${CURRENT_BRANCH}${NC} ${RED}(protected)${NC}" >&2
    echo -e "${BOLD}🛠️  Attempted tool:${NC} ${TOOL_NAME}" >&2

    if [[ -n "$details" ]]; then
        echo "$details" >&2
    fi

    echo "" >&2
    echo -e "${BOLD}⚠️  You cannot ${action} on protected branches.${NC}" >&2
    echo "   Please create a feature branch first." >&2
    echo "" >&2
    echo -e "${BOLD}💡 Quick fix:${NC}" >&2
    echo "" >&2
    echo "   1. Ask Claude to create a branch for you, or" >&2
    echo "   2. Run: git checkout -b feature/your-feature-name" >&2
    echo "" >&2
    echo "Then try again!" >&2
    echo "" >&2
}

# On protected branches, check the tool and operation
case "$TOOL_NAME" in
    "Write"|"Edit"|"NotebookEdit")
        # Allow modifications to .claude/ and .claude-workspace/ directories
        if [[ "$FILE_PATH" =~ \.claude/ ]] || [[ "$FILE_PATH" =~ \.claude-workspace/ ]]; then
            exit 0
        fi

        # Block all other file modifications
        show_error "modify files" "$(echo -e "${BOLD}📁 File:${NC} ${FILE_PATH}")"
        exit 2
        ;;

    "Bash")
        # Allow safe git read operations
        if [[ "$COMMAND" =~ ^git[[:space:]]+(status|diff|log|show|branch|rev-parse|remote|ls-files) ]]; then
            exit 0
        fi

        # Allow git operations for branch switching and getting updates
        if [[ "$COMMAND" =~ ^git[[:space:]]+(checkout|switch|pull|fetch|stash) ]]; then
            exit 0
        fi

        # Block dangerous git operations
        if [[ "$COMMAND" =~ ^git[[:space:]]+(commit|push|merge|rebase|cherry-pick|reset|tag) ]]; then
            show_error "perform git state-changing operations" "$(echo -e "${BOLD}📝 Command:${NC} ${COMMAND}")"
            exit 2
        fi

        # Detect package manager from lock files (inline, no external script)
        DETECTED_PKG=""
        if [ -f "pnpm-lock.yaml" ]; then
            DETECTED_PKG="pnpm"
        elif [ -f "bun.lockb" ]; then
            DETECTED_PKG="bun"
        elif [ -f "yarn.lock" ]; then
            DETECTED_PKG="yarn"
        elif [ -f "package-lock.json" ]; then
            DETECTED_PKG="npm"
        elif [ -f "package.json" ]; then
            DETECTED_PKG="pnpm"  # Default to pnpm if no lock file
        fi

        # Check for package manager consistency (JavaScript/Node.js)
        if [[ "$COMMAND" =~ ^(npm|pnpm|yarn|bun)[[:space:]] ]]; then
            CMD_PKG=$(echo "$COMMAND" | grep -oE "^(npm|pnpm|yarn|bun)")

            if [ -n "$DETECTED_PKG" ] && [ "$DETECTED_PKG" != "$CMD_PKG" ]; then
                # Wrong package manager detected
                echo "" >&2
                echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}" >&2
                echo -e "${BOLD}${CYAN}║${NC}           ${BOLD}${RED}⚠️  WRONG PACKAGE MANAGER DETECTED${NC}                   ${BOLD}${CYAN}║${NC}" >&2
                echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}" >&2
                echo "" >&2
                echo -e "${BOLD}❌ You're trying to use:${NC} ${RED}${CMD_PKG}${NC}" >&2
                echo -e "${BOLD}✅ This project uses:${NC} ${YELLOW}${DETECTED_PKG}${NC}" >&2
                echo "" >&2
                echo -e "${BOLD}💡 Lock file detected:${NC}" >&2
                case "$DETECTED_PKG" in
                    pnpm) echo "   📄 pnpm-lock.yaml" >&2 ;;
                    npm)  echo "   📄 package-lock.json" >&2 ;;
                    yarn) echo "   📄 yarn.lock" >&2 ;;
                    bun)  echo "   📄 bun.lockb" >&2 ;;
                esac
                echo "" >&2
                echo "Please use '${DETECTED_PKG}' instead to maintain consistency." >&2
                echo "" >&2
                exit 2
            fi
        fi

        # Block package installation commands
        if [[ "$COMMAND" =~ ^(npm|pnpm|yarn|bun)[[:space:]]+(install|add) ]]; then
            show_error "install packages" "$(echo -e "${BOLD}📝 Command:${NC} ${COMMAND}")"
            exit 2
        fi

        # Block Python package installations
        if [[ "$COMMAND" =~ ^(pip[[:space:]]+install|uv[[:space:]]+pip[[:space:]]+install|uv[[:space:]]+sync|uv[[:space:]]+venv) ]]; then
            show_error "install Python packages" "$(echo -e "${BOLD}📝 Command:${NC} ${COMMAND}")"
            exit 2
        fi

        # Block other package manager installations
        if [[ "$COMMAND" =~ ^(cargo[[:space:]]+add|go[[:space:]]+get|bundle[[:space:]]+install|composer[[:space:]]+install) ]]; then
            show_error "install packages" "$(echo -e "${BOLD}📝 Command:${NC} ${COMMAND}")"
            exit 2
        fi

        # Warn about cd usage (Agent OS specific - should use __zoxide_cd)
        if [[ "$COMMAND" =~ ^cd[[:space:]] ]] && [[ ! "$COMMAND" =~ ^__zoxide_cd ]]; then
            echo -e "${YELLOW}⚠️  WARNING: Use '__zoxide_cd' instead of 'cd' for directory navigation${NC}" >&2
            echo -e "   Command: ${COMMAND}" >&2
            echo -e "   Suggested: __zoxide_cd ${COMMAND#cd }" >&2
            # Don't block, just warn
        fi

        # Allow all other bash commands
        exit 0
        ;;

    "Read"|"Glob"|"Grep"|"Task"|"TodoWrite"|"AskUserQuestion"|"WebFetch"|"WebSearch")
        # Always allow read-only operations and task management
        exit 0
        ;;

    *)
        # Allow other tools by default
        exit 0
        ;;
esac

exit 0
