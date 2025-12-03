# Agent OS Architecture Reference

This document provides detailed technical information about Agent OS internals. It's referenced by CLAUDE.md but kept separate to avoid performance issues.

---

## Complete Repository Architecture

### Directory Structure

```
agent-os/
├── config.yml                      # Version & configuration defaults
│
├── profiles/                       # Profile templates
│   ├── default/                   # Ships with Agent OS
│   │   ├── agents/                # 8 specialized Claude Code subagents
│   │   │   ├── product-planner.md
│   │   │   ├── spec-initializer.md
│   │   │   ├── spec-shaper.md
│   │   │   ├── spec-writer.md
│   │   │   ├── spec-verifier.md
│   │   │   ├── tasks-list-creator.md
│   │   │   ├── implementer.md
│   │   │   └── implementation-verifier.md
│   │   │
│   │   ├── commands/              # Slash commands
│   │   │   ├── single-agent/     # For Cursor/Windsurf
│   │   │   │   ├── plan-product.md
│   │   │   │   ├── shape-spec.md
│   │   │   │   ├── write-spec.md
│   │   │   │   ├── create-tasks.md
│   │   │   │   ├── implement-tasks.md
│   │   │   │   └── orchestrate-tasks.md
│   │   │   │
│   │   │   └── multi-agent/      # For Claude Code with subagents
│   │   │       ├── plan-product.md
│   │   │       ├── shape-spec.md
│   │   │       ├── write-spec.md
│   │   │       ├── create-tasks.md
│   │   │       ├── implement-tasks.md
│   │   │       └── orchestrate-tasks.md
│   │   │
│   │   ├── workflows/             # Step-by-step instructions
│   │   │   ├── planning/
│   │   │   │   ├── create-product-mission.md
│   │   │   │   ├── create-product-roadmap.md
│   │   │   │   └── create-tech-stack.md
│   │   │   │
│   │   │   ├── specification/
│   │   │   │   ├── initialize-spec.md
│   │   │   │   ├── shape-requirements.md
│   │   │   │   ├── write-spec.md
│   │   │   │   └── verify-spec.md
│   │   │   │
│   │   │   └── implementation/
│   │   │       ├── create-tasks-list.md
│   │   │       ├── implement-tasks.md
│   │   │       └── verify-implementation.md
│   │   │
│   │   └── standards/             # Coding standards
│   │       ├── global/
│   │       │   ├── tech-stack.md
│   │       │   ├── coding-style.md
│   │       │   ├── conventions.md
│   │       │   ├── error-handling.md
│   │       │   ├── commenting.md
│   │       │   └── validation.md
│   │       │
│   │       ├── frontend/
│   │       │   ├── components.md
│   │       │   ├── css.md
│   │       │   ├── responsive.md
│   │       │   └── accessibility.md
│   │       │
│   │       ├── backend/
│   │       │   ├── api.md
│   │       │   ├── models.md
│   │       │   ├── queries.md
│   │       │   └── migrations.md
│   │       │
│   │       └── testing/
│   │           └── test-writing.md
│   │
│   └── [custom-profiles]/         # User-created profiles
│
├── scripts/                        # Installation & management
│   ├── common-functions.sh        # Shared utilities
│   ├── base-install.sh            # Base installation
│   ├── project-install.sh         # Project installation
│   ├── project-update.sh          # Project updates
│   └── create-profile.sh          # Profile creation
│
├── CHANGELOG.md                    # Version history
├── README.md                       # Project documentation
│
└── .claude-workspace/              # Development workspace (gitignored)
    ├── analysis/                  # Understanding Agent OS
    ├── planning/                  # Feature designs
    ├── progress/                  # Development logs
    ├── research/                  # Research notes
    ├── references/                # Quick references
    └── templates/                 # Experimental templates
```

---

## Profile System (Three-Tier Architecture)

### Tier 1: Base Installation (`~/agent-os/`)

**Location:** Developer's local machine  
**Purpose:** Source of truth for all project installations  
**Contents:**
- `config.yml` - Global configuration
- `profiles/` - All available profiles (default + custom)
- `scripts/` - Installation and management scripts

