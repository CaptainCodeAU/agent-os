# Profile System

Agent OS uses a three-tier profile architecture that provides maximum flexibility for different project types while maintaining a single source of truth. This system allows you to define global preferences once, create specialized templates for different frameworks, and install customized Agent OS configurations into individual projects.

The three-tier model separates concerns between **base installation** (your global Agent OS), **profiles** (templates for project types), and **project installations** (self-contained copies in each codebase).

---

## Three-Tier Architecture Overview

```
┌─────────────────────────────────────┐
│   Tier 1: Base Installation         │
│   ~/agent-os/                        │
│   - Source of truth                  │
│   - Global configuration             │
│   - All profiles stored here         │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Tier 2: Profiles                  │
│   ~/agent-os/profiles/[name]/       │
│   - Templates for project types     │
│   - default, rails, nextjs, etc.    │
│   - Customizable per framework      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Tier 3: Project Installation      │
│   project/.claude/ or agent-os/     │
│   - Self-contained Agent OS copy    │
│   - Compiled from profile templates │
│   - Independent of base after setup │
└─────────────────────────────────────┘
```

This architecture enables:
- **Reusability**: Define profiles once, use across many projects
- **Customization**: Override at any tier without affecting others
- **Portability**: Projects work independently after installation
- **Maintainability**: Update base or profiles without breaking existing projects

---

## Tier 1: Base Installation

### Location

`~/agent-os/` (or custom directory specified during installation)

### Purpose

The base installation serves as the **source of truth** for all project installations. It lives on your local machine outside any specific project and contains:

- Global configuration defaults
- All available profiles (default + custom)
- Installation and management scripts
- No project-specific data

### Contents

```
~/agent-os/
├── config.yml              # Global configuration defaults
├── profiles/               # All available profiles
│   ├── default/           # Ships with Agent OS
│   ├── rails/             # Custom profile example
│   ├── nextjs/            # Custom profile example
│   └── django/            # Custom profile example
├── scripts/                # Installation & management
│   ├── common-functions.sh
│   ├── base-install.sh
│   ├── project-install.sh
│   ├── project-update.sh
│   └── create-profile.sh
├── CHANGELOG.md
└── README.md
```

### Installation

Install Agent OS base to your local machine:

```bash
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash
```

**What this does:**
1. Prompts for installation directory (default: `~/agent-os`)
2. Creates directory structure
3. Copies default profile
4. Copies all scripts
5. Creates `config.yml` with defaults
6. Shows next steps for project installation

**Installation output example:**
```
Agent OS base installation
==========================
✓ Created ~/agent-os/
✓ Installed default profile
✓ Installed scripts
✓ Created config.yml

Next steps:
1. cd ~/your-project
2. ~/agent-os/scripts/project-install.sh
```

### Characteristics

**Lives Outside Projects**
- Not tied to any specific codebase
- Persists across all your projects
- One installation serves many projects

**Customizable for Your Preferences**
- Edit `config.yml` to set global defaults
- Create custom profiles for your frameworks
- Modify scripts if needed (advanced)

**Updated Independently**
- Pull latest Agent OS updates to base
- Existing project installations unaffected
- Choose when to update each project

**Supports Multiple Profiles**
- Default profile ships with Agent OS
- Create unlimited custom profiles
- Switch profiles per project

### Configuration

The `config.yml` in base installation sets global defaults:

```yaml
version: 2.1.2
profile: default                        # Default profile to use

claude_code_commands: true              # Install to .claude/commands/
agent_os_commands: false                # Install to agent-os/commands/
use_claude_code_subagents: true         # Enable subagent delegation
standards_as_claude_code_skills: false  # Use Skills vs injection
```

These defaults apply to all new project installations unless overridden via CLI flags.

---

## Tier 2: Profiles

### Location

`~/agent-os/profiles/[name]/`

### Purpose

Profiles are **templates for different project types**. Each profile contains a complete set of agents, commands, workflows, and standards tailored for a specific framework or language.

