# Script Architecture

Agent OS uses bash scripts for installation, updates, and profile management. All scripts follow common patterns, share utilities via `common-functions.sh`, and use strict error handling with `set -euo pipefail`.

Understanding the script architecture helps when customizing installations, debugging issues, or extending Agent OS functionality.

---

## Overview

### Script Files

Agent OS includes five main scripts:

```
scripts/
├── common-functions.sh    # Shared utilities (20+ functions)
├── base-install.sh        # Base installation to ~/agent-os
├── project-install.sh     # Install profile into project
├── project-update.sh      # Update existing installation
└── create-profile.sh      # Create custom profiles
```

### Common Patterns

**All scripts use:**
- `set -euo pipefail` - Strict error handling
- `source common-functions.sh` - Shared utilities
- Color-coded output (print_status, print_success, print_error)
- YAML parsing for config.yml
- User confirmation for destructive operations

---

## common-functions.sh

Shared utilities for all scripts. Contains 20+ functions organized into categories.

### Output Functions

**Color-coded terminal output:**

```bash
print_section(message)
# Prints bold section header
# Example: print_section "Agent OS Installation"
# Output: Agent OS Installation (bold)

print_status(message)
# Prints blue status message
# Example: print_status "Installing profile..."
# Output: Installing profile... (blue)

print_success(message)
# Prints green success message
# Example: print_success "✓ Installation complete"
# Output: ✓ Installation complete (green)

print_warning(message)
# Prints yellow warning
# Example: print_warning "File already exists"
# Output: File already exists (yellow)

print_error(message)
# Prints red error and exits
# Example: print_error "Profile not found"
# Output: Profile not found (red, exits with code 1)

print_verbose(message)
# Prints only if VERBOSE=1
# Example: print_verbose "Reading config..."
# Output: Reading config... (only in verbose mode)
```

**Usage in scripts:**
```bash
print_section "Agent OS Project Installation"
print_status "Reading configuration..."
print_success "✓ Profile installed successfully"
```

### YAML Parsing

**Extract values from config.yml:**

```bash
get_yaml_value(file, key, default)
# Extract value from YAML file
# Handles tabs, quotes, indentation
# Returns default if key not found

# Example:
profile=$(get_yaml_value "config.yml" "profile" "default")
# Returns: "default" or value from config.yml

version=$(get_yaml_value "config.yml" "version" "0.0.0")
# Returns: "2.1.2" from config.yml

use_subagents=$(get_yaml_value "config.yml" "use_claude_code_subagents" "true")
# Returns: "true" or "false"
```

**Implementation details:**
- Parses YAML line by line
- Handles quoted and unquoted values
- Respects YAML indentation
- Strips comments
- Normalizes boolean values

```bash
get_yaml_array(file, key)
# Extract array values from YAML
# Returns space-separated list

# Example config.yml:
# tools:
#   - Write
#   - Read
#   - Bash

tools=$(get_yaml_array "agent.md" "tools")
# Returns: "Write Read Bash"
```

### File Operations

```bash
ensure_dir(directory)
# Create directory if it doesn't exist
# Creates parent directories as needed
# Example: ensure_dir ".claude/commands/agent-os"

copy_file(source, destination)
# Copy file and create parent directories
# Preserves permissions
# Example: copy_file "profile/agent.md" ".claude/agents/agent.md"

write_file(content, destination)
# Write content to file
# Creates parent directories
# Example: write_file "$compiled_content" "output.md"

should_skip_file(path, exclusions)
# Check if file matches exclusion patterns
# Used for .git, .DS_Store, etc.
# Returns: 0 if should skip, 1 otherwise

# Example:
if should_skip_file "$file" ".git .DS_Store"; then
  continue
fi
```

### Template Compilation

**Core template system functions:**

```bash
compile_template(source_file, dest_file, config)
# Main compilation function
# Resolves {{template_tags}}
# Processes {{UNLESS}} blocks
# Recursive compilation

# Example:
compile_template \
  "profiles/default/agents/spec-writer.md" \
  ".claude/agents/agent-os/spec-writer.md" \
  "standards_as_claude_code_skills=false use_claude_code_subagents=true"
```

**Process:**
1. Read source file line by line
2. Detect template tags (`{{...}}`)
3. For `{{workflows/path}}`:
   - Read referenced workflow file
   - Inject content inline
   - Recursively compile injected content
4. For `{{standards/*}}`:
   - Find all matching standard files
   - Concatenate and inject
5. For `{{UNLESS flag}}...{{ENDUNLESS}}`:
   - Check config flag value
   - Include or exclude block
6. Write compiled output

**Supporting functions:**

