# Research GitHub Issue

Research a GitHub issue by analyzing the issue details and codebase to generate a comprehensive task analysis file.

## Usage

This command helps you systematically research a GitHub issue. When invoked, you'll need to provide the issue number to research.

**Example:** `/research-issue` (then specify the issue number when Claude asks)

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated (`gh auth status`)
- Access to the repository with the issue
- Issue number to research

## Instructions

You are tasked with researching a GitHub issue. First, ask the user for the issue number if not already provided, then proceed with the research using that issue number (referred to as `{ISSUE_NUMBER}` below).

{{workflows/research/research-issue}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that your analysis and proposed solutions ARE ALIGNED and DO NOT CONFLICT with the user's tech stack, coding conventions, and standards as detailed in the following files:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
