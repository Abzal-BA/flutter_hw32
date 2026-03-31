import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error_handler.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/i_notes_repository.dart';
import '../../domain/usecases/watch_notes_usecase.dart';
import '../state/notes_state.dart';

class NotesViewModel extends ChangeNotifier {
  NotesViewModel({
    required WatchNotesUseCase watchNotesUseCase,
    required AppErrorHandler errorHandler,
  }) : _watchNotesUseCase = watchNotesUseCase,
       _errorHandler = errorHandler;

  final WatchNotesUseCase _watchNotesUseCase;
  final AppErrorHandler _errorHandler;

  NotesState _state = const NotesState();
  NotesState get state => _state;

  StreamSubscription<List<Note>>? _notesSub;

  Future<void> loadNotes({
    NotesLoadStrategy? strategy,
  }) async {
    final nextStrategy = strategy ?? _state.strategy;
    _state = _state.copyWith(
      isLoading: true,
      errorMessage: null,
      strategy: nextStrategy,
    );
    notifyListeners();

    await _notesSub?.cancel();
    _notesSub = _watchNotesUseCase
        .call(strategy: nextStrategy)
        .listen(
          (notes) {
            _state = _state.copyWith(
              items: List.unmodifiable(notes),
              isLoading: false,
              errorMessage: null,
            );
            notifyListeners();
          },
          onError: (Object error) {
            _state = _state.copyWith(
              isLoading: false,
              errorMessage: _errorHandler.toMessage(error),
            );
            notifyListeners();
          },
        );
  }

  Future<void> setStrategy(NotesLoadStrategy strategy) async {
    await loadNotes(strategy: strategy);
  }

  @override
  void dispose() {
    _notesSub?.cancel();
    super.dispose();
  }
}
