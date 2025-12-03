#!/bin/bash
# Post-Tool-Use Hook for Agent OS Development
# Optional: Auto-formatting and validation after file modifications

set -e

# Get the tool being used and its arguments from environment variables
TOOL_NAME="${TOOL_NAME:-}"
TOOL_ARGS="${TOOL_ARGS:-}"
TOOL_SUCCESS="${TOOL_SUCCESS:-true}"

# Only proceed if tool was successful
if [[ "$TOOL_SUCCESS" != "true" ]]; then
    exit 0
fi

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

# Only process Write, Edit, and NotebookEdit operations
case "$TOOL_NAME" in
    "Write"|"Edit"|"NotebookEdit")
        if [[ -z "$FILE_PATH" ]]; then
            exit 0
        fi

        # Get file extension
        FILE_EXT="${FILE_PATH##*.}"

        # Optional: Run formatters based on file type
        # Uncomment the formatters you want to enable

        case "$FILE_EXT" in
            # Markdown files - validate structure
            "md")
                # Could add markdown linting here if needed
                # Example: markdownlint "$FILE_PATH" 2>/dev/null || true
                ;;

            # Shell scripts - validate syntax
            "sh")
                if [[ -f "$FILE_PATH" ]]; then
                    # Validate shell script syntax
                    bash -n "$FILE_PATH" 2>/dev/null || {
                        echo "WARNING: Shell script syntax validation failed for $FILE_PATH"
                    }
                fi
                ;;

            # YAML files - validate syntax
            "yml"|"yaml")
                # Could add YAML validation here if needed
                # Example: yamllint "$FILE_PATH" 2>/dev/null || true
                ;;

            # JavaScript/TypeScript
            "js"|"jsx"|"ts"|"tsx")
                # Example: prettier --write "$FILE_PATH" 2>/dev/null || true
                # Example: eslint --fix "$FILE_PATH" 2>/dev/null || true
                ;;

            # Python files
            "py")
                # Example: black "$FILE_PATH" 2>/dev/null || true
                # Example: isort "$FILE_PATH" 2>/dev/null || true
                ;;

            *)
                # No formatting for other file types
                ;;
        esac
        ;;

    *)
        # No post-processing for other tools
        ;;
esac

exit 0
