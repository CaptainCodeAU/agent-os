# Agent OS Core Development - Claude Code Guidelines

## Project Overview

This is a **fork of Agent OS** (`https://github.com/CaptainCodeAU/agent-os` forked from `https://github.com/buildermethods/agent-os`) for core development and enhancement.

**Agent OS** is a framework for spec-driven agentic development that provides AI coding agents with structured workflows, standards, and specifications. It's designed to work with Claude Code, Cursor, Windsurf, and other AI coding tools.

The framework transforms AI agents from "confused interns" into productive developers by giving them:
- **Structured workflows** for product planning, specification, and implementation
- **Coding standards** tailored to different stacks (frontend, backend, testing)
- **Profile system** for different project types
- **Installation scripts** for deploying to projects

This CLAUDE.md provides guidelines for **contributing to Agent OS itself** - improving the framework, adding features, fixing bugs, and enhancing the instruction system.

---

## This is Core Development

### What This Means:
- You're **improving Agent OS itself**, not just using it
- This is a **template/framework repository**, not an application codebase
- Its contents get installed into other projects
- Changes here affect how Agent OS works for all users
- Documentation, workflows, standards, and agents are the **product**

### Key Difference from Using Agent OS:
| Using Agent OS | Developing Agent OS Core |
|----------------|--------------------------|
| Installing `agent-os/` into projects | Modifying the framework itself |
| Customizing standards for your app | Creating reusable standard templates |
| Following workflows | Writing/improving workflows |
| Using agents | Building new subagents |
| Project-specific setup | System-wide improvements |

---

## Repository Architecture

### Core Structure

```
agent-os/
├── config.yml              # Version & configuration defaults
├── profiles/               # Profile templates (default, custom)
│   └── default/
│       ├── agents/         # Claude Code subagent definitions (8 agents)
│       ├── commands/       # Slash commands (single-agent & multi-agent modes)
│       ├── workflows/      # Workflow instruction files
│       └── standards/      # Coding standards by domain
├── scripts/                # Installation & management bash scripts
│   ├── common-functions.sh
│   ├── base-install.sh
│   ├── project-install.sh
│   ├── project-update.sh
│   └── create-profile.sh
├── CHANGELOG.md           # Version history
├── README.md              # Project documentation
└── .claude-workspace/     # Your development workspace (NOT COMMITTED)
    ├── analysis/          # Understanding the codebase
    ├── planning/          # Feature planning for Agent OS
    ├── progress/          # Development logs
    ├── research/          # Research & exploration
    ├── references/        # Quick references
    └── templates/         # Experimental templates
```

### Profile System Architecture

The **profile system** is the central organizational concept:

#### 1. **Base Installation** (`~/agent-os/`)
Lives on developer's machine:
- Contains profiles, scripts, config.yml
- Customizable standards (tech stack, conventions, etc.)
- Source of truth for all project installations
- **This is what you're developing when you fork Agent OS**

#### 2. **Profiles** (`profiles/[name]/`)
Different configurations for different project types:
- `default/` - Generic profile that ships with Agent OS
- Custom profiles - User-created (e.g., `rails`, `python`, `nextjs`)
- Each contains: agents/, commands/, workflows/, standards/
- **When you add features to Agent OS, they go into profiles**

#### 3. **Project Installation**
Copies profile into project's codebase:
- Creates `agent-os/` folder in project
- Optionally creates `.claude/commands/` and `.claude/agents/`
- Self-contained: no external references
- **Users run installation scripts to deploy your improvements**

### Agent Modes

Two operational modes controlled by config.yml:

#### **Multi-Agent Mode** (Claude Code with subagents):
- Commands in `.claude/commands/agent-os/`
- Agents in `.claude/agents/agent-os/`
- Commands delegate to specialized subagents
- Better context efficiency, higher token usage

#### **Single-Agent Mode** (Cursor, Windsurf, or Claude Code without subagents):
- Commands in `agent-os/commands/`
- No subagent delegation
- Main agent executes everything
- Lower token usage, less context efficiency

**When developing Agent OS:** You need to maintain BOTH modes. Commands and workflows must work in both single-agent and multi-agent scenarios.

### Template System

Many files use a **template tag replacement system**:

- `{{workflows/path/file}}` - Injects workflow file content
- `{{standards/*}}` - Injects all standards files
- `{{UNLESS condition}}...{{ENDUNLESS condition}}` - Conditional blocks
- Tags get replaced during project installation by `compile_template()` function

