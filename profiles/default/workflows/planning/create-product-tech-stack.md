Create `agent-os/product/tech-stack.md` with a list of all tech stack choices that cover all aspects of this product's codebase.

### Creating the Tech Stack document

#### Step 1: Note User's Input Regarding Tech Stack

IF the user has provided specific information in the current conversation in regards to tech stack choices, these notes ALWAYS take precidence.  These must be reflected in your final `tech-stack.md` document that you will create.

#### Step 2: Gather User's Default Tech Stack Information

Reconcile and fill in the remaining gaps in the tech stack list by finding, reading and analyzing information regarding the tech stack.  Find this information in the following sources, in this order:

1. If user has provided their default tech stack under "User Standards & Preferences Compliance", READ and analyze this document.
2. If the current project has any of these files, read them to find information regarding tech stack choices for this codebase:
  - `claude.md`
  - `agents.md`

#### Step 2a: Validate Default Tech Stack Template (Optional Warning)

If the tech stack information from "User Standards & Preferences Compliance" contains placeholder examples like `[e.g., Rails, Django, Next.js]` or similar bracketed placeholders:

**Consider informing the user:**
```
Note: Your default tech stack in standards/global/tech-stack.md appears to contain
placeholder examples. While this is fine, filling it out with your actual default
preferences can help provide better defaults for future products.

Would you like to continue with product-specific tech stack choices, or would you
prefer to first update your default tech stack template?
```

**If user wants to update defaults first:** Pause and let them update `standards/global/tech-stack.md` before continuing.

**If user wants to continue:** Proceed with product-specific tech stack creation using user input and project analysis.

#### Step 3: Create the Tech Stack Document

Create `agent-os/product/tech-stack.md` and populate it with the final list of all technical stack choices, reconciled between the information the user has provided to you and the information found in provided sources.
