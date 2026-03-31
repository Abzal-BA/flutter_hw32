import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hw32/features/notes/data/adapters/note_remote_adapter.dart';
import 'package:flutter_hw32/features/notes/data/datasources/note_local_datasource.dart';
import 'package:flutter_hw32/features/notes/data/datasources/note_remote_datasource.dart';
import 'package:flutter_hw32/features/notes/data/models/note_model.dart';
import 'package:flutter_hw32/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:flutter_hw32/features/notes/domain/repositories/i_notes_repository.dart';

void main() {
  test('cacheFirst emits local notes first then refreshed remote notes', () async {
    final local = _FakeLocalDataSource([
      NoteModel(
        id: 'cached-1',
        title: 'Cached note',
        content: 'From local storage',
        updatedAt: DateTime.parse('2026-03-29T10:00:00.000Z'),
      ),
    ]);
    final remote = _FakeRemoteDataSource([
      <String, dynamic>{
        'note_id': 'remote-1',
        'title_text': 'Remote note',
        'body_text': 'Fresh from server',
        'updated_at': '2026-03-30T10:00:00.000Z',
      },
    ]);

    final repository = NotesRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      remoteAdapter: const NoteRemoteAdapter(),
    );

    final emissions = await repository
        .watchNotes(strategy: NotesLoadStrategy.cacheFirst)
        .toList();

    expect(emissions, hasLength(2));
    expect(emissions.first.single.id, 'cached-1');
    expect(emissions.last.single.id, 'remote-1');
    expect(local.saved.single.id, 'remote-1');
  });

  test('localOnly reads only local cache', () async {
    final local = _FakeLocalDataSource([
      NoteModel(
        id: 'cached-2',
        title: 'Offline note',
        content: 'No server call',
        updatedAt: DateTime.parse('2026-03-29T11:00:00.000Z'),
      ),
    ]);
    final remote = _FakeRemoteDataSource([
      <String, dynamic>{'note_id': 'remote-ignored'},
    ]);

    final repository = NotesRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      remoteAdapter: const NoteRemoteAdapter(),
    );

    final emissions = await repository
        .watchNotes(strategy: NotesLoadStrategy.localOnly)
        .toList();

    expect(emissions, hasLength(1));
    expect(emissions.single.single.id, 'cached-2');
    expect(remote.calls, 0);
  });

  test('remoteOnly fetches from remote and refreshes cache', () async {
    final local = _FakeLocalDataSource(const <NoteModel>[]);
    final remote = _FakeRemoteDataSource([
      <String, dynamic>{
        'note_id': 'remote-2',
        'title_text': 'Server note',
        'body_text': 'Remote only strategy',
        'updated_at': '2026-03-30T12:30:00.000Z',
      },
    ]);

    final repository = NotesRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      remoteAdapter: const NoteRemoteAdapter(),
    );

    final emissions = await repository
        .watchNotes(strategy: NotesLoadStrategy.remoteOnly)
        .toList();

    expect(emissions, hasLength(1));
    expect(emissions.single.single.id, 'remote-2');
    expect(local.saved.single.id, 'remote-2');
    expect(remote.calls, 1);
  });
}

class _FakeLocalDataSource implements INoteLocalDataSource {
  _FakeLocalDataSource(this._items);

  final List<NoteModel> _items;
  List<NoteModel> saved = const <NoteModel>[];

  @override
  Future<List<NoteModel>> getCachedNotes() async => List<NoteModel>.from(_items);

  @override
  Future<void> saveNotes(List<NoteModel> notes) async {
    saved = List<NoteModel>.from(notes);
  }
}

class _FakeRemoteDataSource implements INoteRemoteDataSource {
  _FakeRemoteDataSource(this._rawItems);

  final List<Map<String, dynamic>> _rawItems;
  int calls = 0;

  @override
  Future<List<Map<String, dynamic>>> fetchNotes() async {
    calls++;
    return List<Map<String, dynamic>>.from(_rawItems);
  }
}
