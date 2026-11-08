# ETERNALTR4S WEB2APK

Universal WebView wrapper — turn any URL/HTML into APK.

## Usage

### Manual Build (via GitHub Actions)
1. Go to **Actions** tab
2. Select **"Build Web2APK"**
3. Click **"Run workflow"**
4. Fill inputs (URL, app name, control ID, icon URL)
5. Wait ~3 min, download artifact

### Backend Trigger
Backend updates `assets/config.json` + triggers workflow via GitHub API.

## Config Format

\`\`\`json
{
  "app_name": "App Name",
  "target_url": "https://example.com",
  "html_content": "",
  "control_id": "RAT_ID_HERE",
  "icon_url": ""
}
\`\`\`

## License
Private / Internal Use Only
