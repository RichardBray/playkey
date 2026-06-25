# playkey

Stops the macOS **Play/Pause media key** from launching Apple Music when nothing is playing - and optionally runs a command of your choice instead.

## What it does

The Play/Pause key already controls whatever owns the macOS **Now Playing tray** (Spotify, a browser video, Music if it's already open) - that part works natively.
The only annoyance is that when *nothing* is playing, the key launches Apple Music.

playkey leaves the key completely alone, so native media control keeps working, and simply watches for Music launching.
When Music launches - i.e. the tray was empty - playkey quits it before it appears and runs a command instead.

Right now that command plays a short spoken phrase:

```
"Nothing is playing"
```

The phrase is rendered to an audio file once (via `say`) and then played with `afplay`, so there's no text-to-speech spin-up on each press.
Change it by editing `PHRASE` near the top of `playkey.swift`, deleting the cached `phrase.aiff`, and rebuilding.

No event tap, no Accessibility permission, no private frameworks.

## Build

```bash
swiftc playkey.swift -o playkey
```

Produces a single binary, `playkey`. No dependencies.

## Run

```bash
./playkey
```

You should see:

```
playkey running. Music auto-launch is suppressed. Ctrl-C to stop.
```

Now press Play/Pause with nothing playing - Music stays closed and you hear the phrase. With a browser video or Spotify playing, the key toggles it as normal. `Ctrl-C` stops playkey.

## Start automatically at login

Run it as a launchd LaunchAgent (also restarts it if it ever crashes):

```bash
cp com.richardbray.playkey.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.richardbray.playkey.plist
```

Edit the path in the plist if your binary lives somewhere other than `~/playkey/playkey`.
After rebuilding the binary, restart it with `launchctl unload` then `launchctl load`.

## Why not noTunes?

[noTunes](https://github.com/tombonez/noTunes) solves the same core annoyance and is excellent.
playkey exists because I wanted two things noTunes doesn't quite give me:

- **Run an arbitrary command, in code I own.** playkey is a single ~60-line Swift file I can read end to end and bend to whatever I want on an empty-tray press (speak a phrase now, trigger anything later). noTunes' replacement feature launches an app; I wanted full control without a menu-bar app in the loop.
- **Learning / hackability.** Building it myself meant understanding exactly how the media key routes and how Music gets suppressed, rather than installing a black box.

If you just want to stop Music launching and don't care about customising the behaviour, **use noTunes** - it's maintained and battle-tested. playkey is the build-it-yourself option.

## Notes

- playkey quits **every** Apple Music launch, so while it's running you can't open Music on purpose. Stop playkey first if you want to use Music.
- Music is reacted to *after* it launches, so a brief window may flash before it's quit. This is inherent to watching for the launch.
- Only Apple Music is affected. Next/Previous/Volume keys and all other apps are untouched.
