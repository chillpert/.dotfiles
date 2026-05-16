# syncthing-status

Syncthing status plugin for Noctalia.

## Features

- Compact bar widget with a theme-aware main icon
- Status badge for sync state changes
- Detailed panel with device and folder summary
- Folder-level status, including paused and error states
- Automatic detection of Syncthing GUI URL, API key, and `config.xml`
- Automatic language mode that follows the system locale by default
- Manual override for URL, API key, TLS verification, polling interval, and monitored folders

## Usage

The plugin adds a capsule to the Noctalia bar showing the current Syncthing state. Left-click opens the detail panel; right-click provides quick toggle, refresh, and settings shortcuts.

Configure the Syncthing connection in the plugin settings page. By default, the plugin autodetects the GUI URL and API key from Syncthing's `config.xml`.

## Files

- `Main.qml` — State management, polling, translations, and helpers
- `BarWidget.qml` — Bar widget UI
- `Panel.qml` — Expanded panel UI
- `Settings.qml` — Plugin settings UI
- `syncthing-status.py` — Syncthing API integration

## Author

Developed by Pir0c0pter0.

## License

MIT. See [LICENSE](./LICENSE).
