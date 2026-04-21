import 'package:equatable/equatable.dart';

abstract class AddDataState extends Equatable {
  const AddDataState();

  @override
  List<Object?> get props => const [];
}

class AddDataInitial extends AddDataState {
  const AddDataInitial();
}

class AddDataSaving extends AddDataState {
  const AddDataSaving();
}

class AddDataSuccess extends AddDataState {
  const AddDataSuccess({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

class AddDataError extends AddDataState {
  const AddDataError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
