import 'package:equatable/equatable.dart';

abstract class LearnEvent extends Equatable {
  const LearnEvent();

  @override
  List<Object?> get props => const [];
}

class LoadLearningItems extends LearnEvent {
  const LoadLearningItems();
}

class RevealLearningAnswer extends LearnEvent {
  const RevealLearningAnswer();
}

class SkipLearningItem extends LearnEvent {
  const SkipLearningItem();
}

class MarkLearned extends LearnEvent {
  const MarkLearned();
}

class MarkLearnedFromLibrary extends LearnEvent {
  final String id;
  const MarkLearnedFromLibrary(this.id);
}