```bash
get_profile_file(profile, file_path)
# Get full path to profile file
# Example: get_profile_file "default" "workflows/write-spec.md"
# Returns: ~/agent-os/profiles/default/workflows/write-spec.md

get_profile_files(profile, pattern)
# Get all files matching pattern
# Example: get_profile_files "default" "standards/global/*"
# Returns: List of matching files

match_pattern(file, pattern)
# Check if file matches glob pattern
# Used for standards/* patterns
```

### Profile Functions

```bash
normalize_name(name)
# Normalize profile/file name
# Converts to lowercase, replaces spaces with hyphens
# Example: normalize_name "My Profile" → "my-profile"

replace_playwright_tools(content)
# Replace Playwright with Puppeteer in tools list
# Agent OS compatibility function
```

### Validation

```bash
validate_base_installation()
# Verify base install exists at ~/agent-os
# Check required directories present
# Exit with error if invalid

validate_profile(profile_name)
# Check if profile exists
# Verify required directories
# Exit with error if invalid

confirm_action(message)
# Prompt user for yes/no confirmation
# Returns: 0 for yes, 1 for no

# Example:
if confirm_action "Overwrite existing files?"; then
  # User said yes
  overwrite_files
fi
```

---

## base-install.sh

Installs Agent OS base to local machine (usually `~/agent-os`).

### Usage

```bash
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash

# Or with custom location:
INSTALL_DIR=~/my-agent-os bash base-install.sh
```

### Process

**Step 1: Prompt for Location**
```
Agent OS Base Installation
==========================

Install directory [~/agent-os]:
```

**Step 2: Create Directory Structure**
```bash
~/agent-os/
├── profiles/
│   └── default/      # Copied from repo
├── scripts/          # Copied from repo
├── config.yml        # Created with defaults
├── CHANGELOG.md      # Copied from repo
└── README.md         # Copied from repo
```

**Step 3: Copy Files**
- Downloads or copies default profile
- Copies all scripts
- Copies documentation files

**Step 4: Create config.yml**
```yaml
version: 2.1.2
base_install: true
profile: default
claude_code_commands: true
agent_os_commands: false
use_claude_code_subagents: true
standards_as_claude_code_skills: false
```

**Step 5: Show Next Steps**
```
✓ Agent OS base installed to ~/agent-os

Next steps:
1. cd ~/your-project
2. ~/agent-os/scripts/project-install.sh
```

### Key Functions

```bash
download_agent_os()
# Download Agent OS from GitHub
# Or copy from local repository

setup_directory_structure()
# Create required directories

copy_default_profile()
# Copy profiles/default/

create_base_config()
# Generate config.yml

show_completion_message()
# Display next steps
```

---

## project-install.sh

Installs Agent OS profile into a project directory.

### Usage

```bash
# Basic (uses defaults from ~/agent-os/config.yml)
~/agent-os/scripts/project-install.sh

# With options
~/agent-os/scripts/project-install.sh --profile rails

# Full customization
~/agent-os/scripts/project-install.sh \
  --profile nextjs \
  --use-claude-code-subagents false \
  --standards-as-claude-code-skills true \
  --dry-run
```

### CLI Flags

```bash
--profile NAME                     # Profile to install (default: from config)
--claude-code-commands BOOL        # Install to .claude/commands/
--agent-os-commands BOOL           # Install to agent-os/commands/
--use-claude-code-subagents BOOL   # Enable subagent mode
--standards-as-claude-code-skills BOOL  # Use Skills vs injection
--dry-run                          # Preview without installing
--verbose                          # Show detailed output
```

### Process

**Step 1: Validate Base Installation**
```bash
# Check ~/agent-os exists
validate_base_installation

# Read base config.yml
BASE_CONFIG=~/agent-os/config.yml
```

**Step 2: Merge Configuration**
```bash
# Start with base defaults
profile=$(get_yaml_value "$BASE_CONFIG" "profile" "default")
claude_code_commands=$(get_yaml_value "$BASE_CONFIG" "claude_code_commands" "true")
# ... read all flags

# Apply CLI overrides
if [[ $PROFILE_FLAG != "" ]]; then
  profile=$PROFILE_FLAG
fi
# ... override all flags from CLI
```

**Step 3: Validate Profile**
```bash
validate_profile "$profile"
# Checks: ~/agent-os/profiles/$profile/ exists
```

**Step 4: Create Directory Structure**
```bash
# If claude_code_commands=true
ensure_dir ".claude/commands/agent-os"

# If use_claude_code_subagents=true
ensure_dir ".claude/agents/agent-os"

# Always create
ensure_dir "agent-os/product"
ensure_dir "agent-os/specs"
```

**Step 5: Compile and Copy Files**

