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

macOS SwiftUI application targeting macOS 15.6, created with Xcode 26.

## Architecture

- **slownyt/**: Main app target with SwiftUI views
- **slownytTests/**: Unit tests using Swift Testing framework (`import Testing`, `@Test` attribute)
- **slownytUITests/**: UI tests using XCTest framework

## Swift Concurrency

This project uses Swift 6 concurrency settings:
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` - types are `@MainActor` by default
- `SWIFT_APPROACHABLE_CONCURRENCY = YES` - enables approachable concurrency mode

When adding new types that don't need main thread access, explicitly mark them with `nonisolated` or a different actor.
