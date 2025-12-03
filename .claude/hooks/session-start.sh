#!/bin/bash
# Session Start Hook for Agent OS Development
# Shows current branch status and uncommitted files

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

# Get uncommitted files count
UNCOMMITTED_COUNT=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

# Check if on protected branch
PROTECTED_BRANCHES=("main" "master" "develop" "production" "staging")
IS_PROTECTED=false
for branch in "${PROTECTED_BRANCHES[@]}"; do
    if [[ "$CURRENT_BRANCH" == "$branch" ]]; then
        IS_PROTECTED=true
        break
    fi
done

# Build status message with colors
if [[ "$IS_PROTECTED" == true ]]; then
    # Protected branch - use red/yellow for warning
    BRANCH_INFO="${YELLOW}${CURRENT_BRANCH}${NC} ${RED}[PROTECTED]${NC}"
else
    # Regular branch - use green
    BRANCH_INFO="${GREEN}${CURRENT_BRANCH}${NC}"
fi

# Uncommitted files - use blue if 0, yellow if > 0
if [[ "$UNCOMMITTED_COUNT" -eq 0 ]]; then
    FILES_INFO="${BLUE}${UNCOMMITTED_COUNT} uncommitted${NC}"
else
    FILES_INFO="${YELLOW}${UNCOMMITTED_COUNT} uncommitted${NC}"
fi

# Output the status message (without prefix - Claude Code adds it automatically)
echo -e "${BRANCH_INFO} | ${FILES_INFO}"

exit 0
