# DOOMNOTES - DESKTOP APP SPECIFICATION
# Windows, Mac, Linux version (Phase 3)

## Why Desktop?

**User Demand:**
- Users want to access notes on computer
- Easier to review long transcripts on big screen
- Copy/paste into other apps (Notion, Obsidian, etc.)

**Tech Stack:**
- **Option 1:** Flutter Desktop (same codebase)
- **Option 2:** Electron (web tech, larger bundle)
- **Option 3:** Tauri (Rust-based, small bundle)

**Recommendation:** Flutter Desktop (reuse 80% of mobile code)

---

## Platform Support

### Windows
- Windows 10/11 (64-bit)
- MSIX or EXE installer
- Microsoft Store distribution (optional)

### macOS
- macOS 12+ (Monterey or later)
- Universal binary (Intel + Apple Silicon)
- DMG installer
- Mac App Store distribution (optional)

### Linux
- Ubuntu 20.04+, Fedora 35+, etc.
- AppImage, Snap, or Flatpak
- Community-maintained packages

---

## Feature Differences (Desktop vs Mobile)

### Same Features
- ✅ View all notes
- ✅ Search and filter
- ✅ Topic organization
- ✅ Export notes
- ✅ Cloud sync

### Desktop-Only Features
- ✅ Keyboard shortcuts (Cmd/Ctrl + K for search)
- ✅ Multi-window support
- ✅ Drag-and-drop notes to other apps
- ✅ Global hotkey (capture from any app)
- ✅ Browser extension integration

### Mobile-Only Features
- ✅ Instagram/TikTok share sheet
- ✅ Offline-first (desktop always online)
- ✅ Notifications (desktop has system notifications)

---

## Implementation

### Step 1: Enable Flutter Desktop

\`\`\`bash
# Check current platforms
flutter doctor

# Enable desktop support
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop

# Create desktop builds
flutter build windows
flutter build macos
flutter build linux
\`\`\`

### Step 2: Add Desktop-Specific Code

**lib/main.dart (add desktop initialization):**
\`\`\`dart
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Platform-specific initialization
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await initializeDesktop();
  }
  
  // Rest of initialization...
  runApp(const DoomNotesApp());
}

Future<void> initializeDesktop() async {
  // Set up global hotkeys
  await HotkeyService.register('Ctrl+Shift+V', captureFromClipboard);
  
  // Set up system tray icon
  await SystemTray.init();
  
  // Enable multi-window
  await WindowManager.enableMultiWindow();
}
\`\`\`

### Step 3: Desktop UI Adaptations

**Larger Screen Layout:**
\`\`\`dart
// Responsive layout
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  
  if (width > 1200) {
    // Desktop: 3-column layout
    return Row(
      children: [
        TopicSidebar(width: 250),
        NoteList(width: 400),
        NoteDetail(expanded: true),
      ],
    );
  } else {
    // Mobile: single column
    return NoteList();
  }
}
\`\`\`

**Keyboard Shortcuts:**
\`\`\`dart
class KeyboardShortcuts extends StatefulWidget {
  @override
  _KeyboardShortcutsState createState() => _KeyboardShortcutsState();
}

class _KeyboardShortcutsState extends State<KeyboardShortcuts> {
  final Map<LogicalKeySet, VoidCallback> shortcuts = {
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK): _openSearch,
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): _newNote,
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyW): _closeNote,
  };
  
  void _openSearch() {
    // Open search overlay
  }
  
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: {
          // Map actions to intents
        },
        child: child,
      ),
    );
  }
}
\`\`\`

---

## Browser Extension Integration

### Chrome Extension (Capture from Browser)

**manifest.json:**
\`\`\`json
{
  \"name\": \"DoomNotes Capture\",
  \"version\": \"1.0.0\",
  \"manifest_version\": 3,
  \"description\": \"Save YouTube videos to DoomNotes\",
  \"permissions\": [\"activeTab\", \"contextMenus\"],
  \"background\": {
    \"service_worker\": \"background.js\"
  },
  \"action\": {
    \"default_icon\": \"icon.png\"
  }
}
\`\`\`

**background.js:**
\`\`\`javascript
chrome.contextMenus.create({
  id: 'saveToDoomNotes',
  title: 'Save to DoomNotes',
  contexts: ['link', 'video']
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === 'saveToDoomNotes') {
    // Send URL to desktop app
    sendToDesktopApp(tab.url);
  }
});
\`\`\`

### Desktop App Listener

\`\`\`dart
class DesktopShareService {
  void startServer() async {
    final server = await HttpServer.bind('localhost', 8080);
    
    server.listen((request) async {
      if (request.uri.path == '/capture') {
        final url = await request.first.then((data) => utf8.decode(data));
        await captureUrl(url);
        request.response.write('OK');
        await request.response.close();
      }
    });
  }
}
\`\`\`

---

## Distribution

### Windows
- **Direct Download:** MSIX/EXE from website
- **Microsoft Store:** Submit via Partner Center (\$99 one-time)
- **Auto-Update:** Use `msix` package or custom updater

### macOS
- **Direct Download:** DMG from website
- **Mac App Store:** Submit via App Store Connect (\$99/year)
- **Notarization:** Required for macOS Catalina+
- **Auto-Update:** Use `sparkle` or custom solution

### Linux
- **Direct Download:** AppImage from website
- **Snap Store:** Free, easy updates
- **Flatpak:** Flathub repository
- **AUR:** For Arch Linux users

---

## Monetization (Desktop)

### Option 1: Free (Same as Mobile)
- Build goodwill
- Drive mobile app downloads
- Upsell premium features (cloud sync, AI summaries)

### Option 2: Desktop Pro (\$19.99 one-time)
- All mobile premium features
- Keyboard shortcuts
- Multi-window support
- Browser extension
- Priority support

### Option 3: Freemium
- Basic desktop app: Free
- Pro features: \$4.99/month (same as mobile)

---

## Timeline

| Phase | Duration | Tasks |
|-------|----------|-------|
| Development | 4-6 weeks | Enable desktop, adapt UI, add shortcuts |
| Testing | 2 weeks | Bug fixes, platform testing |
| Launch | 1 week | Website updates, marketing |
| **Total** | **7-9 weeks** | |

---

## Resources

- Flutter Desktop Docs: https://docs.flutter.dev/platform-integration/desktop
- Windows App Development: https://learn.microsoft.com/windows/apps/
- macOS App Development: https://developer.apple.com/macos/
- Linux Desktop Guidelines: https://docs.flutter.dev/platform-integration/linux

---

**Desktop version can 2-3x your user base by reaching productivity-focused users.** 💻