**Installation:**
```bash
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash
```

**Characteristics:**
- Lives outside any specific project
- Customizable for your preferences
- Updated independently from projects
- Can define multiple profiles for different project types

### Tier 2: Profiles (`~/agent-os/profiles/[name]/`)

**Purpose:** Templates for different project types  
**Available Profiles:**
- `default/` - Generic, ships with Agent OS
- Custom profiles - User-created (e.g., `rails`, `nextjs`, `django`)

**Profile Structure:**
```
profiles/[name]/
├── agents/       # Agent definitions
├── commands/     # Slash commands (single & multi-agent)
├── workflows/    # Workflow instructions
└── standards/    # Coding standards
```

**Creating Custom Profiles:**
```bash
~/agent-os/scripts/create-profile.sh

# Options:
# - Inherit from existing profile
# - Copy existing profile
# - Start from scratch
```

**Use Cases:**
- Rails profile with Ruby standards
- Next.js profile with React/TypeScript conventions
- Django profile with Python best practices
- FastAPI profile with async patterns

### Tier 3: Project Installation

**Location:** Inside each project's codebase  
**Purpose:** Self-contained Agent OS for that specific project

**Installation:**
```bash
# From within project directory
~/agent-os/scripts/project-install.sh
```

**What Gets Created:**

**If `claude_code_commands: true` (default):**
```
project/
├── .claude/
│   ├── commands/
│   │   └── agent-os/          # Commands installed here
│   └── agents/
│       └── agent-os/          # Agents installed here (if using subagents)
│
└── agent-os/                  # Always created
    ├── product/               # Product planning outputs
    ├── specs/                 # Specification outputs
    └── [compiled files]       # Workflows, standards (compiled from templates)
```

**If `agent_os_commands: true`:**
```
project/
└── agent-os/
    ├── commands/              # Commands here instead
    ├── product/
    ├── specs/
    └── [compiled files]
```

**Characteristics:**
- **Self-contained** - No external dependencies after installation
- **Customizable** - Can edit files in this project without affecting base
- **Version-controlled** - Usually committed to git
- **Updateable** - Can pull updates from base installation

**Updating Installed Profile:**
```bash
~/agent-os/scripts/project-update.sh

# Options:
# --overwrite-all       # Replace everything
# --overwrite-standards # Just standards
# --overwrite-workflows # Just workflows
```

---

## Template System

### How Template Compilation Works

During project installation, Agent OS compiles templates by resolving special tags.

### Template Tags

#### 1. **Workflow Injection**
```markdown
{{workflows/path/file}}
```

**Example in agent definition:**
```markdown
---
name: spec-writer
---

{{workflows/specification/write-spec}}
```

**Compiles to:**
```markdown
---
name: spec-writer
---

[entire contents of profiles/default/workflows/specification/write-spec.md]
```

#### 2. **Standards Injection**
```markdown
{{standards/*}}                    # All standards
{{standards/global/*}}             # Just global/
{{standards/frontend/*}}           # Just frontend/
```

**Example:**
```markdown
## Standards

{{standards/*}}
```

**Compiles to:**
```markdown
## Standards

[contents of all standards files]
```

#### 3. **Conditional Blocks**
```markdown
{{UNLESS flag}}
[content]
{{ENDUNLESS flag}}
```

**Example:**
```markdown
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**Behavior:**
- If `standards_as_claude_code_skills: false` → includes standards
- If `standards_as_claude_code_skills: true` → omits standards (uses Skills feature instead)

### Compilation Process

**Function:** `compile_template()` in `scripts/common-functions.sh`

**Steps:**
1. Read source file line by line
2. Detect template tags (`{{...}}`)
3. For workflow/standards tags:
   - Read referenced file(s)
   - Inject content inline
4. For conditional blocks:
   - Check configuration flag
   - Include or exclude content accordingly
5. Write compiled output to destination

**Important Characteristics:**
- **Recursive** - Templates can include other templates
- **One-time** - Compiles during installation, not dynamic
- **Configuration-aware** - Respects config.yml flags
- **Error handling** - Reports missing files

**Testing Template Compilation:**
```bash
# Dry run shows what would be compiled
~/agent-os/scripts/project-install.sh --dry-run

