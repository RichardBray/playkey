import Cocoa

// The keyboard Play/Pause media key already controls whatever is in the macOS
// Now Playing tray (Spotify, a browser video, etc.) natively. The only annoyance
// is that when nothing is playing, the key launches Apple Music.
//
// playkey leaves the key alone so native media control keeps working, and simply
// watches for Music launching. When it does (i.e. the tray was empty), playkey
// quits Music before it appears and runs COMMAND instead.
//
// No event tap, no Accessibility permission, no private frameworks.
//
// Build:  swiftc playkey.swift -o playkey
// Run:    ./playkey

// ── what to say when the tray was empty (Music tried to launch) ─────────
// Pre-rendered to an audio file once, then played with afplay so there's no
// TTS engine spin-up on every press. Change PHRASE and delete the cached
// .aiff (next to the binary) to re-render.
let PHRASE = "Nothing is playing"

let MUSIC_BUNDLE_ID = "com.apple.Music"

func run(_ argv: [String]) {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: argv[0])
    p.arguments = Array(argv.dropFirst())
    try? p.run()  // fire and forget
}

// Cache the spoken phrase as audio next to the binary; render on first run.
let cacheURL = URL(fileURLWithPath: CommandLine.arguments[0])
    .deletingLastPathComponent()
    .appendingPathComponent("phrase.aiff")

func ensurePhraseRendered() {
    if FileManager.default.fileExists(atPath: cacheURL.path) { return }
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/say")
    p.arguments = ["-o", cacheURL.path, PHRASE]
    try? p.run()
    p.waitUntilExit()
}

let COMMAND = ["/usr/bin/afplay", cacheURL.path]

ensurePhraseRendered()

let workspace = NSWorkspace.shared
workspace.notificationCenter.addObserver(
    forName: NSWorkspace.didLaunchApplicationNotification,
    object: nil,
    queue: .main
) { note in
    guard let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
          app.bundleIdentifier == MUSIC_BUNDLE_ID else { return }
    app.terminate()   // quit Music before it steals focus
    run(COMMAND)
}

print("playkey running. Music auto-launch is suppressed. Ctrl-C to stop.")
NSApplication.shared.run()  // run loop so the notification fires
