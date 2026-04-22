import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manisulearn/features/home/presentation/bloc/analytics_bloc.dart';
import 'package:manisulearn/features/home/presentation/bloc/analytics_state.dart';

import '../../../revision/presentation/bloc/review_queue_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewQueueBloc>().add(const LoadDueItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Manisu Learn',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text('Build your Japanese memory one card at a time.'),
          const SizedBox(height: 20),
          const _HomeCard(
            icon: Icons.library_books_outlined,
            title: 'Library',
            body: 'Browse every word, sentence, and story.',
          ),
          const SizedBox(height: 12),
          const _HomeCard(
            icon: Icons.school_outlined,
            title: 'Learn',
            body: 'Practice new items that are not learned yet.',
          ),
          const SizedBox(height: 12),
          BlocBuilder<ReviewQueueBloc, ReviewQueueState>(
            builder: (BuildContext context, ReviewQueueState state) {
              return _HomeCard(
                icon: Icons.refresh_outlined,
                title: 'Revision',
                body: _reviewQueueMessage(state),
              );
            },
          ),
          const SizedBox(height: 12),

          BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, state) {
              if (state is AnalyticsLoaded) {
                final data = state.data;

                return _HomeCard(
                  icon: Icons.insights_outlined,
                  title: 'Progress',
                  body:
                      'Learned: ${data.learnedItems}/${data.totalItems} • '
                      'Due: ${data.dueToday} • '
                      'Retention: ${data.retentionRate.toStringAsFixed(1)}%',
                );
              }

              if (state is AnalyticsError) {
                return const _HomeCard(
                  icon: Icons.error_outline,
                  title: 'Progress',
                  body: 'Could not load progress data.',
                );
              }

              return const _HomeCard(
                icon: Icons.insights_outlined,
                title: 'Progress',
                body: 'Calculating your learning progress...',
              );
            },
          ),
        ],
      ),
    );
  }

  String _reviewQueueMessage(ReviewQueueState state) {
    return switch (state) {
      ReviewQueueLoading() => 'Checking today\'s review queue.',
      DueItemsLoaded(:final dueCount) =>
        dueCount == 1
            ? 'You have 1 item to review today.'
            : 'You have $dueCount items to review today.',
      ReviewQueueError() => 'Could not load today\'s review count.',
      ReviewQueueState() => 'Review learned items by priority.',
    };
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
