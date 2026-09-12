# DOOMNOTES Part 16: Monetization Strategy (Ads, Sponsors, Premium)

## Research-Based Model for Productivity Apps (2026)

For productivity/note apps in 2026, the dominant and most sustainable model is:

- **Freemium core + Subscription premium**
- Optional **ad-supported free tier** with **paid ad removal**
- Carefully limited **sponsored content** that does not破坏 focus

Sources:
- Subscriptions generate 4.6× more ARPU than ad-only apps (AppsFlyer 2026). [207]
- Productivity apps (Notion, Todoist, Bear) use subscription as primary model. [213][214]
- Ads are a poor primary model for focus-heavy productivity tools; they damage trust and UX. [214]
- Freemium + subscription is the best starting point for new apps in 2026. [212][216]

## Recommended Hybrid Model

### Free Tier

Includes:
- Unlimited local notes
- Auto-transcription (self-hosted)
- Auto-organization by topic
- Search and export (basic)
- Batch capture & OCR

Optional:
- Light, privacy-friendly ads:
  - No interstitials during capture or reading.
  - Optional rewarded ad to unlock a premium feature for 24 hours (e.g., AI summary).
  - Ad mediation (AdMob + AppLovin) to maximize eCPM while respecting focus.

### Premium Tier (Subscription)

Pricing (example):
- Monthly: \$4.99/month
- Annual: \$39.99/year (≈33% discount)
- 7-day free trial

Features:
- Cloud sync (Supabase Pro or equivalent)
- AI summaries (on-demand)
- Unlimited custom topics
- Advanced search & filters
- Export to Notion/Obsidian
- Priority support
- Early access to new features

### Sponsors (Optional, Careful)

Use sponsors only if they align with learning/productivity:

- Sponsored topic icons (e.g., “Video Editing – powered by Skillshare”)
- Non-intrusive banner in settings or about screen
- No sponsored content in the main note list or detail views

Always:
- Clearly label sponsored elements.
- Allow users to disable sponsored topics in settings.
- Never sell or share user data with sponsors.

## Implementation Notes

- Use **RevenueCat** or native in-app purchase libraries for subscriptions.
- Offer a **7-day free trial** to increase conversion.
- Show the paywall:
  - After the first successful capture
  - When the user tries a premium feature
  - In Settings → “Upgrade to Premium”
- Provide a clear “Restore Purchases” button.

## Metrics to Track

- Free → Premium conversion rate (target: 3–8% for productivity).
- Monthly ARPU (target: \$0.30–\$1.50 for freemium, \$5–\$15 for subscription-heavy).
- Retention (D1, D7, D30).
- Ad ARPU if ads are enabled (keep low to protect UX).

## Decision Rules

Use this model if:
- Users open the app daily or several times per week.
- The app becomes part of their learning workflow.
- You can deliver ongoing value (sync, AI, new features).

Avoid heavy ads if:
- The app is meant for deep focus and trust.
- Your differentiator is a clean, fast, private experience.

For DoomNotes, the right mix is:

- **Primary:** Freemium + Subscription
- **Secondary:** Light, optional ads + occasional rewarded unlocks
- **Tertiary:** Carefully curated sponsors for topic folders