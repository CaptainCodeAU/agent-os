# Research GitHub Issue Workflow

## Core Responsibilities

1. Fetch and analyze GitHub issue details systematically
2. Research relevant codebase files and patterns
3. Identify root causes with confidence levels
4. Propose multiple solution approaches with tradeoffs
5. Create comprehensive task analysis documentation

## Workflow

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

### Step 2: Analyze the Issue

1. Extract key information:
   - What is the problem or feature request?
   - What are the expected vs. actual behaviors?
   - Are there error messages, stack traces, or logs?
   - What files or components are mentioned?
   - Are there reproduction steps?

2. Identify relevant keywords and patterns to search for in the codebase

### Step 3: Codebase Research

1. Search for relevant files and code:
   - Files mentioned in the issue
   - Components or modules related to the problem
   - Similar patterns or related functionality
   - Test files that might need updating
   - Documentation that might be affected

2. Use appropriate tools:
   - `Grep` for exact string matches
   - `Task` tool with Explore agent for semantic codebase searches
   - `Glob` for finding files by pattern
   - `Read` to examine relevant files

3. Document your findings:
   - Which files are most relevant?
   - What does the current implementation look like?
   - Are there existing tests?
   - What dependencies or integrations are involved?

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

### Step 5: Solution Planning

Propose **two solution approaches**, ranked by preference:

**Solution 1 (Preferred):**
- High-level approach
- Key changes required
- Files to modify
- Pros and cons
- Estimated complexity (low/medium/high)
- Risks and considerations

**Solution 2 (Alternative):**
- High-level approach
- Key changes required
- Files to modify
- Pros and cons
- Estimated complexity
- Why it's less preferred than Solution 1

### Step 6: Create Task File

1. Check if `.claude-workspace/research/issues/` directory exists, create if needed
2. Check if a task file already exists: `.claude-workspace/research/issues/{ISSUE_NUMBER}-{sanitized-title}.md`
   - If it exists, read it first for context and update accordingly
   - If not, create a new file
3. Use this structure:

```markdown
# Issue #{ISSUE_NUMBER}: {Issue Title}

**Status:** Research Complete | In Progress | Blocked
**Priority:** {from labels or assessment}
**Complexity:** Low | Medium | High
**Labels:** {issue labels}

## Issue Summary

{Brief summary of the issue}

**Link:** {GitHub issue URL}

## Key Details

- **Reporter:** {username}
- **Created:** {date}
- **Updated:** {date}
- **Assignee:** {if any}

### Description

{Issue description - key points}

### Expected Behavior

{what should happen}

### Actual Behavior

{what is happening}

### Reproduction Steps

{if provided}

## Codebase Research Findings

### Relevant Files

1. `path/to/file1.ext` - {why relevant}
2. `path/to/file2.ext` - {why relevant}

### Current Implementation

{summary of how the relevant code currently works}

### Related Code Patterns

{any similar implementations or patterns found}

### Test Coverage

{existing tests, gaps identified}

## Root Cause Analysis

### Possible Causes

1. **{Cause 1}** (Confidence: High/Medium/Low)
   - {explanation}
   - Supporting evidence: {from codebase}

2. **{Cause 2}** (Confidence: High/Medium/Low)
   - {explanation}
   - Supporting evidence: {from codebase}

### Technical Context

- Architecture patterns involved
- Dependencies and integrations
- Potential side effects

## Proposed Solutions

### Solution 1: {Approach Name} ⭐ PREFERRED

**Approach:** {high-level description}

**Changes Required:**
- Modify `file1.ext`: {what to change}
- Update `file2.ext`: {what to change}
- Add tests in `test-file.ext`

**Pros:**
- {benefit 1}
- {benefit 2}

**Cons:**
- {drawback 1}
- {drawback 2}

**Complexity:** Low | Medium | High

**Risks:**
- {risk 1}
- {risk 2}

### Solution 2: {Alternative Approach Name}

**Approach:** {high-level description}

**Changes Required:**
- {changes needed}

**Pros:**
- {benefit 1}

**Cons:**
- {drawback 1}
- {drawback 2}

**Why Less Preferred:**
{explanation of why Solution 1 is better}

**Complexity:** Low | Medium | High

## Technical Considerations

### Dependencies
- {external libraries or services}

### Breaking Changes
- {any breaking changes}

### Migration Requirements
- {if data migration needed}

### Testing Strategy
- {how to test the fix}

## Questions for Clarification

{List any questions you need answered before implementation}

## Next Steps

1. {action item 1}
2. {action item 2}
3. {action item 3}

## Research Notes

{Any additional observations, links, or context}

---

**Research completed:** {date}
**Researched by:** Claude Code
```

### Step 7: Present Summary

After creating the task file, provide the user with:

1. A brief summary of the issue
2. Your top recommended solution
3. Any questions you need answered
4. The path to the created task file

## Important Constraints

1. **Ask for clarification** at any point if:
   - The issue description is unclear
   - You need more context about the codebase
   - You're uncertain about the best approach
   - You need access to external resources

2. **Be thorough but efficient**:
   - Focus on the most relevant parts of the codebase
   - Don't read entire large files unless necessary
   - Use semantic search for exploratory research

3. **Update existing files**:
   - If a task file already exists, read it first
   - Preserve useful information
   - Update with new findings
   - Note what changed in the research notes

4. **Handle errors gracefully**:
   - If GitHub CLI isn't available, ask the user to provide issue details
   - If file operations fail, report the error clearly
   - If the issue number is invalid, let the user know

## Success Criteria

1. ✅ Issue details successfully fetched from GitHub
2. ✅ Relevant codebase files identified and analyzed
3. ✅ Root causes identified with confidence levels
4. ✅ Two solution approaches proposed with clear tradeoffs
5. ✅ Comprehensive task file created in `.claude-workspace/research/issues/`
6. ✅ Summary presented to user with recommended next steps
