# Agent OS Core Development - Claude Code Guidelines

## Project Overview

This is a **fork of Agent OS** (`https://github.com/CaptainCodeAU/agent-os` forked from `https://github.com/buildermethods/agent-os`) for core development and enhancement.

**Agent OS** is a framework for spec-driven agentic development that transforms AI coding agents into productive developers through structured workflows, standards, and specifications.

**You're improving Agent OS itself** - the framework that gets installed into other projects.

---

## This is Core Development

### What This Means:
- You're **improving Agent OS itself**, not just using it
- This is a **template/framework repository**, not an application codebase
- Changes here affect how Agent OS works for all users
- Workflows, standards, and agents are the **product**

### Quick Architecture Overview

```
agent-os/
├── config.yml              # Version & configuration
├── profiles/               # Profile templates (default, custom)
│   └── default/
│       ├── agents/         # 8 Claude Code subagents
│       ├── commands/       # Slash commands (single/multi-agent)
│       ├── workflows/      # Step-by-step instructions
│       └── standards/      # Coding standards
├── scripts/                # Installation & management
└── .claude-workspace/      # Your dev workspace (gitignored)
```

**For detailed architecture:** See `.claude/context/agent-os-architecture.md`

---

## Bash Tool & Directory Navigation

### Zoxide Configuration

**Configuration in `~/.zshrc`:**
```bash
eval "$(zoxide init zsh --cmd cd)"
```

### Navigation Rules for Claude Code

**✅ ALWAYS USE:**
```bash
__zoxide_cd /path/to/directory
```

**❌ NEVER USE:**
```bash
cd /path/to/directory  # Reserved for user
z /path/to/directory   # Reserved for user
```

**Why:** Uses the actual shell builtin `cd` command, avoids conflicts with zoxide's behavior.

---

## Git Workflow & Branch Protection

### Protected Branches

Never commit directly to:
- `main`, `master`, `develop`, `production`, `staging`

### Branch Strategy

**Always create a feature branch:**

```bash
# For new features
git checkout -b feature/new-subagent
git checkout -b feature/workflow-enhancement

# For bug fixes
git checkout -b bugfix/template-compilation
git checkout -b bugfix/script-error

# For documentation
git checkout -b docs/workflow-guide

# For standards
git checkout -b standards/python-testing

# For profiles
git checkout -b profiles/django-profile

# For chores
git checkout -b chore/refactor-scripts
```

### What You Can Do on Main

- Read files and explore
- Run read-only git commands
- Switch branches
- Create files in `.claude-workspace/` (gitignored)

### What You Cannot Do on Main

- Modify workflow/standard/agent files
- Edit scripts or config.yml
- Install packages

### Merging Feature Branches

**Prefer rebase for clean linear history:**

```bash
# After completing work on feature branch
git checkout main
git rebase feature/your-feature
git push origin main

# Delete feature branch
git branch -d feature/your-feature
```

**Why rebase?**
- Creates linear, clean history
- Easier to understand chronological changes
- No merge commits cluttering the log
- Simpler to cherry-pick or revert changes

**When to use merge:**
- Syncing with upstream (see below)
- Long-lived branches with complex history

---

## Commit Conventions

### Your Choice: Descriptive or Conventional

**Option A: Match Upstream**
```bash
git commit -m "Add Python testing standards to default profile

- Create standards/testing/python-testing.md
- Include pytest conventions"
```

**Option B: Conventional Commits (Recommended)**
```bash
git commit -m "feat(standards): Add Python testing standards

- Create standards/testing/python-testing.md
- Include pytest conventions"
```

**Types:** feat, fix, docs, refactor, test, chore, standards, workflows, agents, profiles, scripts

**Scopes:** (workflows), (standards), (agents), (commands), (scripts), (profiles), (config)

---

## Development Workflow

### 1. Understanding Phase (Use `.claude-workspace/`)

```bash
# Analyze and document
"Analyze [component] and save to .claude-workspace/analysis/[name].md"

# Research patterns
"Find all [pattern] and document in .claude-workspace/references/[name].md"
```

### 2. Planning Phase

```bash
# Design new feature
"Design [feature] and save to .claude-workspace/planning/[name].md"
```

### 3. Implementation Phase

