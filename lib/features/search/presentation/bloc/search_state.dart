import 'package:equatable/equatable.dart';

import '../../../../data/models/learning_item.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => const [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchResults extends SearchState {
  SearchResults({required this.query, required this.items})
    : isEmpty = items.isEmpty;

  final String query;
  final List<LearningItem> items;
  final bool isEmpty;

  @override
  List<Object?> get props => <Object?>[query, items, isEmpty];
}

class SearchError extends SearchState {
  const SearchError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
