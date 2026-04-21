import 'package:equatable/equatable.dart';

import '../../../../data/models/learning_item.dart';
import 'library_event.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => const [];
}

class LibraryInitial extends LibraryState {
  const LibraryInitial();
}

class LibraryLoading extends LibraryState {
  const LibraryLoading();
}

class LibraryLoaded extends LibraryState {
  const LibraryLoaded({
    required this.items,
    this.searchQuery = '',
    this.typeFilter = LibraryTypeFilter.all,
    this.progressFilter = LibraryProgressFilter.all,
  });

  final List<LearningItem> items;
  final String searchQuery;
  final LibraryTypeFilter typeFilter;
  final LibraryProgressFilter progressFilter;

  @override
  List<Object?> get props => <Object?>[
    items,
    searchQuery,
    typeFilter,
    progressFilter,
  ];
}

class LibraryError extends LibraryState {
  const LibraryError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
