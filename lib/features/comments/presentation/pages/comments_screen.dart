import 'package:flutter/material.dart';

import '../../../../di/service_locator.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../../core/error/app_error_handler.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/watch_comments_usecase.dart';
import '../controller/comments_controller.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({required this.taskId, super.key});

  final String taskId;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late final CommentsController _commentsController;
  final _textController = TextEditingController();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _commentsController = CommentsController(
      taskId: widget.taskId,
      watchCommentsUseCase: getIt<WatchCommentsUseCase>(),
      addCommentUseCase: getIt<AddCommentUseCase>(),
      deleteCommentUseCase: getIt<DeleteCommentUseCase>(),
      authRepository: getIt<IAuthRepository>(),
      errorHandler: getIt<AppErrorHandler>(),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    setState(() => _isPosting = true);
    final success =
        await _commentsController.addComment(_textController.text);
    if (!mounted) return;
    setState(() => _isPosting = false);
    if (success) {
      _textController.clear();
    }
  }

  String _formatDate(DateTime date) {
    final twoDigitsMonth = date.month.toString().padLeft(2, '0');
    final twoDigitsDay = date.day.toString().padLeft(2, '0');
    final twoDigitsHour = date.hour.toString().padLeft(2, '0');
    final twoDigitsMinute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$twoDigitsMonth-$twoDigitsDay $twoDigitsHour:$twoDigitsMinute';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _commentsController,
      builder: (context, _) {
        final state = _commentsController.state;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Comments (${state.items.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(
                        color: Colors.red.shade700, fontSize: 12),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isPosting ? null : _submitComment,
                  icon: _isPosting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  tooltip: 'Send comment',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No comments yet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final comment = state.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(comment.userName),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(comment.text),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(comment.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall,
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () => _commentsController
                              .deleteComment(comment.id),
                          icon:
                              const Icon(Icons.delete_outline),
                          tooltip: 'Delete comment',
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
