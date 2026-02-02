# Quick Start: Deploy to Railway

## 🚀 Fast Track Deployment

### 1. Push to GitHub
```bash
git add railway.toml RAILWAY_DEPLOYMENT.md
git commit -m "Add Railway deployment configuration"
git push
```

### 2. Deploy on Railway
1. Go to [railway.app](https://railway.app/) and login
2. Click **"New Project"** → **"Deploy from GitHub repo"**
3. Select your `withings-sync` repository

### 3. Set Environment Variables
In Railway dashboard → Your Service → **Variables** tab:

```
GARMIN_USERNAME = your.email@example.com
GARMIN_PASSWORD = your_password
TZ = Europe/Oslo  (optional)
```

### 4. Initial Withings Setup (One-time)

**Option A: Using Railway CLI** (Recommended)
```bash
# Install Railway CLI
npm i -g @railway/cli

# Login and link project
railway login
railway link

# Run interactive setup
railway run poetry run withings-sync --config-folder /home/withings-sync/config
```

Follow the prompts to authenticate with Withings.

**Option B: Local Docker Setup**
```bash
# Run locally first
docker run -v ./config:/config --interactive --tty \
  -e GARMIN_USERNAME=your_username \
  -e GARMIN_PASSWORD=your_password \
  ghcr.io/jaroslawhartman/withings-sync:latest \
  --config-folder /config
```

### 5. Done! ✅

Your app will now sync automatically every 3 hours.

Check logs in Railway dashboard to verify it's working.

---

📖 **For detailed instructions, troubleshooting, and customization**, see [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md)
