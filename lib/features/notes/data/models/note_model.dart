import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.updatedAt,
  });

  factory NoteModel.fromCacheMap(Map<String, dynamic> map) {
    final updatedAtRaw = map['updatedAt'];
    return NoteModel(
      id: (map['id'] ?? '').toString(),
      title: sanitizeTitle(map['title']),
      content: sanitizeContent(map['content']),
      updatedAt: DateTime.tryParse(updatedAtRaw?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toCacheMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'content': content,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static String sanitizeId(Object? value) => (value ?? '').toString().trim();

  static String sanitizeTitle(Object? value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? 'Untitled' : text;
  }

  static String sanitizeContent(Object? value) => (value ?? '').toString().trim();

  static DateTime sanitizeUpdatedAt(Object? value) {
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse((value ?? '').toString());
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}
