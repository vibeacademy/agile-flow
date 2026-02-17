---
description: Create a well-structured ticket that meets Definition of Ready
---

Create a new ticket on the project board with guided workflow.

## Critical Rules

1. **Every ticket must meet Definition of Ready** before being added to the board
2. **Use the board configuration** from the project's GitHub Project settings
3. **Never create duplicate tickets** — search existing issues first
4. **Assign appropriate priority** (P0 = critical, P1 = important, P2 = nice to have)

## Workflow

1. **Understand** — Ask clarifying questions about the feature/fix/task
2. **Research** — Search existing issues to avoid duplicates, check related code
3. **Draft** — Write the ticket following the template below
4. **Review** — Present the draft to the user for approval
5. **Create** — Create the GitHub issue and add it to the project board
6. **Categorize** — Set priority, size estimate, and move to Backlog

## Ticket Template

```markdown
## Problem
[What problem does this solve? Why does it matter?]

## Acceptance Criteria
- [ ] [Specific, testable criterion]
- [ ] [Another criterion]

## Technical Guidance
[Implementation hints, relevant files, patterns to follow]

## Parent Epic
#[epic-number] (if applicable)

## Effort Estimate
[XS (<30 min) | S (1-2 hours) | M (2-4 hours) | L (4-8 hours) | XL (1+ days)]
```

## Usage

```
/create-ticket
/create-ticket Add health check endpoint to the API
```
