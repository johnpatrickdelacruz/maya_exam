import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryInterface _authRepository;
  late StreamSubscription _authStateSubscription;

  AuthBloc({required AuthRepositoryInterface authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthUserChanged>(_onUserChanged);

    // Listen to auth state changes
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        add(AuthUserChanged(isAuthenticated: user != null));
      },
    );
  }

  Future<void> _onAuthStarted(
      AuthStarted event, Emitter<AuthState> emit) async {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onSignInRequested(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    // Input validation
    if (event.email.trim().isEmpty || event.password.trim().isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter both email and password.',
      ));
      return;
    }

    if (!_isValidEmail(event.email.trim())) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter a valid email address.',
      ));
      return;
    }

    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        event.email.trim(),
        event.password,
      );
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Sign in failed. Please check your credentials.',
        ));
      }
    } catch (e) {
      String errorMessage = _getErrorMessage(e.toString());
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onSignOutRequested(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.signOut();
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      ));
    } catch (e) {
      String errorMessage = _getErrorMessage(e.toString());
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onUserChanged(
      AuthUserChanged event, Emitter<AuthState> emit) async {
    if (event.isAuthenticated) {
      final user = _authRepository.getCurrentUser();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ));
    }
  }

  String _getErrorMessage(String error) {
    // Handle common Firebase Auth error messages
    if (error.contains('user-not-found')) {
      return 'No user found with this email address.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('user-disabled')) {
      return 'This user account has been disabled.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('invalid-credential')) {
      return 'Invalid credentials. Please check your email and password.';
    } else {
      // Return a user-friendly generic message for unknown errors
      return 'Authentication failed. Please try again.';
    }
  }

  bool _isValidEmail(String email) {
    // Basic email validation using RegExp
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
