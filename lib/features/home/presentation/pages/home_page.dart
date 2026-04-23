import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_state.dart';
import '../../../revision/presentation/bloc/review_queue_bloc.dart';

import '../widgets/home_header.dart';
import '../widgets/primary_card.dart';
import '../widgets/modern_card.dart';
import '../widgets/analytics_card.dart';
import '../widgets/progress_bar_card.dart';
import '../widgets/animated_card.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onGoToRevision; // ✅ NEW
  final VoidCallback? onGoToLearn; // ✅ NEW

  const HomePage({super.key, this.onGoToRevision, this.onGoToLearn});
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
            SliverToBoxAdapter(
              child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                builder: (context, state) {
                  if (state is AnalyticsLoaded) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: HomeHeader(streakDays: state.data.streakDays),
                    );
                  }

                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: HomeHeader(streakDays: 0),
                  );
                },
              ),
            ),

            /// 🔥 PRIMARY CTA
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<ReviewQueueBloc, ReviewQueueState>(
                  builder: (context, state) {
                    int due = 0;

                    if (state is DueItemsLoaded) {
                      due = state.dueCount;
                    }

                    final isReview = due > 0;

                    return AnimatedCardWrapper(
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          splashColor: Colors.white.withValues(alpha: 0.2),
                          highlightColor: Colors.white.withValues(alpha: 0.1),
                          onTap: () {
                            if (isReview) {
                              widget.onGoToRevision?.call();
                            } else {
                              widget.onGoToLearn?.call();
                            }
                          },
                          child: PrimaryCard(
                            title: isReview ? "Review Now" : "Start Learning",
                            subtitle: isReview
                                ? "$due items waiting"
                                : "No pending reviews",
                            icon: isReview ? Icons.refresh : Icons.play_arrow,
                          ),
                        ),
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

                    // /// 📚 LIBRARY + LEARN
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: AnimatedCardWrapper(
                    //         child: ModernCard(
                    //           icon: Icons.library_books_outlined,
                    //           title: "Library",
                    //           body: "Browse all content",
                    //           onTap: () {
                    //             // TODO: Navigate
                    //           },
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 12),
                    //     Expanded(
                    //       child: AnimatedCardWrapper(
                    //         child: ModernCard(
                    //           icon: Icons.school_outlined,
                    //           title: "Learn",
                    //           body: "Practice new items",
                    //           onTap: () {
                    //             // TODO: Navigate
                    //           },
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    // const SizedBox(height: 16),

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
                              insights: state.insights,
                              weeklyProgress: state.weeklyProgress,
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
}
