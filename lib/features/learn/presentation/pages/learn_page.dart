import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/learn_bloc.dart';
import '../bloc/learn_event.dart';
import '../bloc/learn_state.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key, this.onGoToLibrary});

  final VoidCallback? onGoToLibrary;

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
      appBar: AppBar(
        title: const Text('Learn'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: BlocBuilder<LearnBloc, LearnState>(
          builder: (BuildContext context, LearnState state) {
            return switch (state) {
              LearnInitial() || LearnLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              LearnLoaded() => _LearnFlashcard(state: state),
              LearnCompleted() => _LearnCompletedView(
                onGoToLibrary: widget.onGoToLibrary,
              ),
              LearnError(:final message) => _LearnErrorView(message: message),
              LearnState() => const _LearnCompletedView(),
            };
          },
        ),
      ),
    );
  }
}

class _LearnFlashcard extends StatefulWidget {
  const _LearnFlashcard({required this.state});

  final LearnLoaded state;

  @override
  State<_LearnFlashcard> createState() => _LearnFlashcardState();
}

class _LearnFlashcardState extends State<_LearnFlashcard> {
  double drag = 0;

  @override
  Widget build(BuildContext context) {
    final item = widget.state.currentItem;
    if (item == null) return const Center(child: Text('No items'));

    final isRevealed = widget.state.isAnswerVisible;

    Color overlayColor = Colors.transparent;
    if (drag > 40) {
      overlayColor = Colors.green.withValues(alpha: 0.15);
    } else if (drag < -40) {
      overlayColor = Colors.orange.withValues(alpha: 0.15);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress
          Text(
            '${widget.state.completedCount + 1} of ${widget.state.totalCount}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: (widget.state.completedCount + 1) / widget.state.totalCount,
            ),
            duration: const Duration(milliseconds: 260),
            builder: (context, value, _) {
              return LinearProgressIndicator(value: value);
            },
          ),
          const SizedBox(height: 16),

          // Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isRevealed) {
                  context.read<LearnBloc>().add(const RevealLearningAnswer());
                }
              },
              onHorizontalDragUpdate: (details) {
                if (!isRevealed) return;
                setState(() => drag += details.delta.dx * 0.9);
              },
              onHorizontalDragEnd: (_) {
                if (!isRevealed) return;

                if (drag > 120) {
                  context.read<LearnBloc>().add(const MarkLearned());
                } else if (drag < -120) {
                  context.read<LearnBloc>().add(const SkipLearningItem());
                }

                setState(() => drag = 0);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()
                  ..translate(drag)
                  ..rotateZ(drag * 0.0008),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: isRevealed
                      ? Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.4),
                          width: 1.2,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Swipe color overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: overlayColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    // Drag hint: "Learned"
                    if (drag > 40)
                      const Positioned(
                        left: 20,
                        top: 20,
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'Learned',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Drag hint: "Skip"
                    if (drag < -40)
                      const Positioned(
                        right: 20,
                        top: 20,
                        child: Row(
                          children: [
                            Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.skip_next, color: Colors.orange, size: 18),
                          ],
                        ),
                      ),

                    // Card content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          key: ValueKey(isRevealed),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(),

                            // Type badge
                            Align(
                              alignment: Alignment.center,
                              child: _TypeBadge(type: item.type),
                            ),
                            const SizedBox(height: 24),

                            Text(
                              item.japanese,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.romaji,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const Spacer(),

                            if (isRevealed) ...[
                              const Divider(height: 40),
                              Text(
                                item.english,
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              if (item.hindi.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  item.hindi,
                                  style: Theme.of(context).textTheme.headlineLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const SizedBox(height: 12),
                              AnimatedOpacity(
                                opacity: 1,
                                duration: const Duration(milliseconds: 250),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_left,
                                          color: Colors.orangeAccent,
                                          size: 16,
                                        ),
                                        Text(
                                          'Skip',
                                          style: TextStyle(
                                            color: Colors.orangeAccent,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Learned',
                                          style: TextStyle(
                                            color: Colors.greenAccent,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_right,
                                          color: Colors.greenAccent,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              const Text(
                                'Tap to reveal',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],

                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(type),
      ),
    );
  }
}

class _LearnCompletedView extends StatelessWidget {
  const _LearnCompletedView({this.onGoToLibrary});

  final VoidCallback? onGoToLibrary;

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
              onPressed: () {
                onGoToLibrary?.call();
              },
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
