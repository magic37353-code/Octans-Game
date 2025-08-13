# Octans Insurance — Life Quest (Flutter, CI-built)

This repo is ready for **GitHub Actions** to build and **publish a public Release** with an APK on every push to `main`.

## Quick Start
1. Unzip this folder and upload all files into your GitHub repo: `https://github.com/magic37353-code/Octans-Game`.
2. Commit & push to `main`.
3. Go to **Actions**: wait for **Build & Publish Debug APK** to complete.
4. Go to **Releases**: download `app-debug.apk` from the latest Release.

## Local run (optional, not required)
```bash
flutter pub get
flutter run
```

## Notes
- The app includes: email capture gate, 5 levels (Term, Whole, IUL, Juvenile, Accidental), badges per level, and a light, playful UI.
- This project intentionally avoids extra services so you can build without adding keys.
