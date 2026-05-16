# Look Away

macOS menubar app for eye health and movement breaks. Built with SwiftUI.

## What it does

- Runs a work/break timer from the menubar — no Dock icon
- Full-screen overlay on every break: **"Touch the grass bro 🌿"**
- **Blink reminders** — periodic animated overlay prompts you to blink (👀/🙈)
- **Move reminders** — periodic overlay tells you to stand up and stretch (🤸)
- **Pre-break toolbar** — floating HUD appears 30s before break with extend/end options
- Multi-display: overlays cover all connected screens
- Extend work time on the fly without stopping the session

## Defaults

| Setting | Default |
|---|---|
| Work duration | 20 min |
| Break duration | 30 sec |
| Blink reminder | every 1 min |
| Move reminder | every 15 min |

## Requirements

- macOS 14+ (Sonoma)
- Xcode 15+

## Build

Open `look away.xcodeproj` in Xcode and run (`⌘R`).

## Architecture

SwiftUI + AppKit hybrid. Single `SessionStore` (`@Observable`) drives all state. Four controllers manage overlay/panel windows independently:

- `BreakOverlayController` — full-screen break overlay
- `PreBreakToolbarController` — floating pre-break HUD
- `BlinkReminderController` — blink reminder overlay
- `MoveReminderController` — move reminder overlay

`AppDelegate` observes `SessionStore` via `withObservationTracking` and coordinates all controllers.
