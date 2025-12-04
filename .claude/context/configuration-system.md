# Configuration System

Agent OS uses a hierarchical configuration system based on `config.yml` files that control installation behavior, agent modes, and standards handling. Configuration defaults are set in the base installation and can be overridden per-project via CLI flags during installation.

The configuration system supports multiple coding tools (Claude Code, Cursor, Windsurf) and allows fine-grained control over where files are installed and how templates are compiled.

---

## Overview

###Configuration Flow

```
1. Base Installation Config
   ~/agent-os/config.yml
   (Global defaults)
        ↓
2. CLI Overrides (Optional)
   --profile rails
   --use-claude-code-subagents false
        ↓
3. Project Installation
   Compiled with merged config
        ↓
4. Project Config (Created)
   project/agent-os/config.yml
   (Records what was used)
```

**Key Principle:** Base config sets defaults → CLI flags override → Project gets snapshot of final config

---

## config.yml Structure

### Complete File

`~/agent-os/config.yml`:

```yaml
version: 2.1.2                          # Agent OS version
base_install: true                      # Is this a base installation?

# Installation locations
claude_code_commands: true              # Install to .claude/commands/
agent_os_commands: false                # Install to agent-os/commands/

# Agent modes
use_claude_code_subagents: true         # Enable subagent delegation

# Standards handling
standards_as_claude_code_skills: false  # Use Skills vs file injection

# Profile
profile: default                        # Default profile to use
```

### Sections

**Version Management:**
- `version` - Current Agent OS version (semver)
- `base_install` - Marks this as base installation (vs project)

**Installation Locations:**
- `claude_code_commands` - Install commands to `.claude/commands/agent-os/`
- `agent_os_commands` - Install commands to `agent-os/commands/`

**Agent Modes:**
- `use_claude_code_subagents` - Enable/disable subagent delegation

**Standards Handling:**
- `standards_as_claude_code_skills` - Use Skills feature vs inline injection

**Profile Selection:**
- `profile` - Which profile to use by default

---

## Configuration Hierarchy

### Layer 1: System Defaults (Base)

**Location:** `~/agent-os/config.yml`

**Purpose:** Global defaults for all project installations

**Created by:** `base-install.sh`

**Example:**
```yaml
version: 2.1.2
claude_code_commands: true
agent_os_commands: false
use_claude_code_subagents: true
standards_as_claude_code_skills: false
profile: default
```

**When it matters:** Every `project-install.sh` reads these defaults first

### Layer 2: CLI Overrides (Optional)

**Provided via:** Command-line flags during `project-install.sh`

**Purpose:** Override defaults for specific project installation

**Example:**
```bash
~/agent-os/scripts/project-install.sh \
  --profile rails \
  --use-claude-code-subagents false \
  --standards-as-claude-code-skills true
```

**When it matters:** Overrides base config for this installation only

### Layer 3: Project Config (Snapshot)

**Location:** `project/agent-os/config.yml`

**Purpose:** Records configuration used for this project

**Created by:** `project-install.sh` (automatically)

**Example:**
```yaml
version: 2.1.2
profile: rails
claude_code_commands: true
agent_os_commands: false
use_claude_code_subagents: false  # Overridden via CLI
standards_as_claude_code_skills: true  # Overridden via CLI
```

**When it matters:** `project-update.sh` uses this to preserve original settings

---

## Flag Reference

### version

**Type:** String (semver format)

**Default:** Set by Agent OS release

**Purpose:** Track which Agent OS version is installed

**Example:**
```yaml
version: 2.1.2
```

**Usage:**
- Used by update scripts to compare versions
- Shown in installation output
- Helps diagnose compatibility issues

**Updated:**
- Automatically on each Agent OS release
- Don't manually change unless you know what you're doing

---

### base_install

**Type:** Boolean

**Default:** `true` (in base), not set in projects

**Purpose:** Distinguish base installation from project installation

**Example:**
```yaml
base_install: true
```

**Usage:**
- Only present in `~/agent-os/config.yml`
- Not copied to project installations
- Used by scripts to detect installation type

**When true:** This is the base installation directory

**When absent:** This is a project installation

---

### claude_code_commands

**Type:** Boolean

**Default:** `true`

**Purpose:** Install commands to `.claude/commands/agent-os/` directory

**Example:**
```yaml
claude_code_commands: true
```

**When true:**
```
project/
└── .claude/
    └── commands/
        └── agent-os/
            ├── plan-product.md
            ├── shape-spec.md
            ├── write-spec.md
            ├── create-tasks.md
            ├── implement-tasks.md
            └── orchestrate-tasks.md
```

