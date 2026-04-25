import 'package:equatable/equatable.dart';

import '../../../../data/models/learning_item.dart';

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
  const LibraryLoaded({required this.items, this.hasMore = false});

  final List<LearningItem> items;
  final bool hasMore;

  @override
  List<Object?> get props => <Object?>[items, hasMore];
}

class LibraryError extends LibraryState {
  const LibraryError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