**Example from `agents/spec-writer.md`:**
```markdown
{{workflows/specification/write-spec}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**Important for Development:**
- Template tags are **compiled once** during installation, not dynamic
- Test both the template (source) and compiled output
- Changes to workflows/standards affect compiled output

### The Six Development Phases

Agent OS structures development into 6 phases (commands):

#### 1. **plan-product**
Define product mission, roadmap, tech stack
- Creates `agent-os/product/` folder
- Outputs: mission.md, roadmap.md, tech-stack.md

#### 2. **shape-spec**
Shape rough ideas into requirements
- Creates `agent-os/specs/[spec-name]/planning/`
- Outputs: requirements.md, visuals/

#### 3. **write-spec**
Create formal specification
- Uses spec-writer subagent (multi-agent) or main agent (single-agent)
- Outputs: spec.md

#### 4. **create-tasks**
Break spec into implementation tasks
- Uses tasks-list-creator subagent or main agent
- Outputs: tasks.md (grouped, dependency-aware task list)

#### 5. **implement-tasks**
Simple single-agent implementation
- Implements tasks from tasks.md
- Self-verifies with tests and browser testing (if UI)
- Outputs: code + verification/screenshots/

#### 6. **orchestrate-tasks**
Advanced multi-agent orchestration
- Fine-grained control over which agents implement which task groups
- For complex features requiring multiple specializations

**Users can use all 6 phases or pick only what they need.**

---

## Bash Tool & Directory Navigation

### Zoxide Configuration

**IMPORTANT:** This system uses `zoxide` with a custom setup that modifies the `cd` command behavior.

**Configuration in `~/.zshrc`:**
```bash
eval "$(zoxide init zsh --cmd cd)"
```

This makes `zoxide` respond to `cd` directly while preserving the original `cd` as `__zoxide_cd`.

### Navigation Rules for Claude Code

When using the `bash_tool` to navigate directories:

**✅ ALWAYS USE:**
```bash
__zoxide_cd /path/to/directory
```

**❌ NEVER USE:**
```bash
cd /path/to/directory  # Reserved for user's personal use with zoxide
z /path/to/directory   # Reserved for user's personal use
```

**Why `__zoxide_cd`?**
- Uses the actual shell builtin `cd` command
- Avoids conflicts with zoxide's behavior
- Ensures reliable directory navigation in automated scripts
- Preserved by zoxide specifically for programmatic use

**Example:**
```bash
# ✅ Correct - Navigate to agent-os directory
__zoxide_cd ~/projects/agent-os

# ✅ Correct - Navigate to profiles
__zoxide_cd ./profiles/default

# ❌ Wrong - Don't use cd or z in bash_tool
cd ~/projects/agent-os
z profiles
```

---

## Git Workflow & Branch Protection

### Understanding Upstream vs Your Fork

**Upstream (buildermethods/agent-os):**
- Appears to use main-only development
- Version-based releases (v1.4.0, v2.x, v2.1.1)
- Direct commits to `main` branch
- Release-driven workflow

**Your Fork (CaptainCodeAU/agent-os):**
- **Feature branch workflow with protected branches**
- Structured development process
- Quality controls and review
- Better for systematic development

### Protected Branches

The following branches are protected and should **never** receive direct commits:
- `main` (primary branch)
- `master` (if exists)
- `develop` (if exists)
- `production` (if exists)
- `staging` (if exists)

### Branch Strategy

**Always create a feature branch for development work:**

```bash
# For new Agent OS features
git checkout -b feature/new-subagent
git checkout -b feature/workflow-enhancement
git checkout -b feature/profile-system-improvement

# For bug fixes in Agent OS
git checkout -b bugfix/template-compilation
git checkout -b bugfix/script-error-handling

# For documentation improvements
git checkout -b docs/workflow-guide
git checkout -b docs/installation-improvements

# For new standards or templates
git checkout -b standards/python-testing
git checkout -b standards/api-conventions

# For new profiles
git checkout -b profiles/django-profile
git checkout -b profiles/react-native-profile

# For chores (dependencies, cleanup, etc.)
git checkout -b chore/refactor-scripts
git checkout -b chore/update-changelog
```

**Branch naming conventions:**
- Use lowercase with hyphens
- Use descriptive names indicating what you're improving
- Include the type prefix (feature/, bugfix/, docs/, standards/, profiles/, chore/)

### What You Can Do on Main

- Read files and explore the codebase
- Run git status, git diff, git log (read-only git commands)
- Switch branches (git checkout, git switch)
- View workflows, standards, agents, scripts
- Test Agent OS workflows
- Create files in `.claude-workspace/` (gitignored)

### What You Cannot Do on Main

- Modify workflow files
- Edit standards or templates
- Change agents or commands
- Update scripts
- Modify config.yml
- Install packages or run modification commands

**Note:** The PreToolUse hook (if you add it) will automatically block these actions with helpful error messages.

---

## Package Management & Dependencies

### This Repository Has No Runtime Dependencies

Agent OS is **bash scripts, markdown files, and YAML configuration**. There are:
- ❌ No `package.json`
- ❌ No Python dependencies
- ❌ No npm/pip/cargo packages

### What You Might Need Locally:

**For Developing Agent OS:**
- `bash` - Running and testing scripts
- `git` - Version control
- Claude Code or Cursor - Testing workflows and agents
- `tree` - Viewing directory structure (optional)
- `gh` CLI - If testing PR creation workflows
- YAML parser (built into scripts via `get_yaml_value()`)

**For Testing Agent OS Installations:**
- A test project in any language/framework
- Whatever that project needs (Agent OS will document them)

---

## Script Architecture & Key Functions

All scripts in `scripts/` share `scripts/common-functions.sh` for common functionality.

### YAML Parsing Functions

```bash
get_yaml_value(file, key, default)
# Robust YAML value extraction
# Handles tabs, quotes, variable indentation
# Returns default if key not found

get_yaml_array(file, key)
# Extract array values from YAML
# Returns space-separated list
```

**Example Usage:**
```bash
version=$(get_yaml_value "config.yml" "version" "unknown")
profile=$(get_yaml_value "config.yml" "profile" "default")
```

### Template Compilation Functions

```bash
compile_template(source_file, dest_file, config_flags)
# Main compilation function
# Resolves {{template_tags}} by reading files and injecting content
# Handles conditional blocks: {{UNLESS flag}}...{{ENDUNLESS flag}}
# Recursive: templates can include other templates
```

**How Template Compilation Works:**
1. Reads source file line by line
2. Detects `{{template_tag}}`
3. Reads content from referenced file
4. Injects content into output
5. Processes conditional blocks based on config flags
6. Writes compiled result to destination

**Example Template Tag Resolution:**
```markdown
# Source: agents/spec-writer.md
{{workflows/specification/write-spec}}

