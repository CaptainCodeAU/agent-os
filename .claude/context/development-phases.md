# Development Phases

Agent OS structures development into optional phases that guide you from idea to implementation. Use all phases for complex features, or skip to the ones you need for simpler work.

---

## Overview

Agent OS provides **7 development phases** (Phase 0 through Phase 6) that transform rough ideas into working code through structured workflows. Each phase has:

- **A specific purpose** - What it accomplishes
- **Clear outputs** - Files it creates
- **Associated commands** - How to invoke it
- **Agent assignments** - Which specialized agents handle it (multi-agent mode)
- **When to use guidance** - Helps you decide if you need this phase

You don't need to use all phases. Pick the workflow that matches your needs - from quick fixes to complex features requiring detailed planning.

---

## Phase 0: research-issue (Optional)

**Command:** `/research-issue`

**Purpose:** Systematic GitHub issue analysis before planning a fix or feature.

**When to Use:**
- You have a GitHub issue to investigate
- You need to understand existing codebase before planning
- You want root cause analysis with confidence levels
- You need solution alternatives before deciding on an approach

**Agent (Multi-Agent Mode):** issue-researcher

**Workflow:** `research/research-issue.md`

### What It Does

1. **Fetches issue details** from GitHub via `gh` CLI:
   - Issue title, description, labels
   - Comments and discussion thread
   - Related issues or PRs

2. **Analyzes codebase** for related files and patterns:
   - Searches for relevant code locations
   - Identifies files that need modification
   - Maps out dependencies

3. **Identifies root causes** with confidence levels:
   - High confidence: Clear, reproducible cause
   - Medium confidence: Likely cause with some uncertainty
   - Low confidence: Hypothesis requiring validation

4. **Proposes multiple solutions** with tradeoffs:
   - Preferred approach with rationale
   - Alternative approaches with pros/cons
   - Implementation complexity estimates

5. **Creates comprehensive documentation**

### Outputs

```
.claude-workspace/research/issues/{ISSUE_NUMBER}-{title}.md
```

**Structure:**
- Issue summary
- Root cause analysis
- Solution proposals (preferred + alternatives)
- Files to modify
- Risks and considerations
- Next steps

### Example Output

```markdown
# Issue #123: Authentication timeout on slow networks

## Root Cause Analysis

**Confidence: High**

The authentication flow has a hardcoded 5-second timeout in
`src/auth/login.ts:42` that doesn't account for slow network conditions.

## Preferred Solution

Make timeout configurable with:
- Environment variable support
- Per-request timeout override
- Sensible default (15 seconds)

Pros: Flexible, backwards compatible
Cons: Requires config documentation

## Alternative: Exponential Backoff

Implement retry logic with exponential backoff...
```

### Next Steps After Research

**For significant features:**
```bash
/research-issue  # Understand the problem
/shape-spec      # Gather requirements
/write-spec      # Create formal spec
/create-tasks    # Break into tasks
/implement-tasks # Build it
```

**If requirements are clear:**
```bash
/research-issue  # Understand the problem
/write-spec      # Create spec directly
/implement-tasks # Build it
```

**For straightforward fixes:**
```bash
/research-issue  # Understand the problem
# Proceed directly to implementation
```

---

## Phase 1: plan-product

**Command:** `/plan-product`

**Purpose:** Define product foundation - mission, roadmap, and technical stack.

**When to Use:**
- Starting a new product from scratch
- Documenting an existing product for the first time
- Major pivot requiring redefinition of product direction
- Onboarding new team members who need context

**Agent (Multi-Agent Mode):** product-planner

**Workflows:**
- `planning/create-product-mission.md`
- `planning/create-product-roadmap.md`
- `planning/create-tech-stack.md`

### Outputs

```
agent-os/product/
├── mission.md       # Product vision, goals, target users
├── roadmap.md       # Feature phases and timeline
└── tech-stack.md    # Technologies and architecture decisions
```

### mission.md Structure

```markdown
# Product Mission

## Vision
[1-2 sentence description of what this product is]

## Goals
1. [Primary goal]
2. [Secondary goal]
3. [Tertiary goal]

## Target Users
- **User Persona 1**: [Description and needs]
- **User Persona 2**: [Description and needs]

## Success Metrics
- [Measurable metric 1]
- [Measurable metric 2]
```

### roadmap.md Structure

```markdown
# Product Roadmap

## Phase 1: Foundation (Weeks 1-4)
- [ ] Feature 1
- [ ] Feature 2

## Phase 2: Core Features (Weeks 5-12)
- [ ] Feature 3
- [ ] Feature 4

## Phase 3: Enhancement (Weeks 13-20)
- [ ] Feature 5
- [ ] Feature 6
```

