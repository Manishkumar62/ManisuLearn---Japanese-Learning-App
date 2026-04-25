import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => const [];
}

class QueryChanged extends SearchEvent {
  const QueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

class LoadMoreResults extends SearchEvent {
  const LoadMoreResults();
}
