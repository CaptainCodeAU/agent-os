#!/bin/bash
# Post-Tool-Use Hook for Agent OS Development
# Optional: Auto-formatting and validation after file modifications
#
# Supported formatters (opt-in by setting to true below):
# - Ultracite: Comprehensive JS/TS formatter (biome + prettier)
# - Prettier: Code formatting
# - ESLint: JS/TS linting
# - Black: Python formatting
# - Ruff: Python linting + formatting
# - ShellCheck: Shell script validation (enabled by default)
# - shfmt: Shell script formatting
# - markdownlint: Markdown linting

set -euo pipefail

# ============================================================================
# CONFIGURATION - Enable/disable formatters here
# ============================================================================

# JavaScript/TypeScript formatters
ENABLE_ULTRACITE=false          # All-in-one formatter (recommended)
ENABLE_PRETTIER=false           # Code formatting only
ENABLE_ESLINT=false             # Linting + auto-fix

# Python formatters
ENABLE_BLACK=false              # Code formatting
ENABLE_RUFF=false               # Linting + formatting (faster)

# Shell formatters
ENABLE_SHELLCHECK=true          # Syntax validation (recommended)
ENABLE_SHFMT=false              # Code formatting

# Markdown formatters
ENABLE_MARKDOWNLINT=false       # Markdown linting

# ============================================================================
# DO NOT EDIT BELOW THIS LINE
# ============================================================================

# Get the tool being used and its arguments from environment variables
TOOL_NAME="${TOOL_NAME:-}"
TOOL_ARGS="${TOOL_ARGS:-}"
TOOL_SUCCESS="${TOOL_SUCCESS:-true}"

# Color codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
DIM='\033[2m'
NC='\033[0m'

# Only proceed if tool was successful
if [[ "$TOOL_SUCCESS" != "true" ]]; then
    exit 0
fi

# Parse JSON arguments
FILE_PATH=""
if [[ -n "$TOOL_ARGS" ]]; then
    # Extract file_path (for Write, Edit, NotebookEdit)
    FILE_PATH=$(echo "$TOOL_ARGS" | grep -o '"file_path":"[^"]*"' | sed 's/"file_path":"//;s/"$//' || echo "")

    # If no file_path, try notebook_path
    if [[ -z "$FILE_PATH" ]]; then
        FILE_PATH=$(echo "$TOOL_ARGS" | grep -o '"notebook_path":"[^"]*"' | sed 's/"notebook_path":"//;s/"$//' || echo "")
    fi
fi

# Only process Write, Edit, and NotebookEdit operations
case "$TOOL_NAME" in
    "Write"|"Edit"|"NotebookEdit")
        if [[ -z "$FILE_PATH" ]] || [[ ! -f "$FILE_PATH" ]]; then
            exit 0
        fi
        ;;
    *)
        exit 0
        ;;
esac

# Get file extension
FILE_EXT="${FILE_PATH##*.}"
BASENAME=$(basename "$FILE_PATH")

# Detect package manager (inline, no external script)
detect_package_manager() {
    if [ -f "pnpm-lock.yaml" ]; then
        echo "pnpm"
    elif [ -f "bun.lockb" ]; then
        echo "bun"
    elif [ -f "yarn.lock" ]; then
        echo "yarn"
    elif [ -f "package-lock.json" ]; then
        echo "npm"
    else
        echo "npm"  # fallback
    fi
}

# Run formatter with package manager
run_js_formatter() {
    local tool=$1
    local file=$2
    local pkg_manager=$(detect_package_manager)

    echo ""
    echo -e "${CYAN}🔧 Running ${tool}...${NC}"
    echo -e "${DIM}   File: ${BASENAME}${NC}"

    local output
    local exit_code=0

    case "$pkg_manager" in
        pnpm)
            output=$(pnpm exec "$tool" fix "$file" 2>&1) || exit_code=$?
            ;;
        bun)
            output=$(bunx "$tool" fix "$file" 2>&1) || exit_code=$?
            ;;
        yarn)
            output=$(yarn exec "$tool" fix "$file" 2>&1) || exit_code=$?
            ;;
        npm)
            output=$(npx "$tool" fix "$file" 2>&1) || exit_code=$?
            ;;
    esac

    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ Formatting complete${NC}"
    else
        echo -e "${YELLOW}⚠️  Formatter had issues (exit code: $exit_code)${NC}"
        if [[ -n "$output" ]] && [[ "$output" != "" ]]; then
            echo -e "${DIM}${output}${NC}"
        fi
    fi
    echo ""
}

