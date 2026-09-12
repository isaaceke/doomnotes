# DOOMNOTES - ANALYTICS IMPLEMENTATION GUIDE
# Track user behavior, improve retention, and measure growth

## Why Analytics?

**Goals:**
- Understand how users interact with app
- Identify drop-off points (where users quit)
- Measure feature adoption
- Track retention (do users come back?)
- A/B test improvements

**Privacy-First Approach:**
- No personal data collection (GDPR compliant)
- Anonymous event tracking only
- Users can opt-out in settings
- No third-party cookies

---

## Recommended Stack

### Option 1: Firebase Analytics (FREE)
**Pros:**
- Free unlimited events
- Built-in audience segmentation
- Integrates with Google Ads (for future ads)
- Real-time dashboards

**Cons:**
- Google product (privacy concerns for some users)
- Requires Google Play Services on Android

**Best For:** Most apps, especially if using other Firebase services

### Option 2: Mixpanel (FREE up to 100K events/month)
**Pros:**
- Better funnel analysis than Firebase
- User cohorts and segmentation
- A/B testing built-in
- More privacy-friendly

**Cons:**
- Free tier limited (100K events/month = ~3K users)
- Paid plans start at \$25/month

**Best For:** Growth-focused apps, A/B testing

### Option 3: Amplitude (FREE up to 10M events/month)
**Pros:**
- Most generous free tier
- Advanced analytics (retention, LTV, cohorts)
- Privacy-focused (GDPR compliant)
- No code A/B testing

**Cons:**
- Steeper learning curve
- Overkill for simple apps

**Best For:** Data-driven products, serious about analytics

### Option 4: PostHog (FREE self-hosted)
**Pros:**
- Open-source (full control)
- Self-hosted (complete privacy)
- Feature flags, A/B testing included
- Session recording (optional)

**Cons:**
- Requires hosting (your server)
- More setup work

**Best For:** Privacy-focused apps, technical teams

---

## Recommendation for DoomNotes

**Phase 1 (MVP):** Firebase Analytics (free, easy setup)

**Phase 2 (Growth):** Add Mixpanel or Amplitude for deeper insights

**Phase 3 (Scale):** Consider PostHog for full control

---

## Firebase Analytics Setup

### Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click \"Add project\"
3. Project name: \"DoomNotes\"
4. Enable Google Analytics
5. Create project

### Step 2: Add Firebase to Flutter App

