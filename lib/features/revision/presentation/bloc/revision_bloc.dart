import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/spaced_repetition_service.dart';
import '../../../../data/models/learning_item.dart';
import '../../../../domain/repositories/learning_item_repository.dart';
import 'revision_event.dart';
import 'revision_state.dart';

class RevisionBloc extends Bloc<RevisionEvent, RevisionState> {
  RevisionBloc({
    required LearningItemRepository repository,
    SpacedRepetitionService? spacedRepetitionService,
  })
    : _repository = repository,
      _spacedRepetitionService =
          spacedRepetitionService ?? SpacedRepetitionService(),
      super(const RevisionInitial()) {
    on<LoadRevisionItems>(_onLoadRevisionItems);
    on<RevealRevisionAnswer>(_onRevealRevisionAnswer);
    on<SkipRevisionItem>(_onSkipRevisionItem);
    on<ReviewItem>(_onReviewItem);
  }

  final LearningItemRepository _repository;
  final SpacedRepetitionService _spacedRepetitionService;

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
        ..sort(_spacedRepetitionService.compareReviewPriority);

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

  Future<void> _onReviewItem(
    ReviewItem event,
    Emitter<RevisionState> emit,
  ) async {
    final state = this.state;
    if (state is! RevisionLoaded) {
      return;
    }

    try {
      final item = _spacedRepetitionService.review(
        state.currentItem,
        quality: event.isCorrect
            ? SpacedRepetitionService.defaultPassingQuality
            : 2,
      );

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
}
