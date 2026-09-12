# DOOMNOTES Part 25: Agent Instructions

## Wire Settings

1. Add `package_info_plus`, `share_plus`, `url_launcher` to `pubspec.yaml`.
2. Create `VersionService` and `SettingsTile`/`SettingsSection`.
3. Add a Settings entry in your main navigation (e.g. profile icon or gear icon in Home AppBar).
4. Initialize `AppPrefsServiceSingleton` in `main.dart`.

## Use Canonical Help Screen

Use:

```text
lib/screens/how_to_share_screen.dart
```

for all “how sharing works” help flows.

Do not create multiple competing help/tutorial screens.

## Export/Import

Keep them as stubs for now:

- Show a dialog: “Export and import will let you back up all your notes and restore them on another device. This feature is coming soon.”
- Do not implement partial or broken export/import logic.

When ready, implement:
- JSON export of all notes
- JSON import with conflict resolution
- Clear warnings and confirmations

## Legal

Before store submission:

- Replace `YOUR_WEBSITE.com` with your real domain.
- Ensure privacy policy matches actual behavior:
  - Local-first storage
  - Optional AI clean (on-device or user-triggered)
  - No cloud AI chat
  - No automatic uploads of transcripts/notes

## Test Flow

- Open Settings → toggle topic mode → reopen app → mode persists
- Tap “How to share” → 5-step tutorial appears
- Tap Privacy/Terms → external browser opens
- Tap “Share DoomNotes” → native share sheet appears
- Tap “About DoomNotes” → version and build number shown

## Do Not Break

- Existing topic classification
- Smart search
- Source link cards
- Capture success sheet
- Clean Note (optional)
- No AI chat