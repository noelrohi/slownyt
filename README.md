# slownyt

A macOS menu bar app to diagnose npm download slowness.

![Screenshot](screenshot.png)

## Features

- **Ping (ICMP)** - Real ICMP ping to test raw network latency
- **Internet Connectivity** - HTTP request to verify internet access
- **DNS Resolution** - Time to resolve registry.npmjs.org
- **NPM Registry Latency** - Response time from npm registry
- **NPM Download Speed** - Actual download speed test

## Installation

1. Download `slownyt-v1.0.zip` from [Releases](../../releases)
2. Unzip and drag `slownyt.app` to Applications
3. Open the app - it will appear in your menu bar
4. On first launch, you may need to right-click and select "Open" to bypass Gatekeeper

## Usage

- Click the menu bar icon to see diagnostics
- Results auto-refresh based on your settings (default: 5 min)
- Click the gear icon to adjust refresh cadence
- Color indicators: 🟢 Good | 🟠 Warning | 🔴 Bad

## Thresholds

| Test | Good | Warning | Bad |
|------|------|---------|-----|
| Ping | < 50ms | < 150ms | > 150ms |
| Connectivity | < 100ms | < 500ms | > 500ms |
| DNS | < 50ms | < 200ms | > 200ms |
| NPM Latency | < 100ms | < 300ms | > 300ms |
| Download | > 10 Mbps | > 1 Mbps | < 1 Mbps |

## Building from Source

Requires Xcode 16+ and macOS 15.6+

```bash
git clone https://github.com/YOUR_USERNAME/slownyt.git
cd slownyt
xcodebuild -project slownyt.xcodeproj -scheme slownyt -configuration Release build
```

## License

MIT
