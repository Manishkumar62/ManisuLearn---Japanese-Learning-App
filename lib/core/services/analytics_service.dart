import '../../data/models/learning_item.dart';
import '../../domain/models/analytics_data.dart';

class AnalyticsService {
  AnalyticsData compute(List<LearningItem> items) {
    final now = DateTime.now();

    final totalItems = items.length;

    final learnedItems =
        items.where((e) => e.isLearned).length;

    final dueToday =
        items.where((e) => e.nextReview.isBefore(now)).length;

    final totalReviews =
        items.fold<int>(0, (sum, e) => sum + e.repetitions);

    final correctReviews =
        items.where((e) => e.repetitions > 0).length;

    final double retentionRate = totalReviews == 0
        ? 0
        : (correctReviews / totalReviews) * 100;

    return AnalyticsData(
      totalItems: totalItems,
      learnedItems: learnedItems,
      dueToday: dueToday,
      totalReviews: totalReviews,
      correctReviews: correctReviews,
      retentionRate: retentionRate,
    );
  }
}