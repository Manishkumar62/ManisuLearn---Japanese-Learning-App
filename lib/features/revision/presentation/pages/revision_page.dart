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
      appBar: AppBar(
        title: const Text('Revision'),
        automaticallyImplyLeading: false,

        /// ⭐ LEFT → Due
        leading: IconButton(
          icon: const Icon(Icons.auto_awesome),
          tooltip: 'Due Items',
          onPressed: () {
            context.read<RevisionBloc>().add(const LoadRevisionItems());
          },
        ),

        /// 🌍 RIGHT → Explore
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            tooltip: 'Explore',
            onPressed: () {
              context.read<RevisionBloc>().add(const LoadAllLearnedItems());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<RevisionBloc, RevisionState>(
          builder: (context, state) {
            return switch (state) {
              RevisionInitial() || RevisionLoading() => const Center(
                child: CircularProgressIndicator(),
              ),

              RevisionLoaded() => Column(
                children: [
                  if (state.isExploreMode) _ExploreFilters(),
                  Expanded(child: _RevisionFlashcard(state: state)),
                ],
              ),

              RevisionCompleted() => const _RevisionCompleteMessage(),

              RevisionError(:final message) => _RevisionErrorMessage(
                message: message,
              ),

              _ => const SizedBox(),
            };
          },
        ),
      ),
    );
  }
}

class _RevisionFlashcard extends StatefulWidget {
  const _RevisionFlashcard({required this.state});

  final RevisionLoaded state;

  @override
  State<_RevisionFlashcard> createState() => _RevisionFlashcardState();
}

class _RevisionFlashcardState extends State<_RevisionFlashcard> {
  double drag = 0;

  @override
  Widget build(BuildContext context) {
    final item = widget.state.currentItem;
    if (item == null) return const Center(child: Text('No items'));

    final isRevealed = widget.state.isAnswerVisible;

    final daysAgo = item.firstLearnedAt == null
        ? 0
        : DateTime.now().difference(item.firstLearnedAt!).inDays;

    Color overlayColor = Colors.transparent;

    if (drag > 40) {
      overlayColor = Colors.green.withValues(alpha: 0.15);
    } else if (drag < -40) {
      overlayColor = Colors.red.withValues(alpha: 0.15);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// PROGRESS
          Text(
            '${widget.state.completedCount + 1} of ${widget.state.totalCount}',
          ),
          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: (widget.state.completedCount + 1) / widget.state.totalCount,
          ),

          const SizedBox(height: 16),

          /// 🔥 CARD
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isRevealed) {
                  context.read<RevisionBloc>().add(
                    const RevealRevisionAnswer(),
                  );
                }
              },

              onHorizontalDragUpdate: (details) {
                if (!isRevealed) return; // 🚫 block swipe
                setState(() => drag += details.delta.dx * 0.9);
              },

              onHorizontalDragEnd: (_) {
                if (!isRevealed) return; // 🚫 block swipe

                if (drag > 120) {
                  context.read<RevisionBloc>().add(
                    const ReviewItem(isCorrect: true),
                  );
                } else if (drag < -120) {
                  context.read<RevisionBloc>().add(
                    const ReviewItem(isCorrect: false),
                  );
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
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.4),
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
                    /// swipe color
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: overlayColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    /// skip icon
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          context.read<RevisionBloc>().add(
                            const SkipRevisionItem(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ),

                    /// drag hint
                    if (drag > 40)
                      const Positioned(
                        left: 20,
                        top: 20,
                        child: Text(
                          "✔ Correct",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    if (drag < -40)
                      const Positioned(
                        right: 20,
                        top: 20,
                        child: Text(
                          "✖ Wrong",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          key: ValueKey(isRevealed),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(),

                            Text(
                              item.japanese,
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 12),

                            Text(
                              item.romaji,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 25,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              '${item.repetitions} reviews • $daysAgo days ago',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),

                            const Spacer(),

                            if (isRevealed) ...[
                              const Divider(height: 30),
                              Text(item.english, textAlign: TextAlign.center),
                              const SizedBox(height: 6),
                              Text(
                                item.hindi,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 35),
                              ),
                            ] else ...[
                              const Text(
                                'Tap to reveal',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],

                            if (isRevealed) ...[
                              const SizedBox(height: 12),
                              AnimatedOpacity(
                                opacity: 1,
                                duration: const Duration(milliseconds: 250),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_left,
                                          color: Colors.redAccent,
                                          size: 16,
                                        ),
                                        Text(
                                          "Wrong",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Correct",
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
        ],
      ),
    );
  }
}

class _ExploreFilters extends StatefulWidget {
  @override
  State<_ExploreFilters> createState() => _ExploreFiltersState();
}

class _ExploreFiltersState extends State<_ExploreFilters> {
  double days = 0;
  double revisions = 0;

  void _apply() {
    context.read<RevisionBloc>().add(
      ApplyRevisionFilter(
        minDaysAgo: days.toInt(),
        maxRepetitions: revisions.toInt(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Text("D", style: TextStyle(fontSize: 12)),

          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              ),
              child: Slider(
                value: days,
                min: 0,
                max: 30,
                divisions: 6,
                onChanged: (v) {
                  setState(() => days = v);
                  _apply();
                },
              ),
            ),
          ),

          Text("${days.toInt()}+", style: const TextStyle(fontSize: 11)),

          const SizedBox(width: 6),

          const Text("R", style: TextStyle(fontSize: 12)),

          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              ),
              child: Slider(
                value: revisions,
                min: 0,
                max: 10,
                divisions: 5,
                onChanged: (v) {
                  setState(() => revisions = v);
                  _apply();
                },
              ),
            ),
          ),

          Text("≤${revisions.toInt()}", style: const TextStyle(fontSize: 11)),

          const SizedBox(width: 4),

          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              setState(() {
                days = 0;
                revisions = 0;
              });

              context.read<RevisionBloc>().add(const LoadAllLearnedItems());
            },
            child: const Text("Reset", style: TextStyle(fontSize: 11)),
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
        child: Text('No revision items right now.'),
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
          children: [
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
