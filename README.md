# Memory Status

A macOS system tray utility for monitoring memory usage.

## Features

- **Real-time Monitoring**: Updates memory usage every 2 seconds.
- **Menu Bar Status**: Displays memory pressure status (🟢/🟡/🔴) and current usage (used/total GB).
- **Detailed Breakdown**: Shows used, free, wired, and compressed memory, including the compression ratio.
- **Memory Pressure Detection**:
  - Detects kernel `DispatchSource` pressure events (normal, warning, or critical).
  - Heuristic-based detection (critical if >90%, warning if >75%).
- **Quick Actions**:
  - Open Activity Monitor (⌘M)
  - Quit Memory Monitor (⌘Q)
- **Dock-free**: Runs exclusively in the system tray (menu bar).

## Requirements

- macOS 15.0 (Sequoia) or later
- Swift 6.0
- Xcode 17.0 or later

## Build & Run

```bash
# Open the project in Xcode
open MemoryStatus.xcodeproj

# Or build from the command line
xcodebuild -scheme MemoryStatus -destination 'platform=macOS' build

# Run the application
open build/Products/Debug/MemoryStatus.app
```

## Future Plans
Add support for Homebrew (Formula/Cask).

## License
MIT
