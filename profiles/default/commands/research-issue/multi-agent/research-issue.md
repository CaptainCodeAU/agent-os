# Research GitHub Issue

Research a GitHub issue by delegating to the issue-researcher agent.

## Usage

This command helps you systematically research a GitHub issue and create a comprehensive task analysis file.

**Example:** `/research-issue` (then specify the issue number when prompted)

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated (`gh auth status`)
- Access to the repository with the issue
- Issue number to research

## Instructions

When the user requests issue research:

1. **Get the issue number**: Ask the user for the issue number if not already provided

2. **Delegate to the issue-researcher agent**: Use the **issue-researcher** subagent to research the issue

   Provide the issue-researcher with:
   - The issue number to research
   - Any additional context the user has provided

3. **The agent will**:
   - Fetch issue details from GitHub using `gh issue view`
   - Analyze the issue and extract key information
   - Research the codebase for relevant files and patterns
   - Identify root causes with confidence levels
   - Propose two solution approaches (preferred and alternative)
   - Create a comprehensive task file in `.claude-workspace/research/issues/`

4. **Review and present**: Once the issue-researcher has completed the research, present the summary to the user

## Output

Once the issue-researcher has created the task file, output the following to inform the user:

```
✅ Issue research complete!

**Issue:** #{ISSUE_NUMBER} - {Issue Title}
**Task File:** `.claude-workspace/research/issues/{ISSUE_NUMBER}-{sanitized-title}.md`

**Recommended Solution:** {Brief description of preferred solution}

**Next Steps:**
1. Review the task file for detailed analysis
2. Discuss any questions or clarifications needed
3. Consider creating a spec with `/shape-spec` if this is a significant feature
4. Or proceed directly to implementation if the solution is straightforward
```

## Tips

- The issue-researcher will ask clarifying questions if the issue details are unclear
- You can research multiple related issues and compare approaches
- The task files are stored in `.claude-workspace/` (gitignored) for exploratory analysis
- Once you're ready to implement, consider formalizing with Agent OS workflows (`/shape-spec`, `/write-spec`, etc.)