**When false:**
- Commands not installed to `.claude/`
- Usually combined with `agent_os_commands: true`

**CLI Override:**
```bash
~/agent-os/scripts/project-install.sh --claude-code-commands false
```

**Use case:** Using Claude Code for Agent OS commands

---

### agent_os_commands

**Type:** Boolean

**Default:** `false`

**Purpose:** Install commands to `agent-os/commands/` directory

**Example:**
```yaml
agent_os_commands: true
```

**When true:**
```
project/
└── agent-os/
    └── commands/
        ├── plan-product.md
        ├── shape-spec.md
        ├── write-spec.md
        ├── create-tasks.md
        ├── implement-tasks.md
        └── orchestrate-tasks.md
```

**When false:**
- Commands not installed to `agent-os/commands/`
- Usually combined with `claude_code_commands: true`

**CLI Override:**
```bash
~/agent-os/scripts/project-install.sh --agent-os-commands true
```

**Use case:** Using Cursor, Windsurf, or other tools that scan `agent-os/commands/`

**Note:** You can set both `claude_code_commands` and `agent_os_commands` to `true` to install commands in both locations.

---

### use_claude_code_subagents

**Type:** Boolean

**Default:** `true`

**Purpose:** Enable multi-agent mode with subagent delegation

**Example:**
```yaml
use_claude_code_subagents: true
```

**When true (Multi-Agent Mode):**
- Installs agents to `.claude/agents/agent-os/`
- Commands use `@agent:name` delegation
- Better context efficiency
- Requires Claude Code

```
project/
└── .claude/
    ├── commands/agent-os/      # Delegates to agents
    │   └── write-spec.md       # "Use @agent:spec-writer"
    └── agents/agent-os/        # Agents installed here
        └── spec-writer.md      # Contains workflow
```

**When false (Single-Agent Mode):**
- Agents not installed
- Commands contain full workflows inline
- Lower token usage
- Works with any tool

```
project/
└── .claude/
    └── commands/agent-os/
        └── write-spec.md       # Contains full workflow inline
```

**CLI Override:**
```bash
~/agent-os/scripts/project-install.sh --use-claude-code-subagents false
```

**Dependencies:**
- Requires `claude_code_commands: true` to have effect
- If `claude_code_commands: false`, this flag is ignored

**Use case:** Claude Code users wanting specialized subagents vs. single-agent mode for simpler setup

---

### standards_as_claude_code_skills

**Type:** Boolean

**Default:** `false`

**Purpose:** Use Claude Code Skills feature for standards instead of inline injection

**Example:**
```yaml
standards_as_claude_code_skills: true
```

**When false (Inline Injection):**
- Standards injected into agent/command files
- `{{standards/*}}` template tags compile to full content
- Larger file sizes, but everything in one place

**Agent file after compilation:**
```markdown
---
name: implementer
---

{{workflows/implementation/implement-tasks}}

# Coding Standards

[entire contents of all standards files injected here]
```

**When true (Skills Mode):**
- Standards omitted from agent/command files
- `{{UNLESS standards_as_claude_code_skills}}...{{ENDUNLESS}}` blocks excluded
- Agent reads standards via Skills feature
- Smaller file sizes, standards loaded on-demand

**Agent file after compilation:**
```markdown
---
name: implementer
---

{{workflows/implementation/implement-tasks}}

# Coding Standards

[this section is empty - agent uses Skills to read standards]
```

**CLI Override:**
```bash
~/agent-os/scripts/project-install.sh --standards-as-claude-code-skills true
```

**Dependencies:**
- Requires `claude_code_commands: true`
- Automatically treated as `false` if `claude_code_commands: false`

**Use case:** Claude Code users wanting on-demand standards loading vs. inline everything

---

### profile

**Type:** String

**Default:** `default`

**Purpose:** Select which profile to install into project

**Example:**
```yaml
profile: rails
```

**Available Values:**
- `default` - Generic profile (ships with Agent OS)
- `rails` - Ruby on Rails profile (if created)
- `nextjs` - Next.js profile (if created)
- `django` - Django profile (if created)
- Any custom profile name you've created

**CLI Override:**
```bash
~/agent-os/scripts/project-install.sh --profile rails
```

**What it does:**
- Determines which `~/agent-os/profiles/[name]/` directory to use
- Different profiles have different agents, workflows, standards
- Allows framework-specific customization

**Use case:** Installing different Agent OS configurations for different project types

---

## Common Configuration Patterns

### Pattern 1: Claude Code Only (Default)

**Use case:** Using Claude Code exclusively

