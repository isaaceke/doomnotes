# DOOMNOTES - APP STORE SCREENSHOT REQUIREMENTS
# Complete guide for iOS and Android screenshot specifications

## iOS App Store Screenshots

### Required Sizes (2026)

**Minimum:** 6.7\" iPhone screenshots (5 required)
- Resolution: 1284 x 2778 pixels (portrait) or 2778 x 1284 (landscape)
- Format: PNG or JPEG
- Color space: sRGB or Display P3

**Optional Sizes:**
- 6.5\" iPhone: 1242 x 2688 pixels
- 5.5\" iPhone: 1242 x 2208 pixels

### Screenshot Guidelines

**DO:**
- ✅ Show actual app UI (no mockups or device frames)
- ✅ Include status bar OR remove it completely (be consistent)
- ✅ Use high-resolution images
- ✅ Show key features in first 2 screenshots
- ✅ Maintain visual consistency across all screenshots

**DON'T:**
- ❌ Add text overlays (Apple may reject)
- ❌ Show device bezels or frames
- ❌ Include other app screenshots (Instagram, etc.)
- ❌ Use misleading images
- ❌ Show placeholder content

### Recommended iOS Screenshot Flow

**Screenshot 1: Home Screen**
- Show main interface with topic folders
- Display 4-6 topic folders (investing, color grading, etc.)
- Show note count for each topic
- Clean, uncluttered layout

**Screenshot 2: Share Sheet**
- Show iOS share sheet with DoomNotes icon visible
- Demonstrate one-tap capture from Instagram
- Show Instagram app in background (blurred)

**Screenshot 3: Note Detail**
- Show full transcript with highlighted keywords
- Display video link at bottom
- Show AI summary button (if implemented)

**Screenshot 4: Search**
- Show search bar with query
- Display search results
- Demonstrate instant search functionality

**Screenshot 5: Topic Management**
- Show topic creation/editing interface
- Display keyword customization options
- Show color picker for topic folders

### Tools for Creating Screenshots

**Xcode Simulator:**
\`\`\`bash
# Run app in simulator
flutter run -d \"iPhone 15 Pro Max\"

# Take screenshot
xcrun simctl io booted screenshot screenshot.png
\`\`\`

**Screenshot Size Adjustment:**
\`\`\`bash
# Resize to exact App Store dimensions
convert screenshot.png -resize 1284x2778 screenshot_resized.png
\`\`\`

---

## Google Play Store Screenshots

### Required Sizes (2026)

**Phone Screenshots:**
- Resolution: 1080 x 1920 pixels (minimum, portrait or landscape)
- Format: PNG or JPEG
- Count: 2-8 screenshots (at least 2 required)

**Tablet Screenshots (Optional):**
- 7\" tablet: 1200 x 800 or 800 x 1200 pixels
- 10\" tablet: 1920 x 1200 or 1280 x 800 pixels

### Screenshot Guidelines

**DO:**
- ✅ Show actual app UI
- ✅ Use high-resolution images
- ✅ Highlight key features
- ✅ Maintain consistency

**DON'T:**
- ❌ Add promotional text or overlays
- ❌ Show device frames
- ❌ Include misleading content
- ❌ Use screenshots from other apps

### Recommended Android Screenshot Flow

Same as iOS (section above), but optimized for Android UI guidelines.

---

## Screenshot Templates (Canva/Figma)

### Template Dimensions

**iOS:**
- Create canvas: 1284 x 2778 pixels
- Safe area: Leave 44px top, 34px bottom for status bar

**Android:**
- Create canvas: 1080 x 1920 pixels
- Safe area: Leave 24px top, 48px bottom for system UI

### Design Tips

1. **Consistency:** Use same font, colors, and style across all screenshots
2. **Focus:** Highlight one feature per screenshot
3. **Clarity:** Ensure text is readable at small sizes
4. **Branding:** Use app colors (blue for DoomNotes)
5. **Simplicity:** Avoid clutter, leave white space

---

## Testing Screenshots

### Before Submission

- [ ] View screenshots on actual devices (not just simulator)
- [ ] Check readability on small screens
- [ ] Verify all UI elements are visible
- [ ] Ensure no pixelation or blurriness
- [ ] Test with both light and dark backgrounds

### A/B Testing (Post-Launch)

- [ ] Use Google Play Experiments to test different screenshots
- [ ] Track conversion rate (views → installs)
- [ ] Iterate based on data

---

## Example Screenshot Descriptions

Use these as captions in App Store Connect:

1. \"Organize your knowledge by topic automatically\"
2. \"Capture videos with one tap from Instagram\"
3. \"Read full transcripts with keyword highlighting\"
4. \"Search all your notes instantly\"
5. \"Customize topics and keywords to your needs\"

---

## Resources

- Apple Screenshot Guidelines: https://developer.apple.com/app-store/product-page/
- Google Play Screenshot Guidelines: https://support.google.com/googleplay/android-developer/answer/9866477
- Canva App Store Templates: https://www.canva.com/app-store-screenshots/templates/

---

**Pro Tip:** Create screenshots in Figma or Canva for easy editing and consistency! 🎨