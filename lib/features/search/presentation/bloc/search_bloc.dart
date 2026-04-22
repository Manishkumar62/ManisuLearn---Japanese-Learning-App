import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/learning_item.dart';
import '../../../../domain/repositories/learning_item_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class _ScoredItem {
  final LearningItem item;
  final int score;

  _ScoredItem(this.item, this.score);
}

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

    try {
      final allItems = await _repository.getAllItems();

      final items = _rankedSearch(allItems, normalizedQuery);

      emit(SearchResults(query: event.query, items: items));
    } catch (error) {
      emit(SearchError(error.toString()));
    }
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
