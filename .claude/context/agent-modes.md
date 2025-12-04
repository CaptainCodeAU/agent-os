# Agent Modes

Agent OS supports two distinct agent modes that determine how commands execute workflows: **Multi-Agent Mode** (Claude Code with subagents) and **Single-Agent Mode** (Cursor, Windsurf, and other tools). Each mode has different architecture, benefits, and tradeoffs.

When you install Agent OS into a project, the `use_claude_code_subagents` configuration flag determines which mode to use. You must maintain **both modes** when developing Agent OS features to ensure compatibility across all AI coding tools.

---

## Overview

### What Are Agent Modes?

**Agent modes** define how workflow execution is organized:

**Multi-Agent Mode:**
- Commands **delegate** to specialized subagents
- Each subagent loads only what it needs
- Better context efficiency
- Requires Claude Code

**Single-Agent Mode:**
- Commands **contain** full workflows inline
- Main agent executes everything directly
- Lower token usage per invocation
- Works with any AI coding tool

### Why Two Modes?

**Tool Compatibility:**
- Claude Code supports subagent delegation (`@agent:name`)
- Cursor, Windsurf, and others don't support subagents
- Agent OS works with both by providing two command variants

**Different Optimization Goals:**
- Multi-agent: Optimize for context efficiency (each agent loads less)
- Single-agent: Optimize for simplicity (everything in one file)

**User Choice:**
- Some prefer specialized subagents
- Some prefer simpler single-agent execution
- Configuration flag lets users choose

---

## Multi-Agent Mode (Claude Code)

### When to Use

**Tool:** Claude Code only

**Configuration:**
```yaml
claude_code_commands: true
use_claude_code_subagents: true
```

**Use when:**
- Using Claude Code as your AI coding tool
- Want specialized subagents for different tasks
- Prefer context efficiency over token usage
- Working on complex workflows that benefit from specialization

###Architecture

```
User: /write-spec
    ↓
Command (write-spec.md in .claude/commands/agent-os/)
    - Minimal logic
    - Delegates to subagent
    ↓
    @agent:spec-writer
    ↓
Subagent (spec-writer.md in .claude/agents/agent-os/)
    - Contains full workflow
    - Contains standards (if not using Skills)
    - Executes all steps
    ↓
Returns result to command
    ↓
Command continues or finishes
```

### Directory Structure

**When `use_claude_code_subagents: true`:**

```
project/
├── .claude/
│   ├── commands/agent-os/              # Entry points (delegate)
│   │   ├── plan-product.md
│   │   ├── shape-spec.md
│   │   ├── write-spec.md              # Example below
│   │   ├── create-tasks.md
│   │   ├── implement-tasks.md
│   │   └── orchestrate-tasks.md
│   │
│   └── agents/agent-os/                # Specialized workers
│       ├── product-planner.md
│       ├── spec-initializer.md
│       ├── spec-shaper.md
│       ├── spec-writer.md             # Example below
│       ├── spec-verifier.md
│       ├── tasks-list-creator.md
│       ├── implementer.md
│       └── implementation-verifier.md
│
└── agent-os/
    ├── workflows/                      # Reference (not used directly)
    └── standards/                      # Reference (not used directly)
```

### Example: Write Spec Command

**Command file** (`.claude/commands/agent-os/write-spec.md`):

```markdown
# Write Specification

Use this command to transform shaped requirements or clear ideas into a formal specification document.

## What This Command Does

Delegates to the spec-writer agent to create a complete specification following Agent OS standards.

## Usage

Run this command when you have:
- Shaped requirements from `/shape-spec`
- Or clear understanding of what to build

## Execution

@agent:spec-writer

Create a formal specification document following Agent OS structure.
```

**Agent file** (`.claude/agents/agent-os/spec-writer.md`):

```markdown
---
name: spec-writer
description: Use proactively to write formal specification documents
tools: Write, Read
color: cyan
model: inherit
---

# Spec Writer

I write formal specification documents following Agent OS standards.

{{workflows/specification/write-spec}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**Flow:**
1. User runs `/write-spec`
2. Command delegates to `@agent:spec-writer`
3. Spec-writer agent loads workflow and standards
4. Agent executes workflow steps
5. Returns result to command
6. Command reports completion

### Benefits

**Context Efficiency:**
- Each subagent loads only what it needs
- Main agent doesn't load unnecessary context
- Reduces context window usage per task

**Specialization:**
- Agents optimized for specific tasks
- Clear separation of concerns
- Easier to understand each agent's role

**Parallel Potential:**
- Multiple agents can work simultaneously (future feature)
- Complex workflows can be split across agents
- Better resource utilization

**Modularity:**
- Update one agent without affecting others
- Test agents independently
- Clear interfaces via delegation

### Tradeoffs

**Higher Token Usage:**
- Each subagent invocation costs tokens
- Delegation adds overhead
- Multiple round-trips between command and agent

**Requires Claude Code:**
- Not available in Cursor, Windsurf, or other tools
- Vendor-specific feature
- Limits portability

**Complexity:**
- More files to maintain
- Delegation layer adds abstraction
- Harder to trace execution flow

---

## Single-Agent Mode (Cursor/Windsurf)

### When to Use

**Tools:** Cursor, Windsurf, Cline, Aider, or any AI coding tool

**Configuration:**
```yaml
use_claude_code_subagents: false
```

**Use when:**
- Using tools other than Claude Code
- Want simpler execution model
- Prefer lower token usage
- Don't need specialized subagents

### Architecture

```
User: /write-spec
    ↓
