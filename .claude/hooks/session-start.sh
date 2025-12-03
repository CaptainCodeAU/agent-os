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

# Build status message
STATUS_MESSAGE="SessionStart:startup hook success: "

# Add branch info
if [[ "$IS_PROTECTED" == true ]]; then
    STATUS_MESSAGE="${STATUS_MESSAGE}Branch: ${CURRENT_BRANCH} (PROTECTED)"
else
    STATUS_MESSAGE="${STATUS_MESSAGE}Branch: ${CURRENT_BRANCH}"
fi

# Add uncommitted files count
STATUS_MESSAGE="${STATUS_MESSAGE} | Uncommitted files: ${UNCOMMITTED_COUNT}"

# Output the status message
echo "$STATUS_MESSAGE"

exit 0
