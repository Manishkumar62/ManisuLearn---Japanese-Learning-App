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

  List<LearningItem> _allItems = <LearningItem>[];

  Future<void> _onLoadLibrary(
    LoadLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoading());

    try {
      _allItems = await _repository.getAllItems();
      emit(LibraryLoaded(items: _allItems));
    } catch (error) {
      emit(LibraryError(error.toString()));
    }
  }

  Future<void> _onFilterLibrary(
    FilterLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      if (_allItems.isEmpty) {
        _allItems = await _repository.getAllItems();
      }

      final filteredItems = _applyFilters(
        items: _allItems,
        searchQuery: event.searchQuery,
        typeFilter: event.typeFilter,
        progressFilter: event.progressFilter,
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
            LibraryTypeFilter.stories => item.type == 'story',
          };

          final matchesProgress = switch (progressFilter) {
            LibraryProgressFilter.all => true,
            LibraryProgressFilter.learned => item.isLearned,
            LibraryProgressFilter.notLearned => !item.isLearned,
            LibraryProgressFilter.needsRevision => _needsRevision(item),
          };

          return matchesQuery && matchesType && matchesProgress;
        })
        .toList(growable: false);
  }

  bool _needsRevision(LearningItem item) {
    final now = DateTime.now();
    final daysSinceLastReview = now.difference(item.lastReviewed).inDays;

    return item.isLearned && daysSinceLastReview >= 1;
  }
}
