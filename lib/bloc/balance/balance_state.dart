import 'package:equatable/equatable.dart';
import 'package:new_maya_exam/models/balance_model.dart';

abstract class BalanceState extends Equatable {
  const BalanceState();

  @override
  List<Object?> get props => [];
}

class BalanceInitial extends BalanceState {}

class BalanceLoading extends BalanceState {}

class BalanceLoaded extends BalanceState {
  final BalanceModel balance;

  const BalanceLoaded(this.balance);

  @override
  List<Object> get props => [balance];
}

class BalanceError extends BalanceState {
  final String message;

  const BalanceError(this.message);

  @override
  List<Object> get props => [message];
}

class BalanceUpdated extends BalanceState {
  final BalanceModel balance;

  const BalanceUpdated(this.balance);

  @override
  List<Object> get props => [balance];
}
