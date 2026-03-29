import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/error_handler.dart';
import '../di/service_locator.dart';
import 'comments_controller.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({required this.taskId, super.key});

  final String taskId;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late final CommentsController _commentsController;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentsController = CommentsController(
      taskId: widget.taskId,
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
      errorHandler: getIt<AppErrorHandler>(),
    );
    _commentsController.startListening();
  }

  @override
  void dispose() {
    _textController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    await _commentsController.addComment(_textController.text);
    if (mounted && _commentsController.state.errorMessage == null) {
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
              'Comments (${state.comments.length})',
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
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
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
                  onPressed: state.isPosting ? null : _submitComment,
                  icon: state.isPosting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  tooltip: 'Send comment',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.comments.isEmpty)
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
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    final comment = state.comments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(comment.userName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(comment.text),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(comment.createdAt),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () =>
                              _commentsController.deleteComment(comment.id),
                          icon: const Icon(Icons.delete_outline),
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
