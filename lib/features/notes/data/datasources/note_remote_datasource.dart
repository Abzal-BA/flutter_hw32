abstract class INoteRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchNotes();
}

class NoteRemoteDataSource implements INoteRemoteDataSource {
  const NoteRemoteDataSource();

  @override
  Future<List<Map<String, dynamic>>> fetchNotes() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    return <Map<String, dynamic>>[
      <String, dynamic>{
        'note_id': 'n1',
        'title_text': 'Cached architecture',
        'body_text': 'Repository coordinates local cache and remote refresh.',
        'updated_at': '2026-03-30T09:00:00.000Z',
      },
      <String, dynamic>{
        'note_id': 'n2',
        'title_text': 'Adapter layer',
        'body_text': 'External fields are normalized before domain usage.',
        'updated_at': '2026-03-30T10:15:00.000Z',
      },
      <String, dynamic>{
        'note_id': 'n3',
        'title_text': 'Strategy switch',
        'body_text': 'Choose cacheFirst, remoteOnly, or localOnly.',
        'updated_at': '2026-03-30T11:45:00.000Z',
      },
    ];
  }
}
