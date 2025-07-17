import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_maya_exam/widget/common/common_app_bar.dart';
import 'package:new_maya_exam/bloc/transaction/transaction_bloc.dart';
import 'package:new_maya_exam/bloc/transaction/transaction_event.dart';
import 'package:new_maya_exam/bloc/transaction/transaction_state.dart';
import 'package:new_maya_exam/models/transaction_model.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context
          .read<TransactionBloc>()
          .add(LoadTransactionHistory(currentUser.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: CommonAppBar(
            context: context, title: 'Transaction History', showLogout: true),
        body: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransactionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser != null) {
                          context
                              .read<TransactionBloc>()
                              .add(LoadTransactionHistory(currentUser.uid));
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is TransactionHistoryLoaded) {
              final transactions = state.transactions;
              if (transactions.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No transactions found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your transaction history will appear here',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionTile(transaction);
                },
              );
            } else {
              return const Center(
                child: Text('Please wait while we load your transactions...'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildTransactionTile(TransactionModel transaction) {
    final isReceived = transaction.type == TransactionType.receive;
    final isSent = transaction.type == TransactionType.send;

    IconData icon;
    Color iconColor;
    String typeText;

    if (isReceived) {
      icon = Icons.arrow_downward;
      iconColor = Colors.green;
      typeText = 'Received';
    } else if (isSent) {
      icon = Icons.arrow_upward;
      iconColor = Colors.red;
      typeText = 'Sent';
    } else {
      icon = Icons.account_balance_wallet;
      iconColor = Colors.blue;
      typeText = transaction.type.toString().split('.').last.toUpperCase();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          '₱${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isReceived
                ? Colors.green
                : (isSent ? Colors.red : Colors.black),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(transaction.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            typeText,
            style: TextStyle(
              color: iconColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return 'Today at $hour:$minute';
    } else if (difference.inDays == 1) {
      // Yesterday
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return 'Yesterday at $hour:$minute';
    } else {
      // Older dates
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      return '$day/$month/$year';
    }
  }
}
