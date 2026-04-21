import 'package:equatable/equatable.dart';

import '../../../../data/models/learning_item.dart';

abstract class RevisionState extends Equatable {
  const RevisionState();

  @override
  List<Object?> get props => const [];
}

class RevisionInitial extends RevisionState {
  const RevisionInitial();
}

class RevisionLoading extends RevisionState {
  const RevisionLoading();
}

class RevisionLoaded extends RevisionState {
  const RevisionLoaded({
    required this.items,
    required this.currentIndex,
    this.isAnswerVisible = false,
  });

  final List<LearningItem> items;
  final int currentIndex;
  final bool isAnswerVisible;

  LearningItem get currentItem => items[currentIndex];

  int get completedCount => currentIndex;

  int get totalCount => items.length;

  @override
  List<Object?> get props => <Object?>[items, currentIndex, isAnswerVisible];
}

class RevisionCompleted extends RevisionState {
  const RevisionCompleted();
}

class RevisionError extends RevisionState {
  const RevisionError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
