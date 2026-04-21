import 'package:equatable/equatable.dart';

enum LibraryTypeFilter { all, words, sentences, stories }

enum LibraryProgressFilter { all, learned, notLearned, needsRevision }

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => const [];
}

class LoadLibrary extends LibraryEvent {
  const LoadLibrary();
}

class FilterLibrary extends LibraryEvent {
  const FilterLibrary({
    this.searchQuery = '',
    this.typeFilter = LibraryTypeFilter.all,
    this.progressFilter = LibraryProgressFilter.all,
  });

  final String searchQuery;
  final LibraryTypeFilter typeFilter;
  final LibraryProgressFilter progressFilter;

  @override
  List<Object?> get props => <Object?>[searchQuery, typeFilter, progressFilter];
}
