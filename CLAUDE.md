# playkey

Single-file Swift utility for macOS. Stops Apple Music from auto-launching when the Play/Pause media key is pressed with nothing playing, and runs a command instead.

## Build
- `swiftc playkey.swift -o playkey` (no dependencies)
- The `playkey` binary and `phrase.aiff` are build artifacts and gitignored.

## How it works
- No event tap, no Accessibility permission, no private frameworks.
- Watches `NSWorkspace.didLaunchApplicationNotification` for Apple Music; quits it and runs the command when it launches.
- The media key itself is left untouched, so native control of Spotify/browser/etc. keeps working.

## Git & PRs
- Always merge PRs with **rebase** (`gh pr merge --rebase`). Never squash.
- Never commit directly to main; use feature branches.
