import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/revision_bloc.dart';
import '../bloc/revision_event.dart';
import '../bloc/revision_state.dart';

class RevisionPage extends StatefulWidget {
  const RevisionPage({super.key});

  @override
  State<RevisionPage> createState() => _RevisionPageState();
}

class _RevisionPageState extends State<RevisionPage> {
  @override
  void initState() {
    super.initState();
    context.read<RevisionBloc>().add(const LoadRevisionItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revision')),
      body: SafeArea(
        child: BlocBuilder<RevisionBloc, RevisionState>(
          builder: (BuildContext context, RevisionState state) {
            return switch (state) {
              RevisionInitial() || RevisionLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              RevisionLoaded() => _RevisionFlashcard(state: state),
              RevisionCompleted() => const _RevisionCompleteMessage(),
              RevisionError(:final message) => _RevisionErrorMessage(
                message: message,
              ),
              RevisionState() => const _RevisionCompleteMessage(),
            };
          },
        ),
      ),
    );
  }
}

class _RevisionFlashcard extends StatelessWidget {
  const _RevisionFlashcard({required this.state});

  final RevisionLoaded state;

  @override
  Widget build(BuildContext context) {
    final item = state.currentItem;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '${state.completedCount + 1} of ${state.totalCount}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: (state.completedCount + 1) / state.totalCount,
            ),
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
                      children: <Widget>[
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
                          const SizedBox(height: 8),
                          Text(item.hindi, textAlign: TextAlign.center),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              context.read<RevisionBloc>().add(
                state.isAnswerVisible
                    ? const ReviseItem()
                    : const RevealRevisionAnswer(),
              );
            },
            child: Text(state.isAnswerVisible ? 'Reviewed' : 'Reveal answer'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              context.read<RevisionBloc>().add(const SkipRevisionItem());
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}

class _RevisionCompleteMessage extends StatelessWidget {
  const _RevisionCompleteMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No revision items right now.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _RevisionErrorMessage extends StatelessWidget {
  const _RevisionErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.read<RevisionBloc>().add(const LoadRevisionItems());
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
