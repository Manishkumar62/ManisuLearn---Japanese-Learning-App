import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../bloc/analytics_insight.dart';
import '../../../revision/presentation/bloc/review_queue_bloc.dart';

import '../widgets/home_header.dart';
import '../widgets/primary_card.dart';
import '../widgets/modern_card.dart';
import '../widgets/today_progress_card.dart';
import '../widgets/journey_card.dart';
import '../widgets/progress_chart_card.dart';
import '../widgets/category_breakdown_card.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/streak_timer_card.dart';
import '../widgets/animated_card.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onGoToRevision;
  final VoidCallback? onGoToLearn;

  const HomePage({super.key, this.onGoToRevision, this.onGoToLearn});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChartPeriod _chartPeriod = ChartPeriod.weekly;

  @override
  void initState() {
    super.initState();
    context.read<ReviewQueueBloc>().add(const LoadDueItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<AnalyticsBloc>().add(LoadAnalytics());
            context.read<ReviewQueueBloc>().add(const LoadDueItems());
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              /// HEADER
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

              /// PRIMARY CTA
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

              /// MAIN CONTENT
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                    builder: (context, state) {
                      if (state is AnalyticsLoaded && state.data.totalItems == 0) {
                        return _EmptyState(onStart: widget.onGoToLearn);
                      }

                      if (state is AnalyticsLoaded) {
                        final data = state.data;
                        final progress = state.progress;

                        return Column(
                          children: [
                            /// STREAK TIMER
                            StreakTimerCard(
                              streakDays: data.streakDays,
                              hasActivityToday: data.hasActivityToday,
                            ),

                            const SizedBox(height: 16),

                            /// DAILY GOAL
                            AnimatedCardWrapper(
                              child: DailyGoalCard(
                                done: data.reviewedToday + data.learnedToday,
                                goal: 20,
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// TODAY'S ACTIVITY
                            AnimatedCardWrapper(
                              child: TodayProgressCard(
                                reviewedToday: data.reviewedToday,
                                learnedToday: data.learnedToday,
                                dueToday: data.dueToday,
                                learnedItems: data.learnedItems,
                                totalItems: data.totalItems,
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// OVERALL JOURNEY
                            AnimatedCardWrapper(
                              child: JourneyCard(
                                learnedItems: data.learnedItems,
                                totalItems: data.totalItems,
                                retentionRate: data.retentionRate,
                                streakDays: data.streakDays,
                                totalReviews: data.totalReviews,
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// CATEGORY BREAKDOWN
                            if (data.categories.length > 1)
                              AnimatedCardWrapper(
                                child: CategoryBreakdownCard(categories: data.categories),
                              ),

                            if (data.categories.length > 1)
                              const SizedBox(height: 16),

                            /// PROGRESS CHART
                            _PeriodToggle(
                              selected: _chartPeriod,
                              onChanged: (p) => setState(() => _chartPeriod = p),
                            ),
                            const SizedBox(height: 12),
                            ProgressChartCard(
                              reviewedData: _chartPeriod == ChartPeriod.weekly
                                  ? progress.weeklyReviewed
                                  : _chartPeriod == ChartPeriod.monthly
                                      ? progress.monthlyReviewed
                                      : progress.yearlyReviewed,
                              learnedData: _chartPeriod == ChartPeriod.weekly
                                  ? progress.weeklyLearned
                                  : _chartPeriod == ChartPeriod.monthly
                                      ? progress.monthlyLearned
                                      : progress.yearlyLearned,
                              period: _chartPeriod,
                            ),

                            /// INSIGHTS
                            if (state.insights.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _InsightsList(insights: state.insights),
                            ],
                          ],
                        );
                      }

                      if (state is AnalyticsError) {
                        return GestureDetector(
                          onTap: () {
                            context.read<AnalyticsBloc>().add(LoadAnalytics());
                          },
                          child: const ModernCard(
                            icon: Icons.error_outline,
                            title: 'Progress',
                            body: 'Failed to load analytics. Tap to retry.',
                          ),
                        );
                      }

                      return const _LoadingSkeleton();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final ChartPeriod selected;
  final ValueChanged<ChartPeriod> onChanged;

  const _PeriodToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: ChartPeriod.values.map((p) {
        final isSelected = p == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onChanged(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                p == ChartPeriod.weekly
                    ? 'Weekly'
                    : p == ChartPeriod.monthly
                        ? 'Monthly'
                        : 'Yearly',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onStart;

  const _EmptyState({this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            'はじめまして！',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nice to meet you!',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your Japanese learning journey starts here. '
            'Begin your first lesson to start tracking progress.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Your First Lesson'),
          ),
        ],
      ),
    );
  }
}

class _InsightsList extends StatelessWidget {
  final List<AnalyticsInsight> insights;

  const _InsightsList({required this.insights});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text("Insights", style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          ...insights.map((insight) => _InsightTile(insight: insight)),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final AnalyticsInsight insight;

  const _InsightTile({required this.insight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor(context);
    final icon = _getIcon();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              insight.message,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (insight.type) {
      case InsightType.success:
        return Colors.green;
      case InsightType.warning:
        return colorScheme.tertiary;
      case InsightType.danger:
        return colorScheme.error;
      case InsightType.info:
        return colorScheme.secondary;
    }
  }

  IconData _getIcon() {
    switch (insight.type) {
      case InsightType.success:
        return Icons.check_circle;
      case InsightType.warning:
        return Icons.warning;
      case InsightType.danger:
        return Icons.error;
      case InsightType.info:
        return Icons.info;
    }
  }
}

class _LoadingSkeleton extends StatefulWidget {
  const _LoadingSkeleton();

  @override
  State<_LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<_LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    final highlight = theme.colorScheme.surfaceContainerLow;

    return Column(
      children: [
        _shimmerCard(
          base,
          highlight,
          children: [
            _shimmerRow(base, highlight, [
              _ShimmerBox(24, 24, 12),
              _ShimmerBox(120, 16, 4),
            ]),
            const SizedBox(height: 20),
            Row(
              children: [
                _ShimmerBox(100, 100, 50),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _shimmerRow(base, highlight, [
                        _ShimmerBox(null, 16, 4),
                        _ShimmerBox(30, 16, 4),
                      ]),
                      const SizedBox(height: 12),
                      _shimmerRow(base, highlight, [
                        _ShimmerBox(null, 16, 4),
                        _ShimmerBox(30, 16, 4),
                      ]),
                      const SizedBox(height: 12),
                      _shimmerRow(base, highlight, [
                        _ShimmerBox(null, 16, 4),
                        _ShimmerBox(30, 16, 4),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _shimmerCard(
          base,
          highlight,
          children: [
            _shimmerRow(base, highlight, [
              _ShimmerBox(24, 24, 12),
              _ShimmerBox(120, 16, 4),
            ]),
            const SizedBox(height: 16),
            _ShimmerBox(null, 8, 8),
            const SizedBox(height: 16),
            Row(
              children: [
                _ShimmerBox(80, 28, 8),
                const SizedBox(width: 8),
                _ShimmerBox(90, 28, 8),
                const SizedBox(width: 8),
                _ShimmerBox(80, 28, 8),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _shimmerCard(Color base, Color _, {required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _shimmerRow(Color base, Color _, List<Widget> children) {
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          children[i],
        ],
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _ShimmerBox(this.width, this.height, this.radius);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
