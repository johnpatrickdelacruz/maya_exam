import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/balance_model.dart';
import '../models/transaction_model.dart';
import '../utils/debug_utils.dart';

abstract class BalanceRepositoryInterface {
  Future<BalanceModel?> getUserBalance(String uid);
  Future<void> updateUserBalance(String uid, double amount);
  Future<void> createUserBalance(String uid, double initialBalance);
  Stream<BalanceModel?> watchUserBalance(String uid);
  Future<void> recordTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getUserTransactions(String uid);
}

class BalanceRepository implements BalanceRepositoryInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<BalanceModel?> getUserBalance(String uid) async {
    try {
      final doc = await _firestore.collection('user_balances').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return BalanceModel(
          userId: uid,
          amount: (data['amount'] as num).toDouble(),
          lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
        );
      }
      return null;
    } catch (e) {
      DebugUtils.errorPrint('Error getting user balance: $e',
          tag: 'BalanceRepository');
      return null;
    }
  }

  @override
  Future<void> updateUserBalance(String uid, double amount) async {
    try {
      await _firestore.collection('user_balances').doc(uid).update({
        'amount': amount,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      DebugUtils.errorPrint('Error updating user balance: $e',
          tag: 'BalanceRepository');
      rethrow;
    }
  }

  @override
  Future<void> createUserBalance(String uid, double initialBalance) async {
    try {
      await _firestore.collection('user_balances').doc(uid).set({
        'userId': uid,
        'amount': initialBalance,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      DebugUtils.errorPrint('Error creating user balance: $e',
          tag: 'BalanceRepository');
      rethrow;
    }
  }

  @override
  Stream<BalanceModel?> watchUserBalance(String uid) {
    return _firestore
        .collection('user_balances')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        return BalanceModel(
          userId: uid,
          amount: (data['amount'] as num).toDouble(),
          lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
        );
      }
      return null;
    });
  }

  @override
  Future<void> recordTransaction(TransactionModel transaction) async {
    try {
      // Use a batch write to ensure atomicity
      final batch = _firestore.batch();

      // Add the transaction
      final transactionRef = _firestore.collection('transactions').doc();
      batch.set(transactionRef, transaction.toJson());

      // Update the user's balance
      final balanceRef =
          _firestore.collection('user_balances').doc(transaction.uid);

      // Get current balance to calculate new amount
      final currentBalanceDoc = await balanceRef.get();
      if (currentBalanceDoc.exists) {
        final currentAmount =
            (currentBalanceDoc.data()!['amount'] as num).toDouble();
        double newAmount;

        // Calculate new balance based on transaction type
        if (transaction.type == TransactionType.send) {
          newAmount = currentAmount - transaction.amount;
        } else if (transaction.type == TransactionType.receive) {
          newAmount = currentAmount + transaction.amount;
        } else {
          // For other transaction types, don't modify balance
          newAmount = currentAmount;
        }

        batch.update(balanceRef, {
          'amount': newAmount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      DebugUtils.errorPrint('Error recording transaction: $e',
          tag: 'BalanceRepository');
      rethrow;
    }
  }

  @override
  Future<List<TransactionModel>> getUserTransactions(String uid) async {
    try {
      final query = await _firestore
          .collection('transactions')
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      DebugUtils.errorPrint('Error getting user transactions: $e',
          tag: 'BalanceRepository');
      return [];
    }
  }
}
