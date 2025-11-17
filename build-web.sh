#!/bin/bash
# Build script for LenSki web deployment

echo "🌐 Building LenSki for Web..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🔨 Building web release..."
flutter build web --release --web-renderer canvaskit

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📁 Output directory: build/web"
    echo ""
    echo "To test locally, run:"
    echo "  cd build/web && python3 -m http.server 8000"
    echo "  Then visit: http://localhost:8000"
    echo ""
    echo "To deploy:"
    echo "  - GitHub Pages: git push (if workflow is set up)"
    echo "  - Vercel: vercel"
    echo "  - Netlify: netlify deploy --prod"
    echo "  - See DEPLOYMENT.md for more options"
else
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi
