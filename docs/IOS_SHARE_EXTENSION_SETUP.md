# iOS Share Extension — Manual Setup

The code side of the share extension is in place (`ios/ShareExtension/ShareViewController.swift`
and `Info.plist`), but wiring it into an actual Xcode target requires steps
only Xcode itself can do — this can't be scripted from outside Xcode.

This project doesn't have an `ios/Runner.xcodeproj` yet at all (see
`STATUS_REPORT.md` — nothing in the original 29-part script ever ran
`flutter create`). Do that first, then come back here.

## Steps

1. Open `ios/Runner.xcworkspace` (after step 0 in `STATUS_REPORT.md` has created it) in Xcode.
2. **File → New → Target → Share Extension.** Name it exactly `ShareExtension`
   (must match `CFBundleIdentifier: com.doomnotes.app.ShareExtension` in the
   provided `Info.plist`, and must match the folder `ios/ShareExtension/`).
3. When Xcode creates the new target, it will generate its own
   `ShareViewController.swift` and `Info.plist` in `ios/ShareExtension/` —
   **replace both with the versions already in this project** (they're
   written to work with the `receive_sharing_intent` plugin; Xcode's
   defaults are not).
4. **Enable Swift Package Manager** (the plugin ships as an SPM package,
   not CocoaPods): `flutter config --enable-swift-package-manager`
5. **Link the plugin to the extension target:** select the `ShareExtension`
   target → General tab → Frameworks and Libraries → **+** → choose
   `FlutterGeneratedPluginSwiftPackage` (from the `receive_sharing_intent`
   package).
6. **Add App Groups capability to BOTH targets** (`Runner` and
   `ShareExtension`): Signing & Capabilities → **+ Capability** → App Groups
   → add a group. Use exactly `group.com.doomnotes.app` (already set as
   `AppGroupId` in `ios/ShareExtension/Info.plist`) — it must be identical
   on both targets.
7. Make sure the extension's deployment target matches `Runner`'s.
8. Build. If Xcode reports **"No such module 'receive_sharing_intent'"**
   in the extension target, go to Runner's Build Phases → move
   **Embed Foundation Extension** above **Thin Binary**, then rebuild.
9. Test: share a link from Safari, then from TikTok/Instagram/YouTube, to
   DoomNotes, with the app both running and fully closed.

## Why this couldn't be done for you

Steps 2, 4, 5, and 6 are Xcode project-file / signing operations — they
require an actual Xcode installation and (for App Groups) your Apple
Developer account. There's no way to script them from a text-only
environment. Everything that *could* be prepared as plain code — the
correct `ShareViewController` subclass and a matching `Info.plist` — has
been done for you.

## Source

Setup steps confirmed against the `receive_sharing_intent` package's own
documentation as of writing this. Plugin setup details do shift between
versions, so if anything above doesn't match what you see in Xcode, check
the plugin's current README on pub.dev before assuming this doc is wrong.
