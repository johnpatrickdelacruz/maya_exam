import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:new_maya_exam/view/pages/login_page.dart';
import 'package:new_maya_exam/view/pages/transaction_history_page.dart';
import 'package:new_maya_exam/view/pages/transaction_page.dart';
import 'package:new_maya_exam/view/pages/wallet_page.dart';
import 'package:new_maya_exam/bloc/auth/auth_bloc.dart';
import 'package:new_maya_exam/bloc/auth/auth_state.dart';
import 'package:new_maya_exam/services/service_locator.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthChangeNotifier(),
    redirect: (context, state) {
      final authBloc = getIt<AuthBloc>();
      final authState = authBloc.state;

      final isGoingToLogin = state.matchedLocation == '/';
      final isAuthenticated = authState.status == AuthStatus.authenticated;

      print(
          'Router redirect - Location: ${state.matchedLocation}, Auth Status: ${authState.status}');

      // If not authenticated and not going to login, redirect to login
      if (!isAuthenticated && !isGoingToLogin) {
        print('Redirecting to login');
        return '/';
      }

      // If authenticated and going to login, redirect to wallet
      if (isAuthenticated && isGoingToLogin) {
        print('Redirecting to wallet');
        return '/wallet';
      }

      // No redirect needed
      print('No redirect needed');
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: '/transaction',
        builder: (context, state) => const TransactionPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const TransactionHistoryPage(),
      ),
    ],
  );
}

class _AuthChangeNotifier extends ChangeNotifier {
  late StreamSubscription _subscription;

  _AuthChangeNotifier() {
    final authBloc = getIt<AuthBloc>();
    _subscription = authBloc.stream.listen((state) {
      print('Auth state changed: ${state.status}');
      // Notify listeners when auth state changes
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
