import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/spaced_repetition_service.dart';
import '../../../../domain/repositories/learning_item_repository.dart';
import 'revision_event.dart';
import 'revision_state.dart';

class RevisionBloc extends Bloc<RevisionEvent, RevisionState> {
  RevisionBloc({
    required LearningItemRepository repository,
    SpacedRepetitionService? spacedRepetitionService,
  }) : _repository = repository,
       _spacedRepetitionService =
           spacedRepetitionService ?? SpacedRepetitionService(),
       super(const RevisionInitial()) {
    on<LoadRevisionItems>(_onLoadRevisionItems);
    on<RevealRevisionAnswer>(_onRevealRevisionAnswer);
    on<SkipRevisionItem>(_onSkipRevisionItem);
    on<ReviewItem>(_onReviewItem);
    on<LoadAllLearnedItems>(_onLoadAllLearnedItems);
    on<ApplyRevisionFilter>(_onApplyRevisionFilter);
    on<MarkItemReviewed>(_onMarkItemReviewed);
  }

  final LearningItemRepository _repository;
  final SpacedRepetitionService _spacedRepetitionService;

  Future<void> _onLoadRevisionItems(
    LoadRevisionItems event,
    Emitter<RevisionState> emit,
  ) async {
    emit(const RevisionLoading());

    try {
      final dueItems = await _repository.getDueItems();
      final sortedDueItems = dueItems.toList(growable: false)
        ..sort(_spacedRepetitionService.compareReviewPriority);

      if (sortedDueItems.isEmpty) {
        emit(const RevisionCompleted());
        return;
      }

      emit(
        RevisionLoaded(
          items: sortedDueItems,
          currentIndex: 0,
          isExploreMode: false,
        ),
      );
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
        isExploreMode: state.isExploreMode,
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
      final currentItem = state.currentItem;

      if (currentItem == null) return;

      final reviewedItem = _spacedRepetitionService.review(
        currentItem,
        quality: event.isCorrect
            ? SpacedRepetitionService.defaultPassingQuality
            : 2,
      );

      final item = reviewedItem.copyWith(
        isLearned: true,
        firstLearnedAt: reviewedItem.firstLearnedAt ?? DateTime.now(),
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

    emit(
      RevisionLoaded(
        items: state.items,
        currentIndex: nextIndex,
        isExploreMode: state.isExploreMode,
      ),
    );
  }

  Future<void> _onLoadAllLearnedItems(
    LoadAllLearnedItems event,
    Emitter<RevisionState> emit,
  ) async {
    emit(const RevisionLoading());

    try {
      final allItems = await _repository.getAllItems();

      final learnedItems = allItems.where((e) => e.isLearned).toList();

      if (learnedItems.isEmpty) {
        emit(const RevisionCompleted());
        return;
      }

      emit(
        RevisionLoaded(
          items: learnedItems,
          currentIndex: 0,
          isExploreMode: true,
        ),
      );
    } catch (error) {
      emit(RevisionError(error.toString()));
    }
  }

  Future<void> _onApplyRevisionFilter(
    ApplyRevisionFilter event,
    Emitter<RevisionState> emit,
  ) async {
    final currentState = state;

    if (currentState is! RevisionLoaded || !currentState.isExploreMode) {
      return;
    }

    try {
      final allItems = await _repository.getAllItems();

      final now = DateTime.now();

      final filtered = allItems.where((item) {
        if (!item.isLearned) return false;

        final daysAgo = item.firstLearnedAt == null
            ? 0
            : now.difference(item.firstLearnedAt!).inDays;

        // time filter
        if (event.minDaysAgo != null && daysAgo < event.minDaysAgo!) {
          return false;
        }

        if (event.maxDaysAgo != null && daysAgo > event.maxDaysAgo!) {
          return false;
        }

        // repetition filter
        if (event.maxRepetitions != null &&
            item.repetitions > event.maxRepetitions!) {
          return false;
        }

        return true;
      }).toList();

      emit(
        RevisionLoaded(items: filtered, currentIndex: 0, isExploreMode: true),
      );
    } catch (error) {
      emit(RevisionError(error.toString()));
    }
  }

  Future<void> _onMarkItemReviewed(
    MarkItemReviewed event,
    Emitter<RevisionState> emit,
  ) async {
    try {
      final item = await _repository.getItem(event.id);
      if (item == null) return;

      final reviewedItem = _spacedRepetitionService.review(
        item,
        quality: SpacedRepetitionService.defaultPassingQuality,
      );

      final updated = reviewedItem.copyWith(
        isLearned: true,
        firstLearnedAt: reviewedItem.firstLearnedAt ?? DateTime.now(),
      );

      await _repository.updateItem(updated);
    } catch (_) {
      // silent fail
    }
  }
}
