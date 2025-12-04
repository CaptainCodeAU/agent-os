# Workflow Patterns

Workflows are the heart of Agent OS - they provide step-by-step instructions that guide agents through complex tasks. Every workflow follows a consistent structure that ensures clarity, completeness, and successful execution.

---

## Overview

A **workflow** is a markdown file that defines:

- **What the agent is responsible for** (Core Responsibilities)
- **How to accomplish the task** (Workflow steps)
- **What to avoid or watch out for** (Important Constraints)
- **How to verify success** (Success Criteria)

Workflows are stored in `profiles/[name]/workflows/` and are **injected into commands and agents** via template tags during installation. This means the same workflow can be reused in both single-agent mode (directly in commands) and multi-agent mode (in specialized agents).

---

## Standard Workflow Structure

Every workflow MUST follow this 4-section structure:

```markdown
# [Workflow Name]

## Core Responsibilities

1. [Primary responsibility - start with action verb]
2. [Secondary responsibility - start with action verb]
3. [Tertiary responsibility - start with action verb]
4. [Additional responsibilities as needed]
5. [Usually 3-5 total]

## Workflow

### Step 1: [Action Verb] [Object]

[Detailed instructions for this step]

[Optional: Code example]
\```bash
# Example command
\```

[Optional: File template]
\```markdown
[Template content]
\```

### Step 2: [Action Verb] [Object]

[More detailed instructions]

### Step N: [Action Verb] [Object]

[Continue with remaining steps]

## Important Constraints

1. [Critical rule or limitation]
2. [What NOT to do]
3. [Edge case to handle]
4. [Error handling requirement]
5. [Usually 3-5 constraints]

## Success Criteria

1. [Checkable condition 1]
2. [Checkable condition 2]
3. [Observable outcome 3]
4. [Verification step 4]
5. [Usually 3-6 criteria]
```

---

## Section Breakdown

### Core Responsibilities

**Purpose:** Provide a quick overview of what this workflow accomplishes.

**Format:**
- Numbered list (3-5 items)
- Start each with an action verb (Fetch, Create, Analyze, Verify, etc.)
- Be specific and concrete
- Focus on *what* gets done, not *how*

**Good Examples:**

```markdown
## Core Responsibilities

1. Fetch and analyze GitHub issue details systematically
2. Research relevant codebase files and patterns
3. Identify root causes with confidence levels
4. Propose multiple solution approaches with tradeoffs
5. Create comprehensive task analysis documentation
```

```markdown
## Core Responsibilities

1. Create agent-os/product/mission.md with product definition
2. Define target users and their pain points
3. Articulate the problem and solution approach
4. Highlight key differentiators and features
```

**Bad Examples:**

```markdown
## Core Responsibilities

1. Do analysis  # Too vague
2. Make things better  # No concrete outcome
3. Help the user  # Not specific
```

---

### Workflow Steps

**Purpose:** Provide sequential, detailed instructions for completing the workflow.

**Format:**
- Use `### Step N: [Action Verb] [Object]` for each step
- Number steps sequentially (1, 2, 3...)
- Provide detailed sub-instructions using numbered or bulleted lists
- Include examples (bash commands, file templates) where helpful
- Explain error handling and edge cases inline

**Common Action Verbs:**
- **Creation:** Create, Write, Generate, Build, Initialize
- **Modification:** Update, Edit, Refine, Improve, Enhance
- **Analysis:** Analyze, Investigate, Research, Review, Examine
- **Verification:** Verify, Check, Confirm, Validate, Test
- **Retrieval:** Fetch, Get, Load, Read, Retrieve
- **Organization:** Organize, Structure, Group, Categorize

**Step Structure Pattern:**

```markdown
### Step 1: [Action] [Object]

1. [High-level instruction]
   - [Sub-instruction or detail]
   - [Sub-instruction or detail]

2. [Next instruction]
   - [Detail]
   - [Detail]

3. If [condition]:
   - [Handle this way]
   - [Error handling]

4. Example:
   \```bash
   # Show concrete command or code
   \```
```

**Example from research-issue workflow:**

```markdown
### Step 1: Fetch Issue Details

1. Use `gh issue view {ISSUE_NUMBER}` to retrieve:
   - Issue title and description
   - Labels and assignees
   - Comments and discussion
   - Current status
   - Related PRs or issues

2. If the command fails:
   - Check if GitHub CLI is authenticated (`gh auth status`)
   - Verify the issue number exists
   - Ask the user for clarification if needed
```

**Example from create-product-mission workflow:**

