import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/item_type.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../data/models/learning_item.dart';
import '../../../../domain/repositories/learning_item_repository.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc({required LearningItemRepository repository})
    : _repository = repository,
      super(const LibraryInitial()) {
    on<LoadLibrary>(_onLoadLibrary);
    on<FilterLibrary>(_onFilterLibrary);
    on<LoadMoreLibrary>(_onLoadMoreLibrary);
  }

  final LearningItemRepository _repository;
  static const int _pageSize = 30;
  List<LearningItem> _allFilteredItems = const [];

  Future<void> _onLoadLibrary(
    LoadLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoading());

    try {
      _allFilteredItems = await _repository.getAllItems();
      _allFilteredItems.shuffle(Random());
      emit(_buildPage(emit));
    } catch (error) {
      emit(LibraryError(AppError.userMessage(error)));
    }
  }

  Future<void> _onFilterLibrary(
    FilterLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      final items = await _repository.getAllItems();

      _allFilteredItems = _applyFilters(
        items: items,
        searchQuery: event.searchQuery,
        typeFilter: event.typeFilter,
        progressFilter: event.progressFilter,
        minDaysAgo: event.minDaysAgo,
        maxRevisions: event.maxRevisions,
      )..shuffle(Random());

      emit(_buildPage(emit));
    } catch (error) {
      emit(LibraryError(AppError.userMessage(error)));
    }
  }

  void _onLoadMoreLibrary(
    LoadMoreLibrary event,
    Emitter<LibraryState> emit,
  ) {
    final state = this.state;
    if (state is! LibraryLoaded || !state.hasMore) return;

    final currentCount = state.items.length;
    final nextBatch = _allFilteredItems
        .skip(currentCount)
        .take(_pageSize)
        .toList();

    emit(
      LibraryLoaded(
        items: [...state.items, ...nextBatch],
        hasMore: currentCount + nextBatch.length < _allFilteredItems.length,
      ),
    );
  }

  LibraryLoaded _buildPage(Emitter<LibraryState> emit) {
    return LibraryLoaded(
      items: _allFilteredItems.take(_pageSize).toList(),
      hasMore: _allFilteredItems.length > _pageSize,
    );
  }

  List<LearningItem> _applyFilters({
    required List<LearningItem> items,
    required String searchQuery,
    required LibraryTypeFilter typeFilter,
    required LibraryProgressFilter progressFilter,
    int? minDaysAgo,
    int? maxRevisions,
  }) {
    return items
        .where((LearningItem item) {
          final normalizedQuery = searchQuery.trim().toLowerCase();
          final matchesQuery =
              normalizedQuery.isEmpty ||
              item.japanese.toLowerCase().contains(normalizedQuery) ||
              item.romaji.toLowerCase().contains(normalizedQuery) ||
              item.hindi.toLowerCase().contains(normalizedQuery) ||
              item.english.toLowerCase().contains(normalizedQuery);

          final matchesType = switch (typeFilter) {
            LibraryTypeFilter.all => true,
            LibraryTypeFilter.hiragana => item.itemType == ItemType.hiragana,
            LibraryTypeFilter.katakana => item.itemType == ItemType.katakana,
            LibraryTypeFilter.kanji => item.itemType == ItemType.kanji,
            LibraryTypeFilter.words => item.itemType == ItemType.word,
            LibraryTypeFilter.sentences => item.itemType == ItemType.sentence,
            LibraryTypeFilter.dialogue => item.itemType == ItemType.dialogue,
            LibraryTypeFilter.grammar => item.itemType == ItemType.grammar,
            LibraryTypeFilter.stories => item.itemType == ItemType.story,
          };

          final matchesProgress = switch (progressFilter) {
            LibraryProgressFilter.all => true,
            LibraryProgressFilter.learned => item.isLearned,
            LibraryProgressFilter.notLearned => !item.isLearned,
            LibraryProgressFilter.needsRevision => _needsRevision(item),
          };

          final now = DateTime.now();

          final daysSinceLearned = item.firstLearnedAt == null
              ? 0
              : now.difference(item.firstLearnedAt!).inDays;

          final matchesDays =
              minDaysAgo == null || daysSinceLearned >= minDaysAgo;

          final matchesRevisions =
              maxRevisions == null || item.revisionCount <= maxRevisions;

          return matchesQuery &&
              matchesType &&
              matchesProgress &&
              matchesDays &&
              matchesRevisions;
        })
        .toList(growable: false);
  }

  bool _needsRevision(LearningItem item) {
    if (item.lastReviewed == null) {
      return item.isLearned;
    }

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      item.lastReviewed!.year,
      item.lastReviewed!.month,
      item.lastReviewed!.day,
    );

    final daysSinceLastReview = today.difference(last).inDays;

    return item.isLearned && daysSinceLastReview >= 1;
  }
}