```bash
# Create branch
git checkout -b feature/[name]

# Implement
"Create profiles/default/workflows/[name].md following existing patterns"

# For agents: create both single-agent and multi-agent variants
# For workflows: ensure clear steps and constraints
# For standards: organize by category (global/, frontend/, backend/, testing/)
```

### 4. Testing Phase

```bash
# Test compilation
~/agent-os/scripts/project-install.sh --dry-run

# Test in real project
__zoxide_cd ~/test-project
~/agent-os/scripts/project-install.sh

# Document results
"Save test results to .claude-workspace/progress/YYYY-MM-DD-[name].md"
```

### 5. Review & Commit

```bash
# Review
git status
git diff

# Commit
git add [files]
git commit -m "type(scope): description"

# Push
git push origin feature/[name]
```

### 6. PR Phase

```bash
gh pr create --title "type: description" --body "## Summary
[What this does]

## Changes
- [List changes]

## Test Plan
- [How tested]

## Breaking Changes
[None or describe]"
```

---

## Key Agent OS Concepts

### Profile System

**Three-tier architecture:**
1. **Base Installation** (`~/agent-os/`) - On your machine, source of truth
2. **Profiles** (`profiles/[name]/`) - Templates for different project types
3. **Project Installation** - Copies profile into project's codebase

**For details:** See `.claude/context/profile-system.md`

### Template System

Files use template tags that compile during installation:
- `{{workflows/path/file}}` - Injects workflow content
- `{{standards/*}}` - Injects all standards
- `{{UNLESS flag}}...{{ENDUNLESS flag}}` - Conditional blocks

**Important:** Template tags compile **once** during installation, not dynamically.

**For details:** See `.claude/context/template-system.md`

### Agent Modes

**Multi-Agent Mode** (Claude Code):
- Commands in `.claude/commands/agent-os/`
- Delegates to specialized subagents
- Better context efficiency

**Single-Agent Mode** (Cursor/Windsurf):
- Commands in `agent-os/commands/`
- Main agent executes everything
- Lower token usage

**You must maintain BOTH modes** when adding features.

**For details:** See `.claude/context/agent-modes.md`

### The 6 Development Phases

1. **plan-product** - Mission, roadmap, tech stack
2. **shape-spec** - Requirements gathering
3. **write-spec** - Formal specification
4. **create-tasks** - Task breakdown
5. **implement-tasks** - Implementation
6. **orchestrate-tasks** - Multi-agent orchestration

**For details:** See `.claude/context/development-phases.md`

---

## Working with Components

### Workflows (in `profiles/[name]/workflows/`)

**Structure:**
- Core Responsibilities
- Workflow (numbered steps)
- Important Constraints
- Success Criteria

**When modifying:**
1. Understand purpose and usage
2. Test current version
3. Make changes on feature branch
4. Test both agent modes
5. Update CHANGELOG.md

**For patterns:** See `.claude/context/workflow-patterns.md`

### Standards (in `profiles/[name]/standards/`)

**Organization:**
- `global/` - Universal (tech-stack, coding-style, conventions)
- `frontend/` - Frontend-specific (components, css, responsive)
- `backend/` - Backend-specific (api, models, queries)
- `testing/` - Test standards

**For details:** See `.claude/context/standards-structure.md`

### Agents (in `profiles/[name]/agents/`)

**Frontmatter format:**
```markdown
---
name: agent-name
description: Use proactively to [purpose]
tools: Write, Read, Bash, WebFetch
color: purple
model: inherit
---
```

**The 8 specialized agents:**
product-planner, spec-initializer, spec-shaper, spec-writer, spec-verifier, tasks-list-creator, implementer, implementation-verifier

**For patterns:** See `.claude/context/agent-patterns.md`

### Scripts (in `scripts/`)

**Key scripts:**
- `common-functions.sh` - Shared utilities
- `base-install.sh` - Base installation
- `project-install.sh` - Project installation
- `project-update.sh` - Project updates
- `create-profile.sh` - Profile creation

**For architecture:** See `.claude/context/script-architecture.md`

---

## Testing Changes

### Test Compilation
```bash
~/agent-os/scripts/project-install.sh --dry-run
```

