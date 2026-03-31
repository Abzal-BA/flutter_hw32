import '../../domain/entities/note.dart';
import '../../domain/repositories/i_notes_repository.dart';

class NotesState {
  const NotesState({
    this.items = const <Note>[],
    this.isLoading = true,
    this.errorMessage,
    this.strategy = NotesLoadStrategy.cacheFirst,
  });

  final List<Note> items;
  final bool isLoading;
  final String? errorMessage;
  final NotesLoadStrategy strategy;

  NotesState copyWith({
    List<Note>? items,
    bool? isLoading,
    Object? errorMessage = _unset,
    NotesLoadStrategy? strategy,
  }) {
    return NotesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      strategy: strategy ?? this.strategy,
    );
  }

  static const Object _unset = Object();
}