# Run simple command formatter
run_formatter() {
    local tool=$1
    shift
    local args=("$@")

    echo ""
    echo -e "${CYAN}🔧 Running ${tool}...${NC}"
    echo -e "${DIM}   File: ${BASENAME}${NC}"

    local output
    local exit_code=0

    output=$("$tool" "${args[@]}" 2>&1) || exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ Formatting complete${NC}"
    else
        echo -e "${YELLOW}⚠️  ${tool} had issues (exit code: $exit_code)${NC}"
        if [[ -n "$output" ]] && [[ "$output" != "" ]]; then
            echo -e "${DIM}${output}${NC}"
        fi
    fi
    echo ""
}

# Process file based on type
case "$FILE_EXT" in
    # JavaScript/TypeScript files
    ts|tsx|js|jsx|json|jsonc|mjs|cjs)
        # Check if it's a JavaScript project
        if [ ! -f "package.json" ]; then
            exit 0
        fi

        # Run Ultracite if enabled (comprehensive formatter)
        if [[ "$ENABLE_ULTRACITE" == "true" ]]; then
            if command -v npx &> /dev/null; then
                run_js_formatter "ultracite" "$FILE_PATH"
            fi
        fi

        # Run Prettier if enabled (not needed if Ultracite is used)
        if [[ "$ENABLE_PRETTIER" == "true" ]] && [[ "$ENABLE_ULTRACITE" != "true" ]]; then
            if command -v npx &> /dev/null; then
                run_js_formatter "prettier" "$FILE_PATH"
            fi
        fi

        # Run ESLint if enabled
        if [[ "$ENABLE_ESLINT" == "true" ]]; then
            if command -v npx &> /dev/null; then
                run_js_formatter "eslint" "$FILE_PATH"
            fi
        fi
        ;;

    # Python files
    py)
        # Run Black if enabled
        if [[ "$ENABLE_BLACK" == "true" ]]; then
            if command -v black &> /dev/null; then
                run_formatter black "$FILE_PATH"
            fi
        fi

        # Run Ruff if enabled
        if [[ "$ENABLE_RUFF" == "true" ]]; then
            if command -v ruff &> /dev/null; then
                run_formatter ruff format "$FILE_PATH"
            fi
        fi
        ;;

    # Shell scripts
    sh)
        # Run ShellCheck if enabled (validation)
        if [[ "$ENABLE_SHELLCHECK" == "true" ]]; then
            if command -v shellcheck &> /dev/null; then
                echo ""
                echo -e "${CYAN}🔍 Validating shell script syntax...${NC}"
                echo -e "${DIM}   File: ${BASENAME}${NC}"

                if shellcheck "$FILE_PATH" 2>&1; then
                    echo -e "${GREEN}✅ Validation passed${NC}"
                else
                    echo -e "${YELLOW}⚠️  Validation found issues${NC}"
                fi
                echo ""
            else
                # Fallback to bash -n if shellcheck not available
                if bash -n "$FILE_PATH" 2>/dev/null; then
                    echo -e "${GREEN}✅ Shell syntax valid${NC}"
                else
                    echo -e "${RED}⚠️  Shell syntax validation failed${NC}"
                fi
            fi
        fi

        # Run shfmt if enabled (formatting)
        if [[ "$ENABLE_SHFMT" == "true" ]]; then
            if command -v shfmt &> /dev/null; then
                run_formatter shfmt -w "$FILE_PATH"
            fi
        fi
        ;;

    # Markdown files
    md|mdx)
        # Run markdownlint if enabled
        if [[ "$ENABLE_MARKDOWNLINT" == "true" ]]; then
            if command -v markdownlint &> /dev/null; then
                run_formatter markdownlint --fix "$FILE_PATH"
            elif command -v npx &> /dev/null; then
                run_js_formatter "markdownlint-cli" "$FILE_PATH"
            fi
        fi
        ;;

    # YAML files
    yml|yaml)
        # Could add yamllint here
        ;;

    *)
        # No formatting for other file types
        ;;
esac

exit 0
