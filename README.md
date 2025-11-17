# LenSki

<div align="center">

**🌍 Master Any Language - Your Autonomous Learning Companion**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.5.0-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Windows-4CAF50)](https://github.com/SantiagoChamie/echoic)

[Try Web Demo](https://your-demo-url.com) • [Download for Windows](https://github.com/SantiagoChamie/echoic/releases/latest) • [Quick Start](QUICKSTART.md) • [Deployment](DEPLOYMENT.md)

</div>

---

LenSki is an autonomous language learning application designed to help users practice and improve foreign language skills through translation, pronunciation, and interactive exercises. Built with Flutter, LenSki is available as a **web application** and as a **Windows desktop app**.

---

## 🚀 Quick Start

### Try Online
Visit our [**live web demo**](https://your-demo-url.com) - no installation required!

### Desktop Installation
1. Download the latest [Windows installer](https://github.com/SantiagoChamie/echoic/releases/latest) (`lenski.exe`)
2. Run the installer and follow the on-screen instructions
3. Launch LenSki and start learning!

---

## ✨ Features

- **📚 Interactive Reading**: Import books and articles, click any word for instant translation
- **🔄 Instant Translation**: Powered by DeepL API for accurate, context-aware translations
- **🗣️ Text-to-Speech**: Natural pronunciation practice with native TTS
- **🧠 Spaced Repetition**: SM-2 algorithm optimizes your learning schedule
- **📝 Multiple Exercise Types**:
  - Reading comprehension
  - Listening practice
  - Speaking exercises
  - Writing prompts
- **📊 Progress Tracking**: Track streaks, daily goals, and language competence
- **🎯 Personalized Learning**: Set your own goals and track achievements
- **🌐 Multi-Platform**: Available on web and Windows desktop

---

## 💻 Installation & Deployment

### Web Version
The easiest way to use LenSki is through the web version:
- Visit the [live demo](https://your-demo-url.com)
- No installation required, works in any modern browser

For deploying your own instance, see [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions on deploying to:
- GitHub Pages
- Vercel
- Netlify
- Firebase Hosting
- Custom servers

### Windows Desktop
1. Download the latest Windows installer from [Releases](https://github.com/SantiagoChamie/echoic/releases/latest)
2. Run `lenski.exe` and follow the installation wizard
3. Launch LenSki from your desktop or start menu

---

## Configuration

### DeepL API Key

1. Obtain your API key from [DeepL](https://www.deepl.com/pro).
2. Open LenSki and navigate to **Settings** → **API Key**.
3. Paste your DeepL key into the input field.

### Text-to-Speech Setup

1. Ensure your Windows system has the appropriate language voices installed.
2. Go to **Settings** → **Time & Language** → **Speech**.
3. Add or manage speech voices for the language you want to learn.

---

## Usage

1. Launch LenSki.
2. Choose the language you want to learn.
3. Choose your daily and end goal.
4. Load texts from the internet, to use as learning material.
5. Highlight words or phrases to see their translation and pronunciation.
6. Add words or phrases to your review pile, to use them as study material.
7. Review the words or phrases you added.

---

## 🔧 Building from Source

### Requirements

- Flutter SDK 3.5.0 or higher
- Git

### For Web

```bash
git clone https://github.com/SantiagoChamie/echoic.git
cd echoic

flutter channel stable
flutter upgrade
flutter config --enable-web

flutter pub get
flutter run -d chrome

# Production build
flutter build web --release
```

### For Windows Desktop

```bash
git clone https://github.com/SantiagoChamie/echoic.git
cd echoic

flutter channel stable
flutter upgrade
flutter config --enable-windows-desktop

flutter pub get
flutter run -d windows

# Production build
flutter build windows --release
```

---

## Contributing

Contributions are welcome!

1. Fork the repository.
2. Create a new branch:

   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
    ```bash
   git commit -m "Add new feature"
   ```
4. Push to your fork:
    ```bash
   git push origin feature-name
   ```
5. Open a Pull Request.

Please ensure your code follows the existing style and includes documentation where necessary.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contact

For questions, suggestions, or support, please open an issue on the GitHub repository or contact:
santiagochamie@gmail.com