```markdown
### Step 1: Create Mission Document

Create `agent-os/product/mission.md` with this structure:

\```markdown
# Product Mission

## Pitch
[PRODUCT_NAME] is a [PRODUCT_TYPE] that helps [TARGET_USERS]
[SOLVE_PROBLEM] by providing [KEY_VALUE_PROPOSITION].

## Users

### Primary Customers
- [CUSTOMER_SEGMENT_1]: [DESCRIPTION]
- [CUSTOMER_SEGMENT_2]: [DESCRIPTION]
\```
```

---

### Important Constraints

**Purpose:** Define critical rules, limitations, and requirements the agent must follow.

**Format:**
- Numbered list (3-5 items)
- State what NOT to do
- Define boundaries and scope limits
- Specify error handling requirements
- Highlight edge cases to handle

**Good Examples:**

```markdown
## Important Constraints

1. Stay focused - Implement only what's specified in the assigned tasks
2. Reuse existing code - Look for existing patterns before creating new ones
3. Minimal file changes - Modify only necessary files, don't refactor unrelated code
4. Keep it simple - Choose the simplest solution that fulfills requirements
5. No premature optimization - Don't add caching or complex patterns unless required
```

```markdown
## Important Constraints

1. Ask for clarification if issue details are unclear or ambiguous
2. Be thorough but efficient - don't read entire large files unnecessarily
3. Update existing task files - don't create duplicates if file already exists
4. Handle errors gracefully - report issues clearly to the user
```

**Bad Examples:**

```markdown
## Important Constraints

1. Do good work  # Not specific
2. Be careful  # No concrete guidance
3. Think about edge cases  # Should define specific edge cases
```

---

### Success Criteria

**Purpose:** Define how to verify the workflow completed successfully.

**Format:**
- Numbered list (3-6 items)
- Checkable conditions (can be verified as true/false)
- Observable outcomes (files exist, tests pass, etc.)
- What should exist after completion

**Good Examples:**

```markdown
## Success Criteria

1. ✅ Issue details successfully fetched from GitHub
2. ✅ Relevant codebase files identified and analyzed
3. ✅ Root causes identified with confidence levels
4. ✅ Two solution approaches proposed (preferred + alternative)
5. ✅ Comprehensive task file created at correct location
6. ✅ Summary presented to user with next steps
```

```markdown
## Success Criteria

1. ✅ agent-os/product/mission.md exists with complete structure
2. ✅ Target users and pain points clearly defined
3. ✅ Product differentiators articulated
4. ✅ Key features listed with user benefits
```

**Using Checkmarks:**
- Optional but helpful: Use ✅ or checkboxes for visual clarity
- Makes it easy to scan and verify completion

---

## Workflow Categories

Workflows are organized into categories based on their purpose:

### Planning Workflows

**Location:** `profiles/default/workflows/planning/`

**Purpose:** Strategic, long-term planning and product definition

**Characteristics:**
- Document creation focused
- High-level thinking
- Product vision and roadmap
- Foundation for future development

**Files:**
- `create-product-mission.md` - Define product vision, users, problems
- `create-product-roadmap.md` - Plan feature phases and timeline
- `create-product-tech-stack.md` - Document technical stack decisions
- `gather-product-info.md` - Collect product information from user

**Example Length:** 80-150 lines per workflow

---

### Specification Workflows

**Location:** `profiles/default/workflows/specification/`

**Purpose:** Requirements gathering and formal specification creation

**Characteristics:**
- Detailed documentation
- User story focused
- Technical requirements
- Formal structure

**Files:**
- `initialize-spec.md` - Create spec folder structure
- `research-spec.md` - Research and gather requirements (longest: ~290 lines)
- `write-spec.md` - Create formal spec.md document
- `verify-spec.md` - Verify spec completeness and quality

**Example Length:** 100-300 lines per workflow

---

### Implementation Workflows

**Location:** `profiles/default/workflows/implementation/`

**Purpose:** Code creation, testing, and verification

**Characteristics:**
- Code-focused
- Testing requirements
- Deliverable oriented
- Verification steps

**Files:**
- `create-tasks-list.md` - Break spec into implementation tasks
- `implement-tasks.md` - Implement features from tasks
- `compile-implementation-standards.md` - Compile relevant standards
- `verification/` - Subdirectory with verification workflows

**Example Length:** 60-250 lines per workflow

---

### Research Workflows

**Location:** `profiles/default/workflows/research/`

**Purpose:** Analysis, investigation, and information gathering

**Characteristics:**
- Analysis focused
- Information gathering
- Exploratory
- Documentation creation

**Files:**
- `research-issue.md` - Systematic GitHub issue analysis (~200 lines)

**Example Length:** 150-250 lines per workflow

---

## Workflow Injection Pattern

Workflows are designed to be **injected** into commands and agents via template tags.

### In Single-Agent Commands

```markdown
# /write-spec Command

Create a formal specification document from clear requirements.

{{workflows/specification/write-spec}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**Result:** The entire `write-spec.md` workflow content gets injected directly into the command file.

---

### In Multi-Agent Mode

**Command delegates to agent:**

```markdown
# /write-spec Command

Use @agent:spec-writer to create a formal specification.

The agent will:
- Read existing requirements if available
- Create spec.md following standard structure
- Verify completeness before finishing

Expected output: agent-os/specs/[spec-name]/spec.md
```

**Agent contains the workflow:**

```markdown
---
name: spec-writer
description: Use proactively to create a detailed specification
tools: Write, Read, Bash, WebFetch
color: purple
model: inherit
---

# Spec Writer Agent

I create formal specification documents from clear requirements.

{{workflows/specification/write-spec}}

{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

**Result:** The workflow is injected into the agent definition, keeping commands lightweight.

---

## Naming Conventions

### Workflow Files

**Format:** `kebab-case-name.md`

**Examples:**
- `create-product-mission.md`
- `write-spec.md`
- `implement-tasks.md`
- `research-issue.md`
- `verify-implementation.md`

**Naming Guidelines:**
- Start with action verb when possible (create, write, implement, verify)
- Use descriptive noun (product-mission, spec, tasks, issue)
- Keep it concise (2-4 words ideal)
- Match the primary responsibility

---

### Step Headings

**Format:** `### Step N: [Action Verb] [Object]`

**Good Examples:**
- `### Step 1: Fetch Issue Details`
- `### Step 2: Analyze Requirements`
- `### Step 3: Create Task File`
- `### Step 4: Verify Completeness`
- `### Step 5: Update Documentation`

**Bad Examples:**
- `### Step 1: Do the first thing`  # Vague verb
- `### Step 2: Next`  # No verb or object
- `### Step 3: Process data`  # Too generic

---

## Examples from Existing Workflows

### Example 1: research-issue.md (Research Category)

**Length:** ~200 lines

**Structure:**
- Core Responsibilities: 5 items
- Workflow: 7 comprehensive steps
- Important Constraints: 4 items
- Success Criteria: 6 items

**Key Characteristics:**
- External tool integration (`gh` CLI)
- Complex analysis with confidence levels
- Multiple solution proposals
- Comprehensive documentation output

**Core Responsibilities excerpt:**

```markdown
## Core Responsibilities

1. Fetch and analyze GitHub issue details systematically
2. Research relevant codebase files and patterns
3. Identify root causes with confidence levels
4. Propose multiple solution approaches with tradeoffs
5. Create comprehensive task analysis documentation
```

**Step excerpt:**

```markdown
### Step 4: Root Cause Analysis

Based on the issue details and codebase research, identify:

1. **Possible Root Causes** (list 2-3):
   - Technical explanation of what might be causing the issue
   - Supporting evidence from the codebase
   - Confidence level (high/medium/low)

2. **Technical Context**:
   - Architecture or design patterns involved
   - Dependencies or external systems
   - Potential side effects or edge cases
```

---

### Example 2: create-product-mission.md (Planning Category)

**Length:** ~80 lines

**Structure:**
- Workflow: Single step with comprehensive template
- Important Constraints: 2 items
- Focus on document template and structure

**Key Characteristics:**
- Heavy use of file templates
- Focused on document creation
- Includes inline examples with placeholders
- Emphasizes user benefits over technical details

**Template excerpt:**

```markdown
Create `agent-os/product/mission.md` with this structure:

\```markdown
# Product Mission

## Pitch
[PRODUCT_NAME] is a [PRODUCT_TYPE] that helps [TARGET_USERS]
[SOLVE_PROBLEM] by providing [KEY_VALUE_PROPOSITION].

## Users

### Primary Customers
- [CUSTOMER_SEGMENT_1]: [DESCRIPTION]
- [CUSTOMER_SEGMENT_2]: [DESCRIPTION]
\```
```

---

### Example 3: implement-tasks.md (Implementation Category)

**Length:** ~60 lines

**Structure:**
- Implementation process: 4 steps
- Scope Constraints: 5 items (instead of "Important Constraints")
- Self-verification guidance
- Focus on simplicity and existing patterns

**Key Characteristics:**
- Implementation focused
- Strong emphasis on scope control
- Testing requirements
- Visual verification (screenshots)
- Checkbox updates in tasks.md

**Scope Constraints excerpt:**

```markdown
## Scope Constraints:

- **Stay focused:** Implement only what's specified - avoid extra features
- **Reuse existing code:** Use existing patterns rather than creating new ones
- **Minimal file changes:** Modify only necessary files
- **Keep it simple:** Choose simplest solution that fulfills requirements
- **No premature optimization:** Don't add complex patterns unless required
```

---

## Creating New Workflows

### Planning Checklist

Before creating a new workflow, answer these questions:

**1. Define Purpose**
- What problem does this workflow solve?
- Who will use it? (Which agent or command?)
- When should it be invoked?
- What does success look like?

**2. List Core Responsibilities**
- What are the 3-5 main things this workflow does?
- Can each be stated as "Verb + Object"?
- Are they concrete and measurable?

**3. Break Into Steps**
- What's the logical sequence of actions?
- How many steps are needed? (5-10 is typical)
- Is each step atomic (can't be broken down further)?
- Do steps have clear inputs and outputs?

**4. Identify Constraints**
- What must NOT be done?
- What edge cases exist?
- How should errors be handled?
- What are the scope boundaries?

**5. Define Success**
- What should exist after completion?
- How can success be verified?
- What observable outcomes should occur?
- Can criteria be checked objectively?

---

### Writing Guidelines

**1. Be Explicit**
- Don't assume agent knowledge
- Provide concrete examples
- Explain "why" not just "what"
- Spell out edge cases

**2. Use Clear Structure**
- Follow the standard 4-section format
- Use consistent heading levels
- Number steps sequentially
- Organize logically (not chronologically if logic differs)

**3. Include Examples**
- Bash commands for CLI operations
- File templates for document creation
- Expected outputs for verification
- Error messages and solutions

**4. Consider Reusability**
- Can this be injected into multiple places?
- Is it self-contained (minimal external dependencies)?
- Does it work in both agent modes?
- Are template tag references correct?

---

### Testing New Workflows

**1. Read Through**
- Does each step make sense in sequence?
- Are instructions clear and unambiguous?
- Is anything missing or assumed?

**2. Test in Single-Agent Mode**
- Inject workflow into a command
- Run manually with test data
- Verify all outputs created correctly
- Check success criteria

**3. Test in Multi-Agent Mode**
- Inject workflow into agent
- Test delegation from command to agent
- Verify results match single-agent mode
- Check that agent has necessary tools

**4. Review with Fresh Eyes**
- Have someone else read it
- Can they follow the workflow?
- Any confusing sections?
- Are examples helpful?

---

## Common Patterns

### File Creation Pattern

Use this pattern when workflow creates files:

```markdown
### Step N: Create [File Name]

1. Check if directory exists, create if needed:
   \```bash
   mkdir -p path/to/directory
   \```

2. Check if file already exists:
   - If exists: Read for context, update accordingly
   - If not: Create new file

3. Create/update file with this structure:
   \```markdown
   [Template content here]
   \```

4. Verify file was created successfully:
   \```bash
   test -f path/to/file.md && echo "Success"
   \```
```

---

### Analysis Pattern

Use this pattern for investigating or analyzing:

```markdown
### Step N: Analyze [Subject]

1. Extract key information:
   - [Information type 1]
   - [Information type 2]
   - [Information type 3]

2. Identify patterns:
   - [Pattern type 1]
   - [Pattern type 2]

3. Document findings in [location]:
   - Finding 1
   - Finding 2

4. Determine next steps based on analysis
```

---

### Verification Pattern

Use this pattern for checking results:

```markdown
### Step N: Verify [Outcome]

1. Check that [condition 1]:
   - Expected: [what should be true]
   - Verify: [how to check]

2. Confirm [condition 2]:
   - Expected: [what should be true]
   - Verify: [how to check]

3. If verification fails:
   - [Remediation step 1]
   - [Remediation step 2]

4. Report results to user with status summary
```

---

## Anti-Patterns (Avoid These)

### ❌ Vague Instructions

**Bad:**
```markdown
### Step 1: Do the thing

Figure it out and make it work.
```

**Good:**
```markdown
### Step 1: Create Mission Document

1. Create file at `agent-os/product/mission.md`
2. Use the template structure provided below
3. Fill in all placeholder values [LIKE_THIS]
4. Verify file exists after creation
```

---

### ❌ Too Much Assumed Knowledge

**Bad:**
```markdown
### Step 1: Run the standard command

You know which one. Just do what you normally do.
```

**Good:**
```markdown
### Step 1: Fetch Issue Details

Use `gh issue view {ISSUE_NUMBER}` to retrieve:
- Issue title and description
- Labels and assignees
- Comments and discussion
```

---

### ❌ Missing Error Handling

**Bad:**
```markdown
### Step 1: Fetch data from API

Get the data from the API endpoint.
```

**Good:**
```markdown
### Step 1: Fetch Data from API

1. Make request to API endpoint:
   \```bash
   curl https://api.example.com/data
   \```

2. If request fails:
   - Check network connectivity
   - Verify API endpoint is correct
   - Check authentication credentials
   - Report error to user with details

3. If successful, parse response and continue
```

---

### ❌ No Success Criteria

**Bad:**
```markdown
# Workflow Name

## Core Responsibilities
...

## Workflow
...

[No Success Criteria section - workflow just ends]
```

**Good:**
```markdown
## Success Criteria

1. ✅ All required files created in correct locations
2. ✅ File contents match template structure
3. ✅ No errors reported during execution
4. ✅ User informed of completion with summary
```

---

## Maintenance

### When to Update Workflows

**1. User Feedback**
- Users report confusion about specific steps
- Missing information prevents successful execution
- Instructions don't match current tools or patterns

**2. Pattern Changes**
- New tools become available (e.g., new CLI commands)
- Better approaches discovered
- Agent OS architecture evolves

**3. Bug Reports**
- Workflow produces incorrect results
- Steps don't work as described
- Missing edge cases cause failures

---

### Update Process

1. **Identify the issue**
   - What's wrong or missing?
   - Which steps are affected?
   - Is it a pattern used across multiple workflows?

2. **Create feature branch**
   ```bash
   git checkout -b workflows/fix-create-tasks-workflow
   ```

3. **Update workflow file**
   - Make necessary changes
   - Update examples if needed
   - Ensure 4-section structure maintained

4. **Test the update**
   - Test in single-agent mode
   - Test in multi-agent mode
   - Verify both produce same results

5. **Document in CHANGELOG.md**
   ```markdown
   ## [2.1.4] - 2024-01-15

   ### Changed
   - Updated create-tasks-list.md workflow to include dependency tracking
   ```

6. **Commit and PR**
   ```bash
   git commit -m "workflows: Fix task dependency tracking in create-tasks-list"
   git push origin workflows/fix-create-tasks-workflow
   gh pr create
   ```

---

### Versioning

- Workflows inherit Agent OS version (no separate versioning)
- Changes documented in CHANGELOG.md
- Major workflow changes may warrant minor version bump
- Breaking changes require major version bump

---

### Backward Compatibility

**Remember:**
- Existing projects use OLD workflows (installed at their version)
- New projects get NEW workflows (current version)
- Project updates are optional (users choose when to update)

**Implications:**
- Don't break existing workflows without major version bump
- If changing workflow structure, test with both old and new versions
- Document migration path in CHANGELOG.md

---

## Quick Reference

### Workflow Structure Template

```markdown
# [Workflow Name]

## Core Responsibilities

1. [Action verb] [object]
2. [Action verb] [object]
3. [Action verb] [object]

## Workflow

### Step 1: [Action Verb] [Object]

[Instructions]

### Step 2: [Action Verb] [Object]

[Instructions]

## Important Constraints

1. [Constraint]
2. [Constraint]
3. [Constraint]

## Success Criteria

1. ✅ [Checkable condition]
2. ✅ [Checkable condition]
3. ✅ [Observable outcome]
```

---

### Common Template Tags in Workflows

**Workflow injection:**
```markdown
{{workflows/category/workflow-name}}
```

**Standards injection:**
```markdown
{{standards/*}}                    # All standards
{{standards/global/*}}             # Just global
{{standards/frontend/*}}           # Just frontend
{{standards/backend/*}}            # Just backend
{{standards/testing/*}}            # Just testing
```

**Conditional blocks:**
```markdown
{{UNLESS standards_as_claude_code_skills}}
{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
```

---

## Related Documentation

- **[development-phases.md](development-phases.md)** - The 7 phases that use these workflows
- **[agent-patterns.md](agent-patterns.md)** - Agents that execute workflows
- **[template-system.md](template-system.md)** - How workflows are injected
- **[agent-modes.md](agent-modes.md)** - Single vs multi-agent workflow execution
- **[standards-structure.md](standards-structure.md)** - Standards that guide workflows