\`\`\`bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Add Firebase to Flutter project
cd doomnotes
flutterfire configure
\`\`\`

This will:
- Create firebase_options.dart
- Add platform-specific configs (iOS/Android/Web)

### Step 3: Install Dependencies

**pubspec.yaml:**
\`\`\`yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_analytics: ^10.7.0
  firebase_crashlytics: ^3.4.0  # Crash reporting
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

### Step 4: Initialize Firebase

**lib/main.dart:**
\`\`\`dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize analytics
  final analytics = FirebaseAnalytics.instance;
  
  // Set analytics collection enabled (user can disable in settings)
  await analytics.setAnalyticsCollectionEnabled(true);
  
  // Set session timeout (default: 30 minutes)
  await analytics.setSessionTimeoutDuration(const Duration(minutes: 30));
  
  runApp(const DoomNotesApp());
}
\`\`\`

### Step 5: Track Key Events

**lib/services/analytics_service.dart:**
\`\`\`dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Track when user captures a video
  Future<void> trackVideoCapture(String topic, String source) async {
    await _analytics.logEvent(
      name: 'video_capture',
      parameters: {
        'topic': topic,
        'source': source, // 'instagram', 'tiktok', 'youtube'
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  // Track when user views a note
  Future<void> trackNoteView(String topic, int noteLength) async {
    await _analytics.logEvent(
      name: 'note_view',
      parameters: {
        'topic': topic,
        'note_length': noteLength,
      },
    );
  }
  
  // Track when user searches
  Future<void> trackSearch(String query, int resultCount) async {
    await _analytics.logEvent(
      name: 'search',
      parameters: {
        'search_term': query,
        'result_count': resultCount,
      },
    );
  }
  
  // Track when user enables cloud sync
  Future<void> trackCloudSyncEnabled() async {
    await _analytics.logEvent(
      name: 'cloud_sync_enabled',
    );
  }
  
  // Track when user exports note
  Future<void> trackExport(String format) async {
    await _analytics.logEvent(
      name: 'export_note',
      parameters: {
        'format': format, // 'txt', 'pdf', 'markdown'
      },
    );
  }
  
  // Track app open (for retention)
  Future<void> trackAppOpen() async {
    await _analytics.logAppOpen();
  }
  
  // Track screen views
  Future<void> trackScreenView(String screenName) async {
    await _analytics.logEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
      },
    );
  }
  
  // Track errors
  Future<void> trackError(String errorType, String message) async {
    await _analytics.logEvent(
      name: 'error',
      parameters: {
        'error_type': errorType,
        'message': message,
      },
    );
  }
  
  // Track user signup (if premium implemented)
  Future<void> trackSignup(String method) async {
    await _analytics.logSignUp(
      signUpMethod: method, // 'email', 'google', 'apple'
    );
  }
  
  // Track purchase (if premium implemented)
  Future<void> trackPurchase(String itemId, double price, String currency) async {
    await _analytics.logPurchase(
      value: price,
      currency: currency,
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: 'DoomNotes Premium',
        ),
      ],
    );
  }
}
\`\`\`

### Step 6: Integrate into App

**lib/screens/home_screen.dart:**
\`\`\`dart
import '../services/analytics_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    // Track screen view
    AnalyticsService().trackScreenView('home');
    AnalyticsService().trackAppOpen();
  }
}
\`\`\`

**lib/services/share_handler_service.dart:**
\`\`\`dart
// After successful capture
await AnalyticsService().trackVideoCapture(
  note.topic,
  _extractSource(url), // 'instagram', 'tiktok', 'youtube'
);
\`\`\`

---

## Key Metrics to Track

### 1. Acquisition (How users find you)
- App store source (organic vs paid)
- Referral source (if implemented)
- Campaign tracking (UTM parameters)

### 2. Activation (First-time experience)
- First video captured
- First note viewed
- First search performed
- Time to first capture

### 3. Engagement (How users interact)
- Daily Active Users (DAU)
- Weekly Active Users (WAU)
- Monthly Active Users (MAU)
- Session duration
- Sessions per user per day
- Captures per user per week
- Notes viewed per session

### 4. Retention (Do users come back?)
- Day 1 retention (% who return next day)
- Day 7 retention (% who return after 1 week)
- Day 30 retention (% who return after 1 month)
- Churn rate (% who stop using app)

### 5. Monetization (If premium implemented)
- Conversion rate (free → premium)
- Monthly Recurring Revenue (MRR)
- Average Revenue Per User (ARPU)
- Lifetime Value (LTV)

---

## Dashboards to Create

### Firebase Dashboard

**Real-time:**
- Current active users
- Top events (last 30 minutes)

**Acquisition:**
- New users by date
- Users by country
- Users by device (iOS vs Android)

**Engagement:**
- DAU/WAU/MAU
- Average session duration
- Screens per session

**Retention:**
- Cohort analysis (users who joined week 1, week 2, etc.)
- Return rate by day

**Events:**
- Top events (video_capture, note_view, search, etc.)
- Event parameters (most popular topics)

---

## Privacy Compliance

### GDPR (EU)
- [ ] Allow users to opt-out of analytics
- [ ] Don't track personal data
- [ ] Anonymize IP addresses
- [ ] Document data usage in privacy policy

**Implementation:**
\`\`\`dart
// Settings screen
Switch(
  value: analyticsEnabled,
  onChanged: (value) async {
    await FirebaseAnalytics.instance
        .setAnalyticsCollectionEnabled(value);
    setState(() => analyticsEnabled = value);
  },
)
\`\`\`

### CCPA (California)
- [ ] Disclose analytics in privacy policy
- [ ] Allow users to opt-out
- [ ] Don't sell data to third parties

### COPPA (Children)
- [ ] If app is for kids under 13, additional restrictions apply
- [ ] DoomNotes: Not directed at children (age rating: Everyone)

---

## A/B Testing (Phase 2)

### Firebase A/B Testing

**Test Example:**
- Hypothesis: \"Adding tutorial on first launch increases retention\"
- Variant A: No tutorial (control)
- Variant B: Tutorial on first launch
- Metric: Day 7 retention

**Implementation:**
\`\`\`dart
import 'package:firebase_remote_config/firebase_remote_config.dart';

final remoteConfig = FirebaseRemoteConfig.instance;

// Get tutorial enabled flag
final showTutorial = remoteConfig.getBool('show_first_launch_tutorial');

if (showTutorial && isFirstLaunch) {
  showTutorialOverlay();
}
\`\`\`

---

## Resources

- Firebase Analytics Docs: https://firebase.google.com/docs/analytics
- Mixpanel Docs: https://developer.mixpanel.com
- Amplitude Docs: https://developers.amplitude.com
- PostHog Docs: https://posthog.com/docs

---

**Start with Firebase Analytics (free), add Mixpanel when you hit 10K+ users.** 📊