```yaml
claude_code_commands: true
agent_os_commands: false
use_claude_code_subagents: true
standards_as_claude_code_skills: false
profile: default
```

**Result:**
- Commands in `.claude/commands/agent-os/`
- Agents in `.claude/agents/agent-os/` (delegates)
- Standards injected inline
- Multi-agent mode enabled

---

### Pattern 2: Cursor/Windsurf Only

**Use case:** Using Cursor, Windsurf, or other tools

```yaml
claude_code_commands: false
agent_os_commands: true
use_claude_code_subagents: false
standards_as_claude_code_skills: false
profile: default
```

**Result:**
- Commands in `agent-os/commands/`
- No agents (single-agent mode)
- Standards injected inline
- Everything in command files

---

### Pattern 3: Both Tools

**Use case:** Team uses different tools

```yaml
claude_code_commands: true
agent_os_commands: true
use_claude_code_subagents: true
standards_as_claude_code_skills: false
profile: default
```

**Result:**
- Commands in **both** `.claude/commands/agent-os/` and `agent-os/commands/`
- Agents in `.claude/agents/agent-os/`
- Claude Code users get multi-agent mode
- Other tool users get single-agent commands

---

### Pattern 4: Skills Mode

**Use case:** Claude Code with on-demand standards loading

```yaml
claude_code_commands: true
agent_os_commands: false
use_claude_code_subagents: true
standards_as_claude_code_skills: true
profile: default
```

**Result:**
- Commands in `.claude/commands/agent-os/`
- Agents in `.claude/agents/agent-os/`
- Standards **not** injected (loaded via Skills)
- Smaller agent files

---

### Pattern 5: Custom Profile

**Use case:** Rails project with Ruby-specific standards

```yaml
claude_code_commands: true
agent_os_commands: false
use_claude_code_subagents: true
standards_as_claude_code_skills: false
profile: rails
```

**Result:**
- Uses `~/agent-os/profiles/rails/` instead of `default/`
- All Rails-specific workflows and standards
- Still in Claude Code multi-agent mode

---

## CLI Overrides

### Override Syntax

```bash
~/agent-os/scripts/project-install.sh [options]
```

### Available Flags

**Profile Selection:**
```bash
--profile NAME
```

**Installation Locations:**
```bash
--claude-code-commands true|false
--agent-os-commands true|false
```

**Agent Mode:**
```bash
--use-claude-code-subagents true|false
```

**Standards Handling:**
```bash
--standards-as-claude-code-skills true|false
```

**Other:**
```bash
--dry-run                    # Preview without installing
```

### Override Examples

**Example 1: Rails project, single-agent mode**
```bash
~/agent-os/scripts/project-install.sh \
  --profile rails \
  --use-claude-code-subagents false
```

**Example 2: Cursor tool, Next.js profile**
```bash
~/agent-os/scripts/project-install.sh \
  --profile nextjs \
  --claude-code-commands false \
  --agent-os-commands true
```

**Example 3: Skills mode with custom profile**
```bash
~/agent-os/scripts/project-install.sh \
  --profile django \
  --standards-as-claude-code-skills true
```

**Example 4: Both tools, default profile**
```bash
~/agent-os/scripts/project-install.sh \
  --claude-code-commands true \
  --agent-os-commands true
```

### Precedence

CLI flags **override** base config:

**Base config:**
```yaml
use_claude_code_subagents: true
profile: default
```

**CLI override:**
```bash
~/agent-os/scripts/project-install.sh \
  --use-claude-code-subagents false \
  --profile rails
```

**Result:** Uses `false` and `rails` (CLI wins)

---

## Troubleshooting Configuration

### Commands Not Found

**Symptom:** `/plan-product` command not recognized

**Check 1: Installation location**
```bash
# If using Claude Code, check .claude/commands/
ls .claude/commands/agent-os/

# If using other tools, check agent-os/commands/
ls agent-os/commands/
```

**Solution:** Verify `claude_code_commands` or `agent_os_commands` is `true`

**Check 2: Profile installation**
```bash
# Verify installation completed
cat agent-os/config.yml
```

**Solution:** Re-run installation if config.yml missing

---

### Wrong Installation Location

**Symptom:** Commands installed to wrong directory

**Check configuration:**
```bash
cat ~/agent-os/config.yml | grep commands
```

**Solution:** Override during installation:
```bash
~/agent-os/scripts/project-install.sh --claude-code-commands true
```

---

### Agents Not Available

**Symptom:** `@agent:spec-writer` not found

**Check 1: Subagents enabled**
```bash
cat agent-os/config.yml | grep subagents
```

