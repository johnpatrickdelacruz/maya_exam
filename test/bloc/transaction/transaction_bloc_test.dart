import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:new_maya_exam/bloc/transaction/transaction_bloc.dart';
import 'package:new_maya_exam/bloc/transaction/transaction_event.dart';
import 'package:new_maya_exam/bloc/transaction/transaction_state.dart';
import 'package:new_maya_exam/repository/auth_repository.dart';
import 'package:new_maya_exam/repository/balance_repository.dart';
import 'package:new_maya_exam/models/balance_model.dart';
import 'package:new_maya_exam/models/transaction_model.dart';
import 'package:new_maya_exam/models/user_model.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepositoryInterface {}

class MockBalanceRepository extends Mock
    implements BalanceRepositoryInterface {}

class MockBalanceModel extends Mock implements BalanceModel {}

class MockUserModel extends Mock implements UserModel {}

class MockTransactionModel extends Mock implements TransactionModel {}

// Fake classes for fallback values
class FakeTransactionModel extends Fake implements TransactionModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTransactionModel());
  });

  group('TransactionBloc', () {
    late TransactionBloc transactionBloc;
    late MockAuthRepository mockAuthRepository;
    late MockBalanceRepository mockBalanceRepository;
    late MockBalanceModel mockSenderBalance;
    late MockBalanceModel mockRecipientBalance;
    late MockUserModel mockRecipient;
    late MockTransactionModel mockTransaction;

    const testSenderUid = 'sender-uid-123';
    const testRecipientEmail = 'recipient@test.com';
    const testRecipientUid = 'recipient-uid-456';
    const testAmount = 1000.0;
    const testDescription = 'Test payment';
    const testSenderBalance = 5000.0;
    const testRecipientBalance = 2000.0;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockBalanceRepository = MockBalanceRepository();
      mockSenderBalance = MockBalanceModel();
      mockRecipientBalance = MockBalanceModel();
      mockRecipient = MockUserModel();
      mockTransaction = MockTransactionModel();

      // Setup mock sender balance
      when(() => mockSenderBalance.userId).thenReturn(testSenderUid);
      when(() => mockSenderBalance.amount).thenReturn(testSenderBalance);
      when(() => mockSenderBalance.lastUpdated).thenReturn(DateTime.now());

      // Setup mock recipient balance
      when(() => mockRecipientBalance.userId).thenReturn(testRecipientUid);
      when(() => mockRecipientBalance.amount).thenReturn(testRecipientBalance);
      when(() => mockRecipientBalance.lastUpdated).thenReturn(DateTime.now());

      // Setup mock recipient user
      when(() => mockRecipient.uid).thenReturn(testRecipientUid);
      when(() => mockRecipient.email).thenReturn(testRecipientEmail);
      when(() => mockRecipient.emailVerified).thenReturn(true);

      // Setup mock transaction
      when(() => mockTransaction.id).thenReturn('test-transaction-id');
      when(() => mockTransaction.uid).thenReturn(testSenderUid);
      when(() => mockTransaction.amount).thenReturn(testAmount);
      when(() => mockTransaction.type).thenReturn(TransactionType.send);
      when(() => mockTransaction.description).thenReturn(testDescription);
      when(() => mockTransaction.timestamp).thenReturn(DateTime.now());

      transactionBloc = TransactionBloc(
        authRepository: mockAuthRepository,
        balanceRepository: mockBalanceRepository,
      );
    });

    tearDown(() {
      transactionBloc.close();
    });

    // Test 1: Initial state
    test('initial state is TransactionInitial', () {
      expect(transactionBloc.state, isA<TransactionInitial>());
    });

    // Test 2: SendMoneyToUser - amount validation error
    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionError when SendMoneyToUser amount is zero or negative',
      build: () => transactionBloc,
      act: (bloc) => bloc.add(const SendMoneyToUser(
        senderUid: testSenderUid,
        recipientEmail: testRecipientEmail,
        amount: 0.0,
        description: testDescription,
      )),
      expect: () => [
        TransactionLoading(),
        const TransactionError('Amount must be greater than zero'),
      ],
    );

    // Test 3: SendMoneyToUser - sender balance not found
    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionError when sender balance not found',
      build: () {
        when(() => mockBalanceRepository.getUserBalance(testSenderUid))
            .thenAnswer((_) async => null);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const SendMoneyToUser(
        senderUid: testSenderUid,
        recipientEmail: testRecipientEmail,
        amount: testAmount,
        description: testDescription,
      )),
      expect: () => [
        TransactionLoading(),
        const TransactionError('Sender balance not found'),
      ],
    );

    // Test 4: SendMoneyToUser - insufficient balance
    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionError when sender has insufficient balance',
      build: () {
        final insufficientBalance = MockBalanceModel();
        when(() => insufficientBalance.amount).thenReturn(500.0);
        when(() => mockBalanceRepository.getUserBalance(testSenderUid))
            .thenAnswer((_) async => insufficientBalance);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const SendMoneyToUser(
        senderUid: testSenderUid,
        recipientEmail: testRecipientEmail,
        amount: testAmount,
        description: testDescription,
      )),
      expect: () => [
        TransactionLoading(),
        const TransactionError('Insufficient balance'),
      ],
    );

    // Test 5: SendMoneyToUser - recipient not found
    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionError when recipient is not found',
      build: () {
        when(() => mockBalanceRepository.getUserBalance(testSenderUid))
            .thenAnswer((_) async => mockSenderBalance);
        when(() => mockAuthRepository.findUserByEmail(testRecipientEmail))
            .thenAnswer((_) async => null);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const SendMoneyToUser(
        senderUid: testSenderUid,
        recipientEmail: testRecipientEmail,
        amount: testAmount,
        description: testDescription,
      )),
      expect: () => [
        TransactionLoading(),
        const TransactionError(
          'Recipient with email "$testRecipientEmail" not found.',
        ),
      ],
    );

    // Test 6: SendMoneyToUser - cannot send to yourself
    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionError when trying to send money to yourself',
      build: () {
        final selfRecipient = MockUserModel();
        when(() => selfRecipient.uid).thenReturn(testSenderUid);
        when(() => selfRecipient.email).thenReturn('sender@test.com');

        when(() => mockBalanceRepository.getUserBalance(testSenderUid))
            .thenAnswer((_) async => mockSenderBalance);
        when(() => mockAuthRepository.findUserByEmail('sender@test.com'))
            .thenAnswer((_) async => selfRecipient);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const SendMoneyToUser(
        senderUid: testSenderUid,
        recipientEmail: 'sender@test.com',
        amount: testAmount,
        description: testDescription,
      )),
      expect: () => [
        TransactionLoading(),
        const TransactionError('Cannot send money to yourself'),
      ],
    );

    // Test 7: SendMoneyToUser - fails to create recipient balance
    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionError when fails to create recipient balance',
      build: () {
        when(() => mockBalanceRepository.getUserBalance(testSenderUid))
            .thenAnswer((_) async => mockSenderBalance);
        when(() => mockAuthRepository.findUserByEmail(testRecipientEmail))
            .thenAnswer((_) async => mockRecipient);
        when(() => mockBalanceRepository.getUserBalance(testRecipientUid))
            .thenAnswer((_) async => null);
        when(() =>
                mockBalanceRepository.createUserBalance(testRecipientUid, 0.0))
            .thenAnswer((_) async {});
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const SendMoneyToUser(
        senderUid: testSenderUid,
        recipientEmail: testRecipientEmail,
        amount: testAmount,
        description: testDescription,
      )),
      expect: () => [
        TransactionLoading(),
        const TransactionError('Failed to create recipient balance'),
      ],
    );

    // Test 8: LoadTransactionHistory - success
    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionHistoryLoaded when LoadTransactionHistory succeeds',
      build: () {
        final transactions = [mockTransaction];
        when(() => mockBalanceRepository.getUserTransactions(testSenderUid))
            .thenAnswer((_) async => transactions);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const LoadTransactionHistory(testSenderUid)),
      expect: () => [
        TransactionLoading(),
        TransactionHistoryLoaded([mockTransaction]),
      ],
    );

    // Test 9: LoadTransactionHistory - error
    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionError when LoadTransactionHistory fails',
      build: () {
        when(() => mockBalanceRepository.getUserTransactions(testSenderUid))
            .thenThrow(Exception('Database error'));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const LoadTransactionHistory(testSenderUid)),
      expect: () => [
        TransactionLoading(),
        const TransactionError(
            'Failed to load transaction history: Exception: Database error'),
      ],
    );

    // Test 10: SendMoneyToUser - general exception handling
    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionError when SendMoneyToUser throws unexpected exception',
      build: () {
        when(() => mockBalanceRepository.getUserBalance(testSenderUid))
            .thenThrow(Exception('Unexpected error'));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const SendMoneyToUser(
        senderUid: testSenderUid,
        recipientEmail: testRecipientEmail,
        amount: testAmount,
        description: testDescription,
      )),
      expect: () => [
        TransactionLoading(),
        const TransactionError(
            'Transaction failed: Exception: Unexpected error'),
      ],
    );

    // Test 11: LoadTransactionHistory - empty transaction list
    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionHistoryLoaded with empty list when no transactions found',
      build: () {
        when(() => mockBalanceRepository.getUserTransactions(testSenderUid))
            .thenAnswer((_) async => <TransactionModel>[]);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const LoadTransactionHistory(testSenderUid)),
      expect: () => [
        TransactionLoading(),
        const TransactionHistoryLoaded(<TransactionModel>[]),
      ],
    );
  });
}
