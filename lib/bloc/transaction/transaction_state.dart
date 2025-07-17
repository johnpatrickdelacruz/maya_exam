import 'package:equatable/equatable.dart';
import 'package:new_maya_exam/models/transaction_model.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionSuccess extends TransactionState {
  final String message;

  const TransactionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object> get props => [message];
}

class TransactionHistoryLoaded extends TransactionState {
  final List<TransactionModel> transactions;

  const TransactionHistoryLoaded(this.transactions);

  @override
  List<Object> get props => [transactions];
}
