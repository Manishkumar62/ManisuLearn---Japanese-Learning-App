import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_utils.dart';
import '../../../../data/models/learning_item.dart';
import '../../../../domain/repositories/learning_item_repository.dart';

abstract class ReviewQueueEvent extends Equatable {
  const ReviewQueueEvent();

  @override
  List<Object?> get props => const [];
}

class LoadDueItems extends ReviewQueueEvent {
  const LoadDueItems({this.now});

  final DateTime? now;

  @override
  List<Object?> get props => <Object?>[now];
}

abstract class ReviewQueueState extends Equatable {
  const ReviewQueueState();

  @override
  List<Object?> get props => const [];
}

class ReviewQueueInitial extends ReviewQueueState {
  const ReviewQueueInitial();
}

class ReviewQueueLoading extends ReviewQueueState {
  const ReviewQueueLoading();
}

class DueItemsLoaded extends ReviewQueueState {
  const DueItemsLoaded({required this.dueItems});

  final List<LearningItem> dueItems;

  int get dueCount => dueItems.length;

  bool get hasDueItems => dueItems.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[dueItems];
}

class ReviewQueueError extends ReviewQueueState {
  const ReviewQueueError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

class ReviewQueueBloc extends Bloc<ReviewQueueEvent, ReviewQueueState> {
  ReviewQueueBloc({required LearningItemRepository repository})
    : _repository = repository,
      super(const ReviewQueueInitial()) {
    on<LoadDueItems>(_onLoadDueItems);
  }

  final LearningItemRepository _repository;

  Future<void> _onLoadDueItems(
    LoadDueItems event,
    Emitter<ReviewQueueState> emit,
  ) async {
    emit(const ReviewQueueLoading());

    try {
      final dueItems = await _repository.getDueItems(now: event.now);
      final sorted = dueItems.toList()
        ..sort((a, b) => a.nextReview.compareTo(b.nextReview));
      emit(DueItemsLoaded(dueItems: sorted));
    } catch (error) {
      emit(ReviewQueueError(AppError.userMessage(error)));
    }
  }
}
