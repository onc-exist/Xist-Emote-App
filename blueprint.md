# Emote Overlay Application Blueprint

## Overview

A Flutter application that provides a system-wide overlay for sending emotes in any application. The overlay is designed to be non-intrusive and highly responsive, allowing users to quickly react with emotes without leaving their current context.

## Implemented Features & Design

*   **System Overlay:** The app requests permission to draw over other apps, enabling a persistent, floating UI.
*   **Floating Emote Wheel:** A circular menu of emotes is accessible via a discreet, draggable handle on the side of the screen.
*   **Responsive Layout:** The UI is built with a robust and responsive layout using `Align` and `SlideTransition`, eliminating overflow errors.
*   **Haptic Feedback:** The device vibrates gently as the user scrolls through emotes, providing tactile feedback.
*   **Customizable Emotes:** The `OverlayProvider` defines a list of emotes that can be a mix of text (emojis) and Material Icons.
*   **Smooth Animations:** The overlay and emote wheel feature fluid animations for showing, hiding, and selection, powered by `AnimationController`.
*   **Transparent Background:** The overlay has a fully transparent background, ensuring it does not obstruct the view of the underlying applications.
*   **State Management:** The application state (e.g., overlay visibility, selected emote) is managed centrally by an `OverlayProvider` using the `provider` package.
*   **Structured Logging:** All debug messages are handled by the `dart:developer` library, adhering to best practices and avoiding `print` statements in production code.
*   **ABI-Specific Builds:** The application is configured to build separate APKs for different Android Application Binary Interfaces (`armeabi-v7a`, `arm64-v8a`, `x86_64`) for optimized distribution.

## Current Request: Re-build for Different ABIs

**Plan:**

1.  **Execute Build Command:** Run `flutter build apk --split-per-abi` to compile the application and generate optimized APK files for the different target architectures.
2.  **Verify Output:** Confirm that the APKs (`app-armeabi-v7a-release.apk`, `app-arm64-v8a-release.apk`, `app-x86_64-release.apk`) are successfully created in the `build/app/outputs/flutter-apks/` directory.
