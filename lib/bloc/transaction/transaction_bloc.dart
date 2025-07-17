import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_maya_exam/bloc/transaction/transaction_event.dart';
import 'package:new_maya_exam/bloc/transaction/transaction_state.dart';
import 'package:new_maya_exam/repository/auth_repository.dart';
import 'package:new_maya_exam/repository/balance_repository.dart';
import 'package:new_maya_exam/models/transaction_model.dart';
// import 'package:new_maya_exam/utils/connectivity_service.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final AuthRepositoryInterface _authRepository;
  final BalanceRepositoryInterface _balanceRepository;

  TransactionBloc({
    required AuthRepositoryInterface authRepository,
    required BalanceRepositoryInterface balanceRepository,
  })  : _authRepository = authRepository,
        _balanceRepository = balanceRepository,
        super(TransactionInitial()) {
    on<SendMoneyToUser>(_onSendMoneyToUser);
    on<LoadTransactionHistory>(_onLoadTransactionHistory);
  }

  Future<void> _onSendMoneyToUser(
      SendMoneyToUser event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());

    try {
      // Check internet connectivity first
      // final isConnected = await ConnectivityService.isConnectedToInternet();
      // if (!isConnected) {
      //   final connectivityStatus =
      //       await ConnectivityService.getConnectivityStatus();
      //   emit(TransactionError(
      //       '$connectivityStatus. Please check your internet connection and try again.'));
      //   return;
      // }

      // Validate amount
      if (event.amount <= 0) {
        emit(const TransactionError('Amount must be greater than zero'));
        return;
      }

      // Get sender's current balance
      final senderBalance =
          await _balanceRepository.getUserBalance(event.senderUid);
      if (senderBalance == null) {
        emit(const TransactionError('Sender balance not found'));
        return;
      }

      // Check if sender has sufficient balance
      if (senderBalance.amount < event.amount) {
        emit(const TransactionError('Insufficient balance'));
        return;
      }

      // Find recipient by email
      print('Looking for recipient with email: ${event.recipientEmail}');
      final recipient =
          await _authRepository.findUserByEmail(event.recipientEmail);
      if (recipient == null) {
        print('Recipient not found in database');
        emit(TransactionError(
            'Recipient with email "${event.recipientEmail}" not found.'));
        return;
      }
      print('Found recipient: ${recipient.uid}');

      // Prevent sending money to yourself
      if (event.senderUid == recipient.uid) {
        emit(const TransactionError('Cannot send money to yourself'));
        return;
      }

      // Get or create recipient's balance
      var recipientBalance =
          await _balanceRepository.getUserBalance(recipient.uid);
      if (recipientBalance == null) {
        // Create balance for recipient if they don't have one
        await _balanceRepository.createUserBalance(recipient.uid, 0.0);
        recipientBalance =
            await _balanceRepository.getUserBalance(recipient.uid);
        if (recipientBalance == null) {
          emit(const TransactionError('Failed to create recipient balance'));
          return;
        }
      }

      // Create transaction records
      final senderTransaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        uid: event.senderUid,
        amount: event.amount,
        type: TransactionType.send,
        description: 'Sent to ${event.recipientEmail}: ${event.description}',
        timestamp: DateTime.now(),
        recipientUid: recipient.uid,
      );

      final recipientTransaction = TransactionModel(
        id: '${DateTime.now().millisecondsSinceEpoch}r',
        uid: recipient.uid,
        amount: event.amount,
        type: TransactionType.receive,
        description:
            'Received from ${FirebaseAuth.instance.currentUser?.email}: ${event.description}',
        timestamp: DateTime.now(),
        senderUid: event.senderUid,
      );

      // Record transactions (balance updates are handled automatically)
      await _balanceRepository.recordTransaction(senderTransaction);
      await _balanceRepository.recordTransaction(recipientTransaction);

      emit(TransactionSuccess(
        'Successfully sent ₱${event.amount.toStringAsFixed(2)} to ${event.recipientEmail}',
      ));
    } catch (e) {
      emit(TransactionError('Transaction failed: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTransactionHistory(
      LoadTransactionHistory event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());

    try {
      // Check internet connectivity first
      // final isConnected = await ConnectivityService.isConnectedToInternet();
      // if (!isConnected) {
      //   final connectivityStatus =
      //       await ConnectivityService.getConnectivityStatus();
      //   emit(TransactionError(
      //       '$connectivityStatus. Please check your internet connection and try again.'));
      //   return;
      // }

      final transactions =
          await _balanceRepository.getUserTransactions(event.uid);
      emit(TransactionHistoryLoaded(transactions));
    } catch (e) {
      emit(TransactionError(
          'Failed to load transaction history: ${e.toString()}'));
    }
  }
}