### Available Profiles

**Default Profile** (`profiles/default/`)
- Generic, framework-agnostic
- Ships with Agent OS
- Works for any project type
- Good starting point for customization

**Custom Profiles** (user-created)
- `rails/` - Ruby on Rails projects
- `nextjs/` - Next.js applications
- `django/` - Django projects
- `fastapi/` - FastAPI services
- `[your-name]/` - Your custom profile

### Profile Structure

Every profile follows this standard structure:

```
profiles/[name]/
├── agents/                 # Claude Code subagent definitions
│   ├── product-planner.md
│   ├── spec-initializer.md
│   ├── spec-shaper.md
│   ├── spec-writer.md
│   ├── spec-verifier.md
│   ├── tasks-list-creator.md
│   ├── implementer.md
│   └── implementation-verifier.md
│
├── commands/               # Slash commands
│   ├── single-agent/      # For Cursor/Windsurf
│   │   ├── plan-product.md
│   │   ├── shape-spec.md
│   │   ├── write-spec.md
│   │   ├── create-tasks.md
│   │   ├── implement-tasks.md
│   │   └── orchestrate-tasks.md
│   │
│   └── multi-agent/       # For Claude Code with subagents
│       ├── plan-product.md
│       ├── shape-spec.md
│       ├── write-spec.md
│       ├── create-tasks.md
│       ├── implement-tasks.md
│       └── orchestrate-tasks.md
│
├── workflows/              # Step-by-step instructions
│   ├── planning/
│   │   ├── create-product-mission.md
│   │   ├── create-product-roadmap.md
│   │   └── create-tech-stack.md
│   │
│   ├── specification/
│   │   ├── initialize-spec.md
│   │   ├── shape-requirements.md
│   │   ├── write-spec.md
│   │   └── verify-spec.md
│   │
│   └── implementation/
│       ├── create-tasks-list.md
│       ├── implement-tasks.md
│       └── verify-implementation.md
│
└── standards/              # Coding standards
    ├── global/
    │   ├── tech-stack.md
    │   ├── coding-style.md
    │   ├── conventions.md
    │   ├── error-handling.md
    │   ├── commenting.md
    │   └── validation.md
    │
    ├── frontend/
    │   ├── components.md
    │   ├── css.md
    │   ├── responsive.md
    │   └── accessibility.md
    │
    ├── backend/
    │   ├── api.md
    │   ├── models.md
    │   ├── queries.md
    │   └── migrations.md
    │
    └── testing/
        └── test-writing.md
```

### Creating Custom Profiles

Use the profile creation script:

```bash
~/agent-os/scripts/create-profile.sh
```

**Interactive prompts:**
```
Create new Agent OS profile
===========================

Profile name: rails

Choose creation method:
1. Inherit from existing profile (links to source)
2. Copy existing profile (independent copy)
3. Start from scratch (empty structure)

Selection: 2

Source profile: default

✓ Created ~/agent-os/profiles/rails/
✓ Copied all files from default profile
✓ Profile ready for customization

Edit files in ~/agent-os/profiles/rails/
Then install into project: ~/agent-os/scripts/project-install.sh --profile rails
```

**Creation Options:**

**1. Inherit from Existing** (Recommended for similar frameworks)
- Links to source profile files
- Automatically gets source updates
- Override only what you need
- Best for: Minor variations (Next.js 14 vs Next.js 13)

**2. Copy Existing** (Recommended for substantial changes)
- Independent copy of all files
- No automatic updates from source
- Full control over all files
- Best for: Different frameworks (Rails vs Django)

**3. Start from Scratch** (Advanced)
- Creates empty directory structure
- Write all agents, commands, workflows, standards yourself
- Maximum flexibility, maximum work
- Best for: Completely unique workflows

### Use Cases

**Framework-Specific Profiles**

**Rails Profile:**
```yaml
# profiles/rails/standards/global/tech-stack.md
Framework: Ruby on Rails 7.x
Database: PostgreSQL with ActiveRecord
Testing: RSpec, FactoryBot
Frontend: Hotwire (Turbo + Stimulus)
```