**Commands:**
```bash
if [[ $claude_code_commands == "true" ]]; then
  # Multi-agent or single-agent commands
  if [[ $use_claude_code_subagents == "true" ]]; then
    source_commands="profiles/$profile/commands/multi-agent/"
  else
    source_commands="profiles/$profile/commands/single-agent/"
  fi

  for command in $source_commands*.md; do
    compile_template "$command" ".claude/commands/agent-os/$(basename $command)" "$config"
  done
fi
```

**Agents (if multi-agent mode):**
```bash
if [[ $use_claude_code_subagents == "true" ]]; then
  for agent in profiles/$profile/agents/*.md; do
    compile_template "$agent" ".claude/agents/agent-os/$(basename $agent)" "$config"
  done
fi
```

**Workflows (reference copy):**
```bash
for workflow in profiles/$profile/workflows/**/*.md; do
  copy_file "$workflow" "agent-os/workflows/$relative_path"
done
```

**Standards (reference copy):**
```bash
for standard in profiles/$profile/standards/**/*.md; do
  copy_file "$standard" "agent-os/standards/$relative_path"
done
```

**Step 6: Create Project config.yml**
```bash
# Record configuration used
write_file "$project_config" "agent-os/config.yml"
```

**Step 7: Report Results**
```
Agent OS Project Installation
=============================

Profile: rails
Configuration:
  claude_code_commands: true
  use_claude_code_subagents: false
  standards_as_claude_code_skills: false

Installed:
  ✓ Commands → .claude/commands/agent-os/ (6 files)
  ✓ Workflows → agent-os/workflows/ (9 files)
  ✓ Standards → agent-os/standards/ (12 files)

Next steps:
1. Run /plan-product to start
2. See agent-os/README.md for workflows
```

### Dry-Run Mode

**When `--dry-run` is specified:**
```bash
DRY_RUN=true

# Simulates installation without writing files
print_status "Would create directory: .claude/commands/agent-os"
print_status "Would compile: agents/spec-writer.md"
print_status "  → Injects: workflows/specification/write-spec"
print_status "  → Injects: standards/* (conditional)"
```

**Useful for:**
- Previewing installation
- Checking template compilation
- Verifying configuration
- Testing changes before applying

---

## project-update.sh

Updates existing project installation from base.

### Usage

```bash
# Interactive (prompts for options)
~/agent-os/scripts/project-update.sh

# Selective update
~/agent-os/scripts/project-update.sh --overwrite-standards

# Complete update
~/agent-os/scripts/project-update.sh --overwrite-all

# With new configuration
~/agent-os/scripts/project-update.sh \
  --use-claude-code-subagents false \
  --overwrite-agents
```

### CLI Flags

```bash
--overwrite-all          # Replace everything
--overwrite-standards    # Just standards
--overwrite-workflows    # Just workflows
--overwrite-agents       # Just agents
--overwrite-commands     # Just commands
--preserve-custom        # Preserve local customizations (default)
--force                  # Skip confirmation prompts
```

### Process

**Step 1: Check Current Installation**
```bash
# Verify project has Agent OS installed
if [[ ! -f "agent-os/config.yml" ]]; then
  print_error "No Agent OS installation found"
  exit 1
fi

# Read current configuration
current_profile=$(get_yaml_value "agent-os/config.yml" "profile")
current_version=$(get_yaml_value "agent-os/config.yml" "version")
```

**Step 2: Compare Versions**
```bash
base_version=$(get_yaml_value "~/agent-os/config.yml" "version")

print_status "Current version: $current_version"
print_status "Base version: $base_version"

if [[ $current_version == $base_version ]]; then
  print_warning "Already at latest version"
fi
```

**Step 3: Detect Changes**
```bash
# Compare file checksums
detect_modified_files() {
  # Check which files user has customized
  # Mark for preservation unless --force
}
```

**Step 4: Preview Changes**
```
Agent OS Update
===============

Profile: default
Current version: 2.1.1
New version: 2.1.2

Changes:
  standards/global/tech-stack.md     MODIFIED
  standards/frontend/components.md   NEW
  workflows/implement-tasks.md       MODIFIED

Local customizations detected:
  standards/global/conventions.md    (will preserve)

Proceed with update? [y/N]:
```

**Step 5: Selective Update**
```bash
if [[ $OVERWRITE_STANDARDS == "true" ]]; then
  update_standards
fi

if [[ $OVERWRITE_WORKFLOWS == "true" ]]; then
  update_workflows
fi

if [[ $OVERWRITE_AGENTS == "true" ]]; then
  update_agents
fi

if [[ $OVERWRITE_COMMANDS == "true" ]]; then
  update_commands
fi
```

**Step 6: Update config.yml**
```bash
# Update version
update_config_value "version" "$base_version"

# Apply new configuration flags if provided
if [[ $NEW_USE_SUBAGENTS != "" ]]; then
  update_config_value "use_claude_code_subagents" "$NEW_USE_SUBAGENTS"
fi
```

