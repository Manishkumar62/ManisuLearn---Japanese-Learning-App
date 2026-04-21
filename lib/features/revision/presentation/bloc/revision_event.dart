import 'package:equatable/equatable.dart';

abstract class RevisionEvent extends Equatable {
  const RevisionEvent();

  @override
  List<Object?> get props => const [];
}

class LoadRevisionItems extends RevisionEvent {
  const LoadRevisionItems();
}

class RevealRevisionAnswer extends RevisionEvent {
  const RevealRevisionAnswer();
}

class SkipRevisionItem extends RevisionEvent {
  const SkipRevisionItem();
}

class ReviewItem extends RevisionEvent {
  const ReviewItem({required this.isCorrect});

  final bool isCorrect;

  @override
  List<Object?> get props => <Object?>[isCorrect];
}
