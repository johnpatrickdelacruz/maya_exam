import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_maya_exam/bloc/auth/auth_bloc.dart';
import 'package:new_maya_exam/bloc/auth/auth_event.dart';
import 'package:new_maya_exam/bloc/auth/auth_state.dart';
import 'package:new_maya_exam/repository/auth_repository.dart';
import 'package:new_maya_exam/models/user_model.dart';
import 'dart:async';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepositoryInterface {}

class MockUser extends Mock implements User {}

class MockUserModel extends Mock implements UserModel {}

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockAuthRepository mockAuthRepository;
    late MockUserModel mockUserModel;
    late StreamController<User?> authStateController;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockUserModel = MockUserModel();
      authStateController = StreamController<User?>();

      // Setup mock UserModel properties
      when(() => mockUserModel.uid).thenReturn('test-uid-123');
      when(() => mockUserModel.email).thenReturn('test@example.com');
      when(() => mockUserModel.displayName).thenReturn('Test User');
      when(() => mockUserModel.emailVerified).thenReturn(true);

      // Mock the auth state changes stream
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStateController.stream);

      authBloc = AuthBloc(authRepository: mockAuthRepository);
    });

    tearDown(() {
      authStateController.close();
      authBloc.close();
    });

    // Test 1: Initial state
    test('initial state is AuthState with initial status', () {
      expect(authBloc.state, const AuthState());
      expect(authBloc.state.status, AuthStatus.initial);
    });

    // Test 2: AuthStarted - authenticated user
    blocTest<AuthBloc, AuthState>(
      'emits authenticated state when user is logged in',
      build: () {
        when(() => mockAuthRepository.getCurrentUser())
            .thenReturn(mockUserModel);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [
        AuthState(
          status: AuthStatus.authenticated,
          user: mockUserModel,
        ),
      ],
    );

    // Test 3: AuthStarted - no user
    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated state when no user is logged in',
      build: () {
        when(() => mockAuthRepository.getCurrentUser()).thenReturn(null);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [
        const AuthState(status: AuthStatus.unauthenticated),
      ],
    );

    // Test 4: Sign in success
    blocTest<AuthBloc, AuthState>(
      'emits loading then authenticated when sign in succeeds',
      build: () {
        when(() => mockAuthRepository.signInWithEmailAndPassword(
                'test@example.com', 'password123'))
            .thenAnswer((_) async => mockUserModel);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignInRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        AuthState(
          status: AuthStatus.authenticated,
          user: mockUserModel,
          errorMessage: null,
        ),
      ],
    );

    // Test 5: Sign in failure
    blocTest<AuthBloc, AuthState>(
      'emits loading then error when sign in returns null',
      build: () {
        when(() => mockAuthRepository.signInWithEmailAndPassword(
            'test@example.com', 'password123')).thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignInRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Sign in failed. Please check your credentials.',
        ),
      ],
    );

    // Test 6: Sign in validation - empty email
    blocTest<AuthBloc, AuthState>(
      'emits error when email is empty',
      build: () => authBloc,
      act: (bloc) => bloc.add(const AuthSignInRequested(
        email: '',
        password: 'password123',
      )),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Please enter both email and password.',
        ),
      ],
    );

    // Test 7: Sign in validation - invalid email format
    blocTest<AuthBloc, AuthState>(
      'emits error when email format is invalid',
      build: () => authBloc,
      act: (bloc) => bloc.add(const AuthSignInRequested(
        email: 'invalid-email',
        password: 'password123',
      )),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Please enter a valid email address.',
        ),
      ],
    );

    // Test 8: Sign out success
    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated state when sign out succeeds',
      build: () {
        when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.unauthenticated),
      ],
    );

    // Test 9: Sign out failure
    blocTest<AuthBloc, AuthState>(
      'emits error when sign out fails',
      build: () {
        when(() => mockAuthRepository.signOut())
            .thenThrow(Exception('sign-out-failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Authentication failed. Please try again.',
        ),
      ],
    );

    // Test 10: Firebase error handling
    blocTest<AuthBloc, AuthState>(
      'emits Firebase-specific error message for user-not-found',
      build: () {
        when(() => mockAuthRepository.signInWithEmailAndPassword(
                'test@example.com', 'password123'))
            .thenThrow(Exception('user-not-found'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignInRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.error,
          errorMessage: 'No user found with this email address.',
        ),
      ],
    );
  });
}
