// DOOMNOTES - Summarization Result Model
// Output of the "Clean note" feature — a simple extractive summarizer,
// not a real AI model (see ai_summary_service.dart).

class SummarizationResult {
  final String summary;
  final List<String> bulletPoints;
  final String modelSource;
  final bool isFallback;

  SummarizationResult({
    required this.summary,
    required this.bulletPoints,
    required this.modelSource,
    this.isFallback = false,
  });
}