# Template System

Agent OS uses a template compilation system to transform profile templates into project-specific files during installation. Templates contain special tags (`{{...}}`) that get resolved into actual content, allowing for flexible, reusable components that adapt based on configuration.

The template system compiles **once** during project installation—it's not dynamic at runtime. This creates self-contained project installations with all content pre-resolved.

---

## Overview

### What is a Template?

A template is a file containing both regular content and special template tags. During installation (`project-install.sh`), Agent OS:

1. Reads each template file
2. Detects template tags (`{{...}}`)
3. Resolves tags by injecting content or evaluating conditionals
4. Writes compiled output to the project

**Example Template (before compilation):**
```markdown
---
name: spec-writer
---

# Spec Writer Agent

{{workflows/specification/write-spec}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**Compiled Output (after installation):**
```markdown
---
name: spec-writer
---

# Spec Writer Agent

[entire contents of write-spec.md workflow injected here]

[all standards files injected here if flag is false]
```

### Why Templates?

**Reusability**: Write workflows once, inject into multiple commands/agents

**Flexibility**: Same source creates different outputs based on configuration

**Maintainability**: Update workflow in one place, affects all consumers

**Self-Containment**: Compiled projects have no external dependencies

---

## How Template Compilation Works

### Compilation Process

```
Source Template                    Compilation                    Compiled Output
(profiles/default/)               (during install)                (project/)
      │                                  │                              │
      │  {{workflows/path/file}}        │                              │
      ├──────────────────────────────>  │  Read referenced file        │
      │                                  │  Inject content inline  ────>│  [file contents]
      │                                  │                              │
      │  {{standards/*}}                 │                              │
      ├──────────────────────────────>  │  Read all standards          │
      │                                  │  Concatenate & inject   ────>│  [all standards]
      │                                  │                              │
      │  {{UNLESS flag}}...{{ENDUNLESS}} │                              │
      ├──────────────────────────────>  │  Check config.yml            │
      │                                  │  Include or omit        ────>│  [content or empty]
      │                                  │                              │
```

### Function: `compile_template()`

**Location:** `scripts/common-functions.sh`

**Signature:**
```bash
compile_template(source_file, dest_file, config_flags)
```

**Process:**
1. **Read source file line by line**
2. **Detect template tags** - Look for `{{...}}`
3. **For workflow/standards tags:**
   - Extract file path from tag
   - Read referenced file(s)
   - Inject content inline at tag location
   - Recursively compile injected content
4. **For conditional blocks:**
   - Extract flag name from `{{UNLESS flag}}`
   - Check flag value in config
   - Include or exclude block content based on flag
5. **Write compiled output** to destination file

**Characteristics:**

- **Recursive**: Templates can include other templates which include more templates
- **One-time**: Compiles during installation, not at runtime
- **Configuration-aware**: Respects all `config.yml` flags
- **Error handling**: Reports missing files with clear error messages

---

## Template Tags

Agent OS supports three types of template tags:

### 1. Workflow Injection

**Syntax:**
```markdown
{{workflows/path/file}}
```

**Purpose:** Inject the entire contents of a workflow file

**Path Format:**
- Relative to `profiles/[profile]/workflows/`
- No `.md` extension needed
- Use `/` for subdirectories

**Example in agent definition:**

`profiles/default/agents/spec-writer.md`:
```markdown
---
name: spec-writer
description: Use proactively to write formal specifications
tools: Write, Read
---

# Spec Writer

I write formal specification documents following Agent OS standards.

{{workflows/specification/write-spec}}
```

**Compiles to:**

`.claude/agents/agent-os/spec-writer.md` (in project):
```markdown
---
name: spec-writer
description: Use proactively to write formal specifications
tools: Write, Read
---

# Spec Writer

I write formal specification documents following Agent OS standards.

# Write Specification

## Core Responsibilities

1. Transform shaped requirements into formal specification document
2. Follow strict specification structure and format
3. Ensure completeness without including implementation code
4. Create clear, actionable requirements for implementers

[rest of write-spec.md workflow injected here...]
```

**Real Examples from Agent OS:**

```bash
# From profiles/default/agents/tasks-list-creator.md
{{workflows/implementation/create-tasks-list}}

# From profiles/default/agents/product-planner.md
{{workflows/planning/create-product-mission}}
{{workflows/planning/create-product-roadmap}}
{{workflows/planning/create-product-tech-stack}}

# From profiles/default/agents/implementer.md
{{workflows/implementation/implement-tasks}}
```

---

### 2. Standards Injection

**Syntax:**
```markdown
{{standards/*}}                    # All standards
{{standards/global/*}}             # Just global/
{{standards/frontend/*}}           # Just frontend/
{{standards/backend/*}}            # Just backend/
{{standards/testing/*}}            # Just testing/
```

**Purpose:** Inject coding standards from profile

**Path Patterns:**
- `*` means "all files in this directory"
- Works with subdirectories: `standards/global/*`
- Concatenates multiple files in alphabetical order

**Example in agent definition:**

`profiles/default/agents/implementer.md`:
```markdown
---
name: implementer
tools: Write, Read, Bash, WebFetch
---

# Implementer

{{workflows/implementation/implement-tasks}}

## Coding Standards

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**Compiles to (if `standards_as_claude_code_skills: false`):**

`.claude/agents/agent-os/implementer.md`:
```markdown
---
name: implementer
tools: Write, Read, Bash, WebFetch
---

# Implementer

[implement-tasks workflow injected here...]

## Coding Standards

# Tech Stack

[contents of standards/global/tech-stack.md]

# Coding Style

[contents of standards/global/coding-style.md]

# Conventions

[contents of standards/global/conventions.md]

[... all other standards files concatenated ...]
```

**Selective Injection:**

```markdown
## Global Standards
{{standards/global/*}}

## Frontend Standards
{{standards/frontend/*}}

## Backend Standards
{{standards/backend/*}}
```

This injects only specific standard categories.

---

### 3. Conditional Blocks

**Syntax:**
```markdown
{{UNLESS flag}}
[content to include if flag is false]
{{ENDUNLESS flag}}
```

**Purpose:** Include or exclude content based on configuration flags

**Behavior:**
- If flag is `false` → includes content
- If flag is `true` → omits content entirely

**Available Flags:**
- `standards_as_claude_code_skills`
- `use_claude_code_subagents`
- `claude_code_commands`
- `agent_os_commands`

**Example - Standards Injection:**

```markdown
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**Behavior:**
- **If `standards_as_claude_code_skills: false`** → Standards injected inline
- **If `standards_as_claude_code_skills: true`** → Standards omitted (Agent uses Claude Code Skills feature instead)

**Example - Agent Mode:**

```markdown
{{UNLESS use_claude_code_subagents}}
This content only appears in single-agent mode.
{{ENDUNLESS use_claude_code_subagents}}
```

**Real Usage in Agent OS:**

All 8 agents use conditional standards injection:

```markdown
# From profiles/default/agents/spec-writer.md
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

# From profiles/default/agents/implementer.md
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

# From profiles/default/agents/tasks-list-creator.md
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

---

## Template Locations

### Source Templates (Before Compilation)

Templates live in your base installation's profiles:

```
~/agent-os/profiles/default/
├── agents/                  # Agent templates (use workflow + standards injection)
│   ├── product-planner.md  # {{workflows/planning/...}}
│   ├── spec-writer.md      # {{workflows/specification/...}}
│   ├── implementer.md      # {{workflows/implementation/...}}
│   └── ...
│
├── commands/
│   ├── single-agent/       # Single-agent command templates
│   │   ├── plan-product.md    # {{workflows/planning/...}} + {{standards/*}}
│   │   ├── write-spec.md      # {{workflows/specification/...}} + {{standards/*}}
│   │   └── ...
│   │
│   └── multi-agent/        # Multi-agent command templates
│       ├── plan-product.md    # Delegates to agent (minimal templates)
│       ├── write-spec.md      # Delegates to agent (minimal templates)
│       └── ...
│
└── workflows/              # Pure content (no template tags)
    ├── planning/
    │   ├── create-product-mission.md      # Source material
    │   ├── create-product-roadmap.md      # Source material
    │   └── create-product-tech-stack.md   # Source material
    │
    ├── specification/
    │   ├── write-spec.md                  # Source material
    │   └── ...
    │
    └── implementation/
        ├── implement-tasks.md             # Source material
        └── ...
```

**Key Insight:** Workflows contain pure content (no tags), while agents and commands contain templates that inject workflows.

### Compiled Output (After Installation)

Templates compile into your project directory:

**If `claude_code_commands: true` (Claude Code):**

```
project/
├── .claude/
│   ├── commands/agent-os/  # Compiled commands
│   │   ├── plan-product.md        # ✓ Templates resolved
│   │   ├── write-spec.md          # ✓ Templates resolved
│   │   └── ...
│   │
│   └── agents/agent-os/    # Compiled agents (if subagents enabled)
│       ├── product-planner.md     # ✓ Templates resolved
│       ├── spec-writer.md         # ✓ Templates resolved
│       └── ...
│
└── agent-os/
    ├── workflows/          # Reference copies (also compiled)
    │   ├── planning/
    │   ├── specification/
    │   └── implementation/
    │
    └── standards/          # Reference copies
        ├── global/
        ├── frontend/
        ├── backend/
        └── testing/
```

**If `agent_os_commands: true` (Cursor/Windsurf):**

```
project/
└── agent-os/
    ├── commands/           # Compiled commands here instead
    │   ├── plan-product.md
    │   ├── write-spec.md
    │   └── ...
    │
    ├── workflows/
    ├── standards/
    └── ...
```

---

## Advanced Template Patterns

### Nested Template Injection

Templates can reference other templates, which can reference more templates. Compilation is fully recursive.

**Example:**

`profiles/default/agents/product-planner.md`:
```markdown
{{workflows/planning/create-product-mission}}
```

`profiles/default/workflows/planning/create-product-mission.md` might contain:
```markdown
# Create Product Mission

{{workflows/planning/gather-product-info}}

[more content...]
```

**Result:** Both workflows get injected recursively into the final agent.

### Conditional Nesting

You can nest conditionals and injections:

```markdown
{{UNLESS use_claude_code_subagents}}
  # Single-Agent Mode Instructions

  {{workflows/implementation/implement-tasks}}

  {{UNLESS standards_as_claude_code_skills}}
    {{standards/*}}
  {{ENDUNLESS standards_as_claude_code_skills}}
{{ENDUNLESS use_claude_code_subagents}}
```

**Behavior:**
- If `use_claude_code_subagents: false` → includes everything
- Within that, if `standards_as_claude_code_skills: false` → also includes standards

### Selective Standards Injection

Inject only specific standard categories:

```markdown
## Global Standards
{{standards/global/*}}

## Frontend Standards (if applicable)
{{standards/frontend/*}}

## Backend Standards (if applicable)
{{standards/backend/*}}

## Testing Standards
{{standards/testing/*}}
```

This gives you fine-grained control over which standards get injected where.

---

## Testing Template Compilation

### Dry Run Mode

Preview what would be compiled without writing files:

```bash
~/agent-os/scripts/project-install.sh --dry-run
```

**Output shows:**
```
Agent OS Project Installation (Dry Run)
========================================

Would install profile: default
Would create directories:
  - .claude/commands/agent-os/
  - .claude/agents/agent-os/
  - agent-os/product/
  - agent-os/specs/

Would compile templates:
  - agents/product-planner.md → .claude/agents/agent-os/product-planner.md
    - Injects: workflows/planning/gather-product-info
    - Injects: workflows/planning/create-product-mission
    - Injects: workflows/planning/create-product-roadmap
    - Injects: workflows/planning/create-product-tech-stack
    - Injects: standards/* (conditional: standards_as_claude_code_skills=false)

  [... more files ...]

No files written (dry run mode).
```

### Verify Compilation

After installation, verify templates compiled correctly:

```bash
# Check a compiled file
cat project/.claude/agents/agent-os/spec-writer.md

# Look for issues:
# ✓ No remaining {{tags}}
# ✓ Content injected where expected
# ✓ Conditional blocks behaved correctly
```

**Check for unresolved tags:**
```bash
grep -r "{{" project/.claude/
# Should return nothing if compilation succeeded
```

### Manual Compilation Testing

Test template compilation for a single file:

```bash
# Navigate to base installation
__zoxide_cd ~/agent-os

# Source common functions
source scripts/common-functions.sh

# Compile a template manually
compile_template \
  profiles/default/agents/spec-writer.md \
  /tmp/claude/test-output.md \
  "standards_as_claude_code_skills=false use_claude_code_subagents=true"

# Examine output
cat /tmp/claude/test-output.md
```

---

## Common Issues & Solutions

### Issue 1: Tag Not Resolved

**Symptom:**
```markdown
{{workflows/specification/write-spec}}
```
Still appears in compiled output.

**Cause:** Referenced file doesn't exist

**Solution:**
```bash
# Check if workflow exists
ls ~/agent-os/profiles/default/workflows/specification/write-spec.md

# If missing, create it or fix the path
```

**Error Message:**
```
ERROR: Template compilation failed
  File: agents/spec-writer.md
  Tag: {{workflows/specification/write-spec}}
  Cause: Source file not found
  Path: ~/agent-os/profiles/default/workflows/specification/write-spec.md
```

### Issue 2: Standards Not Injected

**Symptom:** Section where standards should be is empty

**Cause:** Conditional block excluded them

**Check configuration:**
```bash
# View config
cat ~/agent-os/config.yml | grep standards_as_claude_code_skills

# If true, standards won't be injected (uses Skills instead)
standards_as_claude_code_skills: true
```

**Solution:** Either accept Skills mode, or set flag to `false`:
```yaml
standards_as_claude_code_skills: false
```

### Issue 3: Duplicate Content

**Symptom:** Same workflow or standards appear multiple times

**Cause:** Multiple tags referencing the same file

**Example:**
```markdown
{{workflows/implementation/implement-tasks}}

## Implementation Details

{{workflows/implementation/implement-tasks}}  # Duplicate!
```

**Solution:** Usually intentional (e.g., reference + full content). Verify it's correct, or remove duplicate tag.

### Issue 4: Compilation Hangs

**Symptom:** `project-install.sh` runs forever

**Cause:** Circular template reference

**Example:**
```markdown
# workflow-a.md
{{workflows/category/workflow-b}}

# workflow-b.md
{{workflows/category/workflow-a}}  # Circular!
```

**Solution:** Remove circular reference. Templates should form a tree, not a cycle.

---

## Debugging Template Issues

### Enable Verbose Output

Run installation with bash debug mode:

```bash
bash -x ~/agent-os/scripts/project-install.sh
```

**Output shows:**
```bash
+ compile_template profiles/default/agents/spec-writer.md ...
+ detect_tag {{workflows/specification/write-spec}}
+ read_file profiles/default/workflows/specification/write-spec.md
+ inject_content [contents...]
[... detailed trace ...]
```

### Check Template Syntax

**Tag Balance:**
```bash
# Count opening tags
grep -o "{{" file.md | wc -l

# Count closing tags
grep -o "}}" file.md | wc -l

# Should be equal
```

**Flag Names:**
```bash
# Extract flag names from template
grep "{{UNLESS" file.md | sed 's/.*{{UNLESS \(.*\)}}/\1/'

# Verify against config.yml
cat ~/agent-os/config.yml
```

**File Paths:**
```bash
# Extract workflow paths
grep "{{workflows/" file.md | sed 's/.*{{workflows\/\(.*\)}}/\1/'

# Check each exists
for path in $(grep "{{workflows/" file.md | sed 's/.*{{workflows\/\(.*\)}}/\1/'); do
  ls ~/agent-os/profiles/default/workflows/$path.md
done
```

### Verify Source Files

**Check workflow exists:**
```bash
ls ~/agent-os/profiles/default/workflows/[path]/[file].md
```

**Check standards exist:**
```bash
ls ~/agent-os/profiles/default/standards/
```

**List all template tags in a file:**
```bash
grep -o "{{[^}]*}}" file.md
```

---

## Best Practices

### 1. Keep Templates Simple

**Good:**
```markdown
{{workflows/specification/write-spec}}
```

**Avoid:**
```markdown
{{workflows/specification/write-spec-{{UNLESS some_flag}}extended{{ENDUNLESS some_flag}}-version}}
```

- Use clear, obvious tag names
- Avoid deeply nested conditionals
- Document why each tag is needed

### 2. Test After Changes

**Always:**
```bash
# Run dry-run first
~/agent-os/scripts/project-install.sh --dry-run

# Verify output
cat project/.claude/agents/agent-os/[file].md

# Test in isolated project
mkdir /tmp/test-project && cd /tmp/test-project
~/agent-os/scripts/project-install.sh
```

### 3. Reference Existing Files

**Before adding a tag:**
```bash
# Verify file exists
ls ~/agent-os/profiles/default/workflows/[path]/[file].md

# Preview file contents
head -20 ~/agent-os/profiles/default/workflows/[path]/[file].md
```

Typos in paths break compilation with clear error messages, but it's better to check first.

### 4. Use Conditionals Wisely

**Good use:**
```markdown
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

Clear purpose: "Inject standards unless using Skills feature"

**Questionable use:**
```markdown
{{UNLESS some_custom_flag}}
[Large amount of content]
{{ENDUNLESS some_custom_flag}}
```

If content is significantly different, consider separate profile or files.

### 5. Document Template Usage

Add comments explaining template tags:

```markdown
# Inject core workflow
{{workflows/specification/write-spec}}

# Include standards if not using Skills feature
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

---

## Template System Limitations

### Not Dynamic

Templates compile **once** during installation. They don't re-compile at runtime.

**Implication:** Updating a workflow in base installation doesn't affect already-installed projects. You must run `project-update.sh` to pull updates.

### Fixed Tag Types

Only three tag types are supported:
1. Workflow injection: `{{workflows/path/file}}`
2. Standards injection: `{{standards/*}}`
3. Conditional blocks: `{{UNLESS flag}}...{{ENDUNLESS flag}}`

**Cannot:**
- Create custom tag types
- Use variables: `{{VAR_NAME}}`
- Perform string substitution: `{{REPLACE:old:new}}`

**To extend:** Modify `compile_template()` function in `scripts/common-functions.sh`

### Configuration Flags Only

Conditionals work only with configuration flags from `config.yml`:
- `standards_as_claude_code_skills`
- `use_claude_code_subagents`
- `claude_code_commands`
- `agent_os_commands`

**Cannot:**
- Use environment variables
- Check file existence
- Evaluate complex expressions

---

## Creating New Template Tags (Advanced)

The template system is **closed** by default—only the three tag types above are supported.

### Extending the System

To add new tag types, modify `scripts/common-functions.sh`:

```bash
compile_template() {
  local source_file="$1"
  local dest_file="$2"
  local config="$3"

  # Existing workflow injection
  if [[ $line =~ \{\{workflows/([^}]+)\}\} ]]; then
    # ... existing code ...
  fi

  # Existing standards injection
  if [[ $line =~ \{\{standards/([^}]+)\}\} ]]; then
    # ... existing code ...
  fi

  # Existing conditional blocks
  if [[ $line =~ \{\{UNLESS\ ([^}]+)\}\} ]]; then
    # ... existing code ...
  fi

  # ADD NEW TAG TYPE HERE
  if [[ $line =~ \{\{CUSTOM_TAG\ ([^}]+)\}\} ]]; then
    # Custom logic
  fi
}
```

**Note:** This is advanced usage. Most users should use existing tag types.

---

## Template System Evolution

**Current Version:** 2.1.2

**Tag Types:** 3 (workflow, standards, conditional)

**Features:**
- Recursive compilation
- Configuration-aware conditionals
- Error handling with clear messages
- Dry-run mode for testing

**Not Supported (Yet):**
- Dynamic/runtime compilation
- Variable substitution
- Custom tag types (without modifying scripts)
- Complex expressions in conditionals

**Future Considerations:**
- Variable substitution: `{{VAR:profile_name}}`
- Custom tag registration: `register_tag_type("custom", handler_func)`
- Runtime template resolution (for dynamic content)
- Conditional expressions: `{{IF flag1 AND flag2}}`

---

## Quick Reference

### Template Tag Syntax

```markdown
# Workflow injection
{{workflows/path/file}}

# Standards injection (all)
{{standards/*}}

# Standards injection (selective)
{{standards/global/*}}
{{standards/frontend/*}}

# Conditional block
{{UNLESS flag}}
[content]
{{ENDUNLESS flag}}
```

### Testing Commands

```bash
# Dry run
~/agent-os/scripts/project-install.sh --dry-run

# Debug mode
bash -x ~/agent-os/scripts/project-install.sh

# Check for unresolved tags
grep -r "{{" project/.claude/
```

### Common Flags

```yaml
standards_as_claude_code_skills: false  # Inject standards inline
use_claude_code_subagents: true         # Enable multi-agent mode
claude_code_commands: true              # Install to .claude/commands/
agent_os_commands: false                # Install to agent-os/commands/
```

---

## Related Documentation

- **[profile-system.md](profile-system.md)** - Three-tier architecture and profiles
- **[configuration-system.md](configuration-system.md)** - Config flags and hierarchy
- **[script-architecture.md](script-architecture.md)** - Script functions including compile_template()
- **[agent-patterns.md](agent-patterns.md)** - How agents use workflow injection
- **[workflow-patterns.md](workflow-patterns.md)** - Workflow structure and patterns
