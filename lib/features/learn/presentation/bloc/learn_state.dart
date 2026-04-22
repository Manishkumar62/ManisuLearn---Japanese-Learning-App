import 'package:equatable/equatable.dart';

import '../../../../data/models/learning_item.dart';

abstract class LearnState extends Equatable {
  const LearnState();

  @override
  List<Object?> get props => const [];
}

class LearnInitial extends LearnState {
  const LearnInitial();
}

class LearnLoading extends LearnState {
  const LearnLoading();
}

class LearnLoaded extends LearnState {
  const LearnLoaded({
    required this.items,
    required this.currentIndex,
    this.isAnswerVisible = false,
  });

  final List<LearningItem> items;
  final int currentIndex;
  final bool isAnswerVisible;

  LearningItem? get currentItem =>
      (items.isEmpty || currentIndex >= items.length)
      ? null
      : items[currentIndex];

  int get completedCount => currentIndex;

  int get totalCount => items.length;

  @override
  List<Object?> get props => <Object?>[items, currentIndex, isAnswerVisible];
}

class LearnCompleted extends LearnState {
  const LearnCompleted();
}

class LearnError extends LearnState {
  const LearnError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
