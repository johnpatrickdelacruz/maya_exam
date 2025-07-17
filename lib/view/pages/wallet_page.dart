import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_maya_exam/widget/common/common_app_bar.dart';
import 'package:new_maya_exam/widget/common/common_button.dart';
import 'package:new_maya_exam/bloc/balance/balance_bloc.dart';
import 'package:new_maya_exam/bloc/balance/balance_event.dart';
import 'package:new_maya_exam/bloc/balance/balance_state.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with WidgetsBindingObserver {
  bool _showBalance = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBalance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh balance when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadBalance();
    }
  }

  void _loadBalance() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<BalanceBloc>().add(GetCurrentBalance(user.uid));
      context.read<BalanceBloc>().add(WatchBalance(user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'Wallet', showLogout: true),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Transaction History'),
              onTap: () async {
                Navigator.pop(context);
                await context.push('/history');
                // Refresh balance after returning from history
                _loadBalance();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<BalanceBloc, BalanceState>(
              builder: (context, state) {
                if (state is BalanceLoading) {
                  return const CircularProgressIndicator();
                } else if (state is BalanceLoaded) {
                  final balance = state.balance.amount;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showBalance
                            ? '₱${balance.toStringAsFixed(2)}'
                            : '••••••',
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(_showBalance
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _showBalance = !_showBalance;
                          });
                        },
                      ),
                    ],
                  );
                } else if (state is BalanceError) {
                  return Column(
                    children: [
                      Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            context
                                .read<BalanceBloc>()
                                .add(GetCurrentBalance(user.uid));
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                } else {
                  return const Text(
                    'No balance data',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            CommonButton(
              text: 'Send Money',
              onPressed: () async {
                // Navigate to transaction page and refresh balance when returning
                await context.push('/transaction');
                // Refresh balance after returning from transaction
                _loadBalance();
              },
            ),
            const SizedBox(height: 16),
            CommonButton(
              text: 'View Transactions',
              onPressed: () async {
                // Navigate to history page and refresh balance when returning
                await context.push('/history');
                // Refresh balance after returning from history
                _loadBalance();
              },
            ),
          ],
        ),
      ),
    );
  }
}
