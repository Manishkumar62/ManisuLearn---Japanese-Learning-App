import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_state.dart';
import '../../../revision/presentation/bloc/review_queue_bloc.dart';

import '../widgets/home_header.dart';
import '../widgets/primary_card.dart';
import '../widgets/modern_card.dart';
import '../widgets/analytics_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/progress_bar_card.dart';
import '../widgets/animated_card.dart';

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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            /// 🔹 HEADER
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: HomeHeader(),
              ),
            ),

            /// 🔥 PRIMARY CTA
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<ReviewQueueBloc, ReviewQueueState>(
                  builder: (context, state) {
                    final dueText = _reviewQueueMessage(state);

                    return AnimatedCardWrapper(
                      onTap: () {
                        // TODO: Navigate to review screen
                      },
                      child: PrimaryCard(
                        title: "Continue Learning",
                        subtitle: dueText,
                        icon: Icons.play_arrow,
                      ),
                    );
                  },
                ),
              ),
            ),

            /// 🔹 MAIN CONTENT
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// 🔥 STREAK
                    const AnimatedCardWrapper(
                      child: StreakCard(
                        streakDays: 7, // TODO: connect real data
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 📊 PROGRESS BAR
                    BlocBuilder<AnalyticsBloc, AnalyticsState>(
                      builder: (context, state) {
                        if (state is AnalyticsLoaded) {
                          return AnimatedCardWrapper(
                            child: ProgressBarCard(
                              learned: state.data.learnedItems,
                              total: state.data.totalItems,
                            ),
                          );
                        }

                        return const SizedBox();
                      },
                    ),

                    const SizedBox(height: 16),

                    /// 📚 LIBRARY + LEARN
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedCardWrapper(
                            child: ModernCard(
                              icon: Icons.library_books_outlined,
                              title: "Library",
                              body: "Browse all content",
                              onTap: () {
                                // TODO: Navigate
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnimatedCardWrapper(
                            child: ModernCard(
                              icon: Icons.school_outlined,
                              title: "Learn",
                              body: "Practice new items",
                              onTap: () {
                                // TODO: Navigate
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// 📊 ANALYTICS
                    BlocBuilder<AnalyticsBloc, AnalyticsState>(
                      builder: (context, state) {
                        if (state is AnalyticsLoaded) {
                          final data = state.data;

                          return AnimatedCardWrapper(
                            child: AnalyticsCard(
                              learned: data.learnedItems,
                              total: data.totalItems,
                              due: data.dueToday,
                              retention: data.retentionRate,
                            ),
                          );
                        }

                        if (state is AnalyticsError) {
                          return const ModernCard(
                            icon: Icons.error_outline,
                            title: "Progress",
                            body: "Failed to load analytics",
                          );
                        }

                        return const ModernCard(
                          icon: Icons.insights_outlined,
                          title: "Progress",
                          body: "Loading analytics...",
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _reviewQueueMessage(ReviewQueueState state) {
    return switch (state) {
      ReviewQueueLoading() => 'Checking today\'s review queue...',
      DueItemsLoaded(:final dueCount) =>
        dueCount == 0
            ? 'You are all caught up 🎉'
            : dueCount == 1
                ? 'You have 1 item to review'
                : 'You have $dueCount items to review',
      ReviewQueueError() => 'Could not load review data',
      _ => 'Review your learned items',
    };
  }
}