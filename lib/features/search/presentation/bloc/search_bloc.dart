import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_utils.dart';
import '../../../../data/models/learning_item.dart';
import '../../../../domain/repositories/learning_item_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class _ScoredItem {
  _ScoredItem(this.item, this.score);

  final LearningItem item;
  final int score;
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required LearningItemRepository repository})
    : _repository = repository,
      super(const SearchInitial()) {
    on<QueryChanged>(_onQueryChanged);
    on<LoadMoreResults>(_onLoadMoreResults);
  }

  final LearningItemRepository _repository;
  static const int _pageSize = 30;
  List<LearningItem> _allSearchResults = const [];

  Future<void> _onQueryChanged(
    QueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final normalizedQuery = _normalize(event.query);

    if (normalizedQuery.isEmpty) {
      _allSearchResults = const [];
      emit(
        SearchResults(query: event.query, items: const <LearningItem>[]),
      );
      return;
    }

    try {
      final allItems = await _repository.getAllItems();

      _allSearchResults = _rankedSearch(allItems, normalizedQuery);

      emit(
        SearchResults(
          query: event.query,
          items: _allSearchResults.take(_pageSize).toList(),
          hasMore: _allSearchResults.length > _pageSize,
        ),
      );
    } catch (error) {
      emit(SearchError(AppError.userMessage(error)));
    }
  }

  void _onLoadMoreResults(
    LoadMoreResults event,
    Emitter<SearchState> emit,
  ) {
    final state = this.state;
    if (state is! SearchResults || !state.hasMore) return;

    final currentCount = state.items.length;
    final nextBatch = _allSearchResults
        .skip(currentCount)
        .take(_pageSize)
        .toList();

    emit(
      SearchResults(
        query: state.query,
        items: [...state.items, ...nextBatch],
        hasMore: currentCount + nextBatch.length < _allSearchResults.length,
      ),
    );
  }

  List<LearningItem> _rankedSearch(List<LearningItem> items, String query) {
    final List<_ScoredItem> scored = [];

    for (final item in items) {
      int score = 0;

      final fields = [item.japanese, item.romaji, item.english, item.hindi];

      for (final field in fields) {
        final value = _normalize(field);

        if (value == query) {
          score += 100;
        } else if (value.startsWith(query)) {
          score += 50;
        } else if (value.contains(query)) {
          score += 10;
        }
      }

      if (score > 0) {
        scored.add(_ScoredItem(item, score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.map((e) => e.item).toList();
  }

  String _normalize(String value) {
    return value.toLowerCase().trim().replaceAll(' ', '');
  }
}