Command (write-spec.md in agent-os/commands/)
    - Contains full workflow
    - Contains standards
    - Executes all steps directly
    ↓
Main agent executes workflow
    ↓
Returns result
```

No delegation, no subagents—everything in one file.

### Directory Structure

**When `use_claude_code_subagents: false`:**

```
project/
└── agent-os/
    ├── commands/                       # All-in-one commands
    │   ├── plan-product.md            # Contains full workflow
    │   ├── shape-spec.md              # Contains full workflow
    │   ├── write-spec.md              # Example below
    │   ├── create-tasks.md            # Contains full workflow
    │   ├── implement-tasks.md         # Contains full workflow
    │   └── orchestrate-tasks.md       # Contains full workflow
    │
    ├── workflows/                      # Reference
    └── standards/                      # Reference
```

**Note:** No `.claude/agents/` directory—agents not installed.

### Example: Write Spec Command

**Command file** (single-agent `agent-os/commands/write-spec.md`):

```markdown
# Write Specification

Transform shaped requirements or clear ideas into a formal specification document.

{{workflows/specification/write-spec}}

{{UNLESS standards_as_claude_code_skills}}
## Coding Standards

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**After template compilation:**

```markdown
# Write Specification

Transform shaped requirements or clear ideas into a formal specification document.

# Write Specification Workflow

## Core Responsibilities

1. Transform shaped requirements into formal specification document
2. Follow strict specification structure and format
3. Ensure completeness without including implementation code
4. Create clear, actionable requirements for implementers

[... entire workflow injected here ...]

## Coding Standards

# Tech Stack
[... all standards files injected here ...]
```

**Flow:**
1. User runs `/write-spec`
2. Command contains full workflow + standards
3. Main agent reads everything
4. Main agent executes workflow steps
5. Returns result

### Benefits

**Lower Token Usage (Per Invocation):**
- Single agent invocation
- No delegation overhead
- Fewer round-trips

**Simpler:**
- No delegation complexity
- Everything in one file
- Easier to trace execution
- Fewer moving parts

**Universal Compatibility:**
- Works with any AI coding tool
- No vendor-specific features
- Maximum portability

**Self-Contained:**
- Each command is complete
- No dependencies on subagents
- Easier to understand in isolation

### Tradeoffs

**Less Context Efficiency:**
- Loads everything upfront (workflow + standards)
- Larger context window usage
- May hit context limits on complex tasks

**No Specialization:**
- One agent does all tasks
- No optimization per task type
- Less clear separation of concerns

**Larger Files:**
- Commands contain full workflows + standards
- More duplication across command files
- Harder to navigate large files

---

## Maintaining Both Modes

When developing Agent OS features, you **must maintain both modes** to ensure compatibility.

### Workflow Pattern

The recommended approach:

**1. Create workflow** (shared by both modes):
```
profiles/default/workflows/[category]/[workflow-name].md
```

**2. Create single-agent command:**
```
profiles/default/commands/single-agent/[command-name].md

Content:
{{workflows/[category]/[workflow-name]}}
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**3. Create multi-agent command:**
```
profiles/default/commands/multi-agent/[command-name].md

Content:
Use @agent:[agent-name] to [task description]
```

**4. Create/update agent (if needed):**
```
profiles/default/agents/[agent-name].md

Content:
{{workflows/[category]/[workflow-name]}}
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**5. Test both modes:**
```bash
# Test multi-agent mode
~/agent-os/scripts/project-install.sh --use-claude-code-subagents true

# Test single-agent mode
~/agent-os/scripts/project-install.sh --use-claude-code-subagents false
```

### Real Example: Write-Spec

**Workflow** (`profiles/default/workflows/specification/write-spec.md`):
```markdown
# Write Specification

## Core Responsibilities
[...workflow content...]
```

