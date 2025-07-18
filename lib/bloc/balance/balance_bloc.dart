import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_maya_exam/bloc/balance/balance_event.dart';
import 'package:new_maya_exam/bloc/balance/balance_state.dart';
import 'package:new_maya_exam/repository/balance_repository.dart';
import 'package:new_maya_exam/models/transaction_model.dart';
import 'package:new_maya_exam/utils/debug_utils.dart';
// import 'package:new_maya_exam/utils/connectivity_service.dart';

class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  final BalanceRepositoryInterface _balanceRepository;
  StreamSubscription? _balanceSubscription;

  BalanceBloc(this._balanceRepository) : super(BalanceInitial()) {
    on<LoadBalance>(_onLoadBalance);
    on<UpdateBalance>(_onUpdateBalance);
    on<GetCurrentBalance>(_onGetCurrentBalance);
    on<WatchBalance>(_onWatchBalance);
    on<SendMoney>(_onSendMoney);
  }

  Future<void> _onLoadBalance(
      LoadBalance event, Emitter<BalanceState> emit) async {
    emit(BalanceLoading());
    try {
      final balance = await _balanceRepository.getUserBalance(event.uid);
      if (balance != null) {
        emit(BalanceLoaded(balance));
      } else {
        DebugUtils.debugPrint('No balance found for user: ${event.uid}',
            tag: 'BalanceBloc');
      }
    } catch (e) {
      emit(BalanceError(e.toString()));
    }
  }

  Future<void> _onUpdateBalance(
      UpdateBalance event, Emitter<BalanceState> emit) async {
    try {
      await _balanceRepository.updateUserBalance(event.uid, event.newBalance);
      final updatedBalance = await _balanceRepository.getUserBalance(event.uid);
      if (updatedBalance != null) {
        emit(BalanceUpdated(updatedBalance));
      }
    } catch (e) {
      emit(BalanceError(e.toString()));
    }
  }

  Future<void> _onGetCurrentBalance(
      GetCurrentBalance event, Emitter<BalanceState> emit) async {
    DebugUtils.debugPrint('Getting current balance for UID: ${event.uid}',
        tag: 'BalanceBloc');
    emit(BalanceLoading());

    try {
      // Check internet connectivity first
      // final isConnected = await ConnectivityService.isConnectedToInternet();
      // if (!isConnected) {
      //   final connectivityStatus =
      //       await ConnectivityService.getConnectivityStatus();
      //   emit(BalanceError(
      //       '$connectivityStatus. Please check your internet connection and try again.'));
      //   return;
      // }

      // Check if balance already exists
      final existingBalance =
          await _balanceRepository.getUserBalance(event.uid);
      if (existingBalance != null) {
        DebugUtils.debugPrint(
            'Found existing balance: ${existingBalance.amount}',
            tag: 'BalanceBloc');
        emit(BalanceLoaded(existingBalance));
      } else {
        DebugUtils.debugPrint(
            'No balance found for user: ${event.uid}, creating initial balance',
            tag: 'BalanceBloc');
        // Create initial balance if it doesn't exist
        const double initialBalance = 10000.0;
        await _balanceRepository.createUserBalance(event.uid, initialBalance);

        // Get the created balance to emit
        final newBalance = await _balanceRepository.getUserBalance(event.uid);
        if (newBalance != null) {
          DebugUtils.debugPrint(
              'Successfully created balance: ${newBalance.amount}',
              tag: 'BalanceBloc');
          emit(BalanceLoaded(newBalance));
        } else {
          emit(const BalanceError('Failed to create balance'));
        }
      }
    } catch (e) {
      DebugUtils.errorPrint('Error getting current balance: $e',
          tag: 'BalanceBloc');
      emit(BalanceError(e.toString()));
    }
  }

  Future<void> _onWatchBalance(
      WatchBalance event, Emitter<BalanceState> emit) async {
    DebugUtils.debugPrint('Starting WatchBalance for UID: ${event.uid}',
        tag: 'BalanceBloc');
    await _balanceSubscription?.cancel();

    // First check if balance exists, if not create it
    try {
      DebugUtils.debugPrint('Checking if balance exists for UID: ${event.uid}',
          tag: 'BalanceBloc');
      final existingBalance =
          await _balanceRepository.getUserBalance(event.uid);
      if (existingBalance == null) {
        DebugUtils.debugPrint('No existing balance found, creating new balance',
            tag: 'BalanceBloc');
        // Create initial balance if it doesn't exist
        add(GetCurrentBalance(event.uid));
        return;
      } else {
        DebugUtils.debugPrint(
            'Found existing balance: ${existingBalance.amount}',
            tag: 'BalanceBloc');
      }
    } catch (e) {
      DebugUtils.errorPrint('Error checking existing balance: $e',
          tag: 'BalanceBloc');
      emit(BalanceError(e.toString()));
      return;
    }

    // Start watching for real-time updates
    DebugUtils.debugPrint('Starting real-time balance watcher',
        tag: 'BalanceBloc');
    _balanceSubscription =
        _balanceRepository.watchUserBalance(event.uid).listen(
      (balance) {
        if (balance != null) {
          DebugUtils.debugPrint('Received balance update: ${balance.amount}',
              tag: 'BalanceBloc');
          emit(BalanceLoaded(balance));
        } else {
          DebugUtils.debugPrint('Received null balance from watcher',
              tag: 'BalanceBloc');
        }
      },
      onError: (error) {
        DebugUtils.errorPrint('Error in balance watcher: $error',
            tag: 'BalanceBloc');
        emit(BalanceError(error.toString()));
      },
    );
  }

  Future<void> _onSendMoney(SendMoney event, Emitter<BalanceState> emit) async {
    try {
      // Get current balance
      final currentBalance = await _balanceRepository.getUserBalance(event.uid);
      if (currentBalance == null) {
        emit(const BalanceError('User balance not found'));
        return;
      }

      if (event.amount > currentBalance.amount) {
        emit(const BalanceError('Insufficient balance'));
        return;
      }

      // Create transaction record
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        uid: event.uid,
        amount: event.amount,
        type: TransactionType.send,
        description: event.description,
        timestamp: DateTime.now(),
      );

      // Record transaction and update balance
      final newBalance = currentBalance.amount - event.amount;
      await _balanceRepository.recordTransaction(transaction);
      await _balanceRepository.updateUserBalance(event.uid, newBalance);

      // Get updated balance
      final updatedBalance = await _balanceRepository.getUserBalance(event.uid);
      if (updatedBalance != null) {
        emit(BalanceUpdated(updatedBalance));
      }
    } catch (e) {
      emit(BalanceError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _balanceSubscription?.cancel();
    return super.close();
  }
}