# Gets compiled to:
[entire contents of workflows/specification/write-spec.md]
```

### File Operations

```bash
copy_with_compile(source, dest, config)
# Copy file and compile templates if needed
# Preserves permissions
# Creates parent directories

should_skip_file(path, exclusions)
# Check if file matches exclusion patterns
# Used to skip .git, .DS_Store, etc.

validate_base_installation()
# Verify base install exists
# Checks for required directories and files
```

### User Interaction Functions

```bash
print_section(message)    # Header with colored output
print_status(message)     # Status message (blue)
print_success(message)    # Success message (green)
print_error(message)      # Error message (red)

confirm_action(message)   # Yes/no prompts with defaults
# Returns 0 for yes, 1 for no

parse_bool_flag(current, next_arg)
# Parse boolean CLI flags
# Handles: --flag, --flag true, --flag false
```

### Script Usage Patterns

**Base Installation:**
```bash
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash

# Creates:
# ~/agent-os/config.yml
# ~/agent-os/profiles/
# ~/agent-os/scripts/
```

**Project Installation:**
```bash
~/agent-os/scripts/project-install.sh

# With options:
~/agent-os/scripts/project-install.sh --profile rails --dry-run
~/agent-os/scripts/project-install.sh --claude-code-commands true --use-claude-code-subagents false
```

**Project Update:**
```bash
~/agent-os/scripts/project-update.sh

# Update options:
~/agent-os/scripts/project-update.sh --overwrite-all
~/agent-os/scripts/project-update.sh --overwrite-standards
```

**Create Custom Profile:**
```bash
~/agent-os/scripts/create-profile.sh

# Creates: ~/agent-os/profiles/[profile-name]/
# Can inherit from or copy existing profiles
```

**When Developing Scripts:**
- Use `set -e` (exit on error)
- Use `set -u` (error on undefined variables)
- Source `common-functions.sh` at the start
- Handle errors explicitly with meaningful messages
- Test both with and without config overrides

---

## Configuration System

`config.yml` controls all Agent OS behavior:

```yaml
version: 2.1.1                          # Agent OS version
profile: default                        # Default profile to use

# Feature flags
claude_code_commands: true              # Install to .claude/commands/
agent_os_commands: false                # Install to agent-os/commands/
use_claude_code_subagents: true         # Enable subagent delegation
standards_as_claude_code_skills: false  # Use Skills vs file injection
```

### Configuration Hierarchy

1. **System defaults** - Defined in `config.yml`
2. **CLI overrides** - Passed during installation
3. **Project-specific** - Stored in project's `agent-os/config.yml`

**Example CLI Override:**
```bash
project-install.sh --claude-code-commands false --agent-os-commands true
```

### Key Configuration Flags

| Flag | Purpose | Values |
|------|---------|--------|
| `version` | Agent OS version | Semantic version (2.1.1) |
| `profile` | Default profile to use | Profile name (default, rails, etc.) |
| `claude_code_commands` | Install commands to `.claude/commands/` | true/false |
| `agent_os_commands` | Install commands to `agent-os/commands/` | true/false |
| `use_claude_code_subagents` | Enable subagent delegation | true/false |
| `standards_as_claude_code_skills` | Use Skills feature vs file injection | true/false |

**When Developing:**
- Test with different flag combinations
- Ensure both multi-agent and single-agent modes work
- Update version in `config.yml` when making releases
- Document breaking changes in CHANGELOG.md

---

## Standards Organization

Standards live in `profiles/[profile]/standards/`:

### **global/** - Universal standards:
- `tech-stack.md` - Framework, database, testing tools (template to fill out)
- `coding-style.md` - Formatting, naming conventions
- `conventions.md` - File organization, architecture patterns
- `error-handling.md` - Error handling approaches
- `commenting.md` - When and how to comment
- `validation.md` - Input validation patterns

### **frontend/** - Frontend-specific:
- `components.md` - Component architecture
- `css.md` - CSS/Tailwind conventions
- `responsive.md` - Responsive design approach
- `accessibility.md` - A11y standards

### **backend/** - Backend-specific:
- `api.md` - API design patterns
- `models.md` - Model conventions
- `queries.md` - Database query optimization
- `migrations.md` - Migration best practices

### **testing/** - Test standards:
- `test-writing.md` - Test organization and approach

### Creating New Standards

**For New Languages:**
```bash
# 1. Create feature branch
git checkout -b standards/go-conventions

# 2. Create standard file in appropriate profile
"Create profiles/default/standards/backend/go-conventions.md covering:
- Package organization
- Error handling
- Interface design
- Concurrency patterns
Save it to the file"

# 3. Update tech-stack.md template if needed
"Add Go to the tech-stack.md template with common frameworks"

# 4. Test compilation
~/agent-os/scripts/project-install.sh --dry-run

# 5. Commit
git commit -m "feat(standards): Add Go backend conventions"
```

**For New Categories:**
```bash
# Example: Performance standards
git checkout -b standards/performance

"Create profiles/default/standards/global/performance.md with:
- Profiling approaches
- Optimization guidelines
- Caching strategies
- Load testing practices"

