import '../../../../domain/models/analytics_data.dart';
import 'analytics_insight.dart';

class ProgressData {
  final List<int> weeklyReviewed;
  final List<int> weeklyLearned;
  final List<int> monthlyReviewed;
  final List<int> monthlyLearned;
  final List<int> yearlyReviewed;
  final List<int> yearlyLearned;

  const ProgressData({
    this.weeklyReviewed = const [],
    this.weeklyLearned = const [],
    this.monthlyReviewed = const [],
    this.monthlyLearned = const [],
    this.yearlyReviewed = const [],
    this.yearlyLearned = const [],
  });
}

abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsData data;
  final List<AnalyticsInsight> insights;
  final ProgressData progress;

  AnalyticsLoaded({
    required this.data,
    required this.insights,
    required this.progress,
  });
}

class AnalyticsError extends AnalyticsState {
  final String message;

  AnalyticsError(this.message);
}
