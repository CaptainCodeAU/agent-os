# Agent Patterns

Agents are specialized workers in Agent OS's multi-agent mode. Each agent has a specific purpose, set of tools, and workflows that guide its execution. Understanding agent patterns helps you create effective multi-agent systems and maintain consistency across the framework.

---

## Overview

An **agent** in Agent OS is a markdown file with:

- **YAML frontmatter** - Defines agent properties (name, tools, color, model)
- **Role description** - Explains the agent's purpose and capabilities
- **Workflow injection** - Template tags that inject step-by-step instructions
- **Standards injection** - Template tags that inject coding conventions (conditional)

Agents are stored in `profiles/[name]/agents/` and are compiled during installation. In multi-agent mode, commands **delegate** to agents via `@agent:name` syntax, allowing specialized agents to handle specific tasks with focused context.

---

## Agent Definition Template

Every agent file follows this structure:

```markdown
---
name: agent-name
description: Use proactively to [purpose when it should auto-trigger]
tools: Write, Read, Bash, WebFetch, Grep, Glob
color: purple
model: inherit
---

# Agent Name

[Role description explaining what this agent does]

## What I Do

[Clear 2-3 sentence explanation of agent's purpose and capabilities]

{{workflows/[category]/[workflow-name]}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

---

## Frontmatter Fields

### name

**Type:** String (kebab-case)

**Purpose:** Unique identifier for the agent

**Requirements:**
- Must match filename (e.g., `spec-writer.md` → `name: spec-writer`)
- Use kebab-case (lowercase with hyphens)
- Be descriptive and clear
- Should match role/purpose

**Examples:**
- `product-planner`
- `spec-writer`
- `tasks-list-creator`
- `implementer`

---

### description

**Type:** String (sentence)

**Purpose:** Describes when the agent should be proactively invoked

**Format:** `"Use proactively to [purpose]"`

**Requirements:**
- Start with "Use proactively to"
- Describe the triggering condition or purpose
- Be specific about what the agent does
- Keep it concise (one sentence)

**Good Examples:**
```yaml
description: Use proactively to create product documentation including mission and roadmap
description: Use proactively to create a detailed specification document for development
description: Use proactively to implement a feature by following a given tasks.md for a spec
description: Use proactively to verify the end-to-end implementation of a spec
```

**Bad Examples:**
```yaml
description: Helps with specs  # Too vague, no "Use proactively to"
description: Use this agent to do stuff  # Not specific
description: Creates documents  # Missing "Use proactively to" prefix
```

---

### tools

**Type:** Comma-separated list

**Purpose:** Defines which tools the agent can use

**Available Tools:**
- `Write` - Create and overwrite files
- `Read` - Read files
- `Edit` - Edit existing files
- `Bash` - Execute shell commands
- `WebFetch` - Fetch web content
- `Grep` - Search file contents
- `Glob` - Find files by pattern
- `Task` - Delegate to subagents
- `Playwright` - Browser automation (for testing/verification)

**Common Combinations:**

**Document Creation Agents:**
```yaml
tools: Write, Read
```
Use when: Creating docs, no code execution needed

**Verification Agents:**
```yaml
tools: Read, Bash
```
Use when: Reading files and running tests/checks

**Implementation Agents:**
```yaml
tools: Write, Read, Bash, WebFetch, Playwright
```
Use when: Full implementation with testing capabilities

**Research Agents:**
```yaml
tools: Read, Bash, Grep, Glob, Task
```
Use when: Analyzing codebase, searching, delegating exploration

---

### color

**Type:** String (color name)

**Purpose:** Visual identifier in Claude Code UI

**Available Colors:**
- `cyan` - Teal/aqua color
- `purple` - Purple/violet color
- `blue` - Blue color
- `green` - Green color
- `red` - Red color
- `orange` - Orange color
- `pink` - Pink color
- `yellow` - Yellow color

**Assigning Colors:**
- Choose colors that help distinguish agents visually
- No strict rules, but consistency helps
- Group related agents with similar hues (optional)

**Current Assignments:**
- `cyan` - Product planning (product-planner)
- `green` - Initialization and verification (spec-initializer, implementation-verifier)
- `blue` - Requirements (spec-shaper)
- `purple` - Writing (spec-writer)
- `pink` - Verification (spec-verifier)
- `orange` - Task planning (tasks-list-creator)
- `red` - Implementation (implementer)

---

### model

**Type:** String

**Purpose:** Specifies which AI model to use

**Values:**
- `inherit` - Use the same model as parent (most common)
- `sonnet` - Use Sonnet model explicitly (faster, cheaper)
- `opus` - Use Opus model explicitly (more capable, expensive)
- `haiku` - Use Haiku model explicitly (fastest, cheapest)

**When to Use:**
- **`inherit`** (default) - Let parent command control model selection
- **`sonnet`** - For simple, straightforward tasks (folder creation, verification)
- **`opus`** - For complex reasoning (rarely needed)
- **`haiku`** - For very simple tasks (rarely used)

**Examples:**
```yaml
model: inherit  # Most agents use this
model: sonnet   # spec-initializer, spec-verifier use this
```

---

## The 8 Specialized Agents

Agent OS includes 8 core agents that map to the 6 development phases:

### 1. product-planner

**Purpose:** Create product foundation documentation (mission, roadmap, tech stack)

**Frontmatter:**
```yaml
name: product-planner
description: Use proactively to create product documentation including mission and roadmap
tools: Write, Read, Bash, WebFetch
color: cyan
model: inherit
```

**Phase:** Phase 1 (/plan-product)

**Workflows:**
- `planning/create-product-mission.md`
- `planning/create-product-roadmap.md`
- `planning/create-product-tech-stack.md`

**Outputs:**
- `agent-os/product/mission.md`
- `agent-os/product/roadmap.md`
- `agent-os/product/tech-stack.md`

**Tools Rationale:**
- `Write` - Creates product documentation files
- `Read` - Reads existing docs or standards for context
- `Bash` - Creates directories, checks file existence
- `WebFetch` - Research similar products or technologies

---

### 2. spec-initializer

**Purpose:** Initialize spec folder structure and save user's raw idea

**Frontmatter:**
```yaml
name: spec-initializer
description: Use proactively to initialize spec folder and save raw idea
tools: Write, Bash
color: green
model: sonnet
```

**Phase:** Phase 2 (/shape-spec) - initialization step

**Workflows:**
- `specification/initialize-spec.md`

**Outputs:**
- `agent-os/specs/[spec-name]/` folder structure
- `agent-os/specs/[spec-name]/planning/idea.md` (raw idea)

**Tools Rationale:**
- `Write` - Creates initial files
- `Bash` - Creates directory structure

**Model Rationale:**
- Uses `sonnet` (not inherit) - Simple task, faster execution

---

### 3. spec-shaper

**Purpose:** Gather comprehensive requirements through Q&A and visual analysis

**Frontmatter:**
```yaml
name: spec-shaper
description: Use proactively to gather detailed requirements through targeted questions and visual analysis
tools: Write, Read, Bash, WebFetch
color: blue
model: inherit
```

**Phase:** Phase 2 (/shape-spec)

**Workflows:**
- `specification/shape-requirements.md`

**Outputs:**
- `agent-os/specs/[spec-name]/planning/requirements.md`
- `agent-os/specs/[spec-name]/planning/visuals/` (optional mockups)

**Tools Rationale:**
- `Write` - Creates requirements document
- `Read` - Reads existing specs or related docs
- `Bash` - Creates directories for visuals
- `WebFetch` - Researches similar features or UX patterns

---

### 4. spec-writer

**Purpose:** Create formal specification document from clear requirements

**Frontmatter:**
```yaml
name: spec-writer
description: Use proactively to create a detailed specification document for development
tools: Write, Read, Bash, WebFetch
color: purple
model: inherit
```

**Phase:** Phase 3 (/write-spec)

**Workflows:**
- `specification/write-spec.md`

**Outputs:**
- `agent-os/specs/[spec-name]/spec.md`

**Spec Structure:**
- Goal (1-2 sentences)
- User Stories (1-3 stories)
- Specific Requirements (grouped)
- Visual Design (if applicable)
- Existing Code to Leverage
- Out of Scope

**Tools Rationale:**
- `Write` - Creates spec.md
- `Read` - Reads requirements, existing code, product docs
- `Bash` - File operations
- `WebFetch` - Research best practices or similar implementations

---

### 5. spec-verifier

**Purpose:** Verify spec and tasks list completeness and quality

**Frontmatter:**
```yaml
name: spec-verifier
description: Use proactively to verify the spec and tasks list
tools: Write, Read, Bash, WebFetch
color: pink
model: sonnet
```

**Phase:** Between Phase 3 and 4 (quality check)

**Workflows:**
- `specification/verify-spec.md`

**Outputs:**
- Verification report or feedback
- Updated spec.md if issues found

**Tools Rationale:**
- `Write` - Creates verification report, updates docs
- `Read` - Reads spec.md, tasks.md, requirements.md
- `Bash` - File operations
- `WebFetch` - Look up best practices for verification

**Model Rationale:**
- Uses `sonnet` - Verification is straightforward pattern matching

---

### 6. tasks-list-creator

**Purpose:** Break specification into implementation tasks with dependencies

**Frontmatter:**
```yaml
name: task-list-creator
description: Use proactively to create a detailed and strategic tasks list for development of a spec
tools: Write, Read, Bash, WebFetch
color: orange
model: inherit
```

**Phase:** Phase 4 (/create-tasks)

**Workflows:**
- `implementation/create-tasks-list.md`

**Outputs:**
- `agent-os/specs/[spec-name]/tasks.md`

**Task Structure:**
```markdown
## Task Group Name

