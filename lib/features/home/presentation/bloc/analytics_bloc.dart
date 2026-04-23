import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/repositories/learning_item_repository.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../data/models/learning_item.dart'; // ✅ FIX

import 'analytics_event.dart';
import 'analytics_state.dart';
import 'analytics_insight.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({required LearningItemRepository repository})
      : _repository = repository,
        super(AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
  }

  final LearningItemRepository _repository;

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final items = await _repository.getAllItems();

      final data = AnalyticsService().compute(items);

      final insights = _mapInsights(data.insights);
      final weeklyProgress = _generateWeeklyProgress(items);

      emit(
        AnalyticsLoaded(
          data: data,
          insights: insights,
          weeklyProgress: weeklyProgress,
        ),
      );
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  // ✅ INSIDE CLASS NOW
  List<AnalyticsInsight> _mapInsights(List<String> rawInsights) {
    return rawInsights.map((text) {
      if (text.contains('Great job')) {
        return AnalyticsInsight(message: text, type: InsightType.success);
      }
      if (text.contains('low')) {
        return AnalyticsInsight(message: text, type: InsightType.danger);
      }
      if (text.contains('pending') || text.contains('weak')) {
        return AnalyticsInsight(message: text, type: InsightType.warning);
      }

      return AnalyticsInsight(message: text, type: InsightType.info);
    }).toList();
  }

  // ✅ REAL CHART LOGIC
  List<double> _generateWeeklyProgress(List<LearningItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final Map<DateTime, int> reviewCount = {};

    for (int i = 0; i < 7; i++) {
      final day = today.subtract(Duration(days: i));
      reviewCount[day] = 0;
    }

    for (final item in items) {
      final reviewedAt = item.lastReviewed;
      if (reviewedAt == null) continue;

      final reviewDate = DateTime(
        reviewedAt.year,
        reviewedAt.month,
        reviewedAt.day,
      );

      if (reviewCount.containsKey(reviewDate)) {
        reviewCount[reviewDate] =
            reviewCount[reviewDate]! + 1;
      }
    }

    final sortedDays = reviewCount.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    final values = sortedDays
        .map((day) => reviewCount[day]!.toDouble())
        .toList();

    final max =
        values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);

    return values
        .map((v) => max == 0 ? 0.0 : (v / max).toDouble())
        .toList();
  }
}