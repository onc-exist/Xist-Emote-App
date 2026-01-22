# Emote Overlay Application Blueprint

## Overview

A Flutter application that provides a system-wide overlay for sending emotes in any application. The overlay is designed to be non-intrusive and highly responsive, allowing users to quickly react with emotes without leaving their current context.

## Implemented Features & Design

*   **System Overlay:** The app requests permission to draw over other apps, enabling a persistent, floating UI.
*   **Floating Emote Wheel:** A circular menu of emotes is accessible via a discreet, draggable handle on the side of the screen.
*   **Responsive and Precise Layout:** The UI is built with a robust layout using `Positioned` and `AnimatedBuilder`. The emote wheel's position is now accurately calculated based on the original design's proportions (revealing 120px of the 440px wheel), ensuring the "peeking" effect is consistent and precise across all screen sizes.
*   **Haptic Feedback:** The device vibrates gently as the user scrolls through emotes, providing tactile feedback.
*   **Customizable Emotes:** The `OverlayProvider` defines a list of emotes that can be a mix of text (emojis) and Material Icons.
*   **Smooth Animations:** The overlay and emote wheel feature fluid animations for showing, hiding, and selection, powered by `AnimationController`.
*   **Transparent Background:** The overlay has a fully transparent background, ensuring it does not obstruct the view of the underlying applications.
*   **State Management:** The application state (e.g., overlay visibility, selected emote) is managed centrally by an `OverlayProvider` using the `provider` package.
*   **Structured Logging:** All debug messages are handled by the `dart:developer` library, adhering to best practices and avoiding `print` statements in production code.
*   **ABI-Specific Builds:** The application is configured to build separate APKs for different Android Application Binary Interfaces (`armeabi-v7a`, `arm64-v8a`, `x86_64`) for optimized distribution.

## Current Request: Implement a Persistent Overlay

**Architectural Plan:**

1.  **Integrate `system_alert_window`:** The `system_alert_window` package will be used to create and manage a persistent foreground service for the overlay.
2.  **Isolate the Overlay UI:** The `EmoteOverlay` widget and its related code will be moved into a separate, top-level function. This function will serve as the entry point for the overlay service, which runs in its own Dart Isolate.
3.  **Manage the Foreground Service:** The main application will be responsible for:
    *   Requesting the necessary permissions (`SYSTEM_ALERT_WINDOW` and `FOREGROUND_SERVICE`).
    *   Starting and stopping the overlay service.
    *   Communicating with the service to show/hide the overlay and update settings.
4.  **Update `AndroidManifest.xml`:** The manifest will be updated to declare the foreground service and its required permissions.
5.  **Re-implement Precise Positioning:** The design-driven positioning logic will be re-implemented using the layout capabilities of the `system_alert_window` package to ensure the emote wheel is perfectly placed.

**Next Steps:**

1.  Update the `pubspec.yaml` with the `system_alert_window` dependency (already completed).
2.  Update the `blueprint.md` file with the new architectural plan (this step).
3.  Refactor the code to move the overlay into a separate Isolate and manage it with the new package.
4.  Update the `AndroidManifest.xml` file.
5.  Test the persistent overlay to ensure it remains active after the main app is closed.