**Next.js Profile:**
```yaml
# profiles/nextjs/standards/global/tech-stack.md
Framework: Next.js 14 with App Router
Database: Prisma + PostgreSQL
Testing: Vitest, Testing Library
Frontend: React 18, TypeScript, Tailwind CSS
```

**Django Profile:**
```yaml
# profiles/django/standards/global/tech-stack.md
Framework: Django 4.x
Database: PostgreSQL with Django ORM
Testing: pytest-django
Frontend: HTMX + Alpine.js
```

**FastAPI Profile:**
```yaml
# profiles/fastapi/standards/global/tech-stack.md
Framework: FastAPI with async/await
Database: SQLAlchemy 2.0 (async)
Testing: pytest with pytest-asyncio
API: OpenAPI 3.1, Pydantic v2
```

**Language-Specific Profiles**

- **Python**: pytest patterns, type hints, Black formatting
- **Ruby**: RSpec patterns, Rubocop standards
- **TypeScript**: Strict mode, ESLint rules, Biome config
- **Go**: Standard library first, table-driven tests
- **Rust**: Clippy lints, cargo conventions

**Organization Profiles**

- **Company Standards**: Corporate coding standards, compliance requirements
- **Team Preferences**: Team-specific tools, conventions, workflows
- **Project Templates**: Recurring project types with preset configurations

---

## Tier 3: Project Installation

### Location

Inside each project's codebase:
- `.claude/` directory (if `claude_code_commands: true`)
- `agent-os/` directory (always created)

### Purpose

Project installations are **self-contained Agent OS copies** specific to one codebase. They:
- Contain compiled templates (no runtime dependencies)
- Can be version-controlled with the project
- Work independently of base installation
- Allow per-project customization

### Installation

From within your project directory:

```bash
cd ~/my-project
~/agent-os/scripts/project-install.sh
```

**With options:**
```bash
# Use specific profile
~/agent-os/scripts/project-install.sh --profile rails

# Override configuration
~/agent-os/scripts/project-install.sh \
  --profile nextjs \
  --use-claude-code-subagents false

# Dry run (preview without installing)
~/agent-os/scripts/project-install.sh --dry-run
```

### What Gets Created

The installation structure depends on your configuration:

**If `claude_code_commands: true` (default - for Claude Code):**

```
project/
├── .claude/
│   ├── commands/
│   │   └── agent-os/              # Commands installed here
│   │       ├── plan-product.md
│   │       ├── shape-spec.md
│   │       ├── write-spec.md
│   │       ├── create-tasks.md
│   │       ├── implement-tasks.md
│   │       └── orchestrate-tasks.md
│   │
│   └── agents/
│       └── agent-os/              # Agents installed here (if subagents enabled)
│           ├── product-planner.md
│           ├── spec-initializer.md
│           ├── spec-shaper.md
│           ├── spec-writer.md
│           ├── spec-verifier.md
│           ├── tasks-list-creator.md
│           ├── implementer.md
│           └── implementation-verifier.md
│
└── agent-os/                      # Always created
    ├── product/                   # Product planning outputs
    │   ├── mission.md            # Created by /plan-product
    │   ├── roadmap.md
    │   └── tech-stack.md
    │
    ├── specs/                     # Specification outputs
    │   └── [spec-name]/          # Created by /write-spec
    │       ├── spec.md
    │       ├── tasks.md
    │       ├── planning/
    │       └── verification/
    │
    ├── workflows/                 # Compiled workflows (reference)
    │   ├── planning/
    │   ├── specification/
    │   └── implementation/
    │
    └── standards/                 # Compiled standards (reference)
        ├── global/
        ├── frontend/
        ├── backend/
        └── testing/
```

**If `agent_os_commands: true` (for Cursor/Windsurf):**

