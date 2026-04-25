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
      monthlyReviewed: _weeklyAggregatedCounts(items, 4, _buildDailyReviewedMap),
      monthlyLearned: _weeklyAggregatedCounts(items, 4, _buildDailyLearnedMap),
      yearlyReviewed: _monthlyReviewedCounts(items),
      yearlyLearned: _monthlyLearnedCounts(items),
    );
  }

  List<int> _dailyReviewedCounts(List<LearningItem> items, int days) {
    final today = _today();
    final dateRange = List.generate(days, (i) => today.subtract(Duration(days: days - 1 - i)));
    final counts = _countByDate(dateRange, items, (e) => e.lastReviewed);
    return dateRange.map((d) => counts[d]!).toList();
  }

  List<int> _dailyLearnedCounts(List<LearningItem> items, int days) {
    final today = _today();
    final dateRange = List.generate(days, (i) => today.subtract(Duration(days: days - 1 - i)));
    final counts = _countByDate(dateRange, items, (e) => e.isLearned ? e.firstLearnedAt : null);
    return dateRange.map((d) => counts[d]!).toList();
  }

  List<int> _weeklyAggregatedCounts(
    List<LearningItem> items,
    int weeks,
    Map<DateTime, int> Function(List<LearningItem>, DateTime, int) builder,
  ) {
    final today = _today();
    final daily = builder(items, today, weeks * 7);

    return List.generate(weeks, (w) {
      int sum = 0;
      for (int d = 0; d < 7; d++) {
        final day = today.subtract(Duration(days: (weeks - 1 - w) * 7 + (6 - d)));
        sum += daily[day] ?? 0;
      }
      return sum;
    });
  }

  List<int> _monthlyReviewedCounts(List<LearningItem> items) {
    final now = DateTime.now();
    final months = List.generate(12, (i) => DateTime(now.year, now.month - 11 + i, 1));
    final counts = _countByMonth(months, items, (e) => e.lastReviewed);
    return months.map((m) => counts[m]!).toList();
  }

  List<int> _monthlyLearnedCounts(List<LearningItem> items) {
    final now = DateTime.now();
    final months = List.generate(12, (i) => DateTime(now.year, now.month - 11 + i, 1));
    final counts = _countByMonth(months, items, (e) => e.isLearned ? e.firstLearnedAt : null);
    return months.map((m) => counts[m]!).toList();
  }

  Map<DateTime, int> _buildDailyReviewedMap(List<LearningItem> items, DateTime today, int days) {
    final dateRange = List.generate(days, (i) => today.subtract(Duration(days: days - 1 - i)));
    return _countByDate(dateRange, items, (e) => e.lastReviewed);
  }

  Map<DateTime, int> _buildDailyLearnedMap(List<LearningItem> items, DateTime today, int days) {
    final dateRange = List.generate(days, (i) => today.subtract(Duration(days: days - 1 - i)));
    return _countByDate(dateRange, items, (e) => e.isLearned ? e.firstLearnedAt : null);
  }

  Map<DateTime, int> _countByDate(
    List<DateTime> dateRange,
    List<LearningItem> items,
    DateTime? Function(LearningItem) dateExtractor,
  ) {
    final counts = {for (final d in dateRange) d: 0};
    for (final item in items) {
      final raw = dateExtractor(item);
      if (raw == null) continue;
      final d = DateTime(raw.year, raw.month, raw.day);
      if (counts.containsKey(d)) counts[d] = counts[d]! + 1;
    }
    return counts;
  }

  Map<DateTime, int> _countByMonth(
    List<DateTime> months,
    List<LearningItem> items,
    DateTime? Function(LearningItem) dateExtractor,
  ) {
    final counts = {for (final m in months) m: 0};
    for (final item in items) {
      final raw = dateExtractor(item);
      if (raw == null) continue;
      final m = DateTime(raw.year, raw.month, 1);
      if (counts.containsKey(m)) counts[m] = counts[m]! + 1;
    }
    return counts;
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
