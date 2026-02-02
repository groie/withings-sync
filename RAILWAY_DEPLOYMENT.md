# Railway Deployment Guide for withings-sync

This guide will help you deploy the withings-sync application to Railway with automated scheduled syncing.

## Prerequisites

- [Railway account](https://railway.app/) (free tier available)
- Withings account with data to sync
- Garmin Connect account
- GitHub account (for connecting your repository)

## Deployment Steps

### 1. Prepare Your Repository

Ensure your repository contains:
- `Dockerfile` ✓
- `railway.toml` ✓
- All project files

### 2. Create a New Railway Project

1. Go to [Railway](https://railway.app/)
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Authorize Railway to access your GitHub account
5. Select the `withings-sync` repository

### 3. Configure Environment Variables

After deployment starts, configure the required environment variables:

1. In your Railway project dashboard, click on your service
2. Go to the **"Variables"** tab
3. Add the following environment variables:

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `GARMIN_USERNAME` | `your.email@example.com` | Your Garmin Connect username/email |
| `GARMIN_PASSWORD` | `your_password` | Your Garmin Connect password |
| `TZ` | `Europe/Oslo` | (Optional) Your timezone |

4. Click **"Add"** for each variable

### 4. Initial Withings Authentication

> [!IMPORTANT]
> The first run requires interactive authentication with Withings. You'll need to visit a URL and paste back a token within 30 seconds.

To perform the initial authentication:

1. In Railway dashboard, go to your service
2. Click on the **"Deployments"** tab
3. Click on the latest deployment
4. Click **"View Logs"**
5. Look for a message like:
   ```
   Open the following URL in your web browser and copy back the token.
   You will have *30 seconds* before the token expires. HURRY UP!
   https://account.withings.com/oauth2_user/authorize2?...
   ```
6. **Quickly** open that URL in your browser
7. Authorize the application
8. Copy the token from the redirect page
9. You'll need to paste this token back - see "Interactive Authentication" section below

#### Interactive Authentication Options

Since Railway doesn't provide an interactive terminal by default, you have two options:

**Option A: Use Railway CLI (Recommended)**

1. Install Railway CLI:
   ```bash
   npm i -g @railway/cli
   ```

2. Login to Railway:
   ```bash
   railway login
   ```

3. Link to your project:
   ```bash
   railway link
   ```

4. Run the authentication command:
   ```bash
   railway run poetry run withings-sync --config-folder /home/withings-sync/config
   ```

5. Follow the prompts to paste the Withings token

**Option B: Use Docker Locally, Then Upload Config**

1. Run locally with Docker:
   ```bash
   docker run -v ./config:/config --interactive --tty \
     -e GARMIN_USERNAME=your_username \
     -e GARMIN_PASSWORD=your_password \
     ghcr.io/jaroslawhartman/withings-sync:latest \
     --config-folder /config
   ```

2. Complete the Withings authentication
3. The session files will be saved in `./config/.withings_user.json`
4. Upload this file to Railway using a volume mount (requires Railway Pro plan) or by modifying the deployment to accept the config file

### 5. Configure Sync Schedule

The default schedule is set to run every 3 hours (at minute 0). To change this:

1. Edit the `railway.toml` file in your repository
2. Modify the cron expression in the `startCommand`:
   ```toml
   startCommand = "sh -c 'mkdir -p /config && echo \"0 */3 * * * poetry run withings-sync --config-folder /config\" > /home/withings-sync/cronjob && supercronic -passthrough-logs /home/withings-sync/cronjob'"
   ```
3. Change `0 */3 * * *` to your desired schedule:
   - `0 */2 * * *` - Every 2 hours
   - `0 8,12,16,20 * * *` - At 8am, 12pm, 4pm, and 8pm
   - `0 0 * * *` - Once daily at midnight

4. Commit and push the changes - Railway will automatically redeploy

> [!WARNING]
> Don't run the sync too frequently! Garmin may block your account if you login too often. **Recommended: 8-10 times per day (every 2-3 hours).**

### 6. Verify Deployment

1. Check the **Logs** tab in Railway
2. You should see messages like:
   ```
   Withings: Refresh Access Token
   Fetching measurements from YYYY-MM-DD HH:MM to YYYY-MM-DD HH:MM
   Fit file uploaded to Garmin Connect
   ```

## Troubleshooting

### "SSO error 401" or "SSO error 403"

This means you're logging into Garmin too frequently. Reduce your sync frequency to every 2-3 hours.

### "Can't read config file"

This is normal on the first run. Follow the Withings authentication steps above.

### Deployment Fails

1. Check the build logs in Railway
2. Ensure all environment variables are set correctly
3. Verify the Dockerfile builds successfully locally:
   ```bash
   docker build -t withings-sync .
   ```

### No Data Syncing

1. Verify you have measurements in Withings during the sync period
2. Check that your Garmin credentials are correct
3. Review the logs for error messages

## Persistent Storage

> [!NOTE]
> Railway's free tier doesn't include persistent volumes. The session files (`.withings_user.json` and `.garmin_session`) are stored in the container's filesystem and will be lost if the container restarts.

To maintain persistent authentication:
- Upgrade to Railway Pro for volume support, OR
- The app will re-authenticate automatically (you may need to re-do Withings auth)

## Additional Features

### Enable Blood Pressure Sync

Modify the `startCommand` in `railway.toml` to include the `--features` flag:

```toml
startCommand = "sh -c 'mkdir -p /config && echo \"0 */3 * * * poetry run withings-sync --config-folder /config --features BLOOD_PRESSURE\" > /home/withings-sync/cronjob && supercronic -passthrough-logs /home/withings-sync/cronjob'"
```

### Sync Specific Date Range

For one-time syncs of historical data, use Railway CLI:

```bash
railway run poetry run withings-sync --config-folder /config --fromdate 2024-01-01 --todate 2024-12-31
```

## Support

For issues specific to:
- **withings-sync**: See the [main README](README.md) or [GitHub Issues](https://github.com/jaroslawhartman/withings-sync/issues)
- **Railway**: Check [Railway Documentation](https://docs.railway.app/)
