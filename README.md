# playkey

Hijacks the keyboard **Play/Pause media key** on macOS so it runs a command of your choice instead of launching Apple Music.

## What it does

macOS routes the Play/Pause key to whatever owns the **Now Playing tray** (Spotify, a browser video, Music if it's already open). Only when the tray is *empty* does the key fall back to launching Apple Music.

`playkey` installs a system event tap that sits *ahead* of that router and checks the tray on every press:

- **Tray has media** - the key passes straight through, toggling play/pause on that app as normal.
- **Tray empty** - the key is swallowed (Music never launches) and a command runs instead.

Right now that command is:

```
say "Nothing is playing"
```

Change it by editing the `COMMAND` line near the top of `playkey.swift`, then rebuild.

The tray check uses the private MediaRemote framework (`MRMediaRemoteGetNowPlayingApplicationPID`), resolved at runtime. If it ever fails to load, playkey logs a warning and falls back to always swallowing + running the command.

## Build

```bash
swiftc playkey.swift -o playkey
```

Produces a single binary, `playkey`. No dependencies.

## Run

```bash
./playkey
```

The first run will appear to do nothing - macOS blocks event taps until you grant permission:

1. Open **System Settings > Privacy & Security > Accessibility**
2. Add (and enable) the terminal app you launched it from - Terminal, iTerm, etc.
3. Quit and re-run `./playkey`

You should see:

```
playkey running. Play/Pause is now hijacked. Ctrl-C to stop.
```

Press the Play/Pause key - it should speak instead of opening Music. `Ctrl-C` stops it and restores normal behaviour.

## Notes

- The command currently runs **unconditionally** on every Play/Pause press. There is no real "is anything playing?" check yet - detecting global playback state on modern macOS is non-trivial (the private MediaRemote framework stopped working in Sonoma).
- Runs in the foreground only. To start it automatically at login, wrap it in a launchd `.plist`.
- Only the Play/Pause key is captured. Next/Previous/Volume keys are untouched.
