# Standards Structure

Standards define your default coding preferences and conventions across all projects. They serve as templates that get filled in with actual values when you create product-specific documentation.

---

## Overview

Agent OS uses **two parallel but distinct documentation systems**:

1. **standards/** - Templates with placeholders for your default preferences
2. **agent-os/product/** - Actual values for the current product being built

Understanding this distinction is **critical** for effective use of Agent OS. Confusing these two systems is a common mistake that leads to agents using generic templates instead of your actual tech stack.

---

## Standards vs Product Files

This is the **most important concept** to understand about standards.

### standards/ (Profile Templates & Defaults)

**Location:** `profiles/[profile-name]/standards/`

**Purpose:** Your default preferences and coding templates across ALL projects

**Characteristics:**
- Contains **placeholders** and **generic best practices**
- Example: `[e.g., Rails, Django, Next.js]` - not actual choices
- Serves as **foundation** when creating product-specific docs
- Injected into agents via `{{standards/*}}` template tag
- Part of Agent OS profile (distributed to all projects)
- Used as **defaults** when running `/plan-product`

**When to Use:**
- Setting up your default preferences across all projects
- Defining coding standards and conventions for your team
- Creating reusable templates that work for multiple projects
- Documenting your preferred patterns and approaches

**Example Content** (from `standards/global/tech-stack.md`):

```markdown
### Framework & Runtime
- **Application Framework:** [e.g., Rails, Django, Next.js, Express]
- **Language/Runtime:** [e.g., Ruby, Python, Node.js, Java]
- **Package Manager:** [e.g., bundler, pip, npm, yarn]

### Database & Storage
- **Database:** [e.g., PostgreSQL, MySQL, MongoDB]
- **ORM/Query Builder:** [e.g., ActiveRecord, Prisma, Sequelize]
- **Caching:** [e.g., Redis, Memcached]
```

**Key Point:** Notice the `[e.g., ...]` placeholders - these are templates, not actual values.

---

### agent-os/product/ (Actual Product Documentation)

**Location:** `agent-os/product/` (within each specific project)

**Purpose:** Specific documentation for the CURRENT product being built

**Characteristics:**
- Contains **actual values** and **real choices**
- Example: "Next.js 14.0.3, PostgreSQL 15, Redis 7.2" - specific versions
- Created by `/plan-product` command
- **Source of truth** for implementation
- Must be **explicitly referenced** (no automatic injection)
- Specific to EACH project (not shared across projects)

**When to Use:**
- Defining the specific product's mission, roadmap, and tech stack
- During implementation when agents need actual technology details
- When specs and workflows reference product-specific information
- As the authoritative source for current project decisions

**Example Content** (from `agent-os/product/tech-stack.md`):

```markdown
### Framework & Runtime
- **Application Framework:** Next.js 14.0.3
- **Language/Runtime:** Node.js 20.9.0 with TypeScript 5.2.2
- **Package Manager:** pnpm 8.10.0

### Database & Storage
- **Database:** PostgreSQL 15.4 with pgvector extension for AI features
- **ORM/Query Builder:** Prisma 5.5.2
- **Caching:** Redis 7.2.3 for session storage and pub/sub
```

**Key Point:** Notice the specific versions and rationale - these are actual decisions, not templates.

---

### Key Differences Table

| Aspect | standards/ | agent-os/product/ |
|--------|-----------|-------------------|
| **Content** | Templates with placeholders | Actual values with versions |
| **Example** | `[e.g., PostgreSQL, MySQL]` | `PostgreSQL 15.4 with pgvector` |
| **Scope** | All projects (defaults) | Single product (specific) |
| **Location** | Profile directory (`~/agent-os/profiles/`) | Project directory (`./agent-os/product/`) |
| **Created By** | User manually edits | `/plan-product` command creates |
| **Injection** | Via `{{standards/*}}` template tag | Manual reference by agents |
| **Purpose** | Foundation/defaults/templates | Source of truth for implementation |
| **Updates** | Rarely (when preferences change) | Per-project (each product unique) |
| **Committed** | To Agent OS repo | To product repo |

---

### How They Work Together

This workflow shows how templates become actual values:

**Step 1: User Sets Defaults** (Optional)

Edit `~/agent-os/profiles/default/standards/global/tech-stack.md`:

```markdown
- **Application Framework:** [e.g., Next.js, Rails, Django]
- **Database:** [e.g., PostgreSQL, MySQL]
```

Or leave as placeholders - both work!

---

**Step 2: User Runs /plan-product**

```bash
$ /plan-product
```

The product-planner agent:
1. Reads `standards/global/tech-stack.md` (your defaults)
2. Asks for product-specific choices
3. Combines defaults + user input
4. Creates `agent-os/product/tech-stack.md`

---

**Step 3: Product File Created**

`agent-os/product/tech-stack.md` now contains:

```markdown
# Product Tech Stack

## Framework
Next.js 14.0.3

**Rationale:** Need server-side rendering for SEO and excellent developer
experience. Version 14 provides stable app router and server components.

## Database
PostgreSQL 15.4 with pgvector extension

**Rationale:** Robust ACID compliance, proven scalability, and vector search
support for AI-powered recommendations feature.
```

---

**Step 4: Implementation Uses Product File**

When implementing features, agents reference `agent-os/product/tech-stack.md`:

```markdown
<!-- In spec.md -->

## Technical Context

This feature will be built using our tech stack defined in
`agent-os/product/tech-stack.md`:
- Next.js 14.0.3 server components for data fetching
- PostgreSQL 15 for data storage
- pgvector for similarity search
```

---

**Important Note in Standards Files:**

All standards files now include this note at the top:

```markdown
**NOTE FOR AGENTS:** This is a template file with placeholder examples.
The actual product tech stack is defined in `agent-os/product/tech-stack.md`
(created by the `/plan-product` command). Always reference
`agent-os/product/tech-stack.md` for implementation guidance.
```

This ensures agents use product files, not templates!

---

## Directory Structure

Standards are organized into **4 main categories**:

```
profiles/default/standards/
├── global/          # Universal standards (6 files)
├── frontend/        # Frontend-specific (4 files)
├── backend/         # Backend-specific (4 files)
└── testing/         # Test standards (1 file)
```

**Total:** 15 standards files

---

## Global Standards

**Location:** `standards/global/`

**Purpose:** Universal coding standards that apply regardless of tech stack

### tech-stack.md

**Default tech stack template**

**Sections:**
- Framework & Runtime
- Frontend technologies
- Database & Storage
- Testing & Quality tools
- Deployment & Infrastructure
- Third-party services

**Example:**
```markdown
### Framework & Runtime
- **Application Framework:** [e.g., Rails, Django, Next.js, Express]
- **Language/Runtime:** [e.g., Ruby, Python, Node.js, Java]
```

**Key Point:** Agents should reference `agent-os/product/tech-stack.md`, not this template.

---

### coding-style.md

**Formatting rules and naming conventions**

**Typical Content:**
- Code formatting (indentation, line length)
- Naming conventions (camelCase, snake_case, PascalCase)
- File structure and organization
- Import organization and ordering
- Whitespace and alignment rules

**Example:**
```markdown
## Naming Conventions

- **Variables:** camelCase for local variables
- **Functions:** camelCase for functions, verb-first naming
- **Classes:** PascalCase for class names
- **Constants:** SCREAMING_SNAKE_CASE for constants
- **Files:** kebab-case for filenames
```

---

### conventions.md

**Architecture patterns and code organization**

**Typical Content:**
- Architecture patterns (MVC, Clean Architecture, etc.)
- File and folder organization
- Module structure and boundaries
- Code organization principles
- Dependency management

---

### error-handling.md

**Error handling approach and patterns**

**Typical Content:**
- Error handling strategy
- Exception types and hierarchy
- Logging patterns and levels
- Recovery strategies
- User-facing error messages

---

### commenting.md

**When and how to comment code**

**Typical Content:**
- When to write comments (and when not to)
- Comment style (block vs inline)
- Documentation format (JSDoc, docstrings, etc.)
- Function/method documentation requirements

---

### validation.md

**Input validation and data sanitization**

**Typical Content:**
- Input validation approach
- Data sanitization rules
- Type checking patterns
- Error messages for validation failures

---

## Frontend Standards

**Location:** `standards/frontend/`

**Purpose:** Frontend-specific conventions and best practices

### components.md

**UI component best practices**

**Content Example:**

```markdown
## UI component best practices

- **Single Responsibility**: Each component should have one clear purpose
- **Reusability**: Design components for reuse with configurable props
- **Composability**: Build complex UIs by combining smaller components
- **Clear Interface**: Define explicit, well-documented props with defaults
- **Encapsulation**: Keep internal implementation details private
- **Consistent Naming**: Use clear names that indicate purpose
- **State Management**: Keep state as local as possible
- **Minimal Props**: Keep props manageable; consider composition if many needed
- **Documentation**: Document component usage, props, and provide examples
```

---

### css.md

**CSS methodology and conventions**

**Typical Content:**
- CSS methodology (BEM, SMACSS, etc.)
- Tailwind CSS conventions (if used)
- Naming patterns for classes
- Organization and file structure
- Responsive design approach

---

### responsive.md

**Responsive design standards**

**Typical Content:**
- Breakpoint definitions
- Mobile-first vs desktop-first approach
- Testing devices and screen sizes
- Responsive patterns and techniques

---

### accessibility.md

**Accessibility (a11y) requirements**

**Typical Content:**
- ARIA attribute usage
- Keyboard navigation requirements
- Screen reader support
- Color contrast requirements
- Form labeling standards

---

## Backend Standards

**Location:** `standards/backend/`

**Purpose:** Backend-specific patterns and conventions

### api.md

**API design conventions**

**Typical Content:**
- REST API conventions
- GraphQL patterns (if used)
- Error response formats
- API versioning strategy
- Rate limiting approach

---

### models.md

**Data model patterns**

**Typical Content:**
- Model structure and organization
- Relationship patterns
- Validation rules placement
- Hooks and callbacks usage
- Scopes and query methods

---

### queries.md

**Database query optimization**

**Typical Content:**
- Query optimization techniques
- N+1 query prevention
- Indexing strategy
- Caching approach
- Connection pooling

---

### migrations.md

**Database migration patterns**

**Typical Content:**
- Migration file organization
- Rollback procedures
- Data migrations vs schema migrations
- Schema change best practices
- Testing migrations

---

## Testing Standards

**Location:** `standards/testing/`

**Purpose:** Test writing and organization standards

### test-writing.md

**Testing conventions and best practices**

**Typical Content:**
- Test organization (unit, integration, e2e)
- Naming conventions for tests
- Fixture and factory patterns
- Mocking and stubbing approach
- Coverage goals and requirements
- Test data management

---

## Creating Standards

When adding new standards files, follow these guidelines:

### File Placement

**Ask yourself:**
- Is this universal across all tech stacks? → `global/`
- Is this frontend-specific? → `frontend/`
- Is this backend-specific? → `backend/`
- Is this testing-specific? → `testing/`

### Template Structure

```markdown
## [Standard Category]

**Purpose:** [Why this standard exists]

## Rules

1. [Rule or guideline 1]
2. [Rule or guideline 2]
3. [Rule or guideline 3]

## Examples

### Good Example
\```[language]
[Show correct pattern]
\```

### Bad Example
\```[language]
[Show incorrect pattern]
\```

## Exceptions

[When it's okay to deviate from this standard]
```

### Content Guidelines

**Do:**
- Be specific and concrete
- Include examples (good and bad)
- Explain *why*, not just *what*
- Consider team preferences
- Keep it concise and scannable

**Don't:**
- Make it too prescriptive (allow reasonable variation)
- Include product-specific values (use placeholders)
- Assume specific technologies (keep generic where possible)
- Make it too long (split into multiple files if needed)

---

## Injecting Standards

Standards are injected into agents and commands via template tags during installation.

### Full Injection

Inject ALL standards files:

```markdown
{{standards/*}}
```

**Result:** All 15 standards files concatenated and injected.

**Use when:** Agent needs complete context across all categories.

---

### Selective Injection

Inject only specific categories:

```markdown
{{standards/global/*}}
{{standards/frontend/*}}
{{standards/backend/*}}
{{standards/testing/*}}
```

**Result:** Only files from specified category injected.

**Use when:** Agent only works in specific area (e.g., frontend-only agent).

---

### Conditional Injection

Inject based on configuration flags:

```markdown
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**How it works:**
- If `standards_as_claude_code_skills: false` → standards injected into file
- If `standards_as_claude_code_skills: true` → standards loaded via Skills feature

**Use when:** Supporting both injection methods.

---

### Injection Example in Agent

```markdown
---
name: implementer
description: Use proactively to implement a feature
tools: Write, Read, Bash, WebFetch
color: red
model: inherit
---

# Implementer Agent

I implement features following your coding standards and best practices.

{{workflows/implementation/implement-tasks}}

{{UNLESS standards_as_claude_code_skills}}
## Standards

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**After compilation**, the agent file contains all workflow instructions and standards.

---

## Customizing Standards

### Option 1: Edit Default Profile

Edit files directly in `~/agent-os/profiles/default/standards/`:

```bash
# Edit your default tech stack preferences
vim ~/agent-os/profiles/default/standards/global/tech-stack.md

# Edit component standards
vim ~/agent-os/profiles/default/standards/frontend/components.md
```

**Effect:** All new projects using default profile get your custom standards.

---

### Option 2: Create Custom Profile

Create a profile with different standards:

```bash
# Create new profile
~/agent-os/scripts/create-profile.sh

# Name it: rails-profile
# Inherit from: default
# Customize: standards/

# Edit Rails-specific standards
vim ~/agent-os/profiles/rails-profile/standards/global/tech-stack.md
vim ~/agent-os/profiles/rails-profile/standards/backend/models.md
```

**Effect:** Rails projects use Rails-specific standards, other projects use default.

---

### Option 3: Per-Project Customization

After installation, edit standards in project:

```bash
# Install Agent OS to project
~/agent-os/scripts/project-install.sh

# Edit project-specific standards
vim ./agent-os/standards/global/tech-stack.md
```

**Effect:** Only this project uses custom standards. Useful for legacy projects with different conventions.

---

## Quick Reference

### Directory Tree

```
profiles/default/standards/
├── global/
│   ├── tech-stack.md      # Tech stack template
│   ├── coding-style.md    # Formatting & naming
│   ├── conventions.md     # Architecture patterns
│   ├── error-handling.md  # Error handling approach
│   ├── commenting.md      # When/how to comment
│   └── validation.md      # Input validation
│
├── frontend/
│   ├── components.md      # Component best practices
│   ├── css.md            # CSS conventions
│   ├── responsive.md     # Responsive design
│   └── accessibility.md  # A11y requirements
│
├── backend/
│   ├── api.md            # API design
│   ├── models.md         # Data model patterns
│   ├── queries.md        # Query optimization
│   └── migrations.md     # Migration patterns
│
└── testing/
    └── test-writing.md    # Testing conventions
```

---

### Injection Patterns

```markdown
# All standards
{{standards/*}}

# By category
{{standards/global/*}}
{{standards/frontend/*}}
{{standards/backend/*}}
{{standards/testing/*}}

# Conditional
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

---

### Standards vs Product Cheat Sheet

| Want to... | File to Edit |
|-----------|-------------|
| Set default preferences | `standards/global/tech-stack.md` |
| Define current product stack | `agent-os/product/tech-stack.md` (via `/plan-product`) |
| Reference during implementation | `agent-os/product/tech-stack.md` |
| Update coding conventions | `standards/global/coding-style.md` |
| Define product mission | `agent-os/product/mission.md` (via `/plan-product`) |

**Rule of thumb:** Standards = templates/defaults, Product = actual values for THIS project.

---

## Related Documentation

- **[template-system.md](template-system.md)** - How standards are injected via template tags
- **[profile-system.md](profile-system.md)** - Profile architecture and customization
- **[configuration-system.md](configuration-system.md)** - The `standards_as_claude_code_skills` flag
- **[development-phases.md](development-phases.md)** - Phase 1 (`/plan-product`) creates product files
- **[agent-patterns.md](agent-patterns.md)** - How agents use injected standards
