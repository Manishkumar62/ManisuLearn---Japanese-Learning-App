class AnalyticsData {
  final int totalItems;
  final int learnedItems;
  final int dueToday;
  final int totalReviews;
  final int correctReviews;
  final double retentionRate;

  AnalyticsData({
    required this.totalItems,
    required this.learnedItems,
    required this.dueToday,
    required this.totalReviews,
    required this.correctReviews,
    required this.retentionRate,
  });
}