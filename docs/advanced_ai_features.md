# DOOMNOTES - ADVANCED AI FEATURES SPECIFICATION
# Phase 2 features (post-MVP) to enhance user experience

## 1. Auto-Summary Generation

### Current State (MVP)
- User must manually tap \"Generate AI Summary\" button
- Saves tokens by not processing every note automatically

### Enhanced Version (Phase 2)
**Smart Auto-Summary:**
- AI detects note length
- Notes > 500 words → Auto-generate summary (user can disable)
- Notes < 500 words → Skip (not worth summarizing)

**Implementation:**
\`\`\`dart
Future<void> processNote(Note note) async {
  if (note.transcript.length > 500 && !note.isSummarized) {
    final summary = await AIService.summarize(note.transcript);
    note.summary = summary;
    note.isSummarized = true;
    await saveNote(note);
  }
}
\`\`\`

**AI Prompt:**
\`\`\`
Summarize this transcript in 3-5 bullet points:
- Capture key insights only
- Remove filler words and examples
- Keep actionable advice
- Maximum 100 words

Transcript: {transcript}
\`\`\`

---

## 2. Knowledge Graph

### Concept
Visualize connections between notes as a graph/network.

**Example:**
- Note A (investing): \"Dollar-cost averaging reduces risk\"
- Note B (investing): \"DCA means buying fixed amounts regularly\"
- **Connection detected:** Both mention \"dollar-cost averaging\" / \"DCA\"
- **Graph shows:** Link between Note A and Note B

### Implementation Options

**Option A: Keyword-Based (Simple)**
\`\`\`dart
Map<String, List<int>> keywordToNoteIds = {};

for (final note in allNotes) {
  for (final keyword in note.keywords) {
    keywordToNoteIds.putIfAbsent(keyword, () => []);
    keywordToNoteIds[keyword]!.add(note.id);
  }
}

// Notes sharing keywords are connected
\`\`\`

**Option B: Embedding-Based (Advanced)**
\`\`\`dart
// Use sentence-transformers or similar
final embedding = await EmbeddingService.embed(note.transcript);

// Calculate cosine similarity between notes
final similarity = cosineSimilarity(embedding1, embedding2);

if (similarity > 0.7) {
  // Notes are related, create link
}
\`\`\`

**UI:**
- Force-directed graph (D3.js or Flutter package)
- Nodes = notes, edges = connections
- Click node → open note
- Filter by topic

---

## 3. Smart Deduplication

### Problem
User shares multiple videos about same topic → redundant notes.

### Solution
**Duplicate Detection:**
1. Calculate similarity score between new note and existing notes
2. If similarity > 85% → flag as potential duplicate
3. Show user: \"This looks similar to 'Color Grading Basics'. Replace it?\"

**Implementation:**
\`\`\`dart
Future<bool> isDuplicate(Note newNote) async {
  final existingNotes = await getNotesByTopic(newNote.topic);
  
  for (final existing in existingNotes) {
    final similarity = calculateSimilarity(
      newNote.transcript,
      existing.transcript,
    );
    
    if (similarity > 0.85) {
      return true; // Duplicate detected
    }
  }
  
  return false;
}

double calculateSimilarity(String text1, String text2) {
  // Use TF-IDF, cosine similarity, or embeddings
  // Return 0.0 to 1.0
}
\`\`\`

**User Flow:**
1. User shares video
2. App detects 90% similarity to existing note
3. Show dialog:
   - \"This is 90% similar to 'Color Grading Basics'\"
   - [View Old Note] [Keep Both] [Replace Old Note]

---

## 4. Auto-Tagging

### Current State
- Topics are based on predefined keywords
- Limited to 8-10 default topics

### Enhanced Version
**AI-Powered Tags:**
- AI reads transcript and suggests tags
- Tags are more granular than topics

**Example:**
- Topic: \"Color Grading\"
- AI Tags: [\"skin tones\", \"log footage\", \"davinci resolve\", \"rec709\"]

**Implementation:**
\`\`\`dart
Future<List<String>> generateTags(String transcript) async {
  final response = await openAI.chat(
    messages: [
      Message(
        role: 'system',
        content: 'Extract 5-10 key tags from this transcript. Single words or short phrases.',
      ),
      Message(role: 'user', content: transcript),
    ],
  );
  
  return parseTags(response.content);
}
\`\`\`

**UI:**
- Tags displayed below note title
- Click tag → search for all notes with that tag
- User can add/remove tags manually

---

## 5. Learning Paths

### Concept
Organize notes into structured learning sequences.

**Example Path: \"Color Grading Mastery\"**
1. Note: \"Understanding Log Footage\" (beginner)
2. Note: \"Primary Color Correction\" (intermediate)
3. Note: \"Secondary Color Correction\" (advanced)
4. Note: \"HDR Grading Techniques\" (expert)

### Implementation

**Manual Curation (Phase 1):**
- User creates learning paths manually
- Drag-and-drop notes into sequence
- Name the path

**AI-Suggested Paths (Phase 2):**
- AI analyzes all notes in a topic
- Detects progression (beginner → advanced)
- Suggests learning path

**AI Prompt:**
\`\`\`
Organize these notes into a learning path from beginner to advanced:

Notes:
{note_titles_and_summaries}

Output:
Ordered list with difficulty level for each note
\`\`\`

**UI:**
- \"Learning Paths\" tab in app
- Progress tracking (0/5 notes completed)
- Checkmarks for completed notes

---

## 6. Spaced Repetition

### Concept
Remind users to review old notes at optimal intervals.

**Based on:**
- Ebbinghaus forgetting curve
- Anki-style spaced repetition

**Schedule:**
- Day 1: Capture note
- Day 2: First review (1 day later)
- Day 4: Second review (3 days later)
- Day 8: Third review (1 week later)
- Day 15: Fourth review (2 weeks later)
- Day 30: Fifth review (1 month later)

### Implementation

\`\`\`dart
class ReviewScheduler {
  Future<List<Note>> getNotesDueForReview() async {
    final now = DateTime.now();
    final notes = await getAllNotes();
    
    return notes.where((note) {
      if (note.lastReviewDate == null) {
        // Never reviewed, due immediately
        return true;
      }
      
      final daysSinceReview = now.difference(note.lastReviewDate!).inDays;
      final nextReviewInterval = calculateNextInterval(note.reviewCount);
      
      return daysSinceReview >= nextReviewInterval;
    }).toList();
  }
  
  int calculateNextInterval(int reviewCount) {
    // Ebbinghaus curve
    const intervals = [1, 3, 7, 15, 30, 60];
    return intervals[reviewCount.clamp(0, intervals.length - 1)];
  }
}
\`\`\`

**UI:**
- Daily notification: \"5 notes due for review\"
- Review screen: Show note, user rates recall (1-5)
- Better recall → longer interval
- Poor recall → shorter interval

---

## 7. Flashcard Generation

### Concept
Auto-generate flashcards from notes for active recall.

**Example:**
- Note: \"Dollar-cost averaging reduces market timing risk\"
- Flashcard:
  - Front: \"What is the main benefit of dollar-cost averaging?\"
  - Back: \"Reduces market timing risk by buying fixed amounts regularly\"

### Implementation

\`\`\`dart
Future<List<Flashcard>> generateFlashcards(Note note) async {
  final response = await openAI.chat(
    messages: [
      Message(
        role: 'system',
        content: 'Generate 5-10 flashcard Q&A pairs from this transcript. Focus on key concepts.',
      ),
      Message(role: 'user', content: note.transcript),
    ],
  );
  
  return parseFlashcards(response.content);
}
\`\`\`

**UI:**
- \"Flashcards\" tab
- Swipe left/right (Tinder-style)
- Know it → swipe right
- Don't know → swipe left (shows again sooner)

---

## 8. AI Chat with Notes

### Concept
Chat with your knowledge base like ChatGPT, but trained on YOUR notes.

**Example Queries:**
- \"What did I learn about color grading?\"
- \"Show me all tips about dollar-cost averaging\"
- \"What's the best workflow for video editing?\"

### Implementation

**RAG (Retrieval-Augmented Generation):**
1. User asks question
2. Search notes for relevant content
3. Send question + relevant notes to AI
4. AI answers based on YOUR notes

\`\`\`dart
Future<String> chatWithNotes(String question) async {
  // Step 1: Find relevant notes
  final relevantNotes = await searchNotes(question, limit: 5);
  
  // Step 2: Build context
  final context = relevantNotes
      .map((note) => 'Note: \${note.transcript}')
      .join('\\n\\n');
  
  // Step 3: Ask AI
  final response = await openAI.chat(
    messages: [
      Message(
        role: 'system',
        content: 'Answer based ONLY on these notes. If answer not in notes, say so.',
      ),
      Message(role: 'user', content: 'Context: \$context\\n\\nQuestion: \$question'),
    ],
  );
  
  return response.content;
}
\`\`\`

**UI:**
- Chat interface (like ChatGPT)
- Input: \"Ask anything about your notes...\"
- Response with citations (\"From note: Color Grading Basics\")

---

## 9. Trend Detection

### Concept
Alert user when new information contradicts or updates old notes.

**Example:**
- Old note (2024): \"Bitcoin mining uses 150 TWh/year\"
- New note (2026): \"Bitcoin mining now uses 100 TWh/year after efficiency improvements\"
- **Alert:** \"This updates your note from 2024 about Bitcoin energy usage\"

### Implementation

\`\`\`dart
Future<List<UpdateAlert>> detectUpdates(Note newNote) async {
  final alerts = <UpdateAlert>[];
  
  final existingNotes = await getNotesByTopic(newNote.topic);
  
  for (final existing in existingNotes) {
    // Check for contradicting numbers or facts
    final contradiction = detectContradiction(newNote.transcript, existing.transcript);
    
    if (contradiction != null) {
      alerts.add(UpdateAlert(
        oldNote: existing,
        newNote: newNote,
        reason: contradiction,
      ));
    }
  }
  
  return alerts;
}
\`\`\`

**UI:**
- Notification: \"New info updates your note about Bitcoin mining\"
- Side-by-side comparison
- [Keep Old] [Update to New] [Keep Both]

---

## 10. Collaborative Playlists (Future)

### Concept
Share topic folders with friends/teams.

**Use Cases:**
- Study group shares investing notes
- Video editing team shares techniques
- Family shares cooking recipes

### Implementation

\`\`\`dart
class CollaborativeFolder {
  String id;
  String name;
  List<String> memberIds;
  List<String> noteIds;
  
  Future<void> addMember(String userId) async {
    // Send invitation
    // Add to members list
  }
  
  Future<void> removeMember(String userId) async {
    // Remove from members list
  }
}
\`\`\`

**Permissions:**
- Owner: Can add/remove members, delete folder
- Member: Can view notes, add notes
- Viewer: Can only view notes

---

## Prioritization

| Feature | Effort | Impact | Priority |
|---------|--------|--------|----------|
| Auto-Summary | Low | High | 1 |
| Smart Deduplication | Medium | High | 2 |
| Auto-Tagging | Medium | Medium | 3 |
| Knowledge Graph | High | Medium | 4 |
| AI Chat with Notes | Medium | High | 5 |
| Learning Paths | Low | Medium | 6 |
| Spaced Repetition | Medium | Low | 7 |
| Flashcard Generation | Medium | Low | 8 |
| Trend Detection | High | Low | 9 |
| Collaborative Folders | High | Low | 10 |

---

**Start with features 1-3 for maximum impact with minimal effort.** 🚀