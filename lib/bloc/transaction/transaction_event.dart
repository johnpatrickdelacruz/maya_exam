import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class SendMoneyToUser extends TransactionEvent {
  final String senderUid;
  final String recipientEmail;
  final double amount;
  final String description;

  const SendMoneyToUser({
    required this.senderUid,
    required this.recipientEmail,
    required this.amount,
    required this.description,
  });

  @override
  List<Object> get props => [senderUid, recipientEmail, amount, description];
}

class LoadTransactionHistory extends TransactionEvent {
  final String uid;

  const LoadTransactionHistory(this.uid);

  @override
  List<Object> get props => [uid];
}
