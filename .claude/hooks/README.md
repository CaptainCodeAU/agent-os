# Claude Code Hooks for Agent OS Development

This directory contains Claude Code hooks that enforce the development guidelines outlined in `CLAUDE.md`.

## Hooks Overview

### 1. session-start.sh

**Purpose:** Display session information when Claude Code starts

**What it shows:**
- Current Git branch
- Whether the branch is protected (main, master, develop, production, staging)
- Number of uncommitted files

**Example output:**
```
SessionStart:startup hook success: Branch: chore/add-claude-code-hooks | Uncommitted files: 1
```

### 2. pre-tool-use.sh

**Purpose:** Enforce branch protection rules before file operations

**Protected branches:**
- main
- master
- develop
- production
- staging

**Rules:**

✅ **Allowed on all branches:**
- Read operations (Read, Glob, Grep)
- Task management (Task, TodoWrite)
- User questions (AskUserQuestion)
- Read-only git commands (git status, git diff, git log)
- Modifications to `.claude-workspace/` directory

❌ **Blocked on protected branches:**
- File modifications (Write, Edit, NotebookEdit) outside `.claude-workspace/`
- Git state changes (commit, push, merge, rebase, etc.)
- Package installations (npm install, pip install, etc.)

⚠️ **Warnings:**
- Using `cd` instead of `__zoxide_cd` for directory navigation

**Example error message:**
```
ERROR: Cannot modify files on protected branch 'main'
File: /path/to/file.md

To make changes:
1. Create a feature branch: git checkout -b feature/your-feature-name
2. Make your changes on the feature branch
3. Push and create a PR when ready

Note: You can still modify files in .claude-workspace/ on any branch
```

### 3. post-tool-use.sh

**Purpose:** Optional validation and formatting after file operations

**Current features:**
- Shell script syntax validation (.sh files)
- Extensible for future formatters (currently commented out)

**Potential extensions (commented out):**
- Markdown linting
- YAML validation
- JavaScript/TypeScript formatting (prettier, eslint)
- Python formatting (black, isort)

## How Hooks Work

Claude Code automatically executes these hooks at specific points using the new matcher-based format:

1. **session-start.sh** - Runs when a new Claude Code session begins
2. **pre-tool-use.sh** - Runs before any tool is executed (Write, Edit, Bash, etc.)
3. **post-tool-use.sh** - Runs after a tool successfully executes

### Configuration Format

Hooks are configured in `.claude/settings.json` using the new format:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/session-start.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre-tool-use.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/post-tool-use.sh"
          }
        ]
      }
    ]
  }
}
```

**Key points:**
- `matcher` is a **string**, not an object
- Use `"*"` to match all tools (or `""` or omit matcher entirely)
- Use regex patterns like `"Write|Edit"` to match specific tools
- `SessionStart` doesn't need a matcher (no tool context)

### Environment Variables

Hooks receive information via environment variables:
- `TOOL_NAME` - Name of the tool being used
- `TOOL_ARGS` - JSON string of tool arguments
- `TOOL_SUCCESS` - Whether the tool succeeded (post-hook only)
- `CLAUDE_PROJECT_DIR` - Path to the project directory

## Development Workflow

### On Protected Branches (main, master, etc.)

You can:
- Explore and read files
- Run git status, git diff
- Create/modify files in `.claude-workspace/`
- Plan and analyze

You cannot:
- Modify workflow, standard, or agent files
- Edit scripts or config.yml
- Install packages
- Commit changes

### On Feature Branches

You can do everything, including:
- Modify any files
- Install packages
- Commit changes
- Push to remote

### Typical Workflow

1. **Start on main:** Explore, read, plan
   ```bash
   # Hooks allow read operations
   # Can save notes to .claude-workspace/
   ```

2. **Create feature branch:**
   ```bash
   git checkout -b feature/new-feature
   ```

3. **Make changes:** Hooks allow all operations
   ```bash
   # Modify files, install packages, etc.
   ```

4. **Commit and push:**
   ```bash
   git add .
   git commit -m "feat: description"
   git push origin feature/new-feature
   ```

5. **Create PR:**
   ```bash
   gh pr create --title "feat: description"
   ```

## Customization

### Enabling Formatters

Edit `post-tool-use.sh` to enable formatters by uncommenting the relevant lines:

```bash
# Markdown linting
"md")
    markdownlint "$FILE_PATH" 2>/dev/null || true
    ;;

# JavaScript/TypeScript formatting
"js"|"jsx"|"ts"|"tsx")
    prettier --write "$FILE_PATH" 2>/dev/null || true
    eslint --fix "$FILE_PATH" 2>/dev/null || true
    ;;
```

### Adding Protected Branches

Edit the `PROTECTED_BRANCHES` array in both `session-start.sh` and `pre-tool-use.sh`:

```bash
PROTECTED_BRANCHES=("main" "master" "develop" "production" "staging" "release")
```

### Modifying Rules

The `pre-tool-use.sh` hook uses a case statement to handle different tools. Add or modify cases as needed:

```bash
case "$TOOL_NAME" in
    "Write"|"Edit"|"NotebookEdit")
        # Your custom logic here
        ;;
    "CustomTool")
        # Handle custom tool
        ;;
esac
```

## Troubleshooting

### Hook not executing

1. Check file permissions: `ls -la .claude/hooks/`
2. Ensure execute bit is set: `chmod +x .claude/hooks/*.sh`
3. Verify shebang line: `#!/bin/bash`

### Hook blocking legitimate operation

1. Check current branch: `git branch`
2. Verify file path: Is it in `.claude-workspace/`?
3. Create feature branch if needed: `git checkout -b feature/fix`

### Hook false positive

1. Review hook logic in the script
2. Add exception if needed
3. Test with: `TOOL_NAME=Write TOOL_ARGS='{"file_path":"test.md"}' .claude/hooks/pre-tool-use.sh`

## Testing Hooks

### Manual testing:

```bash
# Test session-start
.claude/hooks/session-start.sh

# Test pre-tool-use (simulated Write)
TOOL_NAME=Write TOOL_ARGS='{"file_path":"test.md"}' .claude/hooks/pre-tool-use.sh

# Test pre-tool-use (simulated workspace write)
TOOL_NAME=Write TOOL_ARGS='{"file_path":".claude-workspace/test.md"}' .claude/hooks/pre-tool-use.sh

# Test post-tool-use
TOOL_NAME=Write TOOL_ARGS='{"file_path":"test.sh"}' TOOL_SUCCESS=true .claude/hooks/post-tool-use.sh
```

## Architecture

These hooks implement the guidelines from `CLAUDE.md`:

1. **Branch Protection** - Enforces protected branch rules
2. **Zoxide Usage** - Warns when using `cd` instead of `__zoxide_cd`
3. **Workspace Freedom** - Always allows `.claude-workspace/` modifications
4. **Development Workflow** - Guides proper feature branch workflow

## References

- Main guidelines: `/CLAUDE.md`
- Architecture docs: `/.claude/context/agent-os-architecture.md`
- Git workflow: `CLAUDE.md#git-workflow--branch-protection`