git commit -m "feat(standards): Add performance optimization guidelines"
```

---

## Workflow File Patterns

Workflow files (in `workflows/`) provide step-by-step instructions that agents follow.

### Structure Pattern

```markdown
# [Workflow Name]

## Core Responsibilities
1. [Responsibility 1]
2. [Responsibility 2]

## Workflow

### Step 1: [Action]
[Detailed instructions, often with bash examples or file creation templates]

### Step 2: [Action]
[More instructions with specific requirements]

## Important Constraints
1. [Constraint 1]
2. [Constraint 2]

## Success Criteria
1. [How to verify success]
2. [What outputs should exist]
```

### Key Workflows

**Planning Phase:**
- `planning/create-product-mission.md` - Mission document structure
- `planning/create-product-roadmap.md` - Roadmap creation process
- `planning/create-tech-stack.md` - Tech stack documentation

**Specification Phase:**
- `specification/initialize-spec.md` - Spec folder setup
- `specification/shape-requirements.md` - Requirements gathering
- `specification/write-spec.md` - Spec document template & process
- `specification/verify-spec.md` - Spec completeness check

**Implementation Phase:**
- `implementation/create-tasks-list.md` - Task breakdown methodology
- `implementation/implement-tasks.md` - Implementation guidelines
- `implementation/verify-implementation.md` - Verification process

### When Modifying Workflows

**Before:**
1. Understand the workflow's purpose and where it's used
2. Check which agents/commands reference it (search for `{{workflows/path/file}}`)
3. Test the current version with a real scenario
4. Document current behavior in `.claude-workspace/analysis/`

**During:**
1. Make changes on a feature branch
2. Maintain the workflow pattern (Responsibilities → Steps → Constraints → Success)
3. Keep instructions clear and actionable
4. Include examples where helpful
5. Test both single-agent and multi-agent modes

**After:**
1. Test the modified workflow in a real project
2. Document changes in `.claude-workspace/progress/`
3. Update CHANGELOG.md
4. Create clear commit messages
5. Verify template compilation works

---

## Agent Definition Pattern

Claude Code agents (in `agents/`) follow this frontmatter format:

```markdown
---
name: agent-name
description: Use proactively to [purpose]
tools: Write, Read, Bash, WebFetch
color: purple
model: inherit
---

[Agent role description and capabilities]

