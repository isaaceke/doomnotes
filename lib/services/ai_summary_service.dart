// DOOMNOTES - Note Cleaning Service
//
// This is NOT a real AI/LLM model. It's a simple extractive summarizer:
// it takes the first few sentences of the saved text and presents them as
// bullet points. An earlier draft of this file had separate iOS/Android/
// desktop code paths with comments about Apple Foundation Models and an
// on-device Gemma model — all three paths actually called this same
// placeholder, so the "model source" labels were fabricated. Removed that
// branching entirely rather than leave misleading comments in place.
//
// If you want this to be real AI, replace `_extractiveBullets` with an
// actual on-device or API-based call. Until then, don't market "Clean
// note" as AI-powered.

import '../models/summarization_result.dart';

class AiSummaryService {
  Future<SummarizationResult> summarize(String transcript) async {
    final bullets = _extractiveBullets(transcript, maxBullets: 4);
    return SummarizationResult(
      summary: bullets.join('\n'),
      bulletPoints: bullets,
      modelSource: 'extractive_heuristic',
    );
  }

  List<String> _extractiveBullets(String text, {int maxBullets = 4}) {
    final sentences = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .take(maxBullets)
        .map((s) => '• ${s.trim()}')
        .toList();

    if (sentences.isEmpty) return ['• No text to summarize'];
    return sentences;
  }
}