# Check compiled output
cat [project]/agent-os/[compiled-file]
```

---

## Agent Modes

### Multi-Agent Mode (Claude Code)

**When:** `use_claude_code_subagents: true`

**Architecture:**
- **Commands** - Entry points (in `.claude/commands/agent-os/`)
- **Subagents** - Specialized workers (in `.claude/agents/agent-os/`)
- **Delegation** - Commands delegate to subagents via `@agent:name`

**Example Flow:**
```
User: /write-spec

Command (write-spec.md):
  → Delegates to @agent:spec-writer
  
Subagent (spec-writer.md):
  → Executes workflow
  → Returns result
  
Command:
  → Receives result
  → Continues or finishes
```

**Benefits:**
- **Context efficiency** - Each subagent loads only what it needs
- **Specialization** - Agents optimized for specific tasks
- **Parallel potential** - Multiple agents can work simultaneously

**Tradeoffs:**
- **Higher token usage** - More agent invocations
- **Requires Claude Code** - Not available in Cursor/Windsurf

### Single-Agent Mode (Cursor/Windsurf)

**When:** `use_claude_code_subagents: false`

**Architecture:**
- **Commands** - Do everything (in `agent-os/commands/`)
- **No subagents** - Main agent executes all steps
- **Direct execution** - Workflows embedded in commands

**Example Flow:**
```
User: /write-spec

Command (write-spec.md):
  → Loads full workflow
  → Loads all standards
  → Executes all steps
  → Returns result
```

**Benefits:**
- **Lower token usage** - Single agent invocation
- **Simpler** - No delegation complexity
- **Universal** - Works in any AI coding tool

**Tradeoffs:**
- **Less context efficiency** - Loads everything upfront
- **No specialization** - One agent does all tasks

### Maintaining Both Modes

When developing Agent OS features:

**1. Create workflow** (shared by both)
```
profiles/default/workflows/[category]/[name].md
```

**2. Create single-agent command**
```
profiles/default/commands/single-agent/[name].md

