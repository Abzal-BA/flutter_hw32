import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hw32/features/notes/data/adapters/note_remote_adapter.dart';

void main() {
  const adapter = NoteRemoteAdapter();

  test('maps normal remote payload into note model', () {
    final note = adapter.fromExternal(<String, dynamic>{
      'note_id': 'a1',
      'title_text': 'Architecture',
      'body_text': 'Repository + datasource',
      'updated_at': '2026-03-30T12:00:00.000Z',
    });

    expect(note.id, 'a1');
    expect(note.title, 'Architecture');
    expect(note.content, 'Repository + datasource');
    expect(note.updatedAt.toIso8601String(), '2026-03-30T12:00:00.000Z');
  });

  test('maps empty payload with safe defaults', () {
    final note = adapter.fromExternal(const <String, dynamic>{});

    expect(note.id, '');
    expect(note.title, 'Untitled');
    expect(note.content, '');
    expect(note.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('maps invalid payload types without crashing', () {
    final note = adapter.fromExternal(<String, dynamic>{
      'note_id': 77,
      'title_text': null,
      'body_text': ['wrong'],
      'updated_at': 'not-a-date',
    });

    expect(note.id, '77');
    expect(note.title, 'Untitled');
    expect(note.content, '[wrong]');
    expect(note.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
  });
}
