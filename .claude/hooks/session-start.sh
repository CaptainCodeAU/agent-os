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
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Git repository validation
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo ""
  echo -e "${RED}⚠️  Not in a git repository${NC}"
  echo ""
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
PKG_ICON=""
if [ -f "package.json" ]; then
  if [ -f "pnpm-lock.yaml" ]; then
    PKG_MANAGER="pnpm"
    PKG_ICON="📦"
  elif [ -f "yarn.lock" ]; then
    PKG_MANAGER="yarn"
    PKG_ICON="📦"
  elif [ -f "bun.lockb" ]; then
    PKG_MANAGER="bun"
    PKG_ICON="🍞"
  elif [ -f "package-lock.json" ]; then
    PKG_MANAGER="npm"
    PKG_ICON="📦"
  else
    PKG_MANAGER="npm"
    PKG_ICON="📦"
  fi
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "poetry.lock" ]; then
  if [ -f "poetry.lock" ]; then
    PKG_MANAGER="poetry"
  else
    PKG_MANAGER="pip"
  fi
  PKG_ICON="🐍"
elif [ -f "Gemfile" ]; then
  PKG_MANAGER="bundler"
  PKG_ICON="💎"
elif [ -f "go.mod" ]; then
  PKG_MANAGER="go"
  PKG_ICON="🐹"
elif [ -f "Cargo.toml" ]; then
  PKG_MANAGER="cargo"
  PKG_ICON="🦀"
elif [ -f "composer.json" ]; then
  PKG_MANAGER="composer"
  PKG_ICON="🎵"
fi

# Build colored branch info
if [[ "$IS_PROTECTED" == true ]]; then
    BRANCH_DISPLAY="${YELLOW}${CURRENT_BRANCH}${NC} ${RED}[PROTECTED]${NC}"
    BRANCH_EMOJI="🔒"
else
    BRANCH_DISPLAY="${GREEN}${CURRENT_BRANCH}${NC}"
    BRANCH_EMOJI="🌿"
fi

# Build colored uncommitted files info
if [[ "$UNCOMMITTED_COUNT" -eq 0 ]]; then
    FILES_DISPLAY="${BLUE}${UNCOMMITTED_COUNT}${NC} ${DIM}(clean)${NC}"
    FILES_EMOJI="✓"
else
    FILES_DISPLAY="${YELLOW}${UNCOMMITTED_COUNT}${NC} ${DIM}(uncommitted)${NC}"
    FILES_EMOJI="📝"
fi

# Output box format with colors
echo ""
echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║${NC}              ${BOLD}🚦 SESSION CHECKPOINT${NC}                   ${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BRANCH_EMOJI}  ${BOLD}Branch:${NC} ${BRANCH_DISPLAY}"
echo -e "${FILES_EMOJI}  ${BOLD}Files:${NC} ${FILES_DISPLAY}"

if [ -n "$PKG_MANAGER" ]; then
  echo -e "${PKG_ICON}  ${BOLD}Package Manager:${NC} ${CYAN}${PKG_MANAGER}${NC}"
fi

echo ""
echo -e "${DIM}────────────────────────────────────────────────────────────${NC}"
echo ""

exit 0
