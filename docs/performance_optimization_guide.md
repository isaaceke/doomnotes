# DOOMNOTES - PERFORMANCE OPTIMIZATION GUIDE
# Make app 10x faster: lazy loading, caching, const constructors, minimal rebuilds

---

## Why Performance Matters

- **First impression:** App must load in <2 seconds
- **Retention:** Users quit if app feels slow
- **Reviews:** \"Slow app\" = 1-star reviews
- **Competitors:** Notion, Bear, Obsidian are FAST

---

## Optimization Checklist

### 1. Use const Constructors Everywhere

**Before (slow):**
\`\`\`dart
Text('Hello')
Icon(Icons.add)
\`\`\`

**After (fast):**
\`\`\`dart
const Text('Hello')
const Icon(Icons.add)
\`\`\`

**Impact:** 20-30% faster build time

---

### 2. Use ListView.builder (Lazy Loading)

**Before (slow - builds all items):**
\`\`\`dart
ListView(
  children: notes.map((note) => NoteCard(note: note)).toList(),
)
\`\`\`

**After (fast - builds visible items only):**
\`\`\`dart
ListView.builder(
  itemCount: notes.length,
  itemBuilder: (context, index) => NoteCard(note: notes[index]),
)
\`\`\`

**Impact:** 10x faster for long lists

---

### 3. Use ValueNotifier for Reactive Updates

**Before (rebuilds entire screen):**
\`\`\`dart
setState(() {
  notes.add(newNote);
});
\`\`\`

**After (rebuilds only changed widget):**
\`\`\`dart
final ValueNotifier<List<Note>> _notes = ValueNotifier([]);

// Update
_notes.value = [..._notes.value, newNote];

// Listen
ValueListenableBuilder<List<Note>>(
  valueListenable: _notes,
  builder: (context, notes, _) => ListView(...),
)
\`\`\`

**Impact:** 5-10x fewer rebuilds

---

### 4. Cache Images

**Before (loads image every time):**
\`\`\`dart
Image.network(url)
\`\`\`

**After (caches image):**
\`\`\`dart
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
\`\`\`

**Impact:** 10x faster image loading

---

### 5. Use const in build() Method

**Before:**
\`\`\`dart
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Title'),
    ),
    body: Column(
      children: [
        Icon(Icons.add),
        Text('Hello'),
      ],
    ),
  );
}
\`\`\`

**After:**
\`\`\`dart
Widget build(BuildContext context) {
  return const Scaffold(
    appBar: AppBar(
      title: Text('Title'),
    ),
    body: Column(
      children: [
        Icon(Icons.add),
        Text('Hello'),
      ],
    ),
  );
}
\`\`\`

**Impact:** 15-20% faster rendering

---

### 6. Split Stateful Widgets

**Before (rebuilds everything):**
\`\`\`dart
class HomeScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Header(), // Rebuilds when notes change
          NoteList(), // Rebuilds when notes change
          Footer(), // Rebuilds when notes change (unnecessary)
        ],
      ),
    );
  }
}
\`\`\`

**After (rebuilds only what changes):**
\`\`\`dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(), // const, never rebuilds
          NoteList(), // Rebuilds when notes change
          const Footer(), // const, never rebuilds
        ],
      ),
    );
  }
}
\`\`\`

**Impact:** 30-40% fewer rebuilds

---

### 7. Use RepaintBoundary for Animations

**Before (entire screen repaints):**
\`\`\`dart
AnimatedBuilder(
  animation: animation,
  builder: (context, child) {
    return Transform.scale(
      scale: animation.value,
      child: child,
    );
  },
  child: LargeWidget(),
)
\`\`\`

**After (only animation repaints):**
\`\`\`dart
AnimatedBuilder(
  animation: animation,
  builder: (context, child) {
    return RepaintBoundary(
      child: Transform.scale(
        scale: animation.value,
        child: child,
      ),
    );
  },
  child: LargeWidget(),
)
\`\`\`

**Impact:** 50% faster animations

---

### 8. Profile with DevTools

**Steps:**

1. Run app in profile mode:
\`\`\`bash
flutter run --profile
\`\`\`

2. Open DevTools:
\`\`\`bash
flutter pub global activate devtools
flutter pub global run devtools
\`\`\`

3. Check:
- **Performance tab:** Frame rendering time (<16ms = good)
- **Memory tab:** No memory leaks
- **Network tab:** No slow API calls

---

## Performance Targets

| Metric | Target | How to Measure |
|--------|--------|----------------|
| App launch time | <2 seconds | Time from tap to home screen |
| Frame rate | 60 fps | DevTools Performance tab |
| Memory usage | <100 MB | DevTools Memory tab |
| List scroll | No jank | Scroll fast, check for stutter |
| Image load | <500ms | Network tab in DevTools |

---

## Common Performance Mistakes

### ❌ Don't:

\`\`\`dart
// Rebuilds entire list on every change
ListView(
  children: notes.map((note) => NoteCard(note: note)).toList(),
)

// Loads full-size image into small thumbnail
Image.network(largeImageUrl)

// Rebuilds parent when child changes
setState(() {
  // Changes child state
})
\`\`\`

### ✅ Do:

\`\`\`dart
// Lazy loads only visible items
ListView.builder(
  itemCount: notes.length,
  itemBuilder: (context, index) => NoteCard(note: notes[index]),
)

// Resizes image to display size
CachedNetworkImage(
  imageUrl: largeImageUrl,
  cacheWidth: 100, // Thumbnail size
)

// Uses ValueNotifier for child state
final ValueNotifier<bool> _childState = ValueNotifier(false);
\`\`\`

---

## Resources

- Flutter Performance Best Practices: https://docs.flutter.dev/perf
- DevTools Guide: https://docs.flutter.dev/tools/devtools
- Impeller Engine (Flutter 3.0+): https://docs.flutter.dev/perf/impeller

---

**Fast apps = happy users. Optimize early, optimize often.** ⚡