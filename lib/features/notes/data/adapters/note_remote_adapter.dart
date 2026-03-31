import '../models/note_model.dart';

class NoteRemoteAdapter {
  const NoteRemoteAdapter();

  NoteModel fromExternal(Map<String, dynamic> raw) {
    return NoteModel(
      id: NoteModel.sanitizeId(raw['note_id'] ?? raw['id']),
      title: NoteModel.sanitizeTitle(raw['title_text'] ?? raw['title']),
      content: NoteModel.sanitizeContent(raw['body_text'] ?? raw['content']),
      updatedAt:
          NoteModel.sanitizeUpdatedAt(raw['updated_at'] ?? raw['updatedAt']),
    );
  }
}
