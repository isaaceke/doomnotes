# DOOMNOTES Part 16: Design Sources (5 Apps We “Stole” From)

We explicitly combined patterns from five proven apps instead of generating random “AI slop” UIs.

## 1. Notion

What we copied:
- Clean typography and spacing.
- Information density in cards (topic, preview, timestamp, URL).
- Subtle blue accent color and neutral backgrounds.

Where you see it:
- Home screen topic headers and note cards.
- Settings and premium paywall layout.

## 2. Obsidian

What we copied:
- Performance-first mindset: minimal animations, instant load.
- Power-user feel: keyboard-friendly (desktop), fast search.
- Very light UI chrome; content is the star.

Where you see it:
- Optimized list rendering (const, ListView.builder, ValueNotifier).
- Minimal app bar, flat design.

## 3. Bear

What we copied:
- Beautiful, simple cards with rounded corners and subtle borders.
- Topic tags with emoji and soft background colors.
- Distraction-free reading view.

Where you see it:
- Note card design (rounded, clean, readable).
- Topic badges on notes.

## 4. Apple Notes

What we copied:
- Familiar list + detail pattern.
- Friendly empty states with large icons and clear text.
- Simple, reliable search UI.

Where you see it:
- Home screen empty state.
- Search overlay behavior.

## 5. Craft

What we copied:
- Polished micro-interactions (subtle hover/press states).
- Card previews with fade and clean typography.
- Bottom-sheet action menus for note options.

Where you see it:
- Note detail actions (archive, delete, share).
- Smooth transitions and bottom sheets.

## How We Avoided “AI Slop”

- We did not ask an AI to “design a pretty UI.”
- We studied real, shipped apps used by millions.
- We combined specific patterns:
  - Notion’s info density
  - Obsidian’s speed
  - Bear’s card beauty
  - Apple Notes’ familiarity
  - Craft’s polish
- We kept everything consistent with a simple design system:
  - One font family (system font)
  - 3 text sizes (heading, body, caption)
  - 2–3 core colors (background, surface, primary blue)
  - Consistent spacing (4, 8, 12, 16, 24, 32)

Result: a design that feels familiar, fast, and focused — not random or over-designed.