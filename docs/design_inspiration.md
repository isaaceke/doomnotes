# DOOMNOTES - DESIGN INSPIRATION (STEAL LIKE AN ARTIST)
# Combining best design patterns from 5 top apps: Notion, Obsidian, Bear, Apple Notes, Craft

---

## Design Philosophy

**\"Good artists copy, great artists steal.\" - Picasso**

We're not copying AI slop. We're combining proven designs from apps that millions love.

---

## App 1: Notion

### What We Steal:

**1. Clean Typography**
- Font: System font (SF Pro on iOS, Roboto on Android)
- Headings: Bold, 20-24px
- Body: 15-16px, 1.5 line height
- Colors: Dark grey (#333) on light, light grey (#CCC) on dark

**2. Info Density**
- Show topic, preview, timestamp, URL in one card
- Not too sparse, not too crowded
- Perfect balance for power users

**3. Subtle Colors**
- Primary: Blue (#2196F3)
- Backgrounds: White / #121212 (dark)
- Cards: White / #1E1E12 (dark)
- Borders: Light grey (#E0E0E0)

**Implementation:**
\`\`\`dart
// Notion-style text
Text(
  'DoomNotes',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
)

// Notion-style card
Container(
  padding: EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
  ),
)
\`\`\`

---

## App 2: Obsidian

### What We Steal:

**1. Speed & Performance**
- Instant load (no splash screen)
- Smooth scrolling (60fps)
- No animations that slow you down

**2. Minimal UI**
- No unnecessary decorations
- Focus on content
- Power user features hidden but accessible

**3. Keyboard-First (Desktop)**
- Cmd/Ctrl + K for search
- Cmd/Ctrl + N for new note
- Escape to close

**Implementation:**
\`\`\`dart
// Obsidian-style minimal
AppBar(
  elevation: 0, // Flat
  backgroundColor: Colors.transparent,
  title: Text('Notes'),
)

// Fast list
ListView.builder(
  itemCount: notes.length,
  cacheExtent: 500, // Preload items
  addAutomaticKeepAlives: false, // Save memory
  addRepaintBoundaries: false, // Faster
)
\`\`\`

---

## App 3: Bear

### What We Steal:

**1. Beautiful Cards**
- Rounded corners (12px)
- Subtle shadows
- Clean spacing

**2. Topic Tags**
- Colored badges for topics
- Emoji icons
- Visual hierarchy

**3. Writing Focus**
- Distraction-free detail view
- Full-screen reading
- Minimal controls

**Implementation:**
\`\`\`dart
// Bear-style card
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: Colors.grey.shade200),
  ),
  child: Padding(
    padding: EdgeInsets.all(14),
    child: Column(...),
  ),
)

// Bear-style tag
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(6),
  ),
  child: Text(
    'Investing',
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.blue,
    ),
  ),
)
\`\`\`

---

## App 4: Apple Notes

### What We Steal:

**1. Familiar Layout**
- List of notes on left
- Detail on right (iPad)
- Intuitive navigation

**2. Friendly Empty States**
- Large icon
- Helpful text
- Clear call-to-action

**3. Smart Search**
- Instant results
- Highlights matches
- Recent searches

**Implementation:**
\`\`\`dart
// Apple Notes-style empty state
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
      SizedBox(height: 24),
      Text(
        'No notes yet',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Share videos to get started',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[500],
        ),
      ),
    ],
  ),
)

// Apple Notes-style search
showSearch(
  context: context,
  delegate: NoteSearchDelegate(),
)
\`\`\`

---

## App 5: Craft

### What We Steal:

**1. Polished Animations**
- Smooth transitions (300ms)
- Subtle hover effects
- Delightful micro-interactions

**2. Card Previews**
- Show first few lines
- Fade out at bottom
- Clean typography

**3. Action Menus**
- Bottom sheet on mobile
- Right-click on desktop
- Contextual actions

**Implementation:**
\`\`\`dart
// Craft-style animation
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  decoration: BoxDecoration(
    color: Colors.blue.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
)

// Craft-style bottom sheet
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        leading: Icon(Icons.delete),
        title: Text('Delete'),
        onTap: () => _delete(),
      ),
    ],
  ),
)
\`\`\`

---

## Combined Design System

### Typography:
\`\`\`dart
// Headings
TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  letterSpacing: -0.5,
)

// Body
TextStyle(
  fontSize: 16,
  height: 1.5,
  color: Colors.grey[800],
)

// Small/Caption
TextStyle(
  fontSize: 12,
  color: Colors.grey[600],
)
\`\`\`

### Colors:
\`\`\`dart
// Light mode
primary: Color(0xFF2196F3),
background: Color(0xFFFFFFFF),
surface: Color(0xFFF5F5F5),
card: Color(0xFFFFFFFF),
text: Color(0xFF333333),
textSecondary: Color(0xFF666666),

// Dark mode
primary: Color(0xFF64B5F6),
background: Color(0xFF121212),
surface: Color(0xFF1E1E1E),
card: Color(0xFF1E1E1E),
text: Color(0xFFE0E0E0),
textSecondary: Color(0xFFB0B0B0),
\`\`\`

### Spacing:
\`\`\`dart
// Consistent spacing system
const double spacing4 = 4.0;
const double spacing8 = 8.0;
const double spacing12 = 12.0;
const double spacing16 = 16.0;
const double spacing24 = 24.0;
const double spacing32 = 32.0;
\`\`\`

### Components:
\`\`\`dart
// Card
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: Colors.grey.shade200),
  ),
  child: Padding(
    padding: EdgeInsets.all(14),
    child: ...
  ),
)

// Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    minimumSize: Size(double.infinity, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('Save'),
)

// Input field
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  ),
)
\`\`\`

---

## Design Checklist

Before shipping, ensure:

- [ ] Typography is consistent (same fonts, sizes, weights)
- [ ] Colors follow design system (no random hex codes)
- [ ] Spacing is consistent (use spacing variables)
- [ ] Cards have same style (rounded, subtle borders)
- [ ] Animations are smooth (300ms, easeInOut)
- [ ] Empty states are friendly (icon + text + CTA)
- [ ] Search is instant (no lag)
- [ ] Scrolling is smooth (60fps, no jank)
- [ ] Dark mode looks good (not just inverted colors)
- [ ] Accessibility (contrast ratios, tap targets)

---

## Tools We Used

- **Figma:** For designing components
- **Material Design 3:** Base component library
- **Apple HIG:** iOS design guidelines
- **Notion/Bear/Obsidian:** Inspiration for layout

---

**Result: A design that feels familiar, polished, and fast - not AI slop.** 🎨