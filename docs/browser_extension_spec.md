# DOOMNOTES - BROWSER EXTENSION SPECIFICATION
# Chrome, Firefox, Safari, Edge extensions

## Why Browser Extension?

**Use Cases:**
- Save YouTube videos directly from browser
- Capture articles/blog posts (not just videos)
- Right-click → \"Save to DoomNotes\"
- Auto-capture from specific sites (Coursera, MasterClass, etc.)

**Platforms:**
- Chrome (largest user base)
- Firefox (privacy-focused users)
- Safari (Mac/iOS users)
- Edge (Windows users, Chromium-based)

---

## Features

### MVP (Phase 1)
- ✅ Save current page URL to DoomNotes
- ✅ Right-click context menu
- ✅ Browser action button (toolbar icon)
- ✅ Sync with desktop app

### Enhanced (Phase 2)
- ✅ Auto-transcribe YouTube videos
- ✅ Save article text (not just URL)
- ✅ Tag with custom keywords
- ✅ Choose topic folder

### Advanced (Phase 3)
- ✅ Auto-save from specific sites (configurable)
- ✅ Highlight text → save to note
- ✅ Keyboard shortcut (Cmd/Ctrl + Shift + D)
- ✅ Offline queue (save without internet)

---

## Implementation

### Chrome Extension (Manifest V3)

**manifest.json:**
\`\`\`json
{
  \"manifest_version\": 3,
  \"name\": \"DoomNotes Capture\",
  \"version\": \"1.0.0\",
  \"description\": \"Save videos and articles to DoomNotes\",
  \"permissions\": [
    \"activeTab\",
    \"contextMenus\",
    \"storage\",
    \"tabs\"
  ],
  \"host_permissions\": [
    \"https://www.youtube.com/*\",
    \"https://*.doomnotes.app/*\"
  ],
  \"background\": {
    \"service_worker\": \"background.js\",
    \"type\": \"module\"
  },
  \"action\": {
    \"default_popup\": \"popup.html\",
    \"default_icon\": {
      \"16\": \"icons/icon16.png\",
      \"48\": \"icons/icon48.png\",
      \"128\": \"icons/icon128.png\"
    },
    \"default_title\": \"Save to DoomNotes\"
  },
  \"icons\": {
    \"16\": \"icons/icon16.png\",
    \"48\": \"icons/icon48.png\",
    \"128\": \"icons/icon128.png\"
  },
  \"commands\": {
    \"capture\": {
      \"suggested_key\": {
        \"default\": \"Ctrl+Shift+D\",
        \"mac\": \"Command+Shift+D\"
      },
      \"description\": \"Save current page to DoomNotes\"
    }
  }
}
\`\`\`

**background.js:**
\`\`\`javascript
// Create context menu
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: 'saveToDoomNotes',
    title: 'Save to DoomNotes',
    contexts: ['page', 'link', 'video']
  });
});

// Handle context menu click
chrome.contextMenus.onClicked.addListener(async (info, tab) => {
  if (info.menuItemId === 'saveToDoomNotes') {
    const url = info.linkUrl || info.pageUrl || tab.url;
    await saveToDoomNotes(url, tab.title);
  }
});

// Handle browser action click
chrome.action.onClicked.addListener(async (tab) => {
  await saveToDoomNotes(tab.url, tab.title);
});

// Handle keyboard shortcut
chrome.commands.onCommand.addListener(async (command) => {
  if (command === 'capture') {
    const [tab] = await chrome.tabs.query({active: true, currentWindow: true});
    await saveToDoomNotes(tab.url, tab.title);
  }
});

// Save to DoomNotes (send to desktop app or cloud)
async function saveToDoomNotes(url, title) {
  try {
    // Option 1: Send to desktop app (if running)
    await fetch('http://localhost:8080/capture', {
      method: 'POST',
      body: JSON.stringify({url, title})
    });
    
    // Show success notification
    chrome.notifications.create({
      type: 'basic',
      iconUrl: 'icons/icon48.png',
      title: 'Saved to DoomNotes',
      message: title
    });
  } catch (error) {
    // Option 2: Queue for later sync
    await chrome.storage.local.get({queue: []}, (result) => {
      result.queue.push({url, title, timestamp: Date.now()});
      chrome.storage.local.set({queue: result.queue});
    });
  }
}
\`\`\`

**popup.html:**
\`\`\`html
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      width: 300px;
      padding: 20px;
      font-family: -apple-system, BlinkMacSystemFont, sans-serif;
    }
    button {
      width: 100%;
      padding: 12px;
      background: #2196F3;
      color: white;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-size: 14px;
    }
    button:hover {
      background: #1976D2;
    }
  </style>
</head>
<body>
  <h3>Save to DoomNotes</h3>
  <p id=\"current-page\">Loading...</p>
  <button id=\"save-btn\">Save This Page</button>
  <script src=\"popup.js\"></script>
</body>
</html>
\`\`\`

**popup.js:**
\`\`\`javascript
// Get current tab info
chrome.tabs.query({active: true, currentWindow: true}, ([tab]) => {
  document.getElementById('current-page').textContent = tab.title;
  
  document.getElementById('save-btn').addEventListener('click', async () => {
    await saveToDoomNotes(tab.url, tab.title);
    window.close();
  });
});
\`\`\`

---

## Firefox Extension

Same codebase as Chrome (Manifest V3 compatible).

**Additional:**
- Submit to Firefox Add-ons (free)
- Review time: 1-3 days
- No fee

---

## Safari Extension

### iOS + macOS (Universal)

**Xcode Project:**
- Create new \"Safari Web Extension\" target
- Use same JavaScript logic
- Swift wrapper for iOS/macOS integration

**Info.plist:**
\`\`\`xml
<key>SFSafariWebsiteAccess</key>
<dict>
  <key>Allowed Domains</key>
  <array>
    <string>youtube.com</string>
    <string>instagram.com</string>
    <string>doomnotes.app</string>
  </array>
</dict>
\`\`\`

**Distribution:**
- Submit to Mac App Store + iOS App Store
- Same review process as iOS app
- \$99/year Apple Developer account

---

## Edge Extension

Same as Chrome (Chromium-based).

**Additional:**
- Submit to Microsoft Edge Add-ons (free)
- Review time: 1-2 days
- Can auto-import from Chrome Web Store

---

## Distribution

### Chrome Web Store
- **Fee:** \$5 one-time
- **Review:** 1-3 days
- **Reach:** 3 billion+ Chrome users

### Firefox Add-ons
- **Fee:** Free
- **Review:** 1-3 days
- **Reach:** 100+ million Firefox users

### Mac App Store (Safari)
- **Fee:** \$99/year
- **Review:** 1-3 days
- **Reach:** Mac/iOS users

### Edge Add-ons
- **Fee:** Free
- **Review:** 1-2 days
- **Reach:** 100+ million Edge users

---

## Monetization

### Option 1: Free (Recommended)
- Drive desktop/mobile app adoption
- No direct revenue from extension
- Upsell premium features in app

### Option 2: Freemium
- Basic capture: Free
- Auto-transcription: Premium (\$4.99/month)
- Unlimited saves: Premium

### Option 3: Paid Extension
- One-time purchase: \$4.99
- All features included
- Lower adoption (users prefer free)

---

## Timeline

| Phase | Duration | Tasks |
|-------|----------|-------|
| Chrome Extension | 1 week | Build, test, submit |
| Firefox Extension | 2 days | Port from Chrome |
| Safari Extension | 1 week | Xcode setup, iOS compatibility |
| Edge Extension | 2 days | Port from Chrome |
| **Total** | **2-3 weeks** | |

---

## Resources

- Chrome Extension Docs: https://developer.chrome.com/docs/extensions/
- Firefox Add-ons: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons
- Safari Extensions: https://developer.apple.com/documentation/safariservices/
- Edge Add-ons: https://learn.microsoft.com/en-us/microsoft-edge/extensions-chromium/

---

**Browser extension can increase captures by 3-5x (easier than mobile share).** 🌐