```
project/
└── agent-os/
    ├── commands/                  # Commands installed here instead
    │   ├── plan-product.md
    │   ├── shape-spec.md
    │   ├── write-spec.md
    │   ├── create-tasks.md
    │   ├── implement-tasks.md
    │   └── orchestrate-tasks.md
    │
    ├── product/                   # Same as above
    ├── specs/                     # Same as above
    ├── workflows/                 # Same as above
    └── standards/                 # Same as above
```

### Characteristics

**Self-Contained**
- No external dependencies after installation
- All templates compiled during installation
- Works even if base installation is deleted
- Project can be moved, shared, forked independently

**Customizable Per Project**
- Edit standards for project-specific conventions
- Modify workflows for unique processes
- Adjust agents for special requirements
- Changes affect only this project

**Version-Controlled**
- Usually committed to git
- Team shares same Agent OS configuration
- Changes tracked in project history
- Can diff Agent OS updates

**Updateable from Base**
- Pull updates from base installation when ready
- Selective updates (standards only, workflows only, etc.)
- Preview changes before applying
- Preserve local customizations

### Updating Installed Profile

Update an existing project installation from your base:

```bash
~/agent-os/scripts/project-update.sh
```

**Update options:**

```bash
# Replace everything (destructive)
~/agent-os/scripts/project-update.sh --overwrite-all

# Update only standards
~/agent-os/scripts/project-update.sh --overwrite-standards

# Update only workflows
~/agent-os/scripts/project-update.sh --overwrite-workflows

# Update only agents
~/agent-os/scripts/project-update.sh --overwrite-agents

# Update only commands
~/agent-os/scripts/project-update.sh --overwrite-commands
```

**Update process:**
1. Checks current installation version
2. Compares with base installation version
3. Shows what will change
4. Confirms with user before proceeding
5. Selectively updates based on flags
6. Preserves local customizations where possible

**Example update session:**
```bash
$ ~/agent-os/scripts/project-update.sh --overwrite-standards

Agent OS Project Update
=======================
Current version: 2.1.1
Base version: 2.1.2

Changes to apply:
  standards/global/tech-stack.md     MODIFIED
  standards/frontend/components.md   NEW
  standards/testing/test-writing.md  MODIFIED

Preserve local customizations? [y/N]: y

✓ Updated standards (3 files)
✓ Preserved local changes to conventions.md
✓ Project updated to 2.1.2
```

---

## Profile Workflow

The complete profile workflow from installation to customization:

```
1. Base Installation
   ~/agent-os/
   ↓
   Run: curl -sSL .../base-install.sh | bash

2. Select Profile
   default, rails, nextjs, django, custom
   ↓
   Choose existing or create new with create-profile.sh

3. Project Installation
   Copies & compiles profile into project
   ↓
   Run: ~/agent-os/scripts/project-install.sh --profile [name]

4. Customization (Optional)
   Edit project's copy as needed
   ↓
   Modify: project/agent-os/standards/, workflows/, etc.

5. Updates (When Ready)
   Pull updates from base
   ↓
   Run: ~/agent-os/scripts/project-update.sh [options]
```

---

## Benefits of Three-Tier System

### Flexibility

**Different Profiles for Different Project Types**
- Rails profile with Ruby/RSpec standards
- Next.js profile with TypeScript/Vitest standards
- Django profile with Python/pytest standards
- Each optimized for its framework

**Customize Base Once, Use Everywhere**
- Set your preferred git workflow once
- Define your code review standards once
- Configure your testing approach once
- Every new project inherits these

**Override Per-Project as Needed**
- Start with profile defaults
- Override standards for legacy projects
- Adjust workflows for unique processes
- Changes stay local to that project

### Maintainability

**Update Base to Affect New Projects**
- Improve workflows in base installation
- New projects get improved workflows
- Existing projects unaffected
- Opt-in updates per project

**Existing Projects Remain Stable**
- Project installations are snapshots
- No surprise breaking changes
- Update when you're ready
- Test updates in one project first

