import '../../domain/entities/note.dart';
import '../../domain/repositories/i_notes_repository.dart';
import '../adapters/note_remote_adapter.dart';
import '../datasources/note_local_datasource.dart';
import '../datasources/note_remote_datasource.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements INotesRepository {
  const NotesRepositoryImpl({
    required INoteRemoteDataSource remoteDataSource,
    required INoteLocalDataSource localDataSource,
    required NoteRemoteAdapter remoteAdapter,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _remoteAdapter = remoteAdapter;

  final INoteRemoteDataSource _remoteDataSource;
  final INoteLocalDataSource _localDataSource;
  final NoteRemoteAdapter _remoteAdapter;

  @override
  Stream<List<Note>> watchNotes({
    NotesLoadStrategy strategy = NotesLoadStrategy.cacheFirst,
  }) async* {
    switch (strategy) {
      case NotesLoadStrategy.localOnly:
        yield await _localDataSource.getCachedNotes();
        return;
      case NotesLoadStrategy.remoteOnly:
        final remote = await _fetchAndCacheRemoteNotes();
        yield remote;
        return;
      case NotesLoadStrategy.cacheFirst:
        final cached = await _localDataSource.getCachedNotes();
        yield cached;
        final remote = await _fetchAndCacheRemoteNotes();
        if (!_sameNotes(cached, remote)) {
          yield remote;
        }
        return;
    }
  }

  Future<List<NoteModel>> _fetchAndCacheRemoteNotes() async {
    final raw = await _remoteDataSource.fetchNotes();
    final notes = raw.map(_remoteAdapter.fromExternal).toList();
    await _localDataSource.saveNotes(notes);
    return notes;
  }

  bool _sameNotes(List<Note> left, List<Note> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var i = 0; i < left.length; i++) {
      final a = left[i];
      final b = right[i];
      if (a.id != b.id ||
          a.title != b.title ||
          a.content != b.content ||
          a.updatedAt != b.updatedAt) {
        return false;
      }
    }

    return true;
  }
}
