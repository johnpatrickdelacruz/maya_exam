import 'package:equatable/equatable.dart';

abstract class BalanceEvent extends Equatable {
  const BalanceEvent();

  @override
  List<Object> get props => [];
}

class LoadBalance extends BalanceEvent {
  final String uid;

  const LoadBalance(this.uid);

  @override
  List<Object> get props => [uid];
}

class UpdateBalance extends BalanceEvent {
  final String uid;
  final double newBalance;

  const UpdateBalance(this.uid, this.newBalance);

  @override
  List<Object> get props => [uid, newBalance];
}

class GetCurrentBalance extends BalanceEvent {
  final String uid;

  const GetCurrentBalance(this.uid);

  @override
  List<Object> get props => [uid];
}

class WatchBalance extends BalanceEvent {
  final String uid;

  const WatchBalance(this.uid);

  @override
  List<Object> get props => [uid];
}

class SendMoney extends BalanceEvent {
  final String uid;
  final double amount;
  final String description;

  const SendMoney(this.uid, this.amount, this.description);

  @override
  List<Object> get props => [uid, amount, description];
}
