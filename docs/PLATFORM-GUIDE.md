# Platform Guide

Agile Flow supports multiple deployment platforms. Your choice is stored
in `.claude/PROJECT.md` and read by the `devops-engineer` and
`system-architect` agents.

## Supported Platforms

| Platform | Best For | Free Tier | Preview Envs |
|----------|----------|-----------|-------------|
| Render | Full-stack web apps, APIs | Yes | Yes (built-in) |
| Cloudflare | Edge computing, static sites | Yes | Yes (Workers) |
| Vercel | Frontend apps, Next.js | Yes | Yes (automatic) |
| Railway | Containers, databases | Trial | Yes |
| Fly.io | Global edge containers | Yes | Manual |

## Default: Render

This template ships configured for Render:

- `render.yaml` defines the service with preview environments enabled
- `deploy.yml` deploys to Render on merge to main
- `preview-deploy.yml` manages Render preview environments
- `rollback-production.yml` rolls back via Render API

## Choosing Your Platform

Run `/bootstrap-architecture` to select your platform. The choice is
written to `.claude/PROJECT.md`:

```markdown
## Platform
- **Hosting**: render
- **Selected**: 2026-02-17
```

## Switching Platforms

To switch platforms after initial setup:

1. Update `.claude/PROJECT.md` with the new platform
2. Replace the platform-specific workflow files:
   - `deploy.yml` -- production deployment
   - `preview-deploy.yml` -- PR preview environments
   - `preview-cleanup.yml` -- cleanup on PR close
3. Update `render.yaml` / `vercel.json` / `fly.toml` as needed
4. Update repository secrets in GitHub Settings

## Platform-Specific Setup

### Render

**Required secrets:**

| Secret | Where to Find |
|--------|--------------|
| `RENDER_API_KEY` | Render Dashboard > Account Settings > API Keys |
| `RENDER_SERVICE_ID` | Render Dashboard > Service > Settings |

**Configuration file:** `render.yaml`

### Cloudflare

**Required secrets:**

| Secret | Where to Find |
|--------|--------------|
| `CLOUDFLARE_API_TOKEN` | Cloudflare Dashboard > Profile > API Tokens |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare Dashboard > Overview (sidebar) |

**Configuration file:** `wrangler.toml`

### Vercel

**Required secrets:**

| Secret | Where to Find |
|--------|--------------|
| `VERCEL_TOKEN` | Vercel Dashboard > Settings > Tokens |
| `VERCEL_ORG_ID` | Vercel Dashboard > Settings > General |
| `VERCEL_PROJECT_ID` | Vercel Dashboard > Project > Settings |

**Configuration file:** `vercel.json`

### Railway

**Required secrets:**

| Secret | Where to Find |
|--------|--------------|
| `RAILWAY_TOKEN` | Railway Dashboard > Account > Tokens |

**Configuration file:** `railway.toml`

### Fly.io

**Required secrets:**

| Secret | Where to Find |
|--------|--------------|
| `FLY_API_TOKEN` | `fly tokens create deploy` |

**Configuration file:** `fly.toml`

## Error Monitoring

The app ships with zero-config error telemetry — errors are captured and
turned into GitHub issues automatically. For a full monitoring dashboard,
you can connect an external service.

### Default: Self-Receiver (Zero Config)

No setup required. The app's built-in `/api/error-events` endpoint receives
errors from the Sentry SDK and creates GitHub issues labeled `bug:auto`.
See `docs/SENTRY-SETUP.md` for details.

### Optional: GlitchTip (Self-Hosted)

[GlitchTip](https://glitchtip.com) is an open-source, Sentry-compatible
error tracker. It uses the same Sentry SDK — just change the DSN.

**Why GlitchTip over Sentry SaaS:**

| Factor | GlitchTip | Sentry SaaS |
|--------|-----------|-------------|
| Cost | Render resources (~$14-25/mo) | Free tier, then scales |
| Privacy | 100% self-hosted | Third-party data processing |
| Maintenance | You manage updates | Zero maintenance |
| Features | Error tracking, basic APM, uptime | Full observability platform |

**Render deployment (3 services):**

| Service | Type | Purpose |
|---------|------|---------|
| glitchtip-web | Docker | Django backend + Angular frontend |
| glitchtip-worker | Docker | Celery worker for event processing |
| glitchtip-db | PostgreSQL | Error data and user accounts |

For deployment instructions, see the
[GlitchTip self-hosted guide](https://glitchtip.com/documentation/install).

**Connecting your app:**

```bash
# Set SENTRY_DSN to your GlitchTip instance
# This overrides the default self-receiver
SENTRY_DSN=https://key@your-glitchtip.onrender.com/1
```

Add `SENTRY_DSN` to your Render environment variables. The app will send
errors to GlitchTip instead of the built-in receiver.

### Optional: Sentry SaaS

[Sentry](https://sentry.io) is the original error tracking platform. The
free tier includes 5,000 errors per month.

**Setup:** See `docs/SENTRY-SETUP.md` for configuration steps.

**Required secrets:**

| Secret | Where to Find |
|--------|---------------|
| `SENTRY_DSN` | Sentry Dashboard > Project > Settings > Client Keys |

## Adding a New Platform

1. Create deployment workflow in `.github/workflows/`
2. Add platform detection to `.claude/agents/devops-engineer.md`
3. Add setup instructions to this guide
4. Document required secrets in `docs/CI-CD-GUIDE.md`
