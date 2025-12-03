# Claude Code Hooks for Agent OS Development

This directory contains Claude Code hooks that enforce the development guidelines outlined in `CLAUDE.md`.

## Hooks Overview

### 1. session-start.sh

**Purpose:** Display session information when Claude Code starts

**What it shows:**
- Current Git branch with protection status
- Number of uncommitted files
- Package manager detection (npm, pnpm, yarn, bun, pip, poetry, bundler, go, cargo, composer)
- Git repository validation

**Example output:**
```
SessionStart:startup hook succeeded: main [PROTECTED] | 1 uncommitted | npm
SessionStart:startup hook succeeded: feature-branch | 0 uncommitted | pnpm
SessionStart:startup hook succeeded: bugfix/issue-123 | 3 uncommitted
```

**Features:**
- 🎨 Color-coded output (green/yellow branch, red [PROTECTED], blue/yellow files, cyan package manager)
- 🔒 Protected branch detection with red [PROTECTED] tag
- 📦 Automatic package manager detection
- ✓ Git repository validation (warns if not in a git repo)
- 📏 Concise single-line format
- 🎯 Works everywhere (not restricted to Claude Code Web)
- 🚀 Self-contained (no external scripts required)

**Colors:**
- **Green** - Regular branch names
- **Yellow** - Protected branch names
- **Red** - [PROTECTED] tag
- **Blue** - 0 uncommitted files (clean)
- **Yellow** - >0 uncommitted files
- **Cyan** - Package manager name

**Package Managers Detected:**
- JavaScript: npm, pnpm, yarn, bun
- Python: pip, poetry
- Ruby: bundler
- Go: go
- Rust: cargo
- PHP: composer

### 2. pre-tool-use.sh

**Purpose:** Enforce branch protection rules and package manager consistency

**Protected branches:**
- main
- master
- develop
- production
- staging

**Rules on protected branches:**

✅ **Allowed:**
- Read operations (Read, Glob, Grep, WebFetch, WebSearch)
- Task management (Task, TodoWrite, AskUserQuestion)
- Read-only git commands (git status, diff, log, show, branch, rev-parse, remote, ls-files)
- Branch switching (git checkout, git switch)
- Getting updates (git pull, git fetch, git stash)
- Modifications to `.claude/` and `.claude-workspace/` directories
- All other bash commands (build, test, file operations, etc.)

❌ **Blocked:**
- File modifications (Write, Edit, NotebookEdit) outside `.claude/` directories
- Git state changes (commit, push, merge, rebase, cherry-pick, reset, tag)
- Package installations:
  - JavaScript: npm/pnpm/yarn/bun install/add
  - Python: pip install, uv pip install, uv sync, uv venv
  - Rust: cargo add
  - Go: go get
  - Ruby: bundle install
  - PHP: composer install

⚠️ **Package Manager Consistency:**
- Automatically detects project's package manager from lock files
- Blocks usage of wrong package manager (e.g., using npm when project has pnpm-lock.yaml)
- Prevents lock file conflicts and ensures team consistency

⚠️ **Warnings:**
- Using `cd` instead of `__zoxide_cd` for directory navigation (Agent OS specific)

**Features:**
- 📦 Automatic package manager detection (npm, pnpm, yarn, bun)
- 🎨 Beautiful error messages with box formatting and colors
- ✅ Smart git operation handling (allows safe operations, blocks dangerous ones)
- 🔒 Protects against accidental changes to protected branches
- 🚀 Self-contained (no external scripts required)

**Example error messages:**

**File modification blocked:**
```
╔════════════════════════════════════════════════════════════════╗
║           🚫 BLOCKED: Protected Branch Detected                ║
╚════════════════════════════════════════════════════════════════╝

📍 Current branch: main (protected)
🛠️  Attempted tool: Write
📁 File: test.md

⚠️  You cannot modify files on protected branches.
   Please create a feature branch first.

💡 Quick fix:

   1. Ask Claude to create a branch for you, or
   2. Run: git checkout -b feature/your-feature-name

Then try again!
```

**Wrong package manager:**
```
╔════════════════════════════════════════════════════════════════╗
║           ⚠️  WRONG PACKAGE MANAGER DETECTED                   ║
╚════════════════════════════════════════════════════════════════╝

❌ You're trying to use: npm
✅ This project uses: pnpm

💡 Lock file detected:
   📄 pnpm-lock.yaml

Please use 'pnpm' instead to maintain consistency.
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
