import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_maya_exam/widget/common/common_app_bar.dart';
import 'package:new_maya_exam/widget/common/common_button.dart';
import 'package:new_maya_exam/widget/common/common_app_text.dart';
import 'package:new_maya_exam/bloc/balance/balance_bloc.dart';
import 'package:new_maya_exam/bloc/balance/balance_event.dart';
import 'package:new_maya_exam/bloc/balance/balance_state.dart';
import 'package:new_maya_exam/utils/app_strings.dart';

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
      appBar: CommonAppBar(
          context: context, title: AppStrings.titleWallet, showLogout: true),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 8),
                  AppText.labelLarge(
                    FirebaseAuth.instance.currentUser?.email ??
                        AppStrings.noEmailAvailable,
                    color: Colors.white70,
                  ),
                ],
              ),
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
                      AppText.currency(
                        _showBalance
                            ? AppStrings.formatCurrency(balance)
                            : AppStrings.balanceHidden,
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
                      AppText.error(
                        AppStrings.formatError(state.message),
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
                        child: const AppText.labelLarge(AppStrings.buttonRetry),
                      ),
                    ],
                  );
                } else {
                  return const AppText.headlineLarge(
                    AppStrings.noBalanceData,
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            CommonButton(
              text: AppStrings.buttonSendMoney,
              onPressed: () async {
                await context.push(AppStrings.routeTransaction);
                _loadBalance();
              },
            ),
            const SizedBox(height: 16),
            CommonButton(
              text: AppStrings.buttonViewTransactions,
              onPressed: () async {
                await context.push(AppStrings.routeHistory);
                _loadBalance();
              },
            ),
          ],
        ),
      ),
    );
  }
}
