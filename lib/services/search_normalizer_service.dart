class SearchNormalizerService {
  String normalize(String input) {
    var text = input.trim().toLowerCase();

    // Remove common punctuation and extra spaces
    text = text.replaceAll(RegExp(r'[^\w\s-]'), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Remove diacritics / accents (basic Latin range)
    text = text.replaceAll(RegExp(r'[\u0300-\u036f]'), '');

    // Fold common confusables
    text = text
        .replaceAll('q', 'g')      // qwara -> gwara
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll('4', 'a')
        .replaceAll('5', 's')
        .replaceAll('7', 't');

    return text;
  }

  List<String> tokenize(String normalized) {
    if (normalized.isEmpty) return [];
    return normalized.split(RegExp(r'\s+'));
  }
}