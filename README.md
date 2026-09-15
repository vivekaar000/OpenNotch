# OpenNotch 🏝️

A native, lightweight macOS notch companion built from scratch in Swift, AppKit, and SwiftUI.

GitHub Repository: [github.com/vivekaar000/OpenNotch](https://github.com/vivekaar000/OpenNotch)

## Features

- **Dynamic Notch Geometry**: Measures the physical notch on modern MacBooks (`NSScreen.auxiliaryTopLeftArea` / `auxiliaryTopRightArea`) or renders an elegant Dynamic Island pill on external displays.
- **Smooth Spring Hover Expansion**: Floating borderless `NSPanel` stays anchored at the top of your display. Hovering smoothly expands the tray into a rich widget drawer; moving the cursor away gracefully collapses it with a debounce buffer.
- **Now Playing Music Controls**:
  - Automatically interfaces with **Apple Music** and **Spotify** via AppleScript.
  - Live album artwork extraction and display.
  - Track title, artist, and audio visualizer.
  - Interactive playback buttons: Previous, Play / Pause, Next.
- **Menu Bar Control**: Status bar icon (`music.note.house.fill`) to toggle the notch tray, refresh state, or quit.

## Running OpenNotch

You can launch the bundled application directly:

```bash
open /Users/aaravvivek/.gemini/antigravity/scratch/OpenNotch/OpenNotch.app
```

Or run via Swift Package Manager:

```bash
cd /Users/aaravvivek/.gemini/antigravity/scratch/OpenNotch
swift run
```

## Rebuilding

To rebuild the application bundle after making modifications:

```bash
./bundle.sh
```
