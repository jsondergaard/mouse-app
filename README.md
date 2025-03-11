# MouseTeleporter

A menu bar application that saves your mouse cursor position at specified intervals and teleports it back with a keyboard shortcut.

## Features

- Lives in the menu bar for easy access
- Saves mouse position at configurable intervals (default: 5 seconds)
- Teleport cursor back to saved position with a keyboard shortcut (default: Command+Shift+F1)
- Configurable settings

## Building & Running

To build the application, run:

```bash
cd /Users/jacob/Projects/mouse-app
swift build
```

To run the application:

```bash
swift run
```

## Usage

1. Launch the application
2. The mouse icon 🖱️ will appear in the menu bar
3. Click on the icon to access settings
4. Set your preferred interval for saving mouse positions
5. Use Command+Shift+F1 to teleport your cursor to the last saved position
