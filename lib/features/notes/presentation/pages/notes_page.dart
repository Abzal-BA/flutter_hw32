import 'package:flutter/material.dart';

import '../../../../di/service_locator.dart';
import '../../domain/repositories/i_notes_repository.dart';
import '../viewmodel/notes_view_model.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late final NotesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<NotesViewModel>();
    _viewModel.loadNotes();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final state = _viewModel.state;

        return Scaffold(
          appBar: AppBar(title: const Text('Notes Repository Demo')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<NotesLoadStrategy>(
                  segments: const [
                    ButtonSegment(
                      value: NotesLoadStrategy.cacheFirst,
                      label: Text('Cache first'),
                    ),
                    ButtonSegment(
                      value: NotesLoadStrategy.localOnly,
                      label: Text('Local only'),
                    ),
                    ButtonSegment(
                      value: NotesLoadStrategy.remoteOnly,
                      label: Text('Remote only'),
                    ),
                  ],
                  selected: <NotesLoadStrategy>{state.strategy},
                  onSelectionChanged: (selection) {
                    _viewModel.setStrategy(selection.first);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Cache strategy: ${state.strategy.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (state.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.errorMessage != null)
                  Expanded(
                    child: Center(
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (state.items.isEmpty)
                  const Expanded(
                    child: Center(child: Text('No notes in cache or server.')),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final note = state.items[index];
                        return Card(
                          child: ListTile(
                            title: Text(note.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(note.content),
                                const SizedBox(height: 8),
                                Text(
                                  'Updated: ${note.updatedAt.toIso8601String()}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
