import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/repositories/learning_item_repository.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../data/models/learning_item.dart';

import 'analytics_event.dart';
import 'analytics_state.dart';

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
    emit(AnalyticsLoading());

    try {
      final items = await _repository.getAllItems();
      final data = AnalyticsService().compute(items);

      emit(
        AnalyticsLoaded(
          data: data,
          insights: data.insights,
          progress: _generateProgress(items),
        ),
      );
    } catch (e) {
      emit(AnalyticsError(AppError.userMessage(e)));
    }
  }

  ProgressData _generateProgress(List<LearningItem> items) {
    return ProgressData(
      weeklyReviewed: _dailyReviewedCounts(items, 7),
      weeklyLearned: _dailyLearnedCounts(items, 7),
      monthlyReviewed: _weeklyAggregatedReviewed(items, 4),
      monthlyLearned: _weeklyAggregatedLearned(items, 4),
      yearlyReviewed: _monthlyReviewedCounts(items),
      yearlyLearned: _monthlyLearnedCounts(items),
    );
  }

  /// Daily reviewed counts for the last [days] days, normalized 0-1.
  List<double> _dailyReviewedCounts(List<LearningItem> items, int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<DateTime> dateRange = List.generate(
      days,
      (i) => today.subtract(Duration(days: days - 1 - i)),
    );

    final Map<DateTime, int> counts = {for (final d in dateRange) d: 0};

    for (final item in items) {
      if (item.lastReviewed == null) continue;
      final d = DateTime(
        item.lastReviewed!.year,
        item.lastReviewed!.month,
        item.lastReviewed!.day,
      );
      if (counts.containsKey(d)) {
        counts[d] = counts[d]! + 1;
      }
    }

    return _normalize(dateRange.map((d) => counts[d]!.toDouble()).toList());
  }

  /// Daily learned counts for the last [days] days, normalized 0-1.
  List<double> _dailyLearnedCounts(List<LearningItem> items, int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<DateTime> dateRange = List.generate(
      days,
      (i) => today.subtract(Duration(days: days - 1 - i)),
    );

    final Map<DateTime, int> counts = {for (final d in dateRange) d: 0};

    for (final item in items) {
      if (!item.isLearned || item.firstLearnedAt == null) continue;
      final d = DateTime(
        item.firstLearnedAt!.year,
        item.firstLearnedAt!.month,
        item.firstLearnedAt!.day,
      );
      if (counts.containsKey(d)) {
        counts[d] = counts[d]! + 1;
      }
    }

    return _normalize(dateRange.map((d) => counts[d]!.toDouble()).toList());
  }

  /// Weekly aggregated reviewed counts for the last [weeks] weeks, normalized 0-1.
  List<double> _weeklyAggregatedReviewed(List<LearningItem> items, int weeks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final daily = _buildDailyReviewedMap(items, today, weeks * 7);

    final values = List.generate(weeks, (w) {
      int sum = 0;
      for (int d = 0; d < 7; d++) {
        final day = today.subtract(Duration(days: (weeks - 1 - w) * 7 + (6 - d)));
        sum += daily[day] ?? 0;
      }
      return sum.toDouble();
    });

    return _normalize(values);
  }

  /// Weekly aggregated learned counts for the last [weeks] weeks, normalized 0-1.
  List<double> _weeklyAggregatedLearned(List<LearningItem> items, int weeks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final daily = _buildDailyLearnedMap(items, today, weeks * 7);

    final values = List.generate(weeks, (w) {
      int sum = 0;
      for (int d = 0; d < 7; d++) {
        final day = today.subtract(Duration(days: (weeks - 1 - w) * 7 + (6 - d)));
        sum += daily[day] ?? 0;
      }
      return sum.toDouble();
    });

    return _normalize(values);
  }

  Map<DateTime, int> _buildDailyReviewedMap(List<LearningItem> items, DateTime today, int days) {
    final dateRange = List.generate(days, (i) => today.subtract(Duration(days: days - 1 - i)));
    final counts = {for (final d in dateRange) d: 0};

    for (final item in items) {
      if (item.lastReviewed == null) continue;
      final d = DateTime(item.lastReviewed!.year, item.lastReviewed!.month, item.lastReviewed!.day);
      if (counts.containsKey(d)) counts[d] = counts[d]! + 1;
    }
    return counts;
  }

  Map<DateTime, int> _buildDailyLearnedMap(List<LearningItem> items, DateTime today, int days) {
    final dateRange = List.generate(days, (i) => today.subtract(Duration(days: days - 1 - i)));
    final counts = {for (final d in dateRange) d: 0};

    for (final item in items) {
      if (!item.isLearned || item.firstLearnedAt == null) continue;
      final d = DateTime(item.firstLearnedAt!.year, item.firstLearnedAt!.month, item.firstLearnedAt!.day);
      if (counts.containsKey(d)) counts[d] = counts[d]! + 1;
    }
    return counts;
  }

  /// Generates monthly review counts for the last 12 months, normalized to 0-1.
  List<double> _monthlyReviewedCounts(List<LearningItem> items) {
    final now = DateTime.now();
    final months = List.generate(12, (i) => DateTime(now.year, now.month - 11 + i, 1));
    final Map<DateTime, int> counts = {for (final m in months) m: 0};

    for (final item in items) {
      if (item.lastReviewed == null) continue;
      final m = DateTime(item.lastReviewed!.year, item.lastReviewed!.month, 1);
      if (counts.containsKey(m)) {
        counts[m] = counts[m]! + 1;
      }
    }

    final values = months.map((m) => counts[m]!.toDouble()).toList();
    final max = values.fold<double>(0, (a, b) => a > b ? a : b);
    return values.map((v) => max == 0 ? 0.0 : v / max).toList();
  }

  /// Generates monthly learned counts for the last 12 months, normalized to 0-1.
  List<double> _monthlyLearnedCounts(List<LearningItem> items) {
    final now = DateTime.now();
    final months = List.generate(12, (i) => DateTime(now.year, now.month - 11 + i, 1));
    final Map<DateTime, int> counts = {for (final m in months) m: 0};

    for (final item in items) {
      if (!item.isLearned || item.firstLearnedAt == null) continue;
      final m = DateTime(item.firstLearnedAt!.year, item.firstLearnedAt!.month, 1);
      if (counts.containsKey(m)) {
        counts[m] = counts[m]! + 1;
      }
    }

    final values = months.map((m) => counts[m]!.toDouble()).toList();
    return _normalize(values);
  }

  List<double> _normalize(List<double> values) {
    final max = values.fold<double>(0, (a, b) => a > b ? a : b);
    return values.map((v) => max == 0 ? 0.0 : v / max).toList();
  }
}
