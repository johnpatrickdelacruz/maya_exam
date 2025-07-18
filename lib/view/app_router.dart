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
import 'package:new_maya_exam/utils/debug_utils.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthChangeNotifier(),
    redirect: (context, state) {
      final authBloc = getIt<AuthBloc>();
      final authState = authBloc.state;

      final isGoingToLogin = state.matchedLocation == '/';
      final isAuthenticated = authState.status == AuthStatus.authenticated;

      DebugUtils.debugPrint(
          'Router redirect - Location: ${state.matchedLocation}, Auth Status: ${authState.status}',
          tag: 'AppRouter');

      // If not authenticated and not going to login, redirect to login
      if (!isAuthenticated && !isGoingToLogin) {
        DebugUtils.debugPrint('Redirecting to login', tag: 'AppRouter');
        return '/';
      }

      // If authenticated and going to login, redirect to wallet
      if (isAuthenticated && isGoingToLogin) {
        DebugUtils.debugPrint('Redirecting to wallet', tag: 'AppRouter');
        return '/wallet';
      }

      // No redirect needed
      DebugUtils.debugPrint('No redirect needed', tag: 'AppRouter');
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
      DebugUtils.debugPrint('Auth state changed: ${state.status}',
          tag: 'AppRouter');
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
