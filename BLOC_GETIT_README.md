# BLoC and GetIt Implementation

This Flutter project demonstrates the implementation of BLoC (Business Logic Component) pattern with GetIt dependency injection.

## Architecture

### 1. Dependency Injection (GetIt)
- **Service Locator**: `lib/services/service_locator.dart`
  - Registers all dependencies
  - Uses singleton pattern for repositories
  - Uses factory pattern for BLoCs

### 2. BLoC Pattern
- **AuthBloc**: `lib/bloc/auth/`
  - Handles authentication state management
  - Events: `AuthStarted`, `AuthSignInRequested`, `AuthSignUpRequested`, `AuthSignOutRequested`
  - States: `initial`, `loading`, `authenticated`, `unauthenticated`, `error`

### 3. Repository Pattern
- **AuthRepository**: `lib/repository/auth_repository.dart` (Firebase implementation)
- **MockAuthRepository**: `lib/repository/mock_auth_repository.dart` (Development/Testing)

## Dependencies Added

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  get_it: ^7.6.4
  equatable: ^2.0.5

dev_dependencies:
  bloc_test: ^9.1.4
  mockito: ^5.4.2
  build_runner: ^2.4.7
```

## Key Features

### 1. Service Locator Setup
```dart
// Setup in main.dart
await setupServiceLocator();

// Register dependencies
sl.registerLazySingleton<AuthRepositoryInterface>(() => MockAuthRepository());
sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl()));
```

### 2. BLoC Provider Integration
```dart
// In MyApp widget
BlocProvider(
  create: (context) => sl<AuthBloc>()..add(AuthStarted()),
  child: MaterialApp.router(
    routerConfig: AppRouter.router,
    // ...
  ),
)
```

### 3. Login Page with BLoC
- Uses `BlocListener` for side effects (navigation, error messages)
- Uses `BlocBuilder` for UI state changes
- Handles loading states and error states

### 4. Authentication Flow
1. User enters email/password
2. `AuthSignInRequested` event is dispatched
3. BLoC calls repository method
4. Repository returns user or throws error
5. BLoC emits new state
6. UI reacts to state changes

## Testing

Basic test structure is set up with:
- Service locator tests
- BLoC tests using `bloc_test` package
- Mock repository for isolated testing

## Usage

### Login
- Email: Any email containing "test"
- Password: "password"

### Sign Out
- Click logout button in app bar
- Confirmation dialog appears
- BLoC handles sign out logic

## Future Enhancements

1. **Firebase Integration**: Replace MockAuthRepository with Firebase implementation
2. **Persistent State**: Add shared preferences for remember me functionality
3. **Error Handling**: Enhanced error handling with custom exceptions
4. **Loading States**: Better loading indicators and progress states
5. **Route Guards**: Protect routes based on authentication state

## File Structure

```
lib/
├── bloc/
│   └── auth/
│       ├── auth_bloc.dart
│       ├── auth_event.dart
│       └── auth_state.dart
├── models/
│   └── user_model.dart
├── repository/
│   ├── auth_repository.dart
│   └── mock_auth_repository.dart
├── services/
│   └── service_locator.dart
├── view/
│   ├── app_router.dart
│   └── pages/
│       ├── login_page.dart
│       └── wallet_page.dart
└── main.dart
```

This implementation provides a solid foundation for scalable Flutter applications using BLoC pattern with dependency injection.
