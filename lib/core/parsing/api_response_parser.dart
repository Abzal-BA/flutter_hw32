import '../../features/comments/data/models/comment_model.dart';
import '../../features/notifications/notification_payload.dart';
import '../../features/tasks/data/models/task_model.dart';

enum ApiResponseType { task, comment, notificationPayload }

class ApiResponseContext {
  const ApiResponseContext({required this.data, this.id, this.source});

  final Map<String, dynamic> data;
  final String? id;
  final String? source;
}

abstract class ApiResponseParser<T> {
  T parse(ApiResponseContext context);
}

class ApiResponseParserFactory {
  const ApiResponseParserFactory._();

  static ApiResponseParser<T> create<T>(ApiResponseType type) {
    switch (type) {
      case ApiResponseType.task:
        return _TaskResponseParser() as ApiResponseParser<T>;
      case ApiResponseType.comment:
        return _CommentResponseParser() as ApiResponseParser<T>;
      case ApiResponseType.notificationPayload:
        return _NotificationPayloadResponseParser() as ApiResponseParser<T>;
    }
  }
}

class _TaskResponseParser implements ApiResponseParser<TaskModel> {
  @override
  TaskModel parse(ApiResponseContext context) {
    return TaskModel.fromMap(context.data, id: context.id ?? '');
  }
}

class _CommentResponseParser implements ApiResponseParser<CommentModel> {
  @override
  CommentModel parse(ApiResponseContext context) {
    return CommentModel.fromMap(context.data, id: context.id ?? '');
  }
}

class _NotificationPayloadResponseParser
    implements ApiResponseParser<NotificationPayload> {
  @override
  NotificationPayload parse(ApiResponseContext context) {
    return NotificationPayload.fromMap(
      context.data,
      fallbackSource: context.source ?? 'local',
    );
  }
}