**Single-Agent Command** (`profiles/default/commands/single-agent/write-spec.md`):
```markdown
# Write Specification

{{workflows/specification/write-spec}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**Multi-Agent Command** (`profiles/default/commands/multi-agent/write-spec.md`):
```markdown
# Write Specification

Use this command to create a formal specification document.

@agent:spec-writer

Create specification following Agent OS standards.
```

**Agent** (`profiles/default/agents/spec-writer.md`):
```markdown
---
name: spec-writer
tools: Write, Read
---

{{workflows/specification/write-spec}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**Result:**
- Same workflow used by both modes
- Single-agent: workflow injected into command
- Multi-agent: workflow injected into agent, command delegates

---

## Testing Both Modes

### Test Environment Setup

**Create test project:**
```bash
mkdir /tmp/agent-os-test
cd /tmp/agent-os-test
git init
```

### Test Multi-Agent Mode

```bash
# Install with multi-agent mode
~/agent-os/scripts/project-install.sh \
  --use-claude-code-subagents true

# Verify installation
ls .claude/commands/agent-os/
ls .claude/agents/agent-os/

# Test a command
# Run in Claude Code: /write-spec

# Verify delegation
cat .claude/commands/agent-os/write-spec.md | grep "@agent"
```

**Should see:**
- Commands in `.claude/commands/agent-os/`
- Agents in `.claude/agents/agent-os/`
- Commands contain `@agent:name` delegation

### Test Single-Agent Mode

```bash
# Clean previous installation
rm -rf .claude agent-os

# Install with single-agent mode
~/agent-os/scripts/project-install.sh \
  --use-claude-code-subagents false

# Verify installation
ls agent-os/commands/

# Verify no agents directory
ls .claude/agents/ 2>/dev/null || echo "No agents (correct)"

# Check command contains full workflow
cat agent-os/commands/write-spec.md | head -50
```

**Should see:**
- Commands in `agent-os/commands/`
- NO `.claude/agents/` directory
- Commands contain full workflow content inline

### Comparison Testing

**Run same command in both modes:**

```bash
# Multi-agent mode
/write-spec
# Observe: Delegation to @agent:spec-writer

# Single-agent mode
/write-spec
# Observe: Direct execution of workflow
```

**Both should produce same output** (spec.md file with same structure).

---

## Choosing a Mode

### Decision Matrix

| Factor | Multi-Agent Mode | Single-Agent Mode |
|--------|------------------|-------------------|
| **Tool** | Claude Code only | Any tool |
| **Context Efficiency** | Better (each agent loads less) | Worse (loads everything) |
| **Token Usage** | Higher (delegation overhead) | Lower (single invocation) |
| **Complexity** | More (delegation layer) | Less (direct execution) |
| **Specialization** | Yes (agent per task) | No (one agent all tasks) |
| **File Count** | More (commands + agents) | Fewer (commands only) |
| **Portability** | Vendor-specific | Universal |

### Recommendations

**Choose Multi-Agent Mode if:**
- You use Claude Code exclusively
- Context efficiency is important
- You work on complex, multi-step workflows
- You want specialized agents per task type
- Team is comfortable with delegation pattern

**Choose Single-Agent Mode if:**
- You use Cursor, Windsurf, or other tools
- You want maximum portability
- You prefer simpler architecture
- Lower per-invocation token usage matters
- You're just starting with Agent OS

**Use Both if:**
- Team uses different tools
- Maximum compatibility needed
- Both are installed by default when `claude_code_commands` and `agent_os_commands` are both `true`

---

## Quick Reference

### Configuration

**Multi-Agent Mode:**
```yaml
claude_code_commands: true
use_claude_code_subagents: true
```

**Single-Agent Mode:**
```yaml
use_claude_code_subagents: false
agent_os_commands: true  # Or claude_code_commands: true
```

### Directory Structures

**Multi-Agent:**
```
.claude/commands/agent-os/  # Delegates
.claude/agents/agent-os/    # Executes
```

**Single-Agent:**
```
agent-os/commands/          # Executes directly
```

### Testing Commands

```bash
# Install multi-agent
~/agent-os/scripts/project-install.sh --use-claude-code-subagents true

# Install single-agent
~/agent-os/scripts/project-install.sh --use-claude-code-subagents false

# Verify mode
cat agent-os/config.yml | grep subagents
```

---

## Related Documentation

- **[configuration-system.md](configuration-system.md)** - Config flags including use_claude_code_subagents
- **[agent-patterns.md](agent-patterns.md)** - How to create agents for multi-agent mode
- **[workflow-patterns.md](workflow-patterns.md)** - Workflow structure shared by both modes
- **[template-system.md](template-system.md)** - How workflows compile into commands/agents
- **[agent-os-architecture.md](agent-os-architecture.md)** - Complete architecture reference
