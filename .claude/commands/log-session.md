---
description: Log a development session summary for continuity across sessions
---

Record what happened this session so the next session has context.

## What to Capture

1. **Tickets Delivered** — Issue numbers, PR numbers, what was implemented
2. **Tickets In Progress** — What's partially done, where you left off
3. **Challenges** — Blockers encountered, workarounds used
4. **Mitigations** — How challenges were resolved or worked around
5. **Insights** — Patterns discovered, lessons learned, things to remember
6. **Next Steps** — What should happen next session

## Output Format

Post the session log as a comment on the relevant epic or milestone issue.
If no epic is active, create a standalone session log in the PR or issue
being worked on.

```markdown
## Session Log — [Date]

### Delivered
- #123: Added health check endpoint (PR #456 merged)
- #124: Fixed Sentry integration (PR #457 in review)

### In Progress
- #125: Preview deploy workflow — CI passing, waiting on RENDER_API_KEY secret

### Challenges
- Render API rate limiting during preview service polling

### Mitigations
- Added exponential backoff to polling loop

### Insights
- Render preview services use naming pattern `{service}-pr-{number}`

### Next Steps
- Configure RENDER_API_KEY secret in repo settings
- Pick up #126 from Ready column
```

## Usage

```
/log-session
```
