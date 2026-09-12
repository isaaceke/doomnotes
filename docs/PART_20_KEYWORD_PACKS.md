# DOOMNOTES Part 20: Interest-Based Topic Keyword Packs

## Product Rule

DoomNotes does not use AI chat.

The only optional AI function in the app is **Clean Note**:
- Remove filler words and duplicated phrases
- Turn a rough transcript into clean bullet points
- Preserve the original transcript
- Let the user review before replacing/saving a clean version

Topic assignment uses local, transparent keyword matching.

## Why Packs, Not One Giant Topic List?

People save content because of their active interests:
- A developer saves API, cloud, AI engineering, and job posts.
- A creative saves illustration, photography, filmmaking, and portfolio advice.
- A student saves scholarships, visa updates, tests, internships, and remote work.
- A 9-to-5 worker saves career growth, salary, office politics, and workplace tools.
- A music fan saves albums, artist news, genres, production, concerts, and playlists.

Packs make the default folders useful and reduce irrelevant matches.

## Included Packs

1. `tech_people.json` — 30 topics
2. `creatives.json` — 28 topics
3. `technical_creatives.json` — 24 topics
4. `philosophy_psychology.json` — 24 topics
5. `lifestyle_beauty_personal_care.json` — 30 topics
6. `students_opportunities.json` — 28 topics
7. `jobs_remote_work_9to5.json` — 30 topics
8. `politics_news_civic.json` — 28 topics
9. `music.json` — 30 topics

Total: 252 topic folders.

## Classification Rules

1. Build one searchable string from:
   - Shared text
   - Shared URL
   - OCR text
   - Transcript
   - Post title, if provided by the share sheet
2. Run `TopicKeywordDatabaseService.classify()`.
3. Auto-save to the highest-scoring topic only if confidence is at least 45.
4. If confidence is below 45, use `Unsorted` and show the top three suggestions.
5. Respect the existing setting:
   - `automatic`: auto-save when confidence is high
   - `alwaysAsk`: always show suggestions before saving
6. Let users move a note after saving. Treat this correction as feedback for a future local override table.

## Do Not Make These Claims

- Do not say DoomNotes "understands" a full social-media post if the share sheet supplied only a URL.
- Do not say content was fetched from Instagram, X, TikTok, or YouTube unless it was actually received or explicitly fetched with permission.
- Do not claim classification is perfect.
- Do not classify based on a person's gender, race, religion, health status, or political identity.

## Important Implementation Note

Add all JSON files to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/topic_packs/
```

Then call `await TopicKeywordDatabaseService().load();` during app startup.