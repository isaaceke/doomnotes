# DOOMNOTES Part 21: Agent Instructions

## Do Not Add AI Chat

Do not create:
- Conversational AI
- RAG
- On-device LLM chat
- Cloud LLM chat
- Chat history
- AI answer citations

## Keep Only Clean Note

The only optional AI feature is **Clean Note**:
- User-triggered
- Shows preview
- Keeps original transcript

## Source Links Are Mandatory

Every note captured from a share that includes a URL must:

1. Save the URL in `Note.videoUrl`.
2. Show a `SourceLinkCard` in:
   - Note Detail
   - Search results
3. Open the link in the external app/browser when tapped.

## Search UX

Search must:

- Filter by topic, summary, transcript, keywords.
- Show a “Watch video” badge for notes with a URL.
- Display the full `SourceLinkCard` under each result that has a link.

## Test Cases

- Share a TikTok “Gwara Gwara dance tutorial” → save to Dance.
- Search “gwara”, “quara”, “gwaragwara” → see the note with a “Watch video ▶️” card.
- Tap card → TikTok app opens to that exact video.
- Share a YouTube “React Server Components explained” → save to Frontend Development.
- Search “react server” → see note with “Watch video ▶️” opening YouTube.

## Do Not Break Existing Behavior

- Topic classification still uses `TopicKeywordDatabaseService`.
- Manual topic picker only appears when confidence is low or in always-ask mode.
- No automatic AI summaries run after share.

## Important

This feature must work **offline** for search and display.
The URL only needs internet when the user taps “Watch video ▶️”.