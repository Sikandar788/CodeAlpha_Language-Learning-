// Simple models for vocab items and categories

class Vocab {
  int? id;
  final String text; // word/phrase
  final String translation;
  final String example;
  final String category; // Vocabulary / Phrases / Grammar
  final String language; // e.g., Spanish

  Vocab({
    this.id,
    required this.text,
    required this.translation,
    this.example = '',
    this.category = 'Vocabulary',
    this.language = 'Spanish',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'translation': translation,
      'example': example,
      'category': category,
      'language': language,
    };
  }

  factory Vocab.fromMap(Map<String, dynamic> m) {
    return Vocab(
      id: m['id'],
      text: m['text'],
      translation: m['translation'],
      example: m['example'] ?? '',
      category: m['category'] ?? 'Vocabulary',
      language: m['language'] ?? 'Spanish',
    );
  }
}
