# Kamal Deployment Guide for Event Management App

## Issues Fixed

1. ✅ Added PostgreSQL with PostGIS database accessory configuration
2. ✅ Configured environment variable injection for all secrets
3. ✅ Fixed Docker registry configuration for Docker Hub
4. ✅ Added missing asset precompilation step in Dockerfile
5. ✅ Added DATABASE_URL configuration
6. ✅ Fixed placeholder values (service name, image name, etc.)

## Prerequisites

Before deploying, you need:

1. **A server** (VPS/Cloud instance) with:
   - Ubuntu 20.04+ or Debian
   - SSH access
   - Docker installed
   - Publicly accessible IP address

2. **A domain name** pointing to your server IP

3. **Docker Hub account** with an access token

## Step-by-Step Deployment Instructions

### 1. Update Configuration Values

You need to replace the following placeholders in **config/deploy.yml**:

```yaml
# Line 5: Replace with your Docker Hub username
image: YOUR_DOCKERHUB_USERNAME/event-management-app

# Line 10: Replace with your actual server IP
servers:
  web:
    - YOUR_SERVER_IP

# Line 22: Replace with your actual domain
proxy:
  host: YOUR_DOMAIN.com

# Line 29: Replace with your Docker Hub username
registry:
  username: YOUR_DOCKERHUB_USERNAME

# Line 89: Replace with your server IP (same as line 10)
accessories:
  db:
    host: YOUR_SERVER_IP
```

### 2. Update Secrets in deploy.env

Edit **deploy.env** and update:

```bash
# Line 6: Set a strong password for PostgreSQL
export POSTGRES_PASSWORD=CHANGE_THIS_SECURE_PASSWORD

# Line 23: Add your Docker Hub access token
export KAMAL_REGISTRY_PASSWORD=YOUR_DOCKERHUB_ACCESS_TOKEN
```

**How to get Docker Hub Access Token:**
1. Go to https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Give it a name (e.g., "kamal-deployment")
4. Copy the token and paste it in deploy.env

### 3. Source Environment Variables

Before running Kamal commands, source your environment:

```bash
source deploy.env
```

Or add this to your shell rc file (.bashrc, .zshrc):

```bash
# Add to ~/.bashrc or ~/.zshrc
if [ -f ~/Ruby-Workspace/Event_Management_Ruby/deploy.env ]; then
    source ~/Ruby-Workspace/Event_Management_Ruby/deploy.env
fi
```

### 4. Prepare Your Server

SSH into your server and ensure Docker is installed:

```bash
ssh YOUR_SERVER_IP

# Install Docker if not already installed
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Exit and reconnect for group changes to take effect
exit
ssh YOUR_SERVER_IP
```

### 5. Initialize Kamal (First Time Only)

```bash
# Verify your configuration
kamal config

# Set up the server infrastructure
kamal setup
```

This will:
- Install required tools on your server
- Set up the database container (PostgreSQL with PostGIS)
- Deploy your application
- Configure SSL with Let's Encrypt

### 6. Deploy Updates

For subsequent deployments:

```bash
# Deploy new changes
kamal deploy

# Or redeploy everything
kamal redeploy
```

### 7. Run Database Migrations

After deployment, run migrations:

```bash
kamal app exec 'bin/rails db:migrate'
```

## Useful Kamal Commands

```bash
# Check application logs
kamal app logs

# Check database logs
kamal accessory logs db

# SSH into the app container
kamal app exec --interactive bash

# Restart the application
kamal app restart

# Stop everything
kamal down

# Check running containers
kamal app containers

# View current configuration
kamal config
```

## DNS Configuration

Point your domain to your server:

```
Type: A Record
Name: @ (or your subdomain)
Value: YOUR_SERVER_IP
TTL: 3600
```

For SSL to work, your domain must be properly configured and pointing to the server before running `kamal setup`.

## Troubleshooting

### Database Connection Issues

If the app can't connect to the database, check:

```bash
# Check if database container is running
kamal accessory details db

# Check database logs
kamal accessory logs db

# Verify DATABASE_URL is set correctly
kamal app exec 'printenv | grep DATABASE'
```

### SSL Certificate Issues

If SSL fails:

```bash
# Check proxy logs
kamal proxy logs

# Ensure your domain is pointing to the server
dig YOUR_DOMAIN.com

# Temporarily disable SSL in config/deploy.yml and redeploy
proxy:
  ssl: false
```

### Asset Compilation Errors

If assets fail to precompile:

```bash
# Check if RAILS_MASTER_KEY is set during build
# Verify config/master.key exists and matches deploy.env

# Try building locally first
docker build --build-arg RAILS_MASTER_KEY=$RAILS_MASTER_KEY -t test .
```

### Container Not Starting

```bash
# Check container logs
kamal app logs --tail 100

# Exec into container to debug
kamal app exec --interactive bash
```

## Security Notes

1. **NEVER commit deploy.env to git** - It contains sensitive secrets
2. **Use strong passwords** for POSTGRES_PASSWORD
3. **Use access tokens** for Docker Hub, not your account password
4. **Keep RAILS_MASTER_KEY secure** - Anyone with this can decrypt your credentials
5. **Update Google OAuth redirect URIs** to include your production domain

## Post-Deployment Checklist

- [ ] Update Google OAuth authorized redirect URIs in Google Cloud Console
- [ ] Update Stripe webhook endpoint to your production domain
- [ ] Test user registration and login
- [ ] Test event creation and ticket purchasing
- [ ] Verify email sending works
- [ ] Check SSL certificate is valid
- [ ] Set up database backups
- [ ] Configure monitoring and error tracking

## Database Backups

To backup your production database:

```bash
# Create backup
kamal accessory exec db 'pg_dump -U $POSTGRES_USER event_management_platform_production' > backup.sql

# Restore from backup
cat backup.sql | kamal accessory exec --interactive db 'psql -U $POSTGRES_USER event_management_platform_production'
```

## Additional Resources

- Kamal Documentation: https://kamal-deploy.org
- Docker Hub: https://hub.docker.com
- Let's Encrypt: https://letsencrypt.org
