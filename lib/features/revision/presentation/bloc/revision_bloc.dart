import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/learning_item.dart';
import '../../../../domain/repositories/learning_item_repository.dart';
import 'revision_event.dart';
import 'revision_state.dart';

class RevisionBloc extends Bloc<RevisionEvent, RevisionState> {
  RevisionBloc({required LearningItemRepository repository})
    : _repository = repository,
      super(const RevisionInitial()) {
    on<LoadRevisionItems>(_onLoadRevisionItems);
    on<RevealRevisionAnswer>(_onRevealRevisionAnswer);
    on<SkipRevisionItem>(_onSkipRevisionItem);
    on<ReviseItem>(_onReviseItem);
  }

  final LearningItemRepository _repository;

  Future<void> _onLoadRevisionItems(
    LoadRevisionItems event,
    Emitter<RevisionState> emit,
  ) async {
    emit(const RevisionLoading());

    try {
      final items = await _repository.filterItems(
        (LearningItem item) => item.isLearned,
      );

      final sortedItems = items.toList(growable: false)
        ..sort(_compareRevisionPriority);

      if (sortedItems.isEmpty) {
        emit(const RevisionCompleted());
        return;
      }

      emit(RevisionLoaded(items: sortedItems, currentIndex: 0));
    } catch (error) {
      emit(RevisionError(error.toString()));
    }
  }

  void _onRevealRevisionAnswer(
    RevealRevisionAnswer event,
    Emitter<RevisionState> emit,
  ) {
    final state = this.state;
    if (state is! RevisionLoaded) {
      return;
    }

    emit(
      RevisionLoaded(
        items: state.items,
        currentIndex: state.currentIndex,
        isAnswerVisible: true,
      ),
    );
  }

  void _onSkipRevisionItem(
    SkipRevisionItem event,
    Emitter<RevisionState> emit,
  ) {
    final state = this.state;
    if (state is! RevisionLoaded) {
      return;
    }

    _moveToNextItem(state, emit);
  }

  Future<void> _onReviseItem(
    ReviseItem event,
    Emitter<RevisionState> emit,
  ) async {
    final state = this.state;
    if (state is! RevisionLoaded) {
      return;
    }

    try {
      final item = state.currentItem
        ..revisionCount += 1
        ..lastReviewed = DateTime.now();

      await _repository.updateItem(item);
      _moveToNextItem(state, emit);
    } catch (error) {
      emit(RevisionError(error.toString()));
    }
  }

  void _moveToNextItem(RevisionLoaded state, Emitter<RevisionState> emit) {
    final nextIndex = state.currentIndex + 1;

    if (nextIndex >= state.items.length) {
      emit(const RevisionCompleted());
      return;
    }

    emit(RevisionLoaded(items: state.items, currentIndex: nextIndex));
  }

  int _compareRevisionPriority(LearningItem a, LearningItem b) {
    final revisionCountCompare = a.revisionCount.compareTo(b.revisionCount);
    if (revisionCountCompare != 0) {
      return revisionCountCompare;
    }

    return a.lastReviewed.compareTo(b.lastReviewed);
  }
}