**Step 7: Report Results**
```
✓ Updated standards (3 files)
✓ Preserved local changes to conventions.md
✓ Project updated to version 2.1.2

Run /write-spec to test updated workflows.
```

### Preservation Logic

**Preserves by default:**
- Files with local modifications
- Custom workflows not in base
- Custom standards not in base

**Overwrites:**
- Files explicitly included in --overwrite-* flags
- Files without local modifications
- If --overwrite-all specified

---

## create-profile.sh

Creates custom profiles interactively.

### Usage

```bash
~/agent-os/scripts/create-profile.sh
```

Interactive prompts guide the process.

### Process

**Step 1: Prompt for Name**
```
Create New Agent OS Profile
===========================

Profile name: rails
```

**Step 2: Choose Creation Method**
```
Choose creation method:
1. Inherit from existing profile (links to source)
2. Copy existing profile (independent copy)
3. Start from scratch (empty structure)

Selection [1-3]: 2
```

**Step 3: Select Source (if inherit/copy)**
```
Available profiles:
- default
- nextjs
- django

Source profile: default
```

**Step 4: Create Profile**

**If inherit:**
```bash
# Create directory structure
ensure_dir "profiles/rails/agents"
ensure_dir "profiles/rails/commands"
ensure_dir "profiles/rails/workflows"
ensure_dir "profiles/rails/standards"

# Create symbolic links
ln -s ../default/agents/* profiles/rails/agents/
ln -s ../default/commands/* profiles/rails/commands/
# ... link all directories
```

**If copy:**
```bash
# Copy entire profile
cp -r profiles/default/* profiles/rails/
```

**If from scratch:**
```bash
# Create empty structure
mkdir -p profiles/rails/{agents,commands,workflows,standards}
mkdir -p profiles/rails/commands/{single-agent,multi-agent}
mkdir -p profiles/rails/workflows/{planning,specification,implementation}
mkdir -p profiles/rails/standards/{global,frontend,backend,testing}

# Create README
create_profile_readme "profiles/rails/README.md"
```

**Step 5: Completion Message**
```
✓ Created profile: rails

Directory: ~/agent-os/profiles/rails/

Next steps:
1. Customize files in ~/agent-os/profiles/rails/
2. Add Rails-specific workflows/standards
3. Install into project:
   ~/agent-os/scripts/project-install.sh --profile rails
```

---

## Error Handling

### Strict Mode

All scripts use:
```bash
set -euo pipefail

# -e: Exit on error
# -u: Exit on undefined variable
# -o pipefail: Exit if any command in pipeline fails
```

### Error Functions

```bash
print_error(message)
# Print red error and exit with code 1

validate_or_exit(condition, message)
# Check condition, exit with message if false

trap_error()
# Catch and report unexpected errors
```

### Common Error Messages

```
ERROR: Base installation not found
  → Run base-install.sh first

ERROR: Profile 'rails' not found
  → Create with create-profile.sh or check spelling

ERROR: Template compilation failed
  File: agents/spec-writer.md
  Tag: {{workflows/missing-file}}
  → Check workflow path exists

ERROR: Insufficient permissions
  → Run with appropriate permissions
```

---

## Testing Scripts

### Dry-Run Mode

```bash
# Test installation without writing files
~/agent-os/scripts/project-install.sh --dry-run
```

### Verbose Mode

```bash
# Show detailed execution
~/agent-os/scripts/project-install.sh --verbose
```

### Debug Mode

```bash
# Full bash trace
bash -x ~/agent-os/scripts/project-install.sh
```

### Manual Testing

```bash
# Test in isolated directory
mkdir /tmp/test-project
cd /tmp/test-project
~/agent-os/scripts/project-install.sh
```

---

## Quick Reference

### Common Functions

```bash
# Output
print_section, print_status, print_success, print_error

# YAML
get_yaml_value, get_yaml_array

# Files
ensure_dir, copy_file, write_file, should_skip_file

# Template
compile_template, get_profile_file, get_profile_files

# Validation
validate_base_installation, validate_profile, confirm_action
```

### Script Commands

```bash
# Install base
curl -sSL .../base-install.sh | bash

# Install into project
~/agent-os/scripts/project-install.sh [options]

# Update project
~/agent-os/scripts/project-update.sh [options]

# Create profile
~/agent-os/scripts/create-profile.sh
```

### Testing

```bash
--dry-run       # Preview
--verbose       # Detailed output
bash -x script  # Full trace
```

---

## Related Documentation

- **[template-system.md](template-system.md)** - Template compilation details
- **[profile-system.md](profile-system.md)** - Three-tier architecture
- **[configuration-system.md](configuration-system.md)** - Config flags used by scripts
- **[agent-os-architecture.md](agent-os-architecture.md)** - Complete architecture reference
