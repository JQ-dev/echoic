@echo off
REM Build script for LenSki web deployment (Windows)

echo 🌐 Building LenSki for Web...
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter is not installed. Please install Flutter first.
    echo Visit: https://docs.flutter.dev/get-started/install
    exit /b 1
)

REM Clean previous build
echo 🧹 Cleaning previous build...
call flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
call flutter pub get

REM Build for web
echo 🔨 Building web release...
call flutter build web --release --web-renderer canvaskit

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Build successful!
    echo.
    echo 📁 Output directory: build\web
    echo.
    echo To test locally, run:
    echo   cd build\web ^&^& python -m http.server 8000
    echo   Then visit: http://localhost:8000
    echo.
    echo To deploy:
    echo   - GitHub Pages: git push ^(if workflow is set up^)
    echo   - Vercel: vercel
    echo   - Netlify: netlify deploy --prod
    echo   - See DEPLOYMENT.md for more options
) else (
    echo ❌ Build failed. Please check the errors above.
    exit /b 1
)
