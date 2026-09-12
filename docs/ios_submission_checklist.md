# DOOMNOTES - iOS APP STORE SUBMISSION CHECKLIST
# Based on Apple App Store Review Guidelines (2026)
# Last Updated: September 2026

## Pre-Submission Requirements

### 1. Apple Developer Account
- [ ] Enroll in Apple Developer Program (\$99/year)
- [ ] Verify account is active and in good standing
- [ ] Two-factor authentication enabled

### 2. App Store Connect Setup
- [ ] Create new app in App Store Connect
- [ ] Select primary language: English
- [ ] Bundle ID: com.doomnotes.app (must match Xcode)
- [ ] SKU: DOOMNOTES-001 (internal tracking)

### 3. Build Requirements (2026)
- [ ] Built with Xcode 26 or later (required from April 2026)
- [ ] iOS 12.0+ minimum deployment target
- [ ] 64-bit architecture only
- [ ] App size under 4GB (cellular download limit)

### 4. Privacy Compliance
- [ ] Privacy policy URL hosted (use docs/PRIVACY_POLICY.md)
- [ ] App Privacy labels completed in App Store Connect
- [ ] Data types declared:
  - [ ] Contact Info: None collected
  - [ ] User Content: Transcripts, video URLs (user-generated)
  - [ ] Identifiers: Device ID (for sync)
  - [ ] Usage Data: App interactions (analytics)
  - [ ] Diagnostics: Crash data
- [ ] Account deletion flow implemented (Settings → Delete Account)
- [ ] Sign in with Apple (if using accounts) - NOT REQUIRED for DoomNotes (no accounts)

### 5. App Extensions
- [ ] Share Extension properly configured
- [ ] NSExtensionActivationRule set correctly
- [ ] App Groups configured in Xcode (group.com.doomnotes.app)
- [ ] Extension icon matches main app branding
- [ ] Extension tested and functional

## App Store Listing

### 6. App Information
- [ ] **App Name:** DoomNotes (30 character limit)
- [ ] **Subtitle:** Auto-transcribe & organize videos (30 character limit)
- [ ] **Description:** (4000 character limit)

