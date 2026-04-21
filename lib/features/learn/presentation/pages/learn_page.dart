import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/learn_bloc.dart';
import '../bloc/learn_event.dart';
import '../bloc/learn_state.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  @override
  void initState() {
    super.initState();
    context.read<LearnBloc>().add(const LoadLearningItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: SafeArea(
        child: BlocBuilder<LearnBloc, LearnState>(
          builder: (BuildContext context, LearnState state) {
            return switch (state) {
              LearnInitial() || LearnLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              LearnLoaded() => _FlashcardView(state: state),
              LearnCompleted() => const _LearnCompletedView(),
              LearnError(:final message) => _LearnErrorView(message: message),
              LearnState() => const _LearnCompletedView(),
            };
          },
        ),
      ),
    );
  }
}

class _FlashcardView extends StatelessWidget {
  const _FlashcardView({required this.state});

  final LearnLoaded state;

  @override
  Widget build(BuildContext context) {
    final item = state.currentItem;
    final progress = state.completedCount + 1;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '$progress of ${state.totalCount}',
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress / state.totalCount),
            duration: const Duration(milliseconds: 260),
            builder: (BuildContext context, double value, Widget? child) {
              return LinearProgressIndicator(value: value);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: SingleChildScrollView(
                    key: ValueKey<String>(
                      '${item.id}-${state.isAnswerVisible}',
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _TypeBadge(type: item.type),
                        const SizedBox(height: 24),
                        Text(
                          item.japanese,
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.romaji,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        if (state.isAnswerVisible) ...<Widget>[
                          const Divider(height: 40),
                          Text(
                            item.english,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          if (item.hindi.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 12),
                            Text(
                              item.hindi,
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!state.isAnswerVisible)
            FilledButton(
              onPressed: () {
                context.read<LearnBloc>().add(const RevealLearningAnswer());
              },
              child: const Text('Reveal translation'),
            )
          else
            FilledButton(
              onPressed: () {
                context.read<LearnBloc>().add(const MarkLearned());
              },
              child: const Text('Mark as learned'),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              context.read<LearnBloc>().add(const SkipLearningItem());
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(type),
        ),
      ),
    );
  }
}

class _LearnCompletedView extends StatelessWidget {
  const _LearnCompletedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.check_circle_outline, size: 48),
            const SizedBox(height: 12),
            Text(
              'All caught up.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'No new learning items right now.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to library'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnErrorView extends StatelessWidget {
  const _LearnErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.read<LearnBloc>().add(const LoadLearningItems());
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
