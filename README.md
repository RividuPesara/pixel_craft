# Pixel Craft

A cross-platform pixel art editor built with Flutter. Create retro-style pixel art on mobile and web an intuitive drawing interface.

## Screenshots

### Mobile
<img width="820" height="1600" alt="image" src="https://github.com/user-attachments/assets/d145715e-e6b9-4e97-a71b-39fd55d5a2dc" /> <img width="824" height="1600" alt="image" src="https://github.com/user-attachments/assets/4555e4da-d667-4c30-9152-8cab32081719" /> <img width="819" height="1600" alt="image" src="https://github.com/user-attachments/assets/fd61ca82-3a08-412f-8bf6-a5df88ea50c5" />

### Web

## Features

- 16x16 pixel canvas for creating pixel art
- Touch and mouse drawing support
- Dynamic color palette with usage based sorting
- Custom color picker for unlimited colors
- Eraser tool for corrections
- Undo/Redo functionality
- Clear canvas option
- Export artwork as PNG image
- Cross-platform support (Android,Web)

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

2. Install dependencies:

```bash
flutter pub get
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
