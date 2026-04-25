import '../../features/home/presentation/bloc/analytics_insight.dart';

class CategoryProgress {
  final String type;
  final int learned;
  final int total;

  const CategoryProgress({
    required this.type,
    required this.learned,
    required this.total,
  });

  double get progress => total == 0 ? 0.0 : learned / total;
}

class AnalyticsData {
  final int totalItems;
  final int learnedItems;
  final int dueToday;
  final int totalReviews;
  final int correctReviews;
  final double retentionRate;
  final List<AnalyticsInsight> insights;

  final int streakDays;

  // Today's activity
  final int reviewedToday;
  final int learnedToday;

  // Category breakdown
  final List<CategoryProgress> categories;

  // Streak protection
  final bool hasActivityToday;

  AnalyticsData({
    required this.totalItems,
    required this.learnedItems,
    required this.dueToday,
    required this.totalReviews,
    required this.correctReviews,
    required this.retentionRate,
    required this.insights,
    required this.streakDays,
    this.reviewedToday = 0,
    this.learnedToday = 0,
    this.categories = const [],
    this.hasActivityToday = false,
  });
}
