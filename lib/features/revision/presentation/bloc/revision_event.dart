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

class ReviseItem extends RevisionEvent {
  const ReviseItem();
}
