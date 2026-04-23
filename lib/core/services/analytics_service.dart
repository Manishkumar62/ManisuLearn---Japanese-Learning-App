import '../../data/models/learning_item.dart';
import '../../domain/models/analytics_data.dart';

class AnalyticsService {
  int _calculateStreak(List<LearningItem> items) {
  final reviewDates = items
      .where((e) => e.isLearned && e.lastReviewed != null)
      .map((e) {
        final d = e.lastReviewed!;
        return DateTime(d.year, d.month, d.day); // normalize
      })
      .toSet() // ✅ remove duplicates (same day)
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

    final totalItems = items.length;

    final learnedItems = items.where((e) => e.isLearned).length;

    final dueToday = items.where((e) => e.nextReview.isBefore(now)).length;

    final totalReviews = items.fold<int>(0, (sum, e) => sum + e.repetitions);

    final correctReviews = items.where((e) => e.repetitions > 0).length;

    final double retentionRate = totalReviews == 0
        ? 0
        : (correctReviews / totalReviews) * 100;

    final List<String> insights = [];

    // 🔹 Weak items (low repetitions)
    final weakItems = items
        .where((e) => e.isLearned && e.repetitions <= 2)
        .length;

    if (weakItems >= 5) {
      insights.add('You have many weak items. Revise them.');
    }

    // 🔹 Overdue items
    if (dueToday >= 10) {
      insights.add('You have many pending reviews. Stay consistent.');
    }

    // 🔹 Good retention
    if (learnedItems > 0 && retentionRate >= 80) {
      insights.add('Great job! Your retention is strong.');
    }

    // 🔹 Low retention
    if (learnedItems > 0 && retentionRate < 50) {
      insights.add('Your retention is low. Try revising more frequently.');
    }

    final streakDays = _calculateStreak(items);

    return AnalyticsData(
      totalItems: totalItems,
      learnedItems: learnedItems,
      dueToday: dueToday,
      totalReviews: totalReviews,
      correctReviews: correctReviews,
      retentionRate: retentionRate,
      insights: insights,
      streakDays: streakDays,
    );
  }
}
