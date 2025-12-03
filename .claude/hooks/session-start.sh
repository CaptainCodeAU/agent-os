#!/bin/bash
# Session Start Hook for Agent OS Development
# Shows current branch status, uncommitted files, and package manager

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Git repository validation
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo -e "${RED}⚠️  Not in a git repository${NC}"
  exit 0
fi

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

# Detect package manager (inline, no external script)
PKG_MANAGER=""
if [ -f "package.json" ]; then
  if [ -f "pnpm-lock.yaml" ]; then
    PKG_MANAGER="pnpm"
  elif [ -f "yarn.lock" ]; then
    PKG_MANAGER="yarn"
  elif [ -f "bun.lockb" ]; then
    PKG_MANAGER="bun"
  elif [ -f "package-lock.json" ]; then
    PKG_MANAGER="npm"
  else
    PKG_MANAGER="npm"
  fi
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "poetry.lock" ]; then
  if [ -f "poetry.lock" ]; then
    PKG_MANAGER="poetry"
  else
    PKG_MANAGER="pip"
  fi
elif [ -f "Gemfile" ]; then
  PKG_MANAGER="bundler"
elif [ -f "go.mod" ]; then
  PKG_MANAGER="go"
elif [ -f "Cargo.toml" ]; then
  PKG_MANAGER="cargo"
elif [ -f "composer.json" ]; then
  PKG_MANAGER="composer"
fi

# Build colored branch info
if [[ "$IS_PROTECTED" == true ]]; then
    BRANCH_INFO="${YELLOW}${CURRENT_BRANCH}${NC} ${RED}[PROTECTED]${NC}"
else
    BRANCH_INFO="${GREEN}${CURRENT_BRANCH}${NC}"
fi

# Build colored uncommitted files info
if [[ "$UNCOMMITTED_COUNT" -eq 0 ]]; then
    FILES_INFO="${BLUE}${UNCOMMITTED_COUNT} uncommitted${NC}"
else
    FILES_INFO="${YELLOW}${UNCOMMITTED_COUNT} uncommitted${NC}"
fi

# Build output line
OUTPUT="${BRANCH_INFO} | ${FILES_INFO}"

# Add package manager if detected
if [ -n "$PKG_MANAGER" ]; then
  OUTPUT="${OUTPUT} | ${CYAN}${PKG_MANAGER}${NC}"
fi

# Output single line (without prefix - Claude Code adds it automatically)
echo -e "${OUTPUT}"

exit 0
