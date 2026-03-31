import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_model.dart';

abstract class INoteLocalDataSource {
  Future<List<NoteModel>> getCachedNotes();
  Future<void> saveNotes(List<NoteModel> notes);
}

class NoteLocalDataSource implements INoteLocalDataSource {
  const NoteLocalDataSource(this._preferences);

  static const String _cacheKey = 'notes_cache_v1';

  final SharedPreferences _preferences;

  @override
  Future<List<NoteModel>> getCachedNotes() async {
    final raw = _preferences.getString(_cacheKey);
    if (raw == null || raw.isEmpty) {
      return const <NoteModel>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <NoteModel>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => NoteModel.fromCacheMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return const <NoteModel>[];
    }
  }

  @override
  Future<void> saveNotes(List<NoteModel> notes) async {
    final raw = jsonEncode(notes.map((note) => note.toCacheMap()).toList());
    await _preferences.setString(_cacheKey, raw);
  }
}
