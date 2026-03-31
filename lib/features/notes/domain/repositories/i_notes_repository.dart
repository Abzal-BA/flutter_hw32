import '../entities/note.dart';

enum NotesLoadStrategy {
  cacheFirst,
  remoteOnly,
  localOnly,
}

abstract class INotesRepository {
  Stream<List<Note>> watchNotes({
    NotesLoadStrategy strategy = NotesLoadStrategy.cacheFirst,
  });
}