### Test Workflows
```bash
# In test project
__zoxide_cd ~/test-project
~/agent-os/scripts/project-install.sh
"/[command-name]"
```

### Test Both Agent Modes
```bash
# Multi-agent mode
~/agent-os/scripts/project-install.sh --use-claude-code-subagents true

# Single-agent mode
~/agent-os/scripts/project-install.sh --use-claude-code-subagents false
```

---

## Configuration

`config.yml` controls behavior:

```yaml
version: 2.1.1                          # Current version
profile: default                        # Default profile

claude_code_commands: true              # Install to .claude/commands/
agent_os_commands: false                # Install to agent-os/commands/
use_claude_code_subagents: true         # Enable subagent delegation
standards_as_claude_code_skills: false  # Use Skills vs injection
```

**For full details:** See `.claude/context/configuration-system.md`

---

## Common Gotchas

1. **Template tags compile once** - Not dynamic, requires project update
2. **Profiles are copied** - Project installations are self-contained
3. **Both agent modes must work** - Test single-agent and multi-agent
4. **Standards injection varies** - Depends on `standards_as_claude_code_skills` flag
5. **Bash scripts use `set -e`** - Handle errors explicitly

---

## Quick Reference

### Common Commands
```bash
# Navigate
__zoxide_cd ~/projects/agent-os

# Branch
git checkout -b feature/new-feature

# Test
~/agent-os/scripts/project-install.sh --dry-run

# Commit
git commit -m "feat(scope): description"

# PR
gh pr create --title "feat: description"

# Sync upstream
git fetch upstream
git merge upstream/main
```

### Key Files
- `config.yml` - Configuration
- `CHANGELOG.md` - Update this!
- `profiles/default/` - Default templates
- `scripts/common-functions.sh` - Shared functions

### Template Tags
- `{{workflows/path/file}}` - Inject workflow
- `{{standards/*}}` - Inject standards
- `{{UNLESS flag}}...{{ENDUNLESS flag}}` - Conditional

---

## Detailed Documentation

For deeper information, see `.claude/context/`:

1. **agent-os-architecture.md** - Complete architecture overview
2. **profile-system.md** - Three-tier installation model
3. **template-system.md** - How template compilation works
4. **agent-modes.md** - Multi-agent vs single-agent details
5. **development-phases.md** - The 6 phases explained
6. **workflow-patterns.md** - Workflow structure and patterns
7. **standards-structure.md** - Standards organization
8. **agent-patterns.md** - Agent definition patterns
9. **script-architecture.md** - Script functions and usage
10. **configuration-system.md** - Config flags and hierarchy

**To read a detailed doc:**
```
"Read .claude/context/[topic].md and explain [specific aspect]"
```

---

## Workspace Structure

```
.claude-workspace/           # Gitignored - your dev space
├── analysis/               # Understanding Agent OS
├── planning/               # Feature designs
├── progress/               # Development logs
├── research/               # Research notes
├── references/             # Quick references
└── templates/              # Experimental templates
```

---

## Syncing with Upstream

```bash
# Add upstream (once)
git remote add upstream https://github.com/buildermethods/agent-os.git

# Fetch and merge
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

---

## Questions or Issues?

### Understanding Agent OS
- Read `.claude/context/` docs for details
- Analyze in `.claude-workspace/analysis/`
- Review CHANGELOG.md for evolution

### Development Help
- Check `.claude-workspace/references/`
- Review similar features
- Test in isolation
- Document in `.claude-workspace/progress/`

### Contributing Upstream
- Review upstream commits
- Follow their conventions
- Test thoroughly
- Focus on value

---

## Summary

**You're contributing to Agent OS core** - improving the framework itself.

**Your workflow:**
1. Understand → `.claude-workspace/analysis/`
2. Plan → `.claude-workspace/planning/`
3. Branch → `feature/your-feature`
4. Implement → Profiles, scripts, config
5. Test → Both modes, compilation
6. Document → CHANGELOG.md, progress logs
7. Commit → Clear messages
8. PR → Your main, then upstream

**Remember:**
- Use `__zoxide_cd` for navigation
- Protected main branch
- Test both agent modes
- Verify template compilation
- Update CHANGELOG.md
- Read `.claude/context/` docs for details

---

**Ready to improve Agent OS! 🚀**
