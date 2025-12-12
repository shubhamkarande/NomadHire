# Azure Deployment Guide

This guide explains how to deploy NomadHire to Azure App Service.

> **Note**: Azure free tier has limited resources. For production, you may need paid tiers.

## Prerequisites

- [Azure account](https://azure.microsoft.com/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Docker](https://www.docker.com/) (for containerized deployment)
- GitHub repository with your code

## Option 1: Azure App Service with Docker

### 1. Create Azure Resources

```bash
# Login to Azure
az login

# Create resource group
az group create --name nomadhire-rg --location eastus

# Create Azure Container Registry
az acr create --resource-group nomadhire-rg \
  --name nomadhireacr --sku Basic

# Create App Service Plan
az appservice plan create --name nomadhire-plan \
  --resource-group nomadhire-rg \
  --sku B1 --is-linux

# Create Web App
az webapp create --resource-group nomadhire-rg \
  --plan nomadhire-plan \
  --name nomadhire-api \
  --deployment-container-image-name nginx
```

### 2. Create PostgreSQL Database

```bash
az postgres flexible-server create \
  --resource-group nomadhire-rg \
  --name nomadhire-db \
  --location eastus \
  --admin-user nomadhire_admin \
  --admin-password <strong-password> \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --version 14

# Create database
az postgres flexible-server db create \
  --resource-group nomadhire-rg \
  --server-name nomadhire-db \
  --database-name nomadhire_production
```

### 3. Build and Push Docker Image

```bash
# Login to ACR
az acr login --name nomadhireacr

# Build backend image
cd backend
docker build -t nomadhireacr.azurecr.io/nomadhire-api:latest .

# Push to ACR
docker push nomadhireacr.azurecr.io/nomadhire-api:latest
```

### 4. Configure Web App

```bash
# Enable admin access to ACR
az acr update --name nomadhireacr --admin-enabled true

# Get ACR credentials
az acr credential show --name nomadhireacr

# Configure web app to use ACR
az webapp config container set \
  --resource-group nomadhire-rg \
  --name nomadhire-api \
  --docker-custom-image-name nomadhireacr.azurecr.io/nomadhire-api:latest \
  --docker-registry-server-url https://nomadhireacr.azurecr.io \
  --docker-registry-server-user nomadhireacr \
  --docker-registry-server-password <acr-password>
```

### 5. Set Environment Variables

```bash
az webapp config appsettings set \
  --resource-group nomadhire-rg \
  --name nomadhire-api \
  --settings \
    RAILS_ENV=production \
    SECRET_KEY_BASE=<secret> \
    DATABASE_URL="postgres://nomadhire_admin:<password>@nomadhire-db.postgres.database.azure.com:5432/nomadhire_production" \
    DEVISE_JWT_SECRET=<secret> \
    FRONTEND_URL=https://nomadhire-frontend.azurestaticapps.net \
    STRIPE_SECRET_KEY=sk_test_xxx \
    STRIPE_WEBHOOK_SECRET=whsec_xxx \
    RAZORPAY_KEY_ID=rzp_test_xxx \
    RAZORPAY_KEY_SECRET=xxx
```

## Option 2: GitHub Actions CI/CD

### Backend Workflow

Create `.github/workflows/azure-backend.yml`:

```yaml
name: Deploy Backend to Azure

on:
  push:
    branches: [main]
    paths:
      - 'backend/**'

env:
  AZURE_WEBAPP_NAME: nomadhire-api
  REGISTRY: nomadhireacr.azurecr.io
  IMAGE_NAME: nomadhire-api

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Login to Azure Container Registry
        uses: azure/docker-login@v1
        with:
          login-server: ${{ env.REGISTRY }}
          username: ${{ secrets.ACR_USERNAME }}
          password: ${{ secrets.ACR_PASSWORD }}
      
      - name: Build and push Docker image
        run: |
          cd backend
          docker build -t ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} .
          docker push ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
      
      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v2
        with:
          app-name: ${{ env.AZURE_WEBAPP_NAME }}
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
```

## Frontend Deployment (Azure Static Web Apps)

### 1. Create Static Web App

```bash
az staticwebapp create \
  --name nomadhire-frontend \
  --resource-group nomadhire-rg \
  --source https://github.com/your-username/nomadhire \
  --location eastus2 \
  --branch main \
  --app-location "frontend" \
  --output-location ".svelte-kit/azure" \
  --login-with-github
```

### 2. Configure Frontend Workflow

Azure will create a workflow file. Update it to include environment variables:

```yaml
env:
  VITE_API_URL: https://nomadhire-api.azurewebsites.net/api/v1
  VITE_WS_URL: wss://nomadhire-api.azurewebsites.net/cable
  VITE_STRIPE_KEY: pk_test_xxx
```

## Backend Dockerfile

Create `backend/Dockerfile`:

```dockerfile
FROM ruby:3.2-slim

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --deployment --without development test

COPY . .

RUN bundle exec rails assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

## Enable WebSockets

Azure App Service supports WebSockets. Enable it:

```bash
az webapp config set \
  --resource-group nomadhire-rg \
  --name nomadhire-api \
  --web-sockets-enabled true
```

## Cost Considerations

### Free/Low-Cost Options

- **App Service B1**: ~$13/month (first month free with trial)
- **PostgreSQL Burstable B1ms**: ~$15/month
- **Static Web Apps**: Free tier available
- **Container Registry Basic**: ~$5/month

### Recommendations

- Use Railway/Render for truly free hosting
- Azure is better for enterprise/scaling needs
- Consider Azure credits for students/startups

## Troubleshooting

### View Logs

```bash
az webapp log tail --resource-group nomadhire-rg --name nomadhire-api
```

### SSH into Container

```bash
az webapp ssh --resource-group nomadhire-rg --name nomadhire-api
```

### Run Migrations

```bash
az webapp ssh --resource-group nomadhire-rg --name nomadhire-api
# Inside container:
bundle exec rails db:migrate
```

### Database Connection Issues

Ensure firewall allows Azure services:

```bash
az postgres flexible-server firewall-rule create \
  --resource-group nomadhire-rg \
  --name nomadhire-db \
  --rule-name AllowAzure \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```
