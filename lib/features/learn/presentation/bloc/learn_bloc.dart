import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/learning_item.dart';
import '../../../../domain/repositories/learning_item_repository.dart';
import 'learn_event.dart';
import 'learn_state.dart';

class LearnBloc extends Bloc<LearnEvent, LearnState> {
  LearnBloc({required LearningItemRepository repository})
    : _repository = repository,
      super(const LearnInitial()) {
    on<LoadLearningItems>(_onLoadLearningItems);
    on<RevealLearningAnswer>(_onRevealLearningAnswer);
    on<SkipLearningItem>(_onSkipLearningItem);
    on<MarkLearned>(_onMarkLearned);
  }

  final LearningItemRepository _repository;

  Future<void> _onLoadLearningItems(
    LoadLearningItems event,
    Emitter<LearnState> emit,
  ) async {
    emit(const LearnLoading());

    try {
      final items = await _repository.filterItems(
        (LearningItem item) => !item.isLearned,
      );

      if (items.isEmpty) {
        emit(const LearnCompleted());
        return;
      }

      emit(LearnLoaded(items: items, currentIndex: 0));
    } catch (error) {
      emit(LearnError(error.toString()));
    }
  }

  void _onRevealLearningAnswer(
    RevealLearningAnswer event,
    Emitter<LearnState> emit,
  ) {
    final state = this.state;
    if (state is! LearnLoaded) {
      return;
    }

    emit(
      LearnLoaded(
        items: state.items,
        currentIndex: state.currentIndex,
        isAnswerVisible: true,
      ),
    );
  }

  void _onSkipLearningItem(SkipLearningItem event, Emitter<LearnState> emit) {
    final state = this.state;
    if (state is! LearnLoaded) {
      return;
    }

    _moveToNextItem(state, emit);
  }

  Future<void> _onMarkLearned(
    MarkLearned event,
    Emitter<LearnState> emit,
  ) async {
    final state = this.state;
    if (state is! LearnLoaded) {
      return;
    }

    try {
      final currentItem = state.currentItem;

      if (currentItem == null) return;

      final item = currentItem.copyWith(
        isLearned: true,
        lastReviewed: DateTime.now(),
        firstLearnedAt: currentItem.firstLearnedAt ?? DateTime.now(),
      );

      await _repository.updateItem(item);
      _moveToNextItem(state, emit);
    } catch (error) {
      emit(LearnError(error.toString()));
    }
  }

  void _moveToNextItem(LearnLoaded state, Emitter<LearnState> emit) {
    final nextIndex = state.currentIndex + 1;

    if (nextIndex >= state.items.length) {
      emit(const LearnCompleted());
      return;
    }

    emit(LearnLoaded(items: state.items, currentIndex: nextIndex));
  }
}
