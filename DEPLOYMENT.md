# Deployment Guide

This guide explains how to deploy the IceBreaker application to production.

## Overview

- **Frontend Apps**: Deployed to Cloudflare Pages
  - Web App: `ice-breaker` project
  - Admin App: `ice-breaker-admin` project
- **Backend**: Supabase for database, auth, and realtime features
- **CI/CD**: GitHub Actions for automated testing and deployment

## Prerequisites

1. **Supabase Account & Project**
   - Create account at https://supabase.com
   - Create a new project
   - Note your project reference ID

2. **Cloudflare Account**
   - Create account at https://cloudflare.com
   - Get your Account ID from dashboard
   - Create API token with Pages permissions

## Setup Instructions

### 1. Supabase Setup

1. Go to https://supabase.com/dashboard
2. Create a new project (or use existing)
3. Get your project reference ID:
   - Settings > General > Reference ID
4. Generate an access token:
   - Account Settings > Access Tokens
   - Create new token with appropriate permissions
5. Link your local project:
   ```bash
   supabase link --project-ref YOUR_PROJECT_REF
   ```

### 2. Cloudflare Pages Setup

1. Log in to Cloudflare dashboard
2. Go to Pages section
3. Create two new projects:
   - `ice-breaker` (for web-app)
   - `ice-breaker-admin` (for admin-app)
4. Get your Account ID:
   - Go to any domain > Overview
   - Account ID is shown in the right sidebar
5. Create API Token:
   - Go to My Profile > API Tokens
   - Create Token > Edit Cloudflare Workers
   - Or use template: "Edit Cloudflare Workers"
   - Permissions needed: Account.Cloudflare Pages (Edit)

### 3. GitHub Secrets Configuration

Add these secrets to your GitHub repository:

**Go to:** Repository > Settings > Secrets and variables > Actions > New repository secret

**Add the following secrets:**

| Secret Name | Description | Where to Find |
|-------------|-------------|---------------|
| `SUPABASE_ACCESS_TOKEN` | Supabase access token | Supabase Dashboard > Account Settings > Access Tokens |
| `SUPABASE_PROJECT_REF` | Supabase project reference ID | Supabase Dashboard > Project Settings > General > Reference ID |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token | Cloudflare Dashboard > My Profile > API Tokens |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare account ID | Cloudflare Dashboard (shown in sidebar) |

### 4. Deploy

Once secrets are configured, deployment is automatic:

**Automatic Deployment:**
- Push to `main` branch triggers deployment workflow
- CI runs tests first, then deploys if tests pass

**Manual Deployment:**
1. Go to Actions tab in GitHub
2. Select "Deploy" workflow
3. Click "Run workflow"
4. Select branch and run

## Deployment Workflow

The deploy workflow (`.github/workflows/deploy.yml`) performs these steps:

1. **Setup Environment**
   - Checkout code
   - Setup Node.js 20 and pnpm
   - Install dependencies

2. **Supabase Deployment**
   - Link to Supabase project
   - Deploy database migrations

3. **Build Applications**
   - Build admin-app for production
   - Build web-app for production

4. **Deploy to Cloudflare Pages**
   - Deploy admin-app to `ice-breaker-admin` project
   - Deploy web-app to `ice-breaker` project

## Build Output

After building, the applications are output to:
- **Admin App**: `apps/admin-app/dist/admin-app/browser/`
- **Web App**: `apps/web-app/dist/web-app/browser/`

These directories are what get deployed to Cloudflare Pages.

## Environment Variables

If you need environment variables in your apps:

1. Create `.env` files in each app directory (already gitignored)
2. Add variables to Cloudflare Pages project settings:
   - Go to Cloudflare Pages > Your Project > Settings > Environment Variables
   - Add production variables

3. Reference in Angular using `environment.ts` files

## Troubleshooting

### Deployment Fails

1. **Check Secrets**: Ensure all GitHub secrets are correctly set
2. **Check Build**: Run `pnpm build:all` locally to verify builds work
3. **Check Logs**: View workflow logs in GitHub Actions tab
4. **Supabase Connection**: Verify project ref and access token are correct

### Cloudflare Deployment Issues

1. **Project Names**: Ensure Cloudflare projects exist with exact names:
   - `ice-breaker`
   - `ice-breaker-admin`
2. **API Token**: Verify token has Pages edit permissions
3. **Account ID**: Double-check account ID is correct

### Database Migration Issues

1. Check migration files in `supabase/migrations/`
2. Test migrations locally: `supabase db push --dry-run`
3. Verify Supabase access token has sufficient permissions

## Monitoring

- **Application Logs**: Cloudflare Pages dashboard
- **Database**: Supabase dashboard > Database
- **Realtime**: Supabase dashboard > API Logs
- **Deployment Status**: GitHub Actions tab

## Rollback

To rollback a deployment:

1. **Cloudflare Pages**:
   - Go to project > Deployments
   - Find previous working deployment
   - Click "Rollback to this deployment"

2. **Supabase**:
   - Database changes may need manual rollback
   - Use migration down scripts if available