**If false:** Subagents disabled, commands run in single-agent mode

**Solution:** Reinstall with subagents:
```bash
~/agent-os/scripts/project-install.sh --use-claude-code-subagents true
```

**Check 2: Claude Code commands enabled**
```bash
cat agent-os/config.yml | grep claude_code_commands
```

**If false:** Subagents require Claude Code commands

**Solution:** Enable both:
```bash
~/agent-os/scripts/project-install.sh \
  --claude-code-commands true \
  --use-claude-code-subagents true
```

---

### Standards Missing

**Symptom:** No standards content in agent files

**Check Skills mode:**
```bash
cat agent-os/config.yml | grep skills
```

**If true:** Standards loaded via Skills (not inline)

**If you want inline:** Reinstall:
```bash
~/agent-os/scripts/project-install.sh --standards-as-claude-code-skills false
```

---

### Wrong Profile Installed

**Symptom:** Got default profile instead of rails

**Check project config:**
```bash
cat agent-os/config.yml | grep profile
```

**Solution:** Reinstall with correct profile:
```bash
~/agent-os/scripts/project-install.sh --profile rails
```

---

## Updating Configuration

### Change Configuration After Installation

**Cannot directly change** - configuration is compiled into files during installation.

**To change:**
1. Re-run `project-install.sh` with new flags
2. Or use `project-update.sh` (preserves customizations)

**Example: Switch to Skills mode**
```bash
~/agent-os/scripts/project-update.sh \
  --standards-as-claude-code-skills true \
  --overwrite-agents
```

### Preserve vs. Overwrite

**Update script behavior:**
- Reads current `project/agent-os/config.yml`
- Applies new flags
- Preserves customizations by default
- Overwrite flags force replacement

**Selective updates:**
```bash
# Update only agents with new config
~/agent-os/scripts/project-update.sh \
  --use-claude-code-subagents false \
  --overwrite-agents

# Update only commands
~/agent-os/scripts/project-update.sh \
  --profile rails \
  --overwrite-commands
```

---

## Configuration Best Practices

### 1. Set Base Defaults Once

**Configure `~/agent-os/config.yml` for your most common setup:**

```yaml
# If you primarily use Claude Code
claude_code_commands: true
use_claude_code_subagents: true
standards_as_claude_code_skills: false

# Default to your most-used profile
profile: default
```

Then most installations just work:
```bash
cd ~/project && ~/agent-os/scripts/project-install.sh
```

### 2. Override for Exceptions

**Use CLI flags for project-specific needs:**

```bash
# Rails project needing Rails profile
~/agent-os/scripts/project-install.sh --profile rails

# Cursor user needing different location
~/agent-os/scripts/project-install.sh \
  --claude-code-commands false \
  --agent-os-commands true
```

### 3. Document Project Decisions

**Add comment to project's config.yml:**

```yaml
# This project uses Skills mode because of large standards files
standards_as_claude_code_skills: true
```

### 4. Test with Dry Run

**Preview configuration before installing:**

```bash
~/agent-os/scripts/project-install.sh \
  --profile rails \
  --standards-as-claude_code_skills true \
  --dry-run
```

Shows what would be installed without making changes.

---

## Quick Reference

### Configuration Files

```
Base:    ~/agent-os/config.yml
Project: project/agent-os/config.yml
```

### Key Flags

```yaml
claude_code_commands: true|false         # .claude/commands/
agent_os_commands: true|false            # agent-os/commands/
use_claude_code_subagents: true|false    # Multi-agent mode
standards_as_claude_code_skills: true|false  # Skills vs inline
profile: default|rails|nextjs|...        # Which profile
```

### CLI Override Format

```bash
~/agent-os/scripts/project-install.sh --flag-name value
```

### Common Commands

```bash
# Install with defaults
~/agent-os/scripts/project-install.sh

# Install with profile
~/agent-os/scripts/project-install.sh --profile rails

# Install for Cursor
~/agent-os/scripts/project-install.sh \
  --claude-code-commands false \
  --agent-os-commands true

# Preview installation
~/agent-os/scripts/project-install.sh --dry-run

# Update with new config
~/agent-os/scripts/project-update.sh --overwrite-all
```

---

## Related Documentation

- **[profile-system.md](profile-system.md)** - Three-tier architecture and profile creation
- **[template-system.md](template-system.md)** - How config flags affect template compilation
- **[agent-modes.md](agent-modes.md)** - Multi-agent vs single-agent details
- **[script-architecture.md](script-architecture.md)** - How scripts read and use configuration
- **[agent-os-architecture.md](agent-os-architecture.md)** - Complete architecture reference
