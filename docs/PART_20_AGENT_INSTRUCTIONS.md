# DOOMNOTES Part 20: Coding Agent Instructions

## Remove Part 19 AI Chat

Do not add:
- Ask Your Notes
- Conversational AI
- RAG
- On-device LLM chat
- Cloud LLM chat
- Chat history
- AI answer citations

The product has no AI chat feature.

## Keep Only Clean Note AI

The only AI-related UI should be:
- `Clean Note`
- Optional and user-triggered
- Never runs automatically after sharing
- Shows a preview before the user accepts the cleaned text
- Keeps the original raw transcript unchanged

## Use the Canonical Classifier

Use:
- `lib/services/topic_keyword_database_service.dart`
- `lib/models/topic_definition.dart`
- `lib/models/topic_match.dart`
- `assets/topic_packs/*.json`

Do not create alternate classifier files such as:
- `topic_classifier_v2.dart`
- `smart_topic_service.dart`
- `ai_topic_classifier.dart`

## Capture Flow

1. Receive shared text, URL, image OCR, or audio transcript.
2. Combine available text sources.
3. Obtain up to five `TopicMatch` results.
4. If auto mode and top confidence >= 45:
   - Save to `topMatch.topic.label`.
   - Notify: `Saved to {Topic Label}`.
5. If always-ask mode or confidence < 45:
   - Present the top three suggestions plus:
     - Search folders
     - Create a custom folder
     - Save to Unsorted
6. Never force a topic picker after every capture in automatic mode.

## Testing

Use these tests:

- "How to use React Server Components in Next.js" -> Frontend Development
- "Full scholarship for international masters students, deadline Friday" -> Scholarships
- "Best EQ settings for clean vocal mixes in FL Studio" -> Mixing & Mastering
- "How attachment styles affect conflict in relationships" -> Attachment & Relationships
- "Remote customer-support role, apply by Monday" -> Remote Jobs or Customer Support Jobs
- "New law passed by parliament on student loans" -> Law & Legislation / Education Policy
- "Night routine: retinol, moisturizer, and SPF tips" -> Skincare

Do not rely on an internet connection. These packs must work entirely offline.