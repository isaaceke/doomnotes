# DOOMNOTES - GOOGLE PLAY STORE SUBMISSION CHECKLIST
# Based on Google Play Developer Policies (2026)
# Last Updated: September 2026

## Pre-Submission Requirements

### 1. Google Play Developer Account
- [ ] Create account at https://play.google.com/console
- [ ] Pay \$25 one-time registration fee
- [ ] Verify identity (government ID required)
- [ ] Complete developer profile

### 2. App Requirements (2026)
- [ ] Target API level 36 (Android 16) or higher (required from August 31, 2026)
- [ ] 64-bit support enabled
- [ ] App size under 150MB (or use Play Asset Delivery)
- [ ] Android 5.0 (API 21) minimum SDK

### 3. Privacy Compliance
- [ ] Privacy policy URL hosted (use docs/PRIVACY_POLICY.md)
- [ ] Data Safety form completed in Play Console
- [ ] Account deletion implemented (Settings → Delete Account)
- [ ] Account deletion URL provided (https://YOUR_WEBSITE.com/delete-account)

## Data Safety Form (REQUIRED)

### 4. Data Collection Declaration

**Navigate to:** Play Console → Your App → App Content → Data Safety

#### Data Types Collected:

**Personal Info:**
- [ ] Name: NO
- [ ] Email: NO
- [ ] Phone: NO
- [ ] Address: NO
- [ ] Other: NO

**Financial Info:**
- [ ] Payment Info: NO
- [ ] Purchase History: NO
- [ ] Credit Score: NO
- [ ] Other: NO

**Health & Fitness:**
- [ ] Health Info: NO
- [ ] Fitness Info: NO

**Messages:**
- [ ] Emails: NO
- [ ] SMS: NO
- [ ] Other: NO

**Photos & Videos:**
- [ ] Photos: NO
- [ ] Videos: NO

**Audio Files:**
- [ ] Voice/Sound: NO (transcripts are user-generated, not collected)

**Files & Docs:**
- [ ] Files: NO

**Calendar:**
- [ ] Calendar Events: NO

**Contacts:**
- [ ] Contacts: NO

**App Activity:**
- [ ] App Interactions: YES (analytics)
- [ ] In-App Search: YES (search queries)
- [ ] Other User Actions: YES (shares, captures)

**Web Browsing:**
- [ ] Browsing History: NO

**App Info & Performance:**
- [ ] Crash Logs: YES (diagnostics)
- [ ] Diagnostics: YES (performance data)
- [ ] Other: NO

**Device or Other IDs:**
- [ ] Device ID: YES (for cloud sync)

#### Data Usage:

**Collected Data:**
- [ ] App Activity: Analytics, App Functionality
- [ ] App Info: Analytics, App Functionality
- [ ] Device ID: App Functionality (sync)

**Shared Data:**
- [ ] NONE (we don't share data with third parties)

**Ephemeral Data:**
- [ ] Video URLs: Processed temporarily for transcription, not stored permanently

#### Security Practices:
- [ ] Data encrypted in transit (HTTPS)
- [ ] Data encrypted at rest (Isar encryption)
- [ ] Can request data deletion (Settings → Delete Account)
- [ ] Committed to follow Play Families Policy (if applicable)
- [ ] Independent security review: NO (not required for this app type)

## App Store Listing

### 5. Main Store Listing

**App Name:**
- [ ] DoomNotes (30 character limit)

**Short Description:**
- [ ] Auto-transcribe Instagram videos & organize by topic (80 character limit)

**Full Description:**
- [ ] (4000 character limit)

**Suggested Description:**
\`\`\`
Turn doomscrolling into organized knowledge. DoomNotes automatically transcribes Instagram, TikTok, and YouTube videos, then organizes them by topic.

KEY FEATURES:
• One-tap capture from share sheet
• Auto-transcription with AI
• Auto-organization by topic (investing, color grading, etc.)
• Offline-first (works without internet)
• Cloud sync (optional, free)
• Search all your notes instantly
• Export as text or PDF

PERFECT FOR:
• Investing tips and stock market advice
• Color grading tutorials and techniques
• Video editing tips and tricks
• Cryptocurrency insights
• Productivity hacks
• Fitness routines and workout tips
• Cooking recipes and techniques

HOW IT WORKS:
1. Find a video on Instagram, TikTok, or YouTube
2. Tap Share → DoomNotes
3. Get instant transcript organized by topic
4. Search, review, and reference anytime

PRIVACY FIRST:
• No account required
• All data stored locally on your device
• Optional cloud sync with Supabase (encrypted)
• We don't sell your data

Download DoomNotes today and never lose a valuable lesson from your favorite videos!
\`\`\`

### 6. Graphics & Assets

**App Icon:**
- [ ] 512 x 512 pixels
- [ ] PNG format, no transparency
- [ ] No text or small details
- [ ] Unique design

**Feature Graphic:**
- [ ] 1024 x 500 pixels
- [ ] PNG or JPEG
- [ ] Optional but recommended

**Screenshots:**
- [ ] Phone: 1080 x 1920 (minimum 2, maximum 8)
- [ ] Tablet: 1920 x 1200 or 1280 x 800 (if supporting tablets)
- [ ] Chrome OS: 1920 x 1200 (if supporting Chrome OS)

**Suggested Screenshots:**
1. Home screen with topic folders
2. Share sheet showing DoomNotes
3. Note detail with transcript
4. Search results
5. Topic management

**Promo Video:**
- [ ] YouTube URL (optional)
- [ ] 30-120 seconds
- [ ] Show app in action

### 7. Categorization

**App Category:**
- [ ] Primary: Productivity
- [ ] Secondary: Education (optional)

**Content Rating:**
- [ ] Complete IARC questionnaire
- [ ] Expected rating: Everyone (no age restrictions)

**Target Audience:**
- [ ] Age groups: All ages
- [ ] Content descriptors: None

### 8. Contact Details

**Developer Contact:**
- [ ] Email: support@YOUR_WEBSITE.com
- [ ] Website: https://YOUR_WEBSITE.com
- [ ] Privacy Policy: https://YOUR_WEBSITE.com/privacy (REQUIRED)
- [ ] Address: Optional (recommended for credibility)

## Technical Requirements

### 9. Build Configuration

**android/app/build.gradle:**
\`\`\`gradle
android {
    compileSdk 36  // Required from August 2026
    targetSdk 36
    
    defaultConfig {
        minSdk 21  // Android 5.0+
        targetSdk 36
    }
}
\`\`\`

**Permissions in AndroidManifest.xml:**
- [ ] INTERNET (for transcription API)
- [ ] ACCESS_NETWORK_STATE (for connectivity check)
- [ ] VIBRATE (for haptic feedback)
- [ ] POST_NOTIFICATIONS (Android 13+, for capture confirmations)
- [ ] RECEIVE_BOOT_COMPLETED (for background sync)
- [ ] FOREGROUND_SERVICE (for background processing)

### 10. App Signing

- [ ] Enroll in Play App Signing (required for new apps)
- [ ] Generate upload key (or use Google-generated key)
- [ ] Store keystore securely (never commit to Git)

**Generate Keystore:**
\`\`\`bash
keytool -genkey -v -keystore doomnotes-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias doomnotes
\`\`\`

**Build Signed AAB:**
\`\`\`bash
flutter build appbundle --release --keystore=doomnotes-upload-key.jks --ks-key-alias=doomnotes
\`\`\`

## Submission Process

### 11. Create App in Play Console

- [ ] Log in to https://play.google.com/console
- [ ] Click \"Create App\"
- [ ] Enter app name: DoomNotes
- [ ] Select default language: English (United States)
- [ ] App or game: App
- [ ] Free or paid: Free

### 12. Set Up App Content

**Navigate to:** Play Console → Your App → App Content

- [ ] Privacy Policy: Enter URL (https://YOUR_WEBSITE.com/privacy)
- [ ] Ads: No (DoomNotes has no ads)
- [ ] Data Safety: Complete form (section 4 above)
- [ ] App Access: No login required
- [ ] Content Rating: Complete questionnaire
- [ ] Target Audience: All ages
- [ ] News App: No
- [ ] COVID-19 Contact Tracing: No
- [ ] Child Safety: Not directed at children under 13

### 13. Main Store Listing

**Navigate to:** Play Console → Your App → Store → Main Store Listing

- [ ] App name: DoomNotes
- [ ] Short description: Auto-transcribe Instagram videos & organize by topic
- [ ] Full description: (paste from section 5)
- [ ] App icon: Upload 512x512 PNG
- [ ] Feature graphic: Upload 1024x500 PNG/JPEG (optional)
- [ ] Screenshots: Upload 2-8 phone screenshots
- [ ] Promo video: YouTube URL (optional)

### 14. Device & Catalog

**Navigate to:** Play Console → Your App → Setup → Devices & Catalog

- [ ] Review supported devices
- [ ] Exclude any incompatible devices (if necessary)

### 15. Pricing & Distribution

**Navigate to:** Play Console → Your App → Pricing & Distribution

- [ ] Price: Free
- [ ] Countries/regions: Select all (or specific countries)
- [ ] Age restrictions: None
- [ ] Google Play Families: Not applicable (not directed at children)

### 16. Upload Release

**Navigate to:** Play Console → Your App → Production → Create New Release

- [ ] Upload AAB file (from step 10)
- [ ] Release name: 1.0.0
- [ ] Release notes:
\`\`\`
Initial release of DoomNotes!

Features:
• Auto-transcribe Instagram, TikTok, and YouTube videos
• Organize notes by topic automatically
• Offline-first design (works without internet)
• Optional cloud sync
• Search all your notes instantly
• Export as text or PDF

Privacy-focused: No account required, data stored locally on your device.
\`\`\`
- [ ] Review release
- [ ] Start rollout to Production

## Common Rejection Reasons (Avoid These!)

### Inaccurate Data Safety Form
- [ ] Ensure form matches actual data collection
- [ ] DoomNotes collects minimal data (only app activity and device ID)

### Misleading Description
- [ ] Don't claim features that don't exist
- [ ] Be clear about what the app does

### Privacy Policy Issues
- [ ] Must be accessible via public URL
- [ ] Must accurately describe data practices
- [ ] Must include contact information

### Copyright/Trademark Violations
- [ ] Don't use Instagram, TikTok, or YouTube logos
- [ ] Don't claim affiliation with these platforms
- [ ] Use disclaimer: \"Not affiliated with Instagram, TikTok, or YouTube\"

### Functionality Issues
- [ ] App must not crash
- [ ] All features must work as described
- [ ] No placeholder text or broken links

## Post-Submission

### 17. Review Process
- [ ] Initial review: 1-7 days (typically 2-3 days)
- [ ] Monitor email for updates
- [ ] If rejected:
  - [ ] Read rejection reason carefully
  - [ ] Fix issues
  - [ ] Resubmit with explanation

### 18. Approval and Launch
- [ ] Once approved, app goes live immediately (for Production rollout)
- [ ] Monitor Play Console for statistics
- [ ] Respond to user reviews
- [ ] Track crashes and ANRs (App Not Responding)

### 19. Post-Launch Updates
- [ ] Regular updates improve visibility
- [ ] Fix bugs promptly
- [ ] Add new features based on user feedback
- [ ] Update Data Safety form if data practices change

## Timeline

| Task | Estimated Time |
|------|---------------|
| Prepare assets (screenshots, icon, etc.) | 2-4 hours |
| Complete Data Safety form | 1-2 hours |
| Fill out store listing | 1-2 hours |
| Build and upload AAB | 30 minutes |
| Google Play review | 2-7 days |
| **Total** | **5-14 days** |

## Resources

- Google Play Developer Policies: https://support.google.com/googleplay/android-developer/answer/9888076
- Data Safety Section: https://support.google.com/googleplay/android-developer/answer/10787469
- App Content Guidelines: https://support.google.com/googleplay/android-developer/answer/9888076

---

**Good luck with your submission! 🚀**