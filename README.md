# Pixel Craft

A cross-platform pixel art editor built with Flutter. Create retro-style pixel art on mobile and web with an intuitive drawing interface.

## Screenshots

### Mobile

<p align="center">
  <img src="https://github.com/user-attachments/assets/d145715e-e6b9-4e97-a71b-39fd55d5a2dc" width="250" />
  <img src="https://github.com/user-attachments/assets/4555e4da-d667-4c30-9152-8cab32081719" width="250" />
  <img src="https://github.com/user-attachments/assets/fd61ca82-3a08-412f-8bf6-a5df88ea50c5" width="250" />
</p>

### Web

<p align="center">
  <img src="https://github.com/user-attachments/assets/09c1647e-e824-4964-a69d-e60cb5dbc9ea" width="400" />
  <img src="https://github.com/user-attachments/assets/9c258dbc-8f2f-4307-9376-0529d4eb200e" width="400" />
  <img src="https://github.com/user-attachments/assets/a4579818-9f1d-4f15-a529-f98f27d9f34c" width="400" />
  <img src="https://github.com/user-attachments/assets/92d32260-184c-4000-ae6d-9f80c00594ab" width="400" />
</p>

## Download

### Android APK

Download the Android APK from the [apk folder](https://github.com/RividuPesara/pixel_craft/tree/main/apk) in this repository.

## Features

- 16x16 pixel canvas for creating pixel art
- Touch and mouse drawing support
- Dynamic color palette with usage-based sorting
- Custom color picker for unlimited colors
- Eraser tool for corrections
- Undo/Redo functionality
- Clear canvas option
- Export artwork as PNG image
- Cross-platform support (Android, Web)

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher

### Installation

1. Clone the repository:

```bash
git clone https://github.com/RividuPesara/pixel_craft.git
cd pixel_craft
```

3. Run the app:

```bash
# For mobile (Android/iOS)
flutter run

# For web
flutter run -d chrome

# For desktop
flutter run -d windows
```

## Building

### Android

```bash
flutter build apk --release
```

### Web

```bash
flutter build web --release
```

## Project Structure

```
lib/
  main.dart              # App entry point
  app.dart               # App configuration and theme
  constants/
    app_theme.dart       # Colors, sizes, and text styles
  screens/
    splash_screen.dart   # Splash screen with branding
    editor_screen.dart   # Main pixel art editor
```

## Dependencies

## Dependencies

- `flutter_colorpicker` — Advanced color selection dialogs, allowing users to choose custom colors easily.
- `screenshot` — Captures the drawing canvas so the artwork can be exported as an image.
- `saver_gallery` — Saves exported images directly to the device gallery on mobile platforms.
- `permission_handler` — Manages storage permissions required for saving images on Android and iOS.
- `device_info_plus` — Helps handle platform-specific permission logic (for example, different Android SDK versions).
- `universal_html` — Enables image download support when running the app on the web.

## Future Development

Planned features

- **In-app Gallery** — View and manage all saved artworks within the app.
- **App Logo & Branding** — Add a custom logo and branded splash screen for a polished look.
- **Additional Canvas Sizes** — Support larger or custom pixel canvases (32x32, 64x64).
- **Theme Toggle** — Toggle between light and dark themes.
