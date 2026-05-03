import '../../domain/task.dart';

class TasksState {
  const TasksState({
    this.items = const <Task>[],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  static const Object _unset = Object();

  final List<Task> items;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  TasksState copyWith({
    List<Task>? items,
    bool? isLoading,
    bool? isSaving,
    Object? errorMessage = _unset,
  }) {
    return TasksState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
