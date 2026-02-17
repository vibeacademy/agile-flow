# Sentry Setup Guide

This guide covers configuring Sentry for the Agile Flow starter app, including
the GitHub integration that auto-creates issues from unhandled exceptions.

## Prerequisites

- A [Sentry](https://sentry.io) account (free tier works)
- A GitHub organization with the agile-flow repo

## 1. Create a Sentry Project

1. Go to **Settings > Projects > Create Project**
1. Select **FastAPI** as the platform
1. Name the project (e.g., `agile-flow-starter`)
1. Copy the **DSN** from the project settings

## 2. Configure the App

The app reads `SENTRY_DSN` from the environment. If unset, Sentry is skipped
and the app runs normally.

**Local development:**

```bash
export SENTRY_DSN="https://examplePublicKey@o0.ingest.sentry.io/0"
uv run uvicorn app.main:app --reload
```

**Render deployment:**

Add `SENTRY_DSN` as an environment variable in the Render dashboard or via
an env group. The `render.yaml` already declares it as a sync-false env var.

## 3. Verify Error Capture

Hit the `/error` endpoint to trigger a deliberate exception:

```bash
curl https://your-app.onrender.com/error
```

The exception should appear in Sentry within seconds. This is the Day 1
workshop exercise — founders see the full loop from code error to Sentry alert.

## 4. Enable GitHub Integration (Auto-Create Issues)

This is configured in the Sentry admin UI, not in code.

1. Go to **Settings > Integrations > GitHub**
1. Click **Install** and authorize for your GitHub organization
1. Link the Sentry project to the GitHub repository
1. Go to **Alerts > Create Alert Rule**:
   - Condition: "A new issue is created"
   - Action: "Create a GitHub issue"
   - Select the target repository
   - Save the alert rule

Now every new unhandled exception in Sentry will automatically create a GitHub
issue, which appears on the project board for triage.

## 5. Optional: Sentry Environment Tags

To distinguish between production and preview deployments, set the
`SENTRY_ENVIRONMENT` env var:

```bash
# Production
SENTRY_ENVIRONMENT=production

# Preview (set in Render preview env)
SENTRY_ENVIRONMENT=preview
```

The app's `sentry_sdk.init()` will pick this up automatically via the
`environment` parameter if you add it to the init call.