**Suggested Description:**
\`\`\`
Turn doomscrolling into organized knowledge. DoomNotes automatically transcribes Instagram, TikTok, and YouTube videos, then organizes them by topic.

KEY FEATURES:
• One-tap capture from share sheet
• Auto-transcription with AI
• Auto-organization by topic
• Offline-first (works without internet)
• Cloud sync (optional)
• Search all your notes instantly

PERFECT FOR:
• Investing tips
• Color grading tutorials
• Video editing techniques
• Cryptocurrency insights
• Productivity hacks
• Fitness routines
• Cooking recipes

HOW IT WORKS:
1. Find a video on Instagram/TikTok/YouTube
2. Tap Share → DoomNotes
3. Get instant transcript organized by topic
4. Search, review, and reference anytime

No account required. All data stored locally on your device. Optional cloud sync available.

Privacy: We don't sell your data. Read our privacy policy at [YOUR_WEBSITE]/privacy
\`\`\`

- [ ] **Keywords:** transcription,notes,instagram,tiktok,video,ai,productivity,organization (100 character limit, comma-separated)
- [ ] **Category:** Productivity (primary), Education (secondary)
- [ ] **Content Rating:** 4+ (no age restrictions)

### 7. Screenshots (Required)
- [ ] 6.7\" iPhone (1284 x 2778) - 5 screenshots minimum
- [ ] 6.5\" iPhone (1242 x 2688) - optional
- [ ] 5.5\" iPhone (1242 x 2208) - optional

**Screenshot Requirements:**
- [ ] No text overlay (Apple may reject)
- [ ] Show actual app UI (no mockups)
- [ ] Include status bar or remove completely
- [ ] Landscape screenshots if app supports landscape

**Suggested Screenshots:**
1. Home screen with notes organized by topic
2. Share sheet showing DoomNotes option
3. Note detail with transcript and video link
4. Search functionality
5. Topic management screen

- [ ] Upload to App Store Connect

### 8. App Preview Video (Optional but Recommended)
- [ ] 15-30 seconds max
- [ ] Show app in action (screen recording)
- [ ] No voiceover or music (or royalty-free only)
- [ ] Upload to App Store Connect

### 9. App Icon
- [ ] 1024 x 1024 pixels (required)
- [ ] PNG format, no transparency
- [ ] No text or small details
- [ ] Unique design (not generic)
- [ ] Matches app branding

### 10. Support Information
- [ ] **Support URL:** https://YOUR_WEBSITE.com/support
- [ ] **Marketing URL:** https://YOUR_WEBSITE.com (optional)
- [ ] **Privacy Policy URL:** https://YOUR_WEBSITE.com/privacy (REQUIRED)

## Technical Review

### 11. App Functionality
- [ ] App launches without crashes
- [ ] All features work as described
- [ ] No broken links or buttons
- [ ] Share extension works from Instagram
- [ ] Offline mode functional
- [ ] Cloud sync works (if enabled)

### 12. Performance
- [ ] App loads in under 3 seconds
- [ ] No memory leaks or excessive battery usage
- [ ] Smooth scrolling and animations
- [ ] No crashes during testing

### 13. User Interface
- [ ] Follows iOS Human Interface Guidelines
- [ ] Supports Dark Mode (required in 2026)
- [ ] Dynamic Type support (accessibility)
- [ ] Right-to-left language support (if applicable)
- [ ] No placeholder text or \"TODO\" comments

### 14. Metadata Accuracy
- [ ] App name matches across all platforms
- [ ] Description accurately reflects functionality
- [ ] Screenshots show actual app (not mockups)
- [ ] No misleading claims or features

## Common Rejection Reasons (Avoid These!)

### 4.1 - Copycats
- [ ] App is unique and not a clone of existing apps
- [ ] DoomNotes is differentiated by auto-organization feature

### 2.1 - App Completeness
- [ ] No \"beta\" or \"demo\" labels
- [ ] All features functional (no \"coming soon\")
- [ ] No broken functionality

### 5.1.1 - Data Collection
- [ ] Privacy policy clearly explains data usage
- [ ] No hidden data collection
- [ ] User consent obtained for optional features

### 5.1.2 - Legal
- [ ] No copyrighted content (Instagram videos are user-shared)
- [ ] Terms of Service included
- [ ] Proper disclaimers (\"not affiliated with Instagram\")

### 3.1.1 - In-App Purchases
- [ ] If adding premium features, use Apple IAP
- [ ] For now: app is free, no IAP needed

## Submission Process

### 15. Build and Upload
\`\`\`bash
# Build release version
flutter build ios --release

# Open in Xcode
open build/ios/iphoneos/Runner.xcworkspace

# In Xcode:
# 1. Select \"Any iOS Device (arm64)\" as target
# 2. Product → Archive
# 3. Wait for archive to complete
# 4. Click \"Distribute App\"
# 5. Select \"App Store Connect\"
# 6. Upload
\`\`\`

### 16. App Store Connect
- [ ] Log in to https://appstoreconnect.apple.com
- [ ] Select your app
- [ ] Click \"+\" to add new version (1.0.0)
- [ ] Fill out all metadata (sections 6-10 above)
- [ ] Upload screenshots
- [ ] Select build you just uploaded
- [ ] Answer export compliance questions:
  - [ ] \"Does your app use encryption?\" → YES (HTTPS/SSL)
  - [ ] \"Is your app eligible for encryption exemption?\" → NO (uses standard encryption)

### 17. Submit for Review
- [ ] Click \"Save\"
- [ ] Click \"Add for Review\"
- [ ] Review all information
- [ ] Click \"Submit to App Store\"

## Post-Submission

### 18. Review Status
- [ ] Monitor status in App Store Connect
- [ ] Typical review time: 24-48 hours
- [ ] If rejected:
  - [ ] Read rejection reason carefully
  - [ ] Fix issues
  - [ ] Resubmit with explanation in \"Notes\" section

### 19. Approval and Release
- [ ] Once approved, set release date
- [ ] Option 1: Manual release (you control timing)
- [ ] Option 2: Automatic release (goes live immediately)

### 20. Post-Launch
- [ ] Monitor reviews and ratings
- [ ] Respond to user feedback
- [ ] Track analytics (downloads, retention)
- [ ] Plan next update (bug fixes, new features)

## Timeline

| Task | Estimated Time |
|------|---------------|
| Prepare assets (screenshots, icon, etc.) | 2-4 hours |
| Fill out App Store Connect metadata | 1-2 hours |
| Build and upload to App Store Connect | 30 minutes |
| Apple review | 24-48 hours |
| **Total** | **3-7 days** |

## Resources

- Apple App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- App Store Connect Help: https://help.apple.com/app-store-connect/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/

---

**Good luck with your submission! 🚀**