{{workflows/relevant/workflow}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

### The 8 Specialized Agents

1. **product-planner** - Plans product mission/roadmap
   - Tools: Write, Read
   - Uses: planning workflows

2. **spec-initializer** - Creates spec folder structure
   - Tools: Write, Bash
   - Uses: specification/initialize-spec

3. **spec-shaper** - Shapes requirements through Q&A
   - Tools: Write, Read
   - Uses: specification/shape-requirements

4. **spec-writer** - Writes spec.md from requirements
   - Tools: Write, Read
   - Uses: specification/write-spec

5. **spec-verifier** - Verifies spec completeness
   - Tools: Read
   - Uses: specification/verify-spec

6. **tasks-list-creator** - Creates tasks.md from spec
   - Tools: Write, Read
   - Uses: implementation/create-tasks-list

7. **implementer** - Implements feature from tasks
   - Tools: Write, Read, Bash, WebFetch
   - Uses: implementation/implement-tasks

8. **implementation-verifier** - Verifies implementation
   - Tools: Read, Bash
   - Uses: implementation/verify-implementation

### Creating New Agents

**Guidelines:**
1. **Single responsibility** - One clear purpose
2. **Minimal tools** - Only what's needed (Write, Read, Bash, WebFetch)
3. **Clear description** - "Use proactively to [purpose]"
4. **Workflow integration** - Reference relevant workflow files
5. **Standards inclusion** - Use conditional blocks for standards
6. **Color coding** - Consistent colors for agent types

**Example Development Flow:**
```bash
# 1. Plan the agent
"Design a new error-recovery agent and save to .claude-workspace/planning/error-recovery-agent.md

Purpose: Analyzes errors during implementation and suggests fixes
Tools needed: Read, Bash (for running tests)
Workflow: Should it be a new workflow or use existing?"

# 2. Create branch
git checkout -b feature/error-recovery-agent

# 3. Create workflow (if new)
"Create profiles/default/workflows/implementation/recover-from-error.md with:
- Error analysis steps
- Common error patterns
- Fix suggestion methodology"

# 4. Create agent definition
"Create profiles/default/agents/error-recovery.md following the pattern:
---
name: error-recovery
description: Use proactively to analyze and recover from implementation errors
tools: Read, Bash
color: red
model: inherit
---

Include the workflow and standards"

# 5. Create single-agent command
"Create profiles/default/commands/single-agent/recover-error.md that uses the workflow"

# 6. Create multi-agent command
"Create profiles/default/commands/multi-agent/recover-error.md that delegates to @agent:error-recovery"

# 7. Test both modes
~/agent-os/scripts/project-install.sh --dry-run --use-claude-code-subagents true
~/agent-os/scripts/project-install.sh --dry-run --use-claude-code-subagents false

# 8. Document in CHANGELOG
"Add to CHANGELOG.md under ## Unreleased"

# 9. Commit
git commit -m "feat(agents): Add error-recovery agent for implementation errors"
```

---

## Important Development Patterns

### Testing Philosophy

Agent OS emphasizes **minimal, focused testing**:
- Write 2-8 tests per task group (not exhaustive)
- Test only critical behaviors
- Run only relevant tests during implementation (not full suite)
- Full test suite runs only during final verification

**Why This Matters for Core Development:**
- Workflows must communicate this philosophy
- Agents must enforce it
- Standards must document it

### File Path Conventions

All Agent OS outputs go in specific locations:
- Product: `agent-os/product/`
- Specs: `agent-os/specs/[spec-name]/`
- Planning: `agent-os/specs/[spec-name]/planning/`
- Verification: `agent-os/specs/[spec-name]/verification/screenshots/`

**When developing workflows:**
- Specify exact paths
- Don't let users choose paths freely
- Consistency enables cross-project patterns

### Spec Document Structure

Specs follow strict template (see `workflows/specification/write-spec.md`):
- Goal, User Stories, Specific Requirements
- Visual Design (if mockups provided)
- Existing Code to Leverage
- Out of Scope

**Key constraint:** Do NOT write actual code in spec.md, only describe requirements.

### Task List Structure

Tasks.md organizes by:
1. **Task groups** - By specialization (Database, API, UI)
2. **Dependencies** - Explicit dependency tracking
3. **Hierarchical tasks** - Parent task + sub-tasks
4. **Acceptance criteria** - Per task group
5. **Checkboxes** - Track completion state

**Example Structure:**
```markdown
## Database Task Group

Dependencies: None

### Task 1: Create User Model
- [ ] Define user schema
- [ ] Add validation rules
- [ ] Create migration

### Task 2: Create Posts Model
- [ ] Define post schema
- [ ] Add foreign key to users
- [ ] Create migration

Acceptance Criteria:
- Models pass validation tests
- Migrations run without errors
```

---

## Understanding Agent OS Conventions

### Commit Style (Observed from CHANGELOG)

Agent OS uses **descriptive, functional commits** rather than conventional commits:

**Their Style:**
```bash
"Add date-checker subagent for accurate date determination"
"Update create-spec instructions to use date-checker subagent"
"Reorganize instruction files into core/ and meta/ subdirectories"
"Enhanced setup scripts to install Claude Code agents"
```

**Pattern:**
- Describes WHAT was done
- Focuses on the feature/change
- Clear and direct
- No type prefixes (feat:, fix:, etc.)

### Your Choice: Adopt Upstream Style or Use Your Own?

**Option A: Match Upstream (Easier for PRs)**
```bash
git commit -m "Add Python testing standards to default profile

- Create standards/testing/python-testing.md
- Include pytest conventions
- Add fixture patterns
- Document in CHANGELOG.md"
```

**Option B: Use Conventional Commits (Better Tracking)**
```bash
git commit -m "feat(standards): Add Python testing standards

- Create standards/testing/python-testing.md
- Include pytest conventions
- Add fixture patterns
- Document in CHANGELOG.md"
```

**Recommendation:**
- Use **conventional commits** in your fork for better tracking
- When creating PRs to upstream, they can squash/rewrite if needed
- Your fork, your rules

### Conventional Commits for Agent OS Development

```
<type>(<scope>): <subject>

<body>
```

**Types:**
- `feat:` - New Agent OS feature (workflow, subagent, standard, profile)
- `fix:` - Bug fix in workflows, agents, or scripts
- `docs:` - Documentation improvements (README, CHANGELOG, guides)
- `refactor:` - Refactoring workflows or scripts without changing behavior
- `test:` - Adding tests or test workflows
- `chore:` - Maintenance (cleanup, repository structure)
- `standards:` - Changes to standards templates
- `workflows:` - Changes to workflow files
- `agents:` - Changes to subagents
- `profiles:` - Changes to profile system
- `scripts:` - Changes to installation/management scripts

**Scopes (optional but helpful):**
- `(workflows)` - Changes to `/workflows`
- `(standards)` - Changes to `/standards`
- `(agents)` - Changes to `/agents`
- `(commands)` - Changes to `/commands`
- `(scripts)` - Changes to `/scripts`
- `(profiles)` - Changes to `/profiles`
- `(config)` - Changes to config.yml

**Examples:**
```bash
# New workflow
git commit -m "feat(workflows): Add database migration workflow

- Create workflows/implementation/create-migration.md
- Include rollback procedures
- Add verification steps"

# Fix script bug
git commit -m "fix(scripts): Correct YAML parsing for arrays

- Fix get_yaml_array() handling of nested arrays
- Add error handling for malformed YAML"

# Improve standards
git commit -m "feat(standards): Add React Native conventions

- Create standards/frontend/react-native.md
- Include platform-specific patterns
- Add performance guidelines"

# Documentation
git commit -m "docs: Update profile system documentation

- Clarify base vs project installation
- Add custom profile creation guide
- Update installation examples"

# New profile
git commit -m "feat(profiles): Add FastAPI profile

- Create profiles/fastapi/ structure
- Include Python backend standards
- Add FastAPI-specific workflows"
```

---

## Development Workflow for Agent OS

### Typical Development Cycle

#### 1. **Understanding Phase** (Use `.claude-workspace/`)
```bash
# Analyze the codebase
"Analyze the profile system architecture and document in .claude-workspace/analysis/profile-system.md"

# Understand template compilation
"Explain how template compilation works in scripts/common-functions.sh and save to .claude-workspace/analysis/template-compilation.md"

# Research patterns
"Find all workflow file patterns and document in .claude-workspace/references/workflow-patterns.md"
```

#### 2. **Planning Phase** (Use `.claude-workspace/planning/`)
```bash
# Design new feature
"I want to add a database migration workflow. Create a design document in .claude-workspace/planning/migration-workflow.md covering:
- When it should be used
- What steps it should include
- How it integrates with existing workflows"

# Plan improvements
"Analyze current script error handling and suggest improvements in .claude-workspace/planning/script-improvements.md"
```

#### 3. **Implementation Phase** (Use feature branches)
```bash
# Create feature branch
git checkout -b feature/migration-workflow

# Implement the workflow
"Create profiles/default/workflows/implementation/create-migration.md following the pattern in other workflow files"

# Create agents (if needed)
"Create profiles/default/agents/migration-creator.md that uses the new workflow"

# Create commands (single-agent)
"Create profiles/default/commands/single-agent/create-migration.md"

# Create commands (multi-agent)
"Create profiles/default/commands/multi-agent/create-migration.md that delegates to @agent:migration-creator"

# Document changes
"Add entry to CHANGELOG.md under '## Unreleased'"
```

#### 4. **Testing Phase** (Use `.claude-workspace/progress/`)
```bash
# Test compilation
~/agent-os/scripts/project-install.sh --dry-run

# Test in a real project
__zoxide_cd ~/test-project
~/agent-os/scripts/project-install.sh

# Test the workflow
"Use the /create-migration command to create a test migration"

# Document results
"Save test results to .claude-workspace/progress/2025-12-03-migration-workflow-testing.md"

# Iterate if needed
"Refine the workflow based on test results"
```

#### 5. **Review & Commit Phase**
```bash
# Review changes
git status
git diff

# Commit with clear message
git add profiles/default/workflows/implementation/create-migration.md
git add profiles/default/agents/migration-creator.md
git add profiles/default/commands/single-agent/create-migration.md
git add profiles/default/commands/multi-agent/create-migration.md
git add CHANGELOG.md

git commit -m "feat(workflows): Add database migration workflow

- Create create-migration.md with step-by-step process
- Add migration-creator agent for multi-agent mode
- Create commands for both modes
- Include rollback procedures
- Update CHANGELOG.md"

# Push to your fork
git push origin feature/migration-workflow
```

#### 6. **PR Phase**
```bash
# Create PR to your fork's main
gh pr create --title "feat(workflows): Add database migration workflow" --body "## Summary
Adds a new workflow for creating and managing database migrations.

## Changes
- New workflow: workflows/implementation/create-migration.md
- New agent: agents/migration-creator.md
- New commands: commands/single-agent/create-migration.md, commands/multi-agent/create-migration.md
- Updated: CHANGELOG.md

## Test Plan
Tested with Rails and Django projects:
- Migration creation works in both modes
- Rollback procedures are clear
- Verification steps catch errors

## Breaking Changes
None - additive feature only"

# After merge to your main, optionally PR to upstream
```

---

## Customization Points

When extending Agent OS, these are the main customization points:

### 1. **Create Custom Profile**
```bash
~/agent-os/scripts/create-profile.sh

# Creates: ~/agent-os/profiles/[profile-name]/
# Can inherit from or copy existing profiles
# Allows project-type-specific standards
```

### 2. **Customize Standards**
Edit profile's `standards/` files:
- `global/` - Universal standards
- `frontend/` - Frontend-specific
- `backend/` - Backend-specific
- `testing/` - Test standards

### 3. **Modify Workflows**
Edit profile's `workflows/` files:
- `planning/` - Product planning workflows
- `specification/` - Spec creation workflows
- `implementation/` - Implementation workflows

### 4. **Add Agents**
Create new agent definitions in `agents/`:
- Follow the frontmatter format
- Reference relevant workflows
- Include standards (conditionally)

### 5. **Create Commands**
Add to `commands/` with both variants:
- `single-agent/` - For Cursor/Windsurf
- `multi-agent/` - For Claude Code with subagents

### 6. **Update Config**
Modify `config.yml`:
- Set new profile as default
- Adjust feature flags
- Update version number (for releases)

---

## Version & Upgrade Process

Current version: **2.1.1** (stored in config.yml)

### Version Format

Semantic versioning: `MAJOR.MINOR.PATCH`
- **MAJOR** - Breaking changes (e.g., 1.x → 2.x)
- **MINOR** - New features (e.g., 2.1.x → 2.2.x)
- **PATCH** - Bug fixes (e.g., 2.1.1 → 2.1.2)

### Upgrade Process

Users upgrade via `project-update.sh`:
- Compares versions between base and project
- Shows what will change before proceeding
- Preserves customizations by default
- Options to selectively overwrite

**Update Options:**
```bash
~/agent-os/scripts/project-update.sh                    # Safe update
~/agent-os/scripts/project-update.sh --overwrite-all    # Full overwrite
~/agent-os/scripts/project-update.sh --overwrite-standards  # Just standards
```

### When Releasing a Version

1. Update `config.yml` version number
2. Update CHANGELOG.md with release date
3. Create git tag: `git tag v2.1.2`
4. Push tag: `git push origin v2.1.2`
5. Create GitHub release with notes

---

## Common Gotchas

When developing Agent OS, watch out for:

### 1. **Template Tags Only Work During Installation**
- They're compiled **once**, not dynamic
- Changes to workflows/standards require project update
- Test both template source and compiled output

### 2. **Profiles Are Copied, Not Referenced**
- Project installations are **self-contained**
- No external dependencies after installation
- Updates don't automatically propagate

### 3. **Standards Injection Depends on Config**
- `standards_as_claude_code_skills` changes behavior
- Test with flag both true and false
- Agents must handle both scenarios

### 4. **Single vs Multi-Agent Modes**
- Commands exist in **both variants**
- Installation picks one based on config
- Both must work for the same workflow

### 5. **Bash Script Strictness**
- Scripts use `set -e` (exit on error)
- Handle errors explicitly
- Test error scenarios
- Provide meaningful error messages

### 6. **YAML Parsing Edge Cases**
- Tabs vs spaces
- Quote handling
- Nested structures
- Use `get_yaml_value()` function

### 7. **Path Assumptions**
- Don't assume `~/agent-os` location
- Use `validate_base_installation()`
- Support custom base install locations

---

## Code Review Process

### Before Creating a PR

1. **Self-review your changes**
   ```bash
   git diff main...HEAD
   ```

2. **Ensure all changes are committed**
   ```bash
   git status
   ```

3. **Test your changes thoroughly**
   - Test template compilation: `--dry-run`
   - Test both agent modes
   - Test in a real project
   - Document tests in `.claude-workspace/progress/`

4. **Update CHANGELOG.md**
   - Add your changes to the "Unreleased" section
   - Follow existing format
   - Be specific about what changed

5. **Clear commit messages**
   - Use conventional commits or descriptive style
   - Include context in the body
   - Reference issues if applicable

### Creating a PR

**To Your Fork's Main:**
```bash
gh pr create --title "feat: [clear title]" --body "## Summary
[What this PR does]

## Changes
- [List key changes with file paths]

## Test Plan
- [How you tested]
- [Which modes you tested]
- [Results]

## Breaking Changes
[None, or describe them with migration path]

## Related Issues
Fixes #[issue] (if applicable)
"
```

**To Upstream (buildermethods/agent-os):**
- Your fork's style may differ from upstream
- Be prepared to adjust to their preferences
- Focus on value of the change
- Be respectful of maintainer's time
- Ensure backward compatibility

### After Merge

**In Your Fork:**
```bash
# Switch to main
git checkout main

# Pull changes
git pull origin main

# Delete feature branch
git branch -d feature/branch-name
git push origin --delete feature/branch-name

# Celebrate! 🎉
```

**If Merged Upstream:**
```bash
# Add upstream remote (if not already)
git remote add upstream https://github.com/buildermethods/agent-os.git

# Fetch upstream changes
git fetch upstream

# Merge into your fork
git checkout main
git merge upstream/main

# Push to your fork
git push origin main
```

---

## Testing Agent OS Changes

### Testing Template Compilation

**Dry Run:**
```bash
~/agent-os/scripts/project-install.sh --dry-run

# Shows what would be installed without actually installing
# Useful for verifying template compilation
```

### Testing Workflows

**Method 1: Direct Reference**
```
# In Claude Code, reference the workflow directly
"Follow the workflow at profiles/default/workflows/implementation/[workflow].md"
```

**Method 2: Install in Test Project**
```bash
# Navigate to test project
__zoxide_cd ~/test-project

# Install your modified Agent OS
~/agent-os/scripts/project-install.sh

# Test the workflow via command
"/[command-name]"

# Check outputs
ls agent-os/specs/
```

### Testing Agents

**Multi-Agent Mode:**
```bash
# Install with subagents enabled
~/agent-os/scripts/project-install.sh --use-claude-code-subagents true

# Test agent delegation
"Use @agent:[agent-name] to [task]"
```

**Single-Agent Mode:**
```bash
# Install without subagents
~/agent-os/scripts/project-install.sh --use-claude-code-subagents false

# Test command directly
"/[command-name]"
```

### Testing Scripts

**Unit Testing Pattern:**
```bash
# Test specific functions
source scripts/common-functions.sh

# Test YAML parsing
get_yaml_value "config.yml" "version" "unknown"

# Test template compilation (create test files)
compile_template "test-source.md" "test-output.md" "--use-claude-code-subagents=true"
```

**Integration Testing:**
```bash
# Full installation test
__zoxide_cd ~/test-project
rm -rf agent-os/ .claude/  # Clean slate

~/agent-os/scripts/project-install.sh

# Verify installation
ls agent-os/
ls .claude/commands/agent-os/
ls .claude/agents/agent-os/
```

---

## Troubleshooting

### Hook is Blocking Me

**Problem:** PreToolUse hook blocks an action you want to perform.

**Solutions:**

1. **You're on main** → Create a feature branch first
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Legitimate exception** → Verify you're not accidentally on a protected branch

### Template Compilation Fails

**Problem:** `compile_template()` errors or produces wrong output.

**Debug:**
```bash
# Add debug output to common-functions.sh
set -x  # Enable trace mode

# Run compilation
compile_template "source.md" "dest.md" "--flag=value"

# Check for:
# - Missing source files
# - Malformed template tags
# - Unclosed conditional blocks
```

### Script Errors

**Problem:** Installation scripts fail with cryptic errors.

**Debug:**
```bash
# Run with verbose output
bash -x ~/agent-os/scripts/project-install.sh

# Check:
# - YAML syntax in config.yml
# - File permissions
# - Path assumptions
# - Missing directories
```

### Git Sync Issues

**Problem:** Your fork is behind/ahead of upstream.

**Solution:**
```bash
# Fetch both remotes
git fetch origin
git fetch upstream

# Check status
git log --oneline --graph --all

# Sync as needed
git merge upstream/main
# or
git rebase upstream/main
```

### Testing in Real Projects

**Problem:** How do I test changes without breaking my workflow?

**Solution:**

**Option 1: Use a dedicated test project**
```bash
mkdir ~/agent-os-test-project
__zoxide_cd ~/agent-os-test-project
~/agent-os/scripts/project-install.sh
```

**Option 2: Backup then test**
```bash
__zoxide_cd ~/real-project
cp -r agent-os/ agent-os.backup/
~/agent-os/scripts/project-update.sh --overwrite-all
# Test...
# If problems: mv agent-os.backup/ agent-os/
```

**Option 3: Git branch in the project**
```bash
__zoxide_cd ~/real-project
git checkout -b test-new-agent-os
~/agent-os/scripts/project-update.sh
# Test...
# If good: git commit; if bad: git checkout main
```

---

## Tools & Extensions

### Required Tools

- Git (version control)
- Bash (running and developing scripts)
- Text editor (for markdown/script/YAML editing)
- Claude Code or Cursor (for testing workflows and agents)

### Recommended

- GitHub CLI (`gh`) - for PR creation and management
- `tree` - visualizing directory structure
- `bat` - better file viewing with syntax highlighting
- `ripgrep` (`rg`) - faster code search
- `yq` - YAML processor (alternative to custom parsing)

### Optional but Useful

- `shellcheck` - Linting bash scripts
- `markdownlint` - Linting markdown files
- `yamllint` - Linting YAML files
- `jq` - JSON processing (if adding JSON support)

---

## Quick Reference

### Common Commands

```bash
# Navigate to repo (with zoxide)
__zoxide_cd ~/projects/agent-os

# Create feature branch
git checkout -b feature/new-workflow

# Check status
git status

# View changes
git diff

# Stage changes
git add [files]

# Commit
git commit -m "feat(workflows): Add new workflow"

# Push to your fork
git push origin feature/new-workflow

# Create PR
gh pr create --title "feat: New workflow"

# Sync with upstream
git fetch upstream
git merge upstream/main

# Test installation
~/agent-os/scripts/project-install.sh --dry-run
```

### Key Files to Know

| File/Directory | Purpose |
|----------------|---------|
| `config.yml` | Version & configuration |
| `CHANGELOG.md` | Version history - update this! |
| `README.md` | Main documentation |
| `profiles/default/` | Default profile templates |
| `profiles/default/workflows/` | Workflow instruction files |
| `profiles/default/standards/` | Standard templates |
| `profiles/default/agents/` | Agent definitions |
| `profiles/default/commands/` | Slash commands (both modes) |
| `scripts/common-functions.sh` | Shared script functions |
| `scripts/base-install.sh` | Base installation |
| `scripts/project-install.sh` | Project installation |
| `scripts/project-update.sh` | Project update |
| `scripts/create-profile.sh` | Profile creation |

### Template Tags Reference

| Tag | Purpose | Example |
|-----|---------|---------|
| `{{workflows/path/file}}` | Inject workflow content | `{{workflows/planning/create-product-mission}}` |
| `{{standards/*}}` | Inject all standards | All files in standards/ |
| `{{standards/global/*}}` | Inject global standards | Just global/ directory |
| `{{UNLESS flag}}...{{ENDUNLESS flag}}` | Conditional block | `{{UNLESS standards_as_claude_code_skills}}...{{ENDUNLESS}}` |

### Configuration Flags Reference

| Flag | Default | Purpose |
|------|---------|---------|
| `claude_code_commands` | true | Install to .claude/commands/ |
| `agent_os_commands` | false | Install to agent-os/commands/ |
| `use_claude_code_subagents` | true | Enable subagent mode |
| `standards_as_claude_code_skills` | false | Use Skills vs injection |

---

## Questions or Issues?

### Understanding Agent OS

- Analyze workflows in `.claude-workspace/analysis/`
- Study agent patterns in existing agents
- Review CHANGELOG.md for feature evolution
- Examine scripts to understand installation
- Ask Claude to explain specific files

### Development Help

- Check `.claude-workspace/references/` for patterns
- Review similar features for guidance
- Test in isolation before integration
- Document learnings in `.claude-workspace/progress/`
- Search CHANGELOG.md for similar features

### Contributing Upstream

- Review upstream's recent commits
- Follow their conventions when contributing
- Be patient and respectful
- Focus on value of the contribution
- Test thoroughly before PR
- Document breaking changes clearly

---

## Summary

**You Are:**
- Contributing to Agent OS core
- Improving a framework/template repository
- Building features for all users
- Maintaining a fork with your enhancements

**This Means:**
- Feature branch workflow for quality
- Clear commit messages for tracking
- Testing changes thoroughly
- Documenting in CHANGELOG.md
- Using `.claude-workspace/` for development
- Understanding the profile system
- Testing both agent modes
- Ensuring template compilation works

**Your Workflow:**
1. Understand → `.claude-workspace/analysis/`
2. Plan → `.claude-workspace/planning/`
3. Branch → `feature/your-feature`
4. Implement → Modify profiles, scripts, config
5. Test → Both agent modes, template compilation
6. Document → CHANGELOG.md, `.claude-workspace/progress/`
7. Commit → Clear, descriptive messages
8. PR → To your main, then optionally upstream

**Remember:**
- Use `__zoxide_cd` for navigation
- Protected main branch = quality control
- Test both single-agent and multi-agent modes
- Verify template compilation with `--dry-run`
- Document changes in CHANGELOG.md
- Your fork, your rules (but consider upstream compatibility)
- Profiles are copied, not referenced
- Template tags compile once during installation

---

**Ready to improve Agent OS! 🚀**
