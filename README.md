# Maya Exam - Flutter App

A Flutter application demonstrating BLoC pattern with unit testing.

## Features

- **Authentication**: Sign in/out with Firebase Auth
- **Balance Management**: View, update, and manage user balances
- **Money Transfers**: Send money between users via email
- **Transaction History**: Track all financial transactions
- **Real-time Updates**: Live balance monitoring
- **Unit Testing**: Unit tests with BLoC pattern testing

## Architecture

This project follows Clean Architecture principles with:
- **BLoC Pattern**: State management for Auth, Balance, and Transaction features
- **Repository Pattern**: Data abstraction layer
- **Service Locator**: Dependency injection
- **Firebase Integration**: Authentication and Firestore database

## Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/johnpatrickdelacruz/maya_exam.git
cd new_maya_exam
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration
Ensure you have the following Firebase configuration files:
- `android/app/google-services.json` (for Android)

## Running the Application

### Development Mode
```bash
# Run on connected device/emulator
flutter run
```

## Unit Testing

This project includes unit tests for BLoC components:

### Test Coverage
- **Auth BLoC**: tests covering authentication, validation, and error handling
- **Balance BLoC**: tests covering balance operations, money sending, and edge cases
- **Transaction BLoC**: tests covering money transfers, transaction history, and validation

### Running All Tests
```bash
# Run all unit tests
flutter test
```

### Running Specific Test Suites
```bash
# Run only Auth BLoC tests
flutter test test/bloc/auth/auth_bloc_test.dart

# Run only Balance BLoC tests
flutter test test/bloc/balance/balance_bloc_test.dart

# Run only Transaction BLoC tests
flutter test test/bloc/transaction/transaction_bloc_test.dart
```

### Running Individual Tests
```bash
# Run a specific test by name
flutter test --plain-name "AuthBloc initial state is AuthState with initial status"
```

## Testing Framework

The project uses the following testing packages:

- **flutter_test**: Core Flutter testing framework
- **bloc_test**: Specialized testing for BLoC pattern
- **mocktail**: Modern mocking framework for Dart


## Key Testing Patterns

### 1. BLoC Test Structure
- **build**: Setup mocks and return BLoC instance
- **act**: Trigger the event to test
- **expect**: Define expected state emissions


## Project Structure

```
lib/
├── bloc/               # BLoC state management
│   ├── auth/          # Authentication BLoC
│   ├── balance/       # Balance management BLoC
│   └── transaction/   # Transaction BLoC
├── models/            # Data models
├── repository/        # Data access layer
├── services/          # Service layer
├── utils/             # Utility functions
├── view/              # UI components
└── main.dart          # App entry point

test/
└── bloc/              # BLoC unit tests
    ├── auth/          # Auth BLoC tests
    ├── balance/       # Balance BLoC tests
    └── transaction/   # Transaction BLoC tests
```

