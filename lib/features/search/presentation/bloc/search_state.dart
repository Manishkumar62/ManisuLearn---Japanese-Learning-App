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
  const SearchResults({required this.query, required this.items});

  final String query;
  final List<LearningItem> items;

  @override
  List<Object?> get props => <Object?>[query, items];
}

class SearchError extends SearchState {
  const SearchError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
