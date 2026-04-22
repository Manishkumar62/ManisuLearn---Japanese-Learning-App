import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/repositories/learning_item_repository.dart';
import '../../../../core/services/analytics_service.dart';
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
    try {
      final items = await _repository.getAllItems();

      final data = AnalyticsService().compute(items);

      emit(AnalyticsLoaded(data));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}