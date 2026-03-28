# MoodJournalAI

MoodJournalAI is a private, on-device mood journaling app for iOS 26 built with SwiftUI and FoundationModels. It helps users capture daily reflections, analyze emotional patterns, generate weekly summaries, and receive gentle self-care suggestions while keeping the journaling experience personal and local to the device.

## Overview

 Users can write or dictate journal entries, review AI-assisted mood suggestions, save the moods that feel right, revisit journal history, and explore weekly emotional patterns over time.

The app focuses on:
- private journaling
- AI-assisted reflection
- local-first experience
- lightweight self-care support
- clear, testable feature-based architecture

## Tech Stack

- `SwiftUI`
- `SwiftData`
- `FoundationModels`
- `Speech`
- `AVFoundation`
- `LocalAuthentication`
- `UserNotifications`
- `Charts`
- `XCTest / Testing`

## Platform

- `iOS 26`
- `Xcode 26`

Note:
Some AI-powered features depend on Apple Intelligence and compatible device support.

## Architecture

The project uses a feature-based structure with clear separation between UI, view models, domain models, and services.

### Architectural approach

- `MVVM` for screen-level state management
- feature-based folders for maintainability
- dependency injection for testability
- domain-focused models for journaling workflows
- shared services for reusable cross-feature logic
- unit-tested view models and business logic

## Accessibility

The app includes a baseline accessibility pass using native SwiftUI semantics and custom accessibility labels/hints for key interactive components.

Current accessibility support includes:
- VoiceOver-friendly labels on major custom controls
- grouped accessibility for reusable cards and entry rows
- reduced reliance on hardcoded font sizes
- semantic system text styles for better Dynamic Type behavior

## Analytics Configuration (TelemetryDeck)

TelemetryDeck is included, but the app ID should not be committed to Git.

1. Copy `Config/Secrets.xcconfig.example` to `Config/Secrets.xcconfig`.
2. Set `TELEMETRYDECK_APP_ID` in `Config/Secrets.xcconfig`.
3. Build and run the app.

If no app ID is configured, analytics stays disabled automatically.
