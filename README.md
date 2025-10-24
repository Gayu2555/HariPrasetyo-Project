# 🍳 Recipe App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</p>

<p align="center">
  <strong>A new Flutter project for discovering and managing your favorite recipes.</strong>
</p>

<p align="center">
  Discover, save, and cook delicious recipes with a beautifully designed and intuitive mobile app.
</p>

---

## 📸 Screenshots

> **Catatan Penting:** Tambahkan screenshot atau GIF aplikasi kamu di sini! Ini adalah bagian terpenting dari sebuah README.
> Contoh formatnya:

<p align="center">
  <img src="assets/images/screenshot_home.png" width="200">
  <img src="assets/images/screenshot_detail.png" width="200">
  <img src="assets/images/screenshot_saved.png" width="200">
</p>

---

## 📱 Features

- ✨ **Beautiful UI:** Built with Flutter Material Design for a modern and clean look.
- 📱 **Responsive Layout:** Adapts perfectly to different screen sizes using the `sizer` package.
- 🎨 **Custom Icons:** Modern and crisp icons from [Unicons](https://unicons.iconscout.com/).
- 🚀 **Smooth Performance:** Cached network images ensure a fast and seamless user experience.
- 📝 **Stylish Typography:** Dynamic and readable fonts with Google Fonts.

---

## 🛠️ Dependencies

This project relies on the following key packages:

| Package                                                                 | Version | Description                                                                                                   |
| :---------------------------------------------------------------------- | :------ | :------------------------------------------------------------------------------------------------------------ |
| [`provider`](https://pub.dev/packages/provider)                         | ^6.0.0  | A simple yet powerful state management solution.                                                              |
| [`cached_network_image`](https://pub.dev/packages/cached_network_image) | ^3.2.0  | A flutter library to show images from the internet and keep them in the cache directory.                      |
| [`sizer`](https://pub.dev/packages/sizer)                               | ^2.0.15 | Helps in making the app responsive to different screen sizes.                                                 |
| [`google_fonts`](https://pub.dev/packages/google_fonts)                 | ^4.0.0  | Allows you to easily use any of the 977 fonts (and their variants) from fonts.google.com in your Flutter app. |
| [`unicons`](https://pub.dev/packages/unicons)                           | ^2.1.0  | 1000+ Pixel-perfect vector icons as Flutter Icons, available in Line, Solid, Monochrome, and Themed styles.   |

---

## ⚠️ Important Notes

### Version Synchronization

The app version is defined in **two places** and **must match** to avoid build issues:

1.  `pubspec.yaml` → `version: 1.0.0+1`
2.  `android/app/build.gradle` → `versionName "1.0.0"` and `versionCode 1`

> 🔥 **Warning:** Mismatched versions may cause build failures or unexpected behavior on Android.

### Google Fonts

Ensure the version of `google_fonts` in `pubspec.yaml` matches the version referenced in your native build files (e.g., `build.gradle`) to avoid runtime errors.

---

## 🚀 Getting Started

Prerequisites:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version >= 3.0.0)
- A code editor like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)

1.  **Clone the repository**

    ```bash
    git clone https://github.com/your-username/recipe-app.git
    cd recipe-app
    ```

2.  **Install dependencies**

    ```bash
    flutter pub get
    ```

    > Make sure `sizer` and other packages resolve without errors.

3.  **Run the app**
    ```bash
    flutter run
    ```

---

## 🤝 How to Contribute

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev/) for the amazing cross-platform framework.
- [Unicons](https://unicons.iconscout.com/) for the beautiful icon set.
- [Google Fonts](https://fonts.google.com/) for the extensive font library.
