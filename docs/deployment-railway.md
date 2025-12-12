# Railway Deployment Guide

This guide explains how to deploy NomadHire to Railway's free tier.

## Prerequisites

- [Railway account](https://railway.app/) (free tier)
- GitHub repository with your code
- Stripe/Razorpay test credentials

## Backend Deployment

### 1. Create New Project

1. Go to [Railway Dashboard](https://railway.app/dashboard)
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Choose your NomadHire repository

### 2. Add PostgreSQL

1. In your project, click "+ New"
2. Select "Database" → "Add PostgreSQL"
3. Railway will automatically set `DATABASE_URL`

### 3. Add Redis (Optional, for Sidekiq)

1. Click "+ New"
2. Select "Database" → "Add Redis"
3. Railway will automatically set `REDIS_URL`

### 4. Configure Backend Service

1. Click on your backend service
2. Go to "Settings" → "Root Directory" → Set to `backend`
3. Set build command: `bundle install`
4. Set start command: `bundle exec rails db:migrate && bundle exec puma -C config/puma.rb`

### 5. Set Environment Variables

Go to "Variables" and add:

```
RAILS_ENV=production
SECRET_KEY_BASE=<generate with: rails secret>
DEVISE_JWT_SECRET=<generate random string>
FRONTEND_URL=https://your-frontend-url.pages.dev
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
RAZORPAY_KEY_ID=rzp_test_xxx
RAZORPAY_KEY_SECRET=xxx
RAILS_MASTER_KEY=<if using credentials>
```

### 6. Generate Domain

1. Go to "Settings" → "Networking"
2. Click "Generate Domain"
3. Note your URL: `https://nomadhire-backend.up.railway.app`

## Frontend Deployment (Cloudflare Pages)

We recommend Cloudflare Pages for the frontend for its generous free tier.

### 1. Create Cloudflare Pages Project

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Select "Workers & Pages"
3. Click "Create application" → "Pages"
4. Connect your GitHub repository

### 2. Configure Build Settings

```
Framework preset: SvelteKit
Build command: npm run build
Build output directory: .svelte-kit/cloudflare
Root directory: frontend
```

### 3. Set Environment Variables

```
VITE_API_URL=https://nomadhire-backend.up.railway.app/api/v1
VITE_WS_URL=wss://nomadhire-backend.up.railway.app/cable
VITE_STRIPE_KEY=pk_test_xxx
VITE_RAZORPAY_KEY=rzp_test_xxx
```

### 4. Deploy

Click "Save and Deploy"

## Post-Deployment

### 1. Update CORS

In Railway backend, update `FRONTEND_URL` to your Cloudflare Pages URL.

### 2. Configure Stripe Webhooks

1. Go to [Stripe Dashboard](https://dashboard.stripe.com/test/webhooks)
2. Add endpoint: `https://your-backend.up.railway.app/api/v1/webhooks/stripe`
3. Select events: `payment_intent.succeeded`, `payment_intent.failed`
4. Copy webhook secret to Railway environment variables

### 3. Configure Razorpay Webhooks

1. Go to [Razorpay Dashboard](https://dashboard.razorpay.com/)
2. Settings → Webhooks
3. Add endpoint: `https://your-backend.up.railway.app/api/v1/webhooks/razorpay`

### 4. Run Database Seeds

```bash
railway run -s backend "bundle exec rails db:seed"
```

## Monitoring

### Railway Logs

```bash
railway logs -s backend
```

### Database Access

```bash
railway connect postgres
```

## Costs

### Railway Free Tier

- $5 credit/month
- Sufficient for MVP usage
- Auto-sleeps after inactivity

### Cloudflare Pages Free Tier

- Unlimited requests
- 500 builds/month
- No sleep/cold starts

## Troubleshooting

### Common Issues

**Assets not loading:**

```bash
# Add to backend Procfile
web: bundle exec rails assets:precompile && bundle exec puma
```

**WebSocket connection failing:**

- Ensure `FRONTEND_URL` includes your Cloudflare domain
- Check ActionCable allowed origins

**Database migrations failing:**

```bash
railway run -s backend "bundle exec rails db:migrate:status"
```