### tech-stack.md Structure

```markdown
# Tech Stack

## Framework
Next.js 14.0.3

**Rationale:** Server-side rendering, excellent DX, strong ecosystem

## Database
PostgreSQL 15 with pgvector extension

**Rationale:** Robust ACID compliance, vector search for AI features

## Cache/Queue
Redis 7.2

**Rationale:** Fast caching, pub/sub for real-time features
```

### Example Usage

```bash
# Start new product
$ /plan-product

# Agent asks questions:
# - What problem does this solve?
# - Who are the target users?
# - What's the tech stack preference?

# Creates:
# - agent-os/product/mission.md
# - agent-os/product/roadmap.md
# - agent-os/product/tech-stack.md
```

---

## Phase 2: shape-spec

**Command:** `/shape-spec`

**Purpose:** Transform rough feature ideas into structured requirements through Q&A.

**When to Use:**
- You have a feature idea but it's not fully formed
- Requirements are unclear or ambiguous
- You need to explore user stories and edge cases
- Stakeholders need to align on what's being built

**Agent (Multi-Agent Mode):** spec-shaper

**Workflow:** `specification/shape-requirements.md`

### Outputs

```
agent-os/specs/[spec-name]/
├── planning/
│   ├── requirements.md    # Structured requirements
│   └── visuals/           # Optional mockups/diagrams
```

### requirements.md Structure

```markdown
# [Feature Name] Requirements

## User Stories

1. **As a [user type]**, I want to [action] so that [benefit]
2. **As a [user type]**, I want to [action] so that [benefit]

## Functional Requirements

### Core Functionality
- Requirement 1
- Requirement 2

### User Interface
- UI Requirement 1
- UI Requirement 2

### Data Requirements
- Data Requirement 1
- Data Requirement 2

## Non-Functional Requirements
- Performance: [Expectation]
- Security: [Expectation]
- Scalability: [Expectation]

## Edge Cases
- Edge case 1: [How to handle]
- Edge case 2: [How to handle]

## Open Questions
- Question 1
- Question 2
```

### Example: Shaping a "User Profile" Feature

```markdown
# User Profile Requirements

## User Stories

1. **As a logged-in user**, I want to view my profile so that I can see my account details
2. **As a logged-in user**, I want to edit my profile so that I can keep my information current
3. **As an admin**, I want to view user profiles so that I can provide support

## Functional Requirements

### Core Functionality
- Display user's name, email, avatar
- Allow editing of name and avatar
- Email changes require verification
- Profile visibility settings (public/private)

### User Interface
- Profile page accessible from navbar
- Inline editing (no separate edit page)
- Avatar upload with preview
- Form validation before save

## Edge Cases
- User uploads 10MB avatar: Show error, enforce 2MB limit
- Email already in use: Show clear error message
- Network fails during save: Retry mechanism with user feedback
```

---

## Phase 3: write-spec

**Command:** `/write-spec`

**Purpose:** Create formal specification document from clear requirements.

**When to Use:**
- Requirements are well understood (from `/shape-spec` or already clear)
- You need a formal document for implementation reference
- Multiple developers will work on the feature
- Complex feature requiring detailed planning

**Agent (Multi-Agent Mode):** spec-writer

**Workflow:** `specification/write-spec.md`

### Outputs

```
agent-os/specs/[spec-name]/
└── spec.md              # Formal specification document
```

### spec.md Structure

