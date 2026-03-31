import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error_handler.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/watch_task_usecase.dart';

class TaskDetailsViewModel extends ChangeNotifier {
  TaskDetailsViewModel({
    required String taskId,
    required WatchTaskUseCase watchTaskUseCase,
    required AppErrorHandler errorHandler,
  })  : _taskId = taskId,
        _watchTaskUseCase = watchTaskUseCase,
        _errorHandler = errorHandler {
    _subscribe();
  }

  final String _taskId;
  final WatchTaskUseCase _watchTaskUseCase;
  final AppErrorHandler _errorHandler;

  StreamSubscription<Task?>? _taskSub;
  Task? _task;
  bool _isLoading = true;
  String? _errorMessage;

  Task? get task => _task;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get title => (_task?.title.trim().isNotEmpty ?? false)
      ? _task!.title
      : 'Task Details';

  void _subscribe() {
    _taskSub = _watchTaskUseCase.call(_taskId).listen(
      (task) {
        _task = task;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = 'Failed to load task: ${_errorHandler.toMessage(error)}';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _taskSub?.cancel();
    super.dispose();
  }
}
