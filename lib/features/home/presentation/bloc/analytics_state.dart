import '../../../../domain/models/analytics_data.dart';
import 'analytics_insight.dart'; // ✅ NEW

abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsData data;

  /// ✅ NEW (for UI)
  final List<AnalyticsInsight> insights;

  /// ✅ NEW (for chart)
  final List<double> weeklyProgress;

  AnalyticsLoaded({
    required this.data,
    required this.insights,
    required this.weeklyProgress,
  });
}

class AnalyticsError extends AnalyticsState {
  final String message;

  AnalyticsError(this.message);
}