**Required sections:**
1. **Goal** (1-2 sentences)
2. **User Stories** (1-3 stories)
3. **Specific Requirements** (grouped by category)
4. **Visual Design** (if applicable)
5. **Existing Code to Leverage** (what can be reused)
6. **Out of Scope** (what this spec explicitly doesn't cover)

**Key Constraint:** No code in spec.md - only descriptions and designs.

### Example spec.md

```markdown
# User Profile Management

## Goal

Enable users to view and edit their profile information, including name, email, and avatar, with proper validation and security controls.

## User Stories

1. **As a logged-in user**, I want to view my profile details so I can verify my account information
2. **As a logged-in user**, I want to update my profile information so I can keep it current
3. **As a logged-in user**, I want to upload a custom avatar so I can personalize my account

## Specific Requirements

### Profile Display
- Show current name, email, avatar
- Display account creation date
- Show last login timestamp
- Indicate email verification status

### Profile Editing
- Inline editing (no separate page)
- Name: 1-50 characters, alphanumeric + spaces
- Email: Valid format, must verify if changed
- Avatar: Max 2MB, PNG/JPG only, auto-resize to 200x200

### Security
- Users can only edit their own profile
- Email changes send verification link
- Password required for email changes
- Rate limiting: Max 10 updates per hour

## Visual Design

[Mockup showing profile page layout]

## Existing Code to Leverage

- `src/auth/middleware.ts` - User authentication checks
- `src/components/Form.tsx` - Form validation utilities
- `src/lib/upload.ts` - File upload handling

## Out of Scope

- Password changes (separate spec)
- Account deletion (separate spec)
- Profile visibility to other users (future phase)
```

---

## Phase 4: create-tasks

**Command:** `/create-tasks`

**Purpose:** Break specification into implementation tasks with dependencies and acceptance criteria.

**When to Use:**
- You have a complete spec.md
- Feature is complex enough to benefit from task breakdown
- Multiple developers or agents will implement different parts
- You need clear acceptance criteria for each component

**Agent (Multi-Agent Mode):** tasks-list-creator

**Workflow:** `implementation/create-tasks-list.md`

### Outputs

```
agent-os/specs/[spec-name]/
└── tasks.md             # Implementation tasks breakdown
```

### tasks.md Structure

```markdown
## Task Group Name

Dependencies: [other task groups this depends on]

### Task 1: [Name]
- [ ] Subtask 1
- [ ] Subtask 2

### Task 2: [Name]
- [ ] Subtask 1

Acceptance Criteria:
- Criterion 1
- Criterion 2
```

### Example tasks.md

```markdown
# User Profile Implementation Tasks

## Database Schema

Dependencies: None

### Task 1: Create users profile fields
- [ ] Add avatar_url column to users table
- [ ] Add profile_updated_at timestamp
- [ ] Create migration script
- [ ] Update User model type definitions

### Task 2: Create email verification table
- [ ] Design email_verifications schema
- [ ] Add indexes for lookup performance
- [ ] Create migration script

Acceptance Criteria:
- Migrations run without errors
- Rollback scripts tested
- Types updated in TypeScript

---

## API Endpoints

Dependencies: Database Schema

### Task 1: GET /api/profile endpoint
- [ ] Create route handler
- [ ] Add authentication middleware
- [ ] Return user profile data
- [ ] Write integration tests (3-5 tests)

### Task 2: PATCH /api/profile endpoint
- [ ] Create route handler
- [ ] Add authentication middleware
- [ ] Validate input data
- [ ] Handle email change workflow
- [ ] Write integration tests (5-8 tests)

### Task 3: POST /api/profile/avatar endpoint
- [ ] Create route handler
- [ ] Add file upload handling
- [ ] Image validation and resizing
- [ ] Store in S3 or local storage
- [ ] Write integration tests (3-5 tests)

Acceptance Criteria:
- All endpoints return proper status codes
- Error messages are clear and helpful
- Rate limiting works correctly
- Tests cover happy path and edge cases

---

## UI Components

Dependencies: API Endpoints

### Task 1: ProfileView component
- [ ] Create React component
- [ ] Fetch profile data on mount
- [ ] Display all profile fields
- [ ] Handle loading and error states
- [ ] Add Storybook stories

### Task 2: ProfileEdit component
- [ ] Create inline edit form
- [ ] Add form validation
- [ ] Handle avatar upload with preview
- [ ] Submit changes to API
- [ ] Show success/error feedback
- [ ] Add Storybook stories

Acceptance Criteria:
- Components follow design mockups
- Form validation works client-side
- Error states are user-friendly
- Loading states prevent duplicate submissions
- Works on mobile and desktop
```

---

## Phase 5: implement-tasks

**Command:** `/implement-tasks`

**Purpose:** Straightforward single-agent implementation following the tasks list.

**When to Use:**
- You have tasks.md with clear task groups
- Implementation is straightforward (not requiring multiple specialized agents)
- You want focused testing per task group
- Feature doesn't require complex orchestration

**Agent (Multi-Agent Mode):** implementer

**Workflow:** `implementation/implement-tasks.md`

### Outputs

- **Code** - Implementation files
- **Tests** - 2-8 tests per task group
- **Screenshots** - `agent-os/specs/[spec-name]/verification/screenshots/` (if UI)

### Process

1. **Implement one task group at a time**
   - Complete all tasks in the group
   - Don't move to next group until current is done

2. **Write focused tests** (2-8 per group)
   - Test happy path
   - Test edge cases identified in spec
   - Test error handling

3. **Run relevant tests only**
   - Don't run entire test suite
   - Focus on tests for current task group
   - Ensures fast feedback loop

4. **Verify manually** if UI involved
   - Take screenshots of key states
   - Save to verification/screenshots/
   - Document in verification report

5. **Move to next group**
   - Mark current group complete
   - Update tasks.md checkboxes
   - Continue with dependencies in mind

### Example Implementation Flow

```bash
$ /implement-tasks

# Agent reads agent-os/specs/user-profile/tasks.md

# Implements Database Schema group:
- Creates migration: db/migrations/2024-01-15-add-profile-fields.sql
- Updates models: src/models/User.ts
- Writes tests: tests/models/User.test.ts (4 tests)
- Runs tests: npm test tests/models/User.test.ts
- ✅ All tests pass

# Implements API Endpoints group:
- Creates routes: src/app/api/profile/route.ts
- Creates routes: src/app/api/profile/avatar/route.ts
- Writes tests: tests/api/profile.test.ts (12 tests)
- Runs tests: npm test tests/api/profile.test.ts
- ✅ All tests pass

# Implements UI Components group:
- Creates component: src/components/ProfileView.tsx
- Creates component: src/components/ProfileEdit.tsx
- Writes tests: tests/components/Profile.test.tsx (8 tests)
- Runs tests: npm test tests/components/Profile.test.tsx
- ✅ All tests pass
- Takes screenshots: verification/screenshots/profile-*.png

# Updates tasks.md with checkboxes marked complete
# Creates verification report
```

---

## Phase 6: orchestrate-tasks

**Command:** `/orchestrate-tasks`

**Purpose:** Advanced multi-agent orchestration for complex features requiring specialized agents.

**When to Use:**
- Feature is complex with distinct specializations (backend, frontend, ML, etc.)
- You want different agents handling different task groups
- You need parallel work on independent components
- Feature requires coordination between multiple systems

**Agent (Multi-Agent Mode):** Multiple agents (implementer + custom agents)

**Workflow:** `implementation/implement-tasks.md` + custom orchestration

### Process

1. **Assign task groups to specific agents**
   - Backend tasks → backend specialist agent
   - Frontend tasks → UI specialist agent
   - ML tasks → ML specialist agent
   - Custom agents for domain-specific work

2. **Agents work on their groups** (potentially in parallel)
   - Each agent follows their specialized workflow
   - Agents have context for their domain
   - Coordination through shared task file

3. **Integration between groups**
   - Ensure APIs match between backend and frontend
   - Verify data flow between components
   - Test integration points

4. **Final verification**
   - End-to-end tests across all components
   - Manual verification of complete feature
   - Performance and security checks

### Example Orchestration

```markdown
# User Profile with AI Avatar Generation - Task Assignment

## Task Assignment

### Database Schema → @agent:database-architect
- Database design and migrations
- Schema optimization
- Index strategy

### API Endpoints → @agent:backend-implementer
- REST API implementation
- Authentication and validation
- Error handling

### UI Components → @agent:frontend-implementer
- React components
- State management
- Responsive design

### AI Avatar Generation → @agent:ml-implementer
- Image processing pipeline
- AI model integration
- Performance optimization

## Integration Points

- **Backend ↔ Frontend**: API contract defined in spec.md
- **Backend ↔ ML**: Avatar generation API endpoint
- **Frontend ↔ ML**: Direct upload to avatar service

## Verification Strategy

1. Unit tests per component (each agent)
2. Integration tests at boundaries
3. End-to-end test of complete flow
4. Performance benchmarking
```

---

## Phase Flow Diagram

```
Phase 0 (Optional): research-issue
    ↓
    Understand the problem, analyze root cause
    Output: .claude-workspace/research/issues/{ISSUE}-{title}.md
    ↓
    ├─→ For complex features
    │   ↓
    │   Phase 1: plan-product
    │   ↓
    │   Define mission, roadmap, tech stack
    │   Output: agent-os/product/*.md
    │   ↓
    │   Phase 2: shape-spec
    │   ↓
    │   Gather and structure requirements
    │   Output: agent-os/specs/{name}/planning/requirements.md
    │   ↓
    │   Phase 3: write-spec
    │   ↓
    │   Create formal specification
    │   Output: agent-os/specs/{name}/spec.md
    │   ↓
    │   Phase 4: create-tasks
    │   ↓
    │   Break into implementation tasks
    │   Output: agent-os/specs/{name}/tasks.md
    │   ↓
    │   ├─→ Phase 5: implement-tasks (straightforward)
    │   │   ↓
    │   │   Single-agent implementation
    │   │   Output: Code, tests, screenshots
    │   │
    │   └─→ Phase 6: orchestrate-tasks (complex)
    │       ↓
    │       Multi-agent orchestration
    │       Output: Code, tests, integration
    │
    ├─→ For clear features
    │   ↓
    │   Phase 3: write-spec
    │   ↓
    │   Phase 4: create-tasks
    │   ↓
    │   Phase 5: implement-tasks
    │
    └─→ For simple fixes
        ↓
        Skip to implementation
```

---

## Choosing Your Phases

### Minimal Workflow (Quick Fixes)

```bash
# Direct implementation, no specs
- Just write the code
- Add tests
- Manual verification
```

**When to use:**
- Bug fixes with clear cause
- Small tweaks or refactors
- Documentation updates
- Dependency updates

---

### Standard Workflow (Most Features)

```bash
/write-spec           # Create spec from clear requirements
/create-tasks         # Break into tasks
/implement-tasks      # Build it
```

**When to use:**
- Well-understood features
- Moderate complexity
- Single developer/agent work
- Clear requirements from outset

---

### Complete Workflow (New Products)

```bash
/plan-product         # Define product foundation
/shape-spec           # Gather requirements for first feature
/write-spec           # Formalize specification
/create-tasks         # Task breakdown
/implement-tasks      # Build it
```

**When to use:**
- Starting from scratch
- Multiple features to coordinate
- Team needs product context
- Long-term roadmap matters

---

### Research-First Workflow (Bug Investigation)

```bash
/research-issue       # Understand the problem deeply
/write-spec          # Document the fix (if complex)
/implement-tasks     # Implement the solution
```

**When to use:**
- GitHub issues requiring investigation
- Bug with unclear root cause
- Multiple possible solutions
- Need to document analysis

---

### Complex Feature Workflow (Multi-Domain)

```bash
/research-issue       # Investigate if building on existing code
/shape-spec           # Gather and explore requirements
/write-spec           # Create formal specification
/create-tasks         # Break into specialized task groups
/orchestrate-tasks    # Multi-agent implementation
```

**When to use:**
- Feature spans multiple domains (backend + frontend + ML)
- Requires specialized expertise
- Parallel development beneficial
- Complex integration points

---

## Phase Comparison Table

| Phase | Command | Time Investment | Best For | Outputs |
|-------|---------|----------------|----------|---------|
| **Phase 0** | `/research-issue` | 30-60 min | Issue investigation | Research analysis |
| **Phase 1** | `/plan-product` | 60-120 min | New products | Mission, roadmap, tech stack |
| **Phase 2** | `/shape-spec` | 45-90 min | Unclear requirements | Requirements document |
| **Phase 3** | `/write-spec` | 30-60 min | Clear requirements | Formal specification |
| **Phase 4** | `/create-tasks` | 20-45 min | Task planning | Task breakdown |
| **Phase 5** | `/implement-tasks` | Variable | Standard features | Code + tests |
| **Phase 6** | `/orchestrate-tasks` | Variable | Complex features | Code + integration |

---

## Quick Reference

### All Commands

```bash
/research-issue       # Phase 0: Research GitHub issue
/plan-product         # Phase 1: Product foundation
/shape-spec           # Phase 2: Requirements gathering
/write-spec           # Phase 3: Formal specification
/create-tasks         # Phase 4: Task breakdown
/implement-tasks      # Phase 5: Straightforward implementation
/orchestrate-tasks    # Phase 6: Complex multi-agent implementation
```

### Output Locations

```
agent-os/
├── product/                    # Phase 1 outputs
│   ├── mission.md
│   ├── roadmap.md
│   └── tech-stack.md
│
├── specs/
│   └── [spec-name]/
│       ├── planning/           # Phase 2 outputs
│       │   └── requirements.md
│       ├── spec.md             # Phase 3 output
│       ├── tasks.md            # Phase 4 output
│       └── verification/       # Phase 5-6 outputs
│           └── screenshots/

.claude-workspace/
└── research/
    └── issues/                 # Phase 0 outputs
        └── {NUMBER}-{title}.md
```

### Agent Assignments (Multi-Agent Mode)

- **Phase 0:** issue-researcher
- **Phase 1:** product-planner
- **Phase 2:** spec-shaper
- **Phase 3:** spec-writer
- **Phase 4:** tasks-list-creator
- **Phase 5:** implementer
- **Phase 6:** implementer + custom agents

---

## Related Documentation

- **[agent-patterns.md](agent-patterns.md)** - The specialized agents for each phase
- **[workflow-patterns.md](workflow-patterns.md)** - Workflow structure for each phase
- **[agent-modes.md](agent-modes.md)** - Single vs multi-agent execution
- **[configuration-system.md](configuration-system.md)** - Enabling multi-agent mode
- **[template-system.md](template-system.md)** - How phases are compiled into commands
