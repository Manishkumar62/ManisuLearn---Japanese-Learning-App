import 'package:flutter_bloc/flutter_bloc.dart';

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
  }

  final LearningItemRepository _repository;

  Future<void> _onLoadLibrary(
    LoadLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoading());

    try {
      final items = await _repository.getAllItems(); // ✅ no cache

      emit(LibraryLoaded(items: items));
    } catch (error) {
      emit(LibraryError(error.toString()));
    }
  }

  Future<void> _onFilterLibrary(
    FilterLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      final items = await _repository.getAllItems(); // ✅ always fresh

      final filteredItems = _applyFilters(
        items: items,
        searchQuery: event.searchQuery,
        typeFilter: event.typeFilter,
        progressFilter: event.progressFilter,
        minDaysAgo: event.minDaysAgo,
        maxRevisions: event.maxRevisions,
      );

      emit(
        LibraryLoaded(
          items: filteredItems,
          searchQuery: event.searchQuery,
          typeFilter: event.typeFilter,
          progressFilter: event.progressFilter,
        ),
      );
    } catch (error) {
      emit(LibraryError(error.toString()));
    }
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
            LibraryTypeFilter.words => item.type == 'word',
            LibraryTypeFilter.sentences => item.type == 'sentence',
            LibraryTypeFilter.dialogue => item.type == 'dialogue',
            LibraryTypeFilter.grammar => item.type == 'grammar',
            LibraryTypeFilter.stories => item.type == 'story',
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
      return item.isLearned; // treat as needs revision
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
