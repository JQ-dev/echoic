# LenSki Deployment Guide

This guide explains how to deploy LenSki as a web application to various hosting platforms.

## Prerequisites

- Flutter SDK 3.5.0 or higher
- Git

## Building for Web

To build the web version locally:

```bash
flutter pub get
flutter build web --release
```

The build output will be in the `build/web` directory.

## Deployment Options

### 1. GitHub Pages (Automated)

The repository includes a GitHub Actions workflow that automatically deploys to GitHub Pages on every push to `main` or `master`.

**Setup:**

1. Go to your GitHub repository settings
2. Navigate to **Pages** section
3. Under "Build and deployment":
   - Source: Select **GitHub Actions**
4. Push to main/master branch
5. The workflow will automatically build and deploy

**Access:** Your site will be available at `https://<username>.github.io/<repository-name>/`

### 2. Vercel

Deploy with one click or using Vercel CLI.

**One-Click Deploy:**

1. Import your GitHub repository at [vercel.com](https://vercel.com)
2. Vercel will auto-detect the `vercel.json` configuration
3. Click "Deploy"

**CLI Deploy:**

```bash
npm i -g vercel
vercel
```

**Custom Domain:**
- Configure in Vercel dashboard under project settings

### 3. Netlify

**One-Click Deploy:**

1. Connect your repository at [netlify.com](https://netlify.com)
2. Netlify will auto-detect the `netlify.toml` configuration
3. Click "Deploy"

**CLI Deploy:**

```bash
npm install -g netlify-cli
netlify deploy --prod
```

**Custom Domain:**
- Configure in Netlify dashboard under domain settings

### 4. Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize Firebase in your project
firebase init hosting

# Deploy
flutter build web --release
firebase deploy --only hosting
```

### 5. Custom Server

After building with `flutter build web --release`:

1. Copy the `build/web` directory to your web server
2. Configure your web server to:
   - Serve `index.html` for all routes (SPA routing)
   - Set proper CORS headers if needed
   - Enable gzip compression for better performance

**Nginx Example:**

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /path/to/build/web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
```

## Environment Variables

If you need to configure API keys or other environment variables:

1. Update the `.env` file in the root directory
2. For web deployment, you may need to configure environment variables in your hosting platform's dashboard

## Custom Domain

### DNS Configuration

For all platforms, configure your DNS with:

- **A Record** or **CNAME** pointing to your hosting provider
- Follow your hosting platform's specific DNS instructions

## Performance Optimization

The web build includes:

- Code minification
- Tree shaking
- Asset optimization
- Lazy loading

For additional optimization:

```bash
flutter build web --release --web-renderer canvaskit  # Better performance
# OR
flutter build web --release --web-renderer html  # Smaller bundle size
```

## Monitoring

After deployment, monitor:

- Build logs in your CI/CD platform
- Browser console for runtime errors
- Loading performance with Lighthouse
- User analytics (implement using your preferred tool)

## Troubleshooting

### Build Fails

- Ensure Flutter SDK version matches (3.5.0+)
- Run `flutter clean` and `flutter pub get`
- Check for platform-specific code that may not work on web

### White Screen After Deployment

- Check browser console for errors
- Verify base href is set correctly
- Ensure all assets are loading properly

### Routes Not Working

- Verify your hosting platform is configured to serve `index.html` for all routes
- Check rewrites/redirects configuration

## Support

For issues specific to:
- **LenSki app**: Check the main README.md
- **Flutter web**: [Flutter web documentation](https://docs.flutter.dev/platform-integration/web)
- **Hosting platform**: Refer to platform-specific documentation

## Security Notes

- Never commit API keys or secrets to the repository
- Use environment variables for sensitive configuration
- Configure CORS headers appropriately
- Enable HTTPS on your custom domain
