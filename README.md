# Recipe App

A new Flutter project for discovering and managing your favorite recipes.

> **Note**: This package is currently set to **not be published** to [pub.dev](https://pub.dev).  
> If you intend to publish it in the future, remember to remove or update the `publish_to: 'none'` line in `pubspec.yaml`.

---

## 📱 Features

- Beautiful UI built with Flutter Material Design
- Responsive layout using the `sizer` package
- Custom icons from [Unicons](https://unicons.iconscout.com/)
- Cached network images for smooth performance
- Stylish typography with Google Fonts

---

## 🛠️ Dependencies

This project relies on the following key packages:

- [`provider`](https://pub.dev/packages/provider) – for state management
- [`cached_network_image`](https://pub.dev/packages/cached_network_image) – for efficient image loading
- [`sizer`](https://pub.dev/packages/sizer) – for responsive sizing across devices
- [`google_fonts`](https://pub.dev/packages/google_fonts) – for dynamic font loading
- [`unicons`](https://pub.dev/packages/unicons) – for modern iconography

---

## ⚠️ Important Notes

### Version Synchronization

The app version is defined in **two places** and **must match**:

1. `pubspec.yaml` → `version: 1.0.0+1`
2. `android/app/build.gradle` → `versionName "1.0.0"` and `versionCode 1`

> 🔥 **Warning**: Mismatched versions may cause build failures or unexpected behavior on Android.

### Google Fonts

Ensure the version of `google_fonts` in `pubspec.yaml` matches the version referenced in your native build files (e.g., `build.gradle`) to avoid runtime errors.

---

## 🚀 Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
   > Make sure `sizer` and other packages resolve without errors.
3. Run the app:
   ```bash
   flutter run
   ```
