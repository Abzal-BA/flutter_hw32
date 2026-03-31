import '../entities/note.dart';
import '../repositories/i_notes_repository.dart';

class WatchNotesUseCase {
  const WatchNotesUseCase(this._repository);

  final INotesRepository _repository;

  Stream<List<Note>> call({
    NotesLoadStrategy strategy = NotesLoadStrategy.cacheFirst,
  }) {
    return _repository.watchNotes(strategy: strategy);
  }
}
