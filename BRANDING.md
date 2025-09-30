# Custom Branding Guide

This document explains how to customize the branding of your ActivePieces fork while ensuring compatibility with upstream updates.

## Overview

The branding system uses environment variables and asset replacement to maintain fork safety. All customizations are external to the core codebase, making them immune to upstream updates.

## Quick Start

### 1. Environment Variables

Add these variables to your `.env` file:

```bash
## Custom Branding Configuration
AP_APP_TITLE="Your Custom Name"
AP_FAVICON_URL="https://your-domain.com/favicon.ico"
AP_BRAND_NAME="YourBrand"
```

### 2. Logo Replacement

Replace the default logo:
```bash
# Backup original
cp activepieces/assets/ap-logo.png activepieces/assets/ap-logo.png.backup

# Replace with your logo
cp /path/to/your/logo.png activepieces/assets/ap-logo.png
```

### 3. Restart Services

After making changes, restart your ActivePieces instance:
```bash
# Using Docker Compose
docker-compose down
docker-compose up -d

# Or using the launch script
./launch.sh
```

## Configuration Details

### Environment Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `AP_APP_TITLE` | Browser tab title and main app name | "Activepieces" | "MyCompany Workflow" |
| `AP_FAVICON_URL` | Favicon URL | Activepieces favicon | "https://mycompany.com/favicon.ico" |
| `AP_BRAND_NAME` | Brand name in "Powered by" text | "activepieces" | "MyCompany" |

### Asset Files

| File | Purpose | Customizable |
|------|---------|--------------|
| `activepieces/assets/ap-logo.png` | Main application logo | ✅ Yes |
| `activepieces/.env` | Environment configuration | ✅ Yes (branding vars) |

## Update-Safe Maintenance

### Before Upstream Updates

1. **Backup your customizations:**
   ```bash
   # Backup branding assets
   cp activepieces/assets/ap-logo.png ~/backup-logo.png

   # Backup environment variables
   grep "^AP_.*TITLE\|^AP_.*FAVICON\|^AP_.*BRAND" .env > ~/branding-backup.env
   ```

2. **Update from upstream:**
   ```bash
   # Assuming you use git
   git fetch upstream
   git merge upstream/main
   ```

3. **Restore your branding:**
   ```bash
   # Restore logo
   cp ~/backup-logo.png activepieces/assets/ap-logo.png

   # Restore environment variables
   # Edit .env and add back your branding variables from the backup
   ```

### Files to Monitor During Updates

These files may need attention after upstream merges:
- `activepieces/.env` - Your branding variables
- `activepieces/assets/ap-logo.png` - Your custom logo
- `activepieces/packages/react-ui/vite.config.ts` - Branding configuration
- `activepieces/packages/react-ui/src/components/show-powered-by.tsx` - Attribution text

## Advanced Customization

### Custom Colors/Themes

For color scheme customization, you can:

1. **Override CSS variables** in your deployment
2. **Create custom themes** using the existing theme system
3. **Modify component styles** in a custom build

### Custom "Powered By" Behavior

The `ShowPoweredBy` component can be enhanced for more control:

```typescript
// Example: Custom powered by component
const CustomPoweredBy = ({ show, position, customText }) => {
  if (!show) return null;

  return (
    <div className={position}>
      <span>Powered by {customText || getBrandName()}</span>
    </div>
  );
};
```

## Troubleshooting

### Branding Not Appearing

1. **Check environment variables** are set in `.env`
2. **Verify asset paths** are correct
3. **Restart services** after changes
4. **Check browser cache** (hard refresh)

### Build Issues

1. **Clear Vite cache:**
   ```bash
   rm -rf node_modules/.vite
   ```

2. **Rebuild assets:**
   ```bash
   npm run build
   ```

### Update Conflicts

If upstream changes conflict with your branding:

1. **Stash your changes:** `git stash`
2. **Merge upstream:** `git merge upstream/main`
3. **Restore selectively:** `git stash pop`
4. **Resolve conflicts** manually if needed

## Best Practices

1. **Always backup** before upstream updates
2. **Test branding** after each update
3. **Use descriptive names** for custom assets
4. **Document your changes** for team members
5. **Version your branding** assets

## Support

For issues with the branding system:
1. Check this documentation first
2. Verify your environment configuration
3. Test with default values to isolate issues
4. Check the ActivePieces community for similar setups

---

*This branding system is designed to be maintainable and update-safe. By keeping customizations external to the core code, you can always pull upstream improvements without losing your brand identity.*