Dependencies: [other groups]

### Task 1: [Name]
- [ ] Subtask 1
- [ ] Subtask 2

Acceptance Criteria:
- Criterion 1
- Criterion 2
```

**Tools Rationale:**
- `Write` - Creates tasks.md
- `Read` - Reads spec.md, requirements.md, existing code
- `Bash` - File operations
- `WebFetch` - Research implementation patterns

---

### 7. implementer

**Purpose:** Implement features following tasks.md specifications

**Frontmatter:**
```yaml
name: implementer
description: Use proactively to implement a feature by following a given tasks.md for a spec
tools: Write, Read, Bash, WebFetch, Playwright
color: red
model: inherit
```

**Phase:** Phase 5 (/implement-tasks) and Phase 6 (/orchestrate-tasks)

**Workflows:**
- `implementation/implement-tasks.md`

**Outputs:**
- Code files (implementation)
- Test files (2-8 tests per task group)
- Screenshots (`agent-os/specs/[spec-name]/verification/screenshots/`)

**Tools Rationale:**
- `Write` - Creates code and test files
- `Read` - Reads spec, tasks, existing code, standards
- `Bash` - Runs tests, creates directories, git operations
- `WebFetch` - Research APIs, libraries, documentation
- `Playwright` - UI testing and screenshot capture

**Scope Constraints:**
- Stay focused on assigned tasks only
- Reuse existing code and patterns
- Minimal file changes
- Keep solutions simple
- No premature optimization

---

### 8. implementation-verifier

**Purpose:** Verify end-to-end implementation of spec

**Frontmatter:**
```yaml
name: implementation-verifier
description: Use proactively to verify the end-to-end implementation of a spec
tools: Write, Read, Bash, WebFetch, Playwright
color: green
model: inherit
```

**Phase:** After Phase 5 or Phase 6 (verification step)

**Workflows:**
- `implementation/verify-implementation.md`

**Outputs:**
- Verification report
- Updated roadmap (if applicable)
- Test results summary

**Tools Rationale:**
- `Write` - Creates verification report, updates roadmap
- `Read` - Reads spec, tasks, code, tests
- `Bash` - Runs tests, checks builds
- `WebFetch` - Look up verification best practices
- `Playwright` - End-to-end UI testing

---

## Agent Best Practices

### 1. Single Responsibility

**Principle:** Each agent should have ONE clear purpose.

**Good Examples:**
- `spec-writer` - Only writes spec.md
- `implementer` - Only implements code from tasks
- `spec-verifier` - Only verifies spec quality

**Bad Examples:**
- Agent that writes spec AND implements it
- Agent that creates tasks AND verifies them
- Agent that does "whatever is needed"

**Why:** Single responsibility makes agents predictable, testable, and reusable.

---

### 2. Minimal Tools

**Principle:** Only include tools the agent actually needs.

**Good Examples:**
```yaml
# Document creator - only needs Write and Read
tools: Write, Read