Content:
{{workflows/[category]/[name]}}
{{standards/*}}
```

**3. Create multi-agent command**
```
profiles/default/commands/multi-agent/[name].md

Content:
Use @agent:[agent-name] to [task]
```

**4. Create/update agent (if needed)**
```
profiles/default/agents/[agent-name].md

Content:
{{workflows/[category]/[name]}}
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**5. Test both**
```bash
# Test multi-agent
~/agent-os/scripts/project-install.sh --use-claude-code-subagents true

# Test single-agent
~/agent-os/scripts/project-install.sh --use-claude-code-subagents false
```

---

## The 6 Development Phases

Agent OS structures development into 6 sequential phases, each with a command:

### Phase 1: plan-product

**Purpose:** Define product foundation  
**Outputs:**
- `agent-os/product/mission.md` - Product vision, goals, users
- `agent-os/product/roadmap.md` - Feature phases
- `agent-os/product/tech-stack.md` - Technologies used

**When to use:** Starting a new product or documenting existing one

**Agent (multi-agent):** product-planner  
**Workflow:** planning/create-product-mission, create-product-roadmap, create-tech-stack

### Phase 2: shape-spec

**Purpose:** Shape rough ideas into requirements  
**Outputs:**
- `agent-os/specs/[spec-name]/planning/requirements.md`
- `agent-os/specs/[spec-name]/planning/visuals/` (if mockups)

**When to use:** Have a feature idea but need to flesh it out

**Agent (multi-agent):** spec-shaper  
**Workflow:** specification/shape-requirements

### Phase 3: write-spec

**Purpose:** Create formal specification document  
**Outputs:**
- `agent-os/specs/[spec-name]/spec.md`

**When to use:** Have clear requirements, need formal spec

**Agent (multi-agent):** spec-writer  
**Workflow:** specification/write-spec

**Spec Structure:**
- Goal (1-2 sentences)
- User Stories (1-3 stories)
- Specific Requirements (grouped)
- Visual Design (if applicable)
- Existing Code to Leverage
- Out of Scope

**Key Constraint:** No code in spec.md, only descriptions

### Phase 4: create-tasks

**Purpose:** Break spec into implementation tasks  
**Outputs:**
- `agent-os/specs/[spec-name]/tasks.md`

**When to use:** Have a spec, need task breakdown

**Agent (multi-agent):** tasks-list-creator  
**Workflow:** implementation/create-tasks-list

**Task Structure:**
```markdown
## Task Group Name (e.g., Database, API, UI)

Dependencies: [other task groups]

### Task 1: [Name]
- [ ] Subtask 1
- [ ] Subtask 2

### Task 2: [Name]
- [ ] Subtask 1

Acceptance Criteria:
- Criterion 1
- Criterion 2
```

### Phase 5: implement-tasks

**Purpose:** Simple single-agent implementation  
**Outputs:**
- Code
- Tests (2-8 per task group)
- `agent-os/specs/[spec-name]/verification/screenshots/` (if UI)

**When to use:** Have tasks, straightforward implementation

**Agent (multi-agent):** implementer  
**Workflow:** implementation/implement-tasks

**Process:**
1. Implement task group
2. Write focused tests (2-8)
3. Run relevant tests only
4. Verify manually (screenshot if UI)
5. Move to next group

### Phase 6: orchestrate-tasks

**Purpose:** Advanced multi-agent orchestration  
**Outputs:**
- Code (via multiple specialized agents)
- Tests
- Verification

**When to use:** Complex feature needing multiple specializations

**Agent (multi-agent):** Multiple agents (implementer + custom)  
**Workflow:** implementation/implement-tasks + custom

**Process:**
1. Assign task groups to specific agents
2. Agents work on their groups
3. Integration between groups
4. Final verification

---

## Workflow Patterns

### Standard Workflow Structure

```markdown
# [Workflow Name]

## Core Responsibilities
1. [Primary responsibility]
2. [Secondary responsibility]
3. [Tertiary responsibility]

## Workflow

### Step 1: [Action Verb] [Object]

[Detailed instructions]

[Optional: Bash example]
```bash
# Example command
```

[Optional: File template]
```markdown
[Template content]
```

### Step 2: [Action Verb] [Object]

[More instructions]

## Important Constraints

1. [Constraint 1]
2. [Constraint 2]
3. [Constraint 3]

## Success Criteria

1. [Verification step 1]
2. [Verification step 2]
```

### Workflow Categories

**Planning:**
- `planning/create-product-mission.md` - Mission document
- `planning/create-product-roadmap.md` - Feature roadmap
- `planning/create-tech-stack.md` - Tech stack docs

**Specification:**
- `specification/initialize-spec.md` - Folder setup
- `specification/shape-requirements.md` - Requirements gathering
- `specification/write-spec.md` - Spec creation
- `specification/verify-spec.md` - Completeness check

**Implementation:**
- `implementation/create-tasks-list.md` - Task breakdown
- `implementation/implement-tasks.md` - Implementation process
- `implementation/verify-implementation.md` - Verification

---

## Standards Organization

### Directory Structure

```
standards/
├── global/          # Universal standards
├── frontend/        # Frontend-specific
├── backend/         # Backend-specific
└── testing/         # Test standards
```

### Global Standards

**tech-stack.md** - Template to fill out
- Framework & version
- Database & version
- Testing tools
- Build tools
- Deployment

**coding-style.md**
- Formatting rules
- Naming conventions
- File structure
- Import organization

**conventions.md**
- Architecture patterns
- File organization
- Module structure
- Code organization

**error-handling.md**
- Error handling approach
- Exception types
- Logging patterns
- Recovery strategies

**commenting.md**
- When to comment
- Comment style
- Documentation format
- Inline vs block

**validation.md**
- Input validation
- Data sanitization
- Type checking
- Error messages

### Frontend Standards

**components.md**
- Component architecture
- Props patterns
- State management
- Component composition

**css.md**
- CSS methodology (BEM, etc.)
- Tailwind conventions
- Naming patterns
- Organization

**responsive.md**
- Breakpoints
- Mobile-first approach
- Testing devices
- Responsive patterns

**accessibility.md**
- ARIA usage
- Keyboard navigation
- Screen reader support
- Color contrast

### Backend Standards

**api.md**
- REST conventions
- GraphQL patterns
- Error responses
- Versioning

**models.md**
- Model structure
- Relationships
- Validation rules
- Hooks/callbacks

**queries.md**
- Query optimization
- N+1 prevention
- Indexing strategy
- Caching approach

**migrations.md**
- Migration patterns
- Rollback procedures
- Data migrations
- Schema changes

### Testing Standards

**test-writing.md**
- Test organization
- Naming conventions
- Fixture patterns
- Mocking approach
- Coverage goals

---

## Script Architecture

### common-functions.sh

Shared utilities for all scripts.

#### YAML Parsing

```bash
get_yaml_value(file, key, default)
# Extract value from YAML
# Handles tabs, quotes, indentation
# Returns default if key not found

get_yaml_array(file, key)
# Extract array values
# Returns space-separated list
```

#### Template Compilation

```bash
compile_template(source_file, dest_file, config_flags)
# Main compilation function
# Resolves {{template_tags}}
# Processes {{UNLESS}} blocks
# Recursive compilation
```

#### File Operations

```bash
copy_with_compile(source, dest, config)
# Copy and compile templates
# Creates parent directories
# Preserves permissions

should_skip_file(path, exclusions)
# Check exclusion patterns
# Used for .git, .DS_Store, etc.

validate_base_installation()
# Verify base install exists
# Check required directories
```

#### User Interaction

```bash
print_section(message)     # Header (bold)
print_status(message)      # Status (blue)
print_success(message)     # Success (green)
print_error(message)       # Error (red)

confirm_action(message)    # Yes/no prompt
# Returns 0 for yes, 1 for no

parse_bool_flag(current, next_arg)
# Parse --flag, --flag true, --flag false
```

### base-install.sh

Installs Agent OS base to local machine.

**Usage:**
```bash
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash
```

**Process:**
1. Prompt for installation directory (default: ~/agent-os)
2. Create directory structure
3. Copy profiles
4. Copy scripts
5. Create config.yml
6. Show project installation command

### project-install.sh

Installs Agent OS profile into project.

**Usage:**
```bash
~/agent-os/scripts/project-install.sh [options]

Options:
  --profile NAME                     Profile to install (default: default)
  --claude-code-commands BOOL        Install to .claude/commands/
  --agent-os-commands BOOL           Install to agent-os/commands/
  --use-claude-code-subagents BOOL   Enable subagent mode
  --dry-run                          Show what would be installed
```

**Process:**
1. Validate base installation exists
2. Read config.yml (base + CLI overrides)
3. Select profile
4. Create directory structure
5. Compile and copy files
6. Report what was installed

### project-update.sh

Updates existing project installation.

**Usage:**
```bash
~/agent-os/scripts/project-update.sh [options]

Options:
  --overwrite-all         # Replace everything
  --overwrite-standards   # Just standards
  --overwrite-workflows   # Just workflows
  --overwrite-agents      # Just agents
  --overwrite-commands    # Just commands
```

**Process:**
1. Check current installation
2. Compare versions
3. Show what will change
4. Confirm with user
5. Selectively update based on flags
6. Preserve customizations

### create-profile.sh

Creates custom profile interactively.

**Usage:**
```bash
~/agent-os/scripts/create-profile.sh
```

**Process:**
1. Prompt for profile name
2. Ask: inherit, copy, or start fresh
3. If inherit/copy: select source profile
4. Create profile directory structure
5. Copy or link files
6. Customize as needed

---

## Configuration System

### config.yml Structure

```yaml
# Version
version: 2.1.1                          # Agent OS version

# Profile
profile: default                        # Default profile to use

# Installation locations
claude_code_commands: true              # Install to .claude/commands/
agent_os_commands: false                # Install to agent-os/commands/

# Agent modes
use_claude_code_subagents: true         # Enable subagent delegation

# Standards handling
standards_as_claude_code_skills: false  # Use Skills vs file injection
```

### Configuration Hierarchy

1. **System defaults** - In base installation's `config.yml`
2. **CLI overrides** - Passed during `project-install.sh`
3. **Project config** - Stored in project's `agent-os/config.yml`

**Example Override:**
```bash
~/agent-os/scripts/project-install.sh \
  --profile rails \
  --use-claude-code-subagents false \
  --standards-as-claude-code-skills true
```

### Key Flags Explained

#### `claude_code_commands` (default: true)
- If true: Commands installed to `.claude/commands/agent-os/`
- If false: Commands not installed to .claude/

#### `agent_os_commands` (default: false)
- If true: Commands installed to `agent-os/commands/`
- Typically used when `claude_code_commands: false`

#### `use_claude_code_subagents` (default: true)
- If true: Install multi-agent mode commands, install agents
- If false: Install single-agent mode commands, no agents
- Determines which command variant is used

#### `standards_as_claude_code_skills` (default: false)
- If true: Standards handled via Skills feature, not injected
- If false: Standards injected into agent definitions
- Affects `{{UNLESS}}` blocks in templates

---

## Agent Patterns

### Agent Definition Template

```markdown
---
name: agent-name
description: Use proactively to [purpose when it should auto-trigger]
tools: Write, Read, Bash, WebFetch, Grep, Glob
color: purple
model: inherit
---

# Agent Name

[Role description and capabilities]

## What I Do

[Clear explanation of agent's purpose]

{{workflows/[category]/[workflow-name]}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

### The 8 Specialized Agents

1. **product-planner**
   - Tools: Write, Read
   - Purpose: Plans product mission and roadmap
   - Workflows: planning/create-product-mission, create-product-roadmap

2. **spec-initializer**
   - Tools: Write, Bash
   - Purpose: Creates spec folder structure
   - Workflows: specification/initialize-spec

3. **spec-shaper**
   - Tools: Write, Read
   - Purpose: Shapes requirements through Q&A
   - Workflows: specification/shape-requirements

4. **spec-writer**
   - Tools: Write, Read
   - Purpose: Writes spec.md from requirements
   - Workflows: specification/write-spec

5. **spec-verifier**
   - Tools: Read
   - Purpose: Verifies spec completeness
   - Workflows: specification/verify-spec

6. **tasks-list-creator**
   - Tools: Write, Read
   - Purpose: Creates tasks.md from spec
   - Workflows: implementation/create-tasks-list

7. **implementer**
   - Tools: Write, Read, Bash, WebFetch
   - Purpose: Implements feature from tasks
   - Workflows: implementation/implement-tasks

8. **implementation-verifier**
   - Tools: Read, Bash
   - Purpose: Verifies implementation
   - Workflows: implementation/verify-implementation

### Agent Best Practices

**1. Single Responsibility**
- One clear purpose
- Don't mix concerns
- Focused workflows

**2. Minimal Tools**
- Only include needed tools
- Common combinations:
  - Write, Read (for document creation)
  - Read, Bash (for verification)
  - Write, Read, Bash, WebFetch (for implementation)

**3. Clear Descriptions**
- Start with "Use proactively to..."
- Describe when agent should auto-trigger
- Be specific about purpose

**4. Workflow Integration**
- Reference relevant workflows
- Don't duplicate workflow content
- Use template tags

**5. Standards Inclusion**
- Use conditional blocks for standards
- Respect `standards_as_claude_code_skills` flag
- Include only relevant standards if possible

---

This reference document covers the complete Agent OS architecture. Refer to it when you need deep technical details about any component.