**Selective Updates When Ready**
- Update just standards, keep custom workflows
- Update just workflows, keep custom standards
- Update everything, or update nothing
- Full control over timing and scope

### Portability

**Projects Are Self-Contained**
- All Agent OS files in project directory
- No links to external base installation
- Works on any machine
- Share via git, works for everyone

**No Runtime Dependencies**
- Templates compiled during installation
- No lookups to base installation
- No missing files if base deleted
- Project is truly independent

**Works Even If Base Deleted**
- Base installation only needed for installation/updates
- After installation, project is standalone
- Delete base, project still works
- Reinstall base later if needed for updates

---

## Common Profile Patterns

### Framework-Specific Profiles

**Rails Profile Example:**

`profiles/rails/standards/backend/models.md`:
```markdown
# Model Standards

## ActiveRecord Conventions

Use Rails naming conventions:
- Model names: singular, PascalCase (User, BlogPost)
- Table names: plural, snake_case (users, blog_posts)
- Foreign keys: singular_name_id (user_id, blog_post_id)

## Validations

Always validate at model level:
```ruby
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, length: { minimum: 3 }
end
```

## Scopes

Use scopes for common queries:
```ruby
class Post < ApplicationRecord
  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc).limit(10) }
end
```
```

**Next.js Profile Example:**

`profiles/nextjs/standards/frontend/components.md`:
```markdown
# Component Standards

## Server vs Client Components

Default to Server Components (Next.js 13+):
```tsx
// app/components/UserProfile.tsx
// Server Component (default)
async function UserProfile({ userId }: { userId: string }) {
  const user = await db.user.findUnique({ where: { id: userId } });
  return <div>{user.name}</div>;
}
```

Use Client Components only when needed:
```tsx
'use client';

import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

## TypeScript Props

Always type props with interfaces:
```tsx
interface ButtonProps {
  variant: 'primary' | 'secondary';
  onClick: () => void;
  children: React.ReactNode;
}

function Button({ variant, onClick, children }: ButtonProps) {
  return <button onClick={onClick} className={variant}>{children}</button>;
}
```
```

### Language-Specific Profiles

**Python Profile:**
- Type hints required for functions
- pytest for all testing
- Black for formatting (line length 88)
- Pydantic for data validation

**TypeScript Profile:**
- Strict mode enabled
- Biome for linting/formatting
- Vitest for testing
- Zod for runtime validation

**Go Profile:**
- Standard library preferred
- Table-driven tests
- gofmt + golangci-lint
- Error wrapping with %w

### Organization Profiles

**Enterprise Profile:**
```markdown
# Corporate Compliance Standards

## Security Requirements

All API endpoints must:
- Require authentication
- Log access attempts
- Rate limit requests
- Validate all inputs

## Code Review

Required before merge:
- 2 approvals from team
- Security scan passing
- All tests passing
- Documentation updated
```

---

## Quick Reference

### Commands

```bash
# Install base to local machine
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash

# Create custom profile
~/agent-os/scripts/create-profile.sh

# Install into project (default profile)
cd ~/project && ~/agent-os/scripts/project-install.sh

# Install with specific profile
~/agent-os/scripts/project-install.sh --profile rails

# Preview installation
~/agent-os/scripts/project-install.sh --dry-run

# Update project from base
~/agent-os/scripts/project-update.sh --overwrite-standards
```

### File Locations

```
Base:     ~/agent-os/
Profiles: ~/agent-os/profiles/[name]/
Project:  project/.claude/ and project/agent-os/
```

### Profile Structure

```
agents/       - Claude Code subagent definitions
commands/     - Slash commands (single & multi-agent)
workflows/    - Step-by-step workflow instructions
standards/    - Coding standards and conventions
```

---

## Related Documentation

- **[template-system.md](template-system.md)** - How templates compile during installation
- **[configuration-system.md](configuration-system.md)** - Config flags and hierarchy
- **[script-architecture.md](script-architecture.md)** - Installation script internals
- **[agent-os-architecture.md](agent-os-architecture.md)** - Complete architecture reference
