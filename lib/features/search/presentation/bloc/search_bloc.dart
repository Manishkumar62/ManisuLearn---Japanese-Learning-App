import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/learning_item.dart';
import '../../../../domain/repositories/learning_item_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required LearningItemRepository repository})
    : _repository = repository,
      super(const SearchInitial()) {
    on<QueryChanged>(_onQueryChanged);
  }

  final LearningItemRepository _repository;

  Future<void> _onQueryChanged(
    QueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final normalizedQuery = _normalize(event.query);

    if (normalizedQuery.isEmpty) {
      emit(SearchResults(query: event.query, items: const <LearningItem>[]));
      return;
    }

    emit(const SearchLoading());

    try {
      final items = await _repository.filterItems(
        (LearningItem item) => _matchesItem(item, normalizedQuery),
      );

      emit(SearchResults(query: event.query, items: items));
    } catch (error) {
      emit(SearchError(error.toString()));
    }
  }

  bool _matchesItem(LearningItem item, String normalizedQuery) {
    return _searchableValues(
      item,
    ).any((String value) => _normalize(value).contains(normalizedQuery));
  }

  Iterable<String> _searchableValues(LearningItem item) sync* {
    yield item.id;
    yield item.type;
    yield item.japanese;
    yield item.romaji;
    yield item.hindi;
    yield item.english;
    yield item.isLearned ? 'learned' : 'not learned';
    yield item.revisionCount.toString();
    yield item.lastReviewed.toIso8601String();
    yield item.createdAt.toIso8601String();
    yield item.difficulty.toString();
    yield* item.tags;
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
