# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

```bash
# Build the project
xcodebuild -project slownyt.xcodeproj -scheme slownyt -configuration Debug build

# Run unit tests (uses Swift Testing framework)
xcodebuild -project slownyt.xcodeproj -scheme slownyt -configuration Debug test

# Run a specific test
xcodebuild -project slownyt.xcodeproj -scheme slownyt -configuration Debug test -only-testing:slownytTests/slownytTests/example

# Run UI tests
xcodebuild -project slownyt.xcodeproj -scheme slownyt -configuration Debug test -only-testing:slownytUITests
```

## Project Overview

macOS menu bar app that diagnoses npm download slowness. Runs 5 network tests (ping, connectivity, DNS, registry latency, download speed) and displays results with color-coded status indicators. Targets macOS 15.6+, requires Xcode 26.

## Architecture

### App Structure
- `slownytApp.swift` - Entry point using `MenuBarExtra` for menu bar integration
- `AppDelegate` - Ensures single instance via bundle identifier check

### MVVM Pattern
- **Models/** - `DiagnosticResult`, `DiagnosticStatus`, `AppSettings` (singleton with UserDefaults persistence)
- **ViewModels/** - `DiagnosticViewModel` orchestrates all services, manages auto-refresh timer
- **Views/** - `MenuBarIconView`, `DiagnosticPopoverView`, `DiagnosticResultRow`, `SettingsView`
- **Services/** - Individual diagnostic services implementing `NetworkDiagnosticService` protocol

### Adding New Diagnostics
1. Create a new service in `Services/` implementing `NetworkDiagnosticService` protocol
2. Add thresholds to `Utilities/DiagnosticThresholds.swift` if needed
3. Add service instance to `DiagnosticViewModel.services` array

### Test Targets
- **slownytTests/** - Unit tests using Swift Testing framework (`import Testing`, `@Test` attribute)
- **slownytUITests/** - UI tests using XCTest framework

## Swift Concurrency

This project uses Swift 6 concurrency settings:
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` - types are `@MainActor` by default
- `SWIFT_APPROACHABLE_CONCURRENCY = YES` - enables approachable concurrency mode

When adding new types that don't need main thread access, explicitly mark them with `nonisolated` or a different actor. Services must be `Sendable`.

## Release Process

Use the `/release` slash command to build, sign, notarize, and publish a GitHub release:

```
/release           # patch bump (1.0 -> 1.0.1)
/release minor     # minor bump (1.0.1 -> 1.1.0)
/release major     # major bump (1.0.1 -> 2.0.0)
/release 2.0.0     # explicit version
```

This command will:
1. Auto-bump the version in the Xcode project
2. Archive with Developer ID signing
3. Notarize with Apple
4. Staple the notarization ticket
5. Create a GitHub release with the signed zip

**Prerequisites:**
- A valid "Developer ID Application" certificate in keychain
- Notarization credentials stored: `xcrun notarytool store-credentials "notarytool"`

**Version locations:**
- `MARKETING_VERSION` in `slownyt.xcodeproj/project.pbxproj` (user-facing version)
- `CURRENT_PROJECT_VERSION` in `slownyt.xcodeproj/project.pbxproj` (build number)
