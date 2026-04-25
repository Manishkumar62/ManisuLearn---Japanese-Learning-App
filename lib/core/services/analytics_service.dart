import '../../data/models/learning_item.dart';
import '../../domain/models/analytics_data.dart';
import '../../features/home/presentation/bloc/analytics_insight.dart';

class AnalyticsService {
  int _calculateStreak(List<LearningItem> items) {
    final reviewDates = items
        .where((e) => e.isLearned && e.lastReviewed != null)
        .map((e) {
          final d = e.lastReviewed!;
          return DateTime(d.year, d.month, d.day);
        })
        .toSet()
        .toList();

    if (reviewDates.isEmpty) return 0;

    reviewDates.sort((a, b) => b.compareTo(a));

    int streak = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < reviewDates.length; i++) {
      final diff = todayDate.difference(reviewDates[i]).inDays;
      if (diff == i) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  AnalyticsData compute(List<LearningItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final totalItems = items.length;
    final learnedItems = items.where((e) => e.isLearned).length;
    final dueToday = items
        .where((e) => e.isLearned && e.nextReview.isBefore(now))
        .length;

    final learned = items.where((e) => e.isLearned).toList();
    final totalReviews = learned.fold<int>(0, (sum, e) => sum + e.repetitions);
    final strongReviews = learned
        .where((e) => e.repetitions >= 3)
        .length;

    final double retentionRate = learned.isEmpty
        ? 0
        : (strongReviews / learned.length) * 100;

    final List<AnalyticsInsight> insights = [];

    final weakItems = items
        .where((e) => e.isLearned && e.repetitions <= 2)
        .length;

    if (weakItems >= 5) {
      insights.add(AnalyticsInsight(
        message: 'You have $weakItems weak items. Revise them.',
        type: InsightType.warning,
      ));
    }

    if (dueToday >= 10) {
      insights.add(AnalyticsInsight(
        message: 'You have $dueToday pending reviews. Stay consistent.',
        type: InsightType.warning,
      ));
    }

    if (learnedItems > 0 && retentionRate >= 80) {
      insights.add(AnalyticsInsight(
        message: 'Great job! Your retention is strong at ${retentionRate.toStringAsFixed(0)}%.',
        type: InsightType.success,
      ));
    }

    if (learnedItems > 0 && retentionRate < 50) {
      insights.add(AnalyticsInsight(
        message: 'Your retention is low (${retentionRate.toStringAsFixed(0)}%). Try revising more frequently.',
        type: InsightType.danger,
      ));
    }

    final streakDays = _calculateStreak(items);

    // Today's activity
    final learnedToday = items.where((e) {
      if (!e.isLearned || e.firstLearnedAt == null) return false;
      final d = DateTime(
        e.firstLearnedAt!.year, e.firstLearnedAt!.month, e.firstLearnedAt!.day,
      );
      return d == today;
    }).length;

    final reviewedToday = items.where((e) {
      if (!e.isLearned || e.lastReviewed == null) return false;
      final d = DateTime(
        e.lastReviewed!.year, e.lastReviewed!.month, e.lastReviewed!.day,
      );
      if (d != today) return false;
      if (e.firstLearnedAt != null) {
        final learnedDate = DateTime(
          e.firstLearnedAt!.year, e.firstLearnedAt!.month, e.firstLearnedAt!.day,
        );
        if (learnedDate == today) return false;
      }
      return true;
    }).length;

    final hasActivityToday = items.any((e) {
      if (e.lastReviewed == null) return false;
      final d = DateTime(
        e.lastReviewed!.year, e.lastReviewed!.month, e.lastReviewed!.day,
      );
      return d == today;
    });

    // Category breakdown
    final typeGroups = <String, List<LearningItem>>{};
    for (final item in items) {
      typeGroups.putIfAbsent(item.type, () => []).add(item);
    }

    final categories = typeGroups.entries.map((entry) {
      return CategoryProgress(
        type: entry.key,
        learned: entry.value.where((e) => e.isLearned).length,
        total: entry.value.length,
      );
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return AnalyticsData(
      totalItems: totalItems,
      learnedItems: learnedItems,
      dueToday: dueToday,
      totalReviews: totalReviews,
      correctReviews: strongReviews,
      retentionRate: retentionRate,
      insights: insights,
      streakDays: streakDays,
      reviewedToday: reviewedToday,
      learnedToday: learnedToday,
      categories: categories,
      hasActivityToday: hasActivityToday,
    );
  }
}
