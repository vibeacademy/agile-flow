# A Day in the Life: Maya's First Agile Flow Workshop

Maya opens her laptop at 9am, coffee in hand. She's a product designer
who's been learning to code — today's the workshop where she builds
something real.

---

## 9:00 — The Template

The instructor shares a link. Maya clicks **"Use this template"** on
GitHub, names her repo `maya-taskflow`, and clones it down. She runs
`/doctor` — all green checkmarks. That felt easy.

## 9:15 — Deploy First

Before writing a single line of code, Maya connects her repo to Render.
She watches the build logs scroll by — Next.js compiling, standalone
output packaging — and two minutes later, her app is live. She visits
the URL and sees the landing page: *"Agile Flow Starter"* with a list of
endpoints. She clicks `/api/health` and gets `{"status":"ok"}`.

She's deployed to production and it's not even 9:30.

## 9:20 — The Error Test

The instructor says, "Now break it on purpose." Maya hits `/api/error`
in her browser. Nothing visible happens. But thirty seconds later, a
GitHub issue appears in her repo:
`bug: Error: Test error for Sentry verification`. Auto-created,
auto-labeled `bug:auto`, complete with a stack trace. She grins. The
safety net works before she's even started building.

## 9:30 — Product Definition

Maya types `/bootstrap-product`. The agent asks her what she wants to
build. She describes a personal task manager with daily focus mode. Back
and forth — the agent pushes back on scope, asks about target users,
suggests cutting a feature she hadn't thought through. Twenty minutes
later she has a PRD. It feels like a real product conversation, not a
template fill-in.

## 10:00 — Architecture

`/bootstrap-architecture`. The agent reads her PRD and asks about her
deployment platform — she picks Render since she's already there. It
proposes Next.js (already set up), Supabase for the database, and a
simple component structure. No over-engineering. She approves and the
technical architecture doc materializes.

## 10:30 — The Board Comes Alive

`/bootstrap-agents`, then `/bootstrap-workflow`. Her GitHub Project board
populates with tickets — each one with acceptance criteria, guardrails,
and a happy path. She can see the whole product laid out as work items.
The "Ready" column has her first sprint.

## 11:00 — First Real Ticket

`/work-ticket`. The agent picks up "Add task creation form" from the
Ready column, moves it to In Progress, creates a branch, writes the
component, adds tests, pushes, and opens a PR. Maya watches it happen in
real time — code appearing, tests running, the PR description linking
back to the ticket.

CI runs. All green. The ticket slides to In Review.

## 11:15 — The Review

The instructor explains: "The agent writes code and reviews code, but
only a human merges." Maya looks at the PR. The reviewer bot has already
left a structured review — requirements checklist, code quality notes,
security check, a **GO** recommendation with one non-blocking suggestion
about extracting a utility function. Maya reads the diff, agrees it
looks good, and hits merge.

The ticket moves to Done. Her app redeploys with the new feature.

## 11:20 — The Moment

Maya refreshes her production URL. There's a task creation form. It
works. She created a product requirement, got an architecture, generated
a ticket, had it implemented, reviewed, merged, and deployed — and it's
still before lunch.

She takes a sip of her now-cold coffee and thinks: *this is what
shipping feels like.*

---

**By end of Day 1**, Maya has three features deployed. By end of Day 3,
she has a working task manager with daily focus mode, error monitoring,
and a clean git history of 20+ PRs — each one reviewed, tested, and
traceable to a ticket.

She never once committed directly to main.
