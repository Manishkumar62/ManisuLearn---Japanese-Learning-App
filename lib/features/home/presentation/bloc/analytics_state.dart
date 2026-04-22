import '../../../../domain/models/analytics_data.dart';

abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsData data;

  AnalyticsLoaded(this.data);
}

class AnalyticsError extends AnalyticsState {
  final String message;

  AnalyticsError(this.message);
}