# Verifier - only needs Read and Bash for running checks
tools: Read, Bash

# Implementer - needs full toolkit
tools: Write, Read, Bash, WebFetch, Playwright
```

**Bad Examples:**
```yaml
# Document creator with unnecessary tools
tools: Write, Read, Bash, WebFetch, Playwright, Grep, Glob

# Verifier with write access (should be read-only)
tools: Write, Read, Bash
```

**Why:** Minimal tools reduce complexity, improve security, and make agent purpose clearer.

---

### 3. Clear Descriptions

**Principle:** Description should explain WHEN to use the agent proactively.

**Good Examples:**
```yaml
description: Use proactively to create product documentation including mission and roadmap
description: Use proactively to implement a feature by following a given tasks.md for a spec
description: Use proactively to verify the end-to-end implementation of a spec
```

**Bad Examples:**
```yaml
description: Helps with specs  # Too vague
description: Creates things  # Not specific
description: Agent for writing  # Doesn't explain when to use
```

**Why:** Clear descriptions help Claude Code know when to suggest the agent proactively.

---

### 4. Workflow Integration

**Principle:** Reference workflows via template tags, don't duplicate content.

**Good Example:**
```markdown
---
name: spec-writer
tools: Write, Read, Bash, WebFetch
---

# Spec Writer

I create formal specification documents from clear requirements.

{{workflows/specification/write-spec}}
```

**Bad Example:**
```markdown
---
name: spec-writer
tools: Write, Read, Bash, WebFetch
---

# Spec Writer

I create formal specification documents.

## How I Work

### Step 1: Read Requirements
[Duplicating workflow content instead of using template tag]

### Step 2: Create Spec
[More duplicated content]
```

**Why:** Template tags ensure consistency and make updates easier (update workflow once, all agents benefit).

---

### 5. Standards Inclusion

**Principle:** Use conditional blocks to respect configuration flags.

**Good Example:**
```markdown
{{workflows/specification/write-spec}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**Behavior:**
- If `standards_as_claude_code_skills: false` → standards injected
- If `standards_as_claude_code_skills: true` → standards via Skills feature

**Bad Example:**
```markdown
{{workflows/specification/write-spec}}

{{standards/*}}  # Always inject, ignoring configuration
```

**Why:** Respecting configuration flags allows flexibility in how standards are delivered.

---

## Template Tag Usage

### Workflow Injection

```markdown
{{workflows/category/workflow-name}}
```

**Examples:**
```markdown
{{workflows/planning/create-product-mission}}
{{workflows/specification/write-spec}}
{{workflows/implementation/implement-tasks}}
```

---

### Standards Injection

**Full standards:**
```markdown
{{standards/*}}
```

**By category:**
```markdown
{{standards/global/*}}
{{standards/frontend/*}}
{{standards/backend/*}}
{{standards/testing/*}}
```

**Conditional:**
```markdown
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

---

## Common Patterns

### Document Creation Agent

**Characteristics:**
- Creates documentation files
- Minimal tools (Write, Read)
- Focused on structure and clarity
- May use WebFetch for research

**Template:**
```markdown
---
name: [name]-creator
description: Use proactively to create [document type]
tools: Write, Read, Bash, WebFetch
color: [color]
model: inherit
---

# [Name] Creator

I create [document type] following Agent OS conventions.

{{workflows/[category]/[workflow-name]}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

---

### Implementation Agent

**Characteristics:**
- Writes code and tests
- Full tool access (Write, Read, Bash, WebFetch, Playwright)
- Follows tasks and specifications
- Runs tests and verifies

**Template:**
```markdown
---
name: [name]-implementer
description: Use proactively to implement [feature type]
tools: Write, Read, Bash, WebFetch, Playwright
color: red
model: inherit
---

# [Name] Implementer

I implement [feature type] following specifications and coding standards.

{{workflows/implementation/[workflow-name]}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

---

### Verification Agent

**Characteristics:**
- Read-only checks (or minimal writes for reports)
- Tools: Read, Bash, potentially Playwright for UI
- Validates completeness and quality
- Provides feedback

**Template:**
```markdown
---
name: [name]-verifier
description: Use proactively to verify [artifact type]
tools: Write, Read, Bash, WebFetch, Playwright
color: green
model: sonnet
---

# [Name] Verifier

I verify [artifact type] meets quality standards and completeness criteria.

{{workflows/[category]/verify-[artifact]}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

---

## Creating New Agents

### Step-by-Step Guide

**1. Identify the Need**
- What specific task needs a specialized agent?
- Is this task distinct from existing agents?
- Would delegation improve context efficiency?

**2. Define Agent Properties**
- **Name:** Descriptive, kebab-case
- **Description:** "Use proactively to [purpose]"
- **Tools:** Minimal set needed
- **Color:** Pick visually distinct color
- **Model:** Usually `inherit`, `sonnet` for simple tasks

**3. Create Workflow (if needed)**
- If no existing workflow fits, create one
- See `workflow-patterns.md` for structure
- Place in appropriate category (planning, specification, implementation)

**4. Write Agent File**

```bash
# Create file in profile
vim ~/agent-os/profiles/default/agents/my-new-agent.md
```

```markdown
---
name: my-new-agent
description: Use proactively to [specific purpose]
tools: Write, Read
color: blue
model: inherit
---

# My New Agent

I [describe role and capabilities].

{{workflows/[category]/[workflow-name]}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**5. Create Command (Multi-Agent)**

```bash
# Create command that delegates to agent
vim ~/agent-os/profiles/default/commands/multi-agent/my-command.md
```

```markdown
# /my-command

[Brief usage instructions]

Use @agent:my-new-agent to [accomplish task].

Expected output: [describe what user should see]
```

**6. Test Both Modes**
- Test multi-agent mode (command delegates to agent)
- Test single-agent mode (command contains full workflow)
- Verify outputs match

---

## Quick Reference

### Agent Frontmatter Template

```yaml
---
name: agent-name               # kebab-case, matches filename
description: Use proactively to [purpose]  # When to invoke
tools: Write, Read, Bash       # Minimal needed tools
color: purple                  # Visual identifier
model: inherit                 # Usually inherit
---
```

### Tool Combinations

| Agent Type | Common Tools |
|-----------|--------------|
| Document Creator | `Write, Read` |
| Verifier | `Read, Bash` |
| Implementer | `Write, Read, Bash, WebFetch, Playwright` |
| Researcher | `Read, Bash, Grep, Glob, Task` |
| Initializer | `Write, Bash` |

### The 8 Core Agents Summary

| Agent | Phase | Color | Model | Key Tools |
|-------|-------|-------|-------|-----------|
| product-planner | 1 | cyan | inherit | Write, Read, Bash, WebFetch |
| spec-initializer | 2 | green | sonnet | Write, Bash |
| spec-shaper | 2 | blue | inherit | Write, Read, Bash, WebFetch |
| spec-writer | 3 | purple | inherit | Write, Read, Bash, WebFetch |
| spec-verifier | 3-4 | pink | sonnet | Write, Read, Bash, WebFetch |
| tasks-list-creator | 4 | orange | inherit | Write, Read, Bash, WebFetch |
| implementer | 5-6 | red | inherit | Write, Read, Bash, WebFetch, Playwright |
| implementation-verifier | 5-6 | green | inherit | Write, Read, Bash, WebFetch, Playwright |

---

## Related Documentation

- **[development-phases.md](development-phases.md)** - The phases that agents implement
- **[workflow-patterns.md](workflow-patterns.md)** - Workflows that agents execute
- **[template-system.md](template-system.md)** - How agents are compiled with workflows
- **[agent-modes.md](agent-modes.md)** - Multi-agent vs single-agent architecture
- **[standards-structure.md](standards-structure.md)** - Standards that